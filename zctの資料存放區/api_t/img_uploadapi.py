import os
import tempfile
import mysql.connector
from flask import Flask, request, jsonify, Blueprint
from werkzeug.utils import secure_filename
from datetime import datetime
from paddleocr import PaddleOCR
import json
import numpy as np
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense, Conv2D, MaxPooling2D, Flatten, Lambda
from tensorflow.keras.optimizers import Adam
from tensorflow.keras import backend as K
import cv2

img_uploadapi = Blueprint('img_uploadapi', __name__)

# 数据库配置
config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'nothispass',
    'database': '113-Ntub_113205DB',
}

# 初始化OCR模型
ocr = PaddleOCR(use_angle_cls=True, lang='ch')

# 定義卷積神經網絡及相似度模型
def create_base_network(input_shape):
    input = Input(shape=input_shape)
    x = Conv2D(32, (3, 3), activation='relu')(input)
    x = MaxPooling2D(pool_size=(2, 2))(x)
    x = Conv2D(64, (3, 3), activation='relu')(x)
    x = MaxPooling2D(pool_size=(2, 2))(x)
    x = Flatten()(x)
    x = Dense(128, activation='relu')(x)
    return Model(input, x)

def euclidean_distance(vects):
    x, y = vects
    sum_square = K.sum(K.square(x - y), axis=1, keepdims=True)
    return K.sqrt(K.maximum(sum_square, K.epsilon()))

def contrastive_loss(y_true, y_pred):
    margin = 1.0
    square_pred = K.square(y_pred)
    margin_square = K.square(K.maximum(margin - y_pred, 0))
    return K.mean(y_true * square_pred + (1 - y_true) * margin_square)

def load_and_preprocess_image(image_path, img_width=224, img_height=224):
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    img_resized = cv2.resize(img, (img_width, img_height))
    img_resized = img_resized.astype('float32') / 255.0
    img_resized = np.expand_dims(img_resized, axis=-1)
    return img_resized

# 設定相似度模型
img_height, img_width = 224, 224
input_shape = (img_height, img_width, 1)
base_network = create_base_network(input_shape)
input_a = Input(shape=input_shape)
input_b = Input(shape=input_shape)
processed_a = base_network(input_a)
processed_b = base_network(input_b)
distance = Lambda(euclidean_distance, output_shape=(1,))([processed_a, processed_b])
model = Model([input_a, input_b], distance)
model.compile(loss=contrastive_loss, optimizer=Adam(), metrics=['accuracy'])

# 參考圖片路徑
reference_image_path = '263_0.jpg'  # 替換成你的參考圖像

@img_uploadapi.route('/upload', methods=['POST'])
def upload_file():
    file = request.files.get('file')
    if file:
        filename = secure_filename(file.filename)
        
        try:
            # 读取文件内容
            content = file.read()
            if not isinstance(content, bytes):
                return jsonify({'error': 'File content is not in binary format'}), 400

            # 强制转换为二进制
            content = bytes(content)

            uploaded_by = '213030'
            cnx = mysql.connector.connect(**config)
            cursor = cnx.cursor()

            # 检查 UploadedBy 是否存在
            cursor.execute("SELECT * FROM users WHERE NationalID = %s", (uploaded_by,))
            if cursor.fetchone() is None:
                return jsonify({'error': 'UploadedBy not found in users'}), 400

            # 使用 tempfile 创建临时文件
            with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as temp_file:
                temp_image_path = temp_file.name
                temp_file.write(content)

            # 預處理上傳的圖像與參考圖像
            uploaded_image = load_and_preprocess_image(temp_image_path)
            reference_image = load_and_preprocess_image(reference_image_path)

            # 預測兩張圖像的距離
            prediction = model.predict([np.expand_dims(uploaded_image, axis=0), np.expand_dims(reference_image, axis=0)])
            print(f"两张图片的距离: {prediction[0][0]}")

            # 根據距離結果設置type欄位
            if prediction < 0.5:
                image_type = '選課單'
            else:
                image_type = '請假單'

            # 插入图像数据
            add_document = (
                "INSERT INTO imageuploads (Image, UploadDate, UploadedBy, type) VALUES (%s, %s, %s, %s)"
            )
            data_document = (content, datetime.now(), uploaded_by, image_type)

            cursor.execute(add_document, data_document)
            cnx.commit()

            # 获取插入记录的 ID
            cursor.execute("SELECT id FROM imageuploads ORDER BY UploadDate DESC LIMIT 1")
            result = cursor.fetchone()
            if result is None:
                return jsonify({'error': 'Failed to retrieve the last inserted ID'}), 500

            imageupload_id = result[0]
            print(f"Image upload ID: {imageupload_id}")

            # 进行OCR识别
            result = ocr.ocr(temp_image_path, cls=True)

            # 处理OCR结果
            ocr_data = []
            for line in result[0]:
                box = line[0]
                text = line[1][0]
                ocr_data.append({
                    'text': text,
                    'box': {
                        'top_left': box[0],
                        'bottom_right': box[2]
                    }
                })

            # 保存OCR结果为JSON
            json_data = json.dumps(ocr_data, ensure_ascii=False)
            add_json_data = (
                "INSERT INTO json_data (data, UploadDate, UploadedBy, id) VALUES (%s, %s, %s, %s)"
            )
            data_json = (json_data, datetime.now(), uploaded_by, imageupload_id)

            print(f"Inserting JSON data with ID: {imageupload_id}")
            cursor.execute(add_json_data, data_json)
            cnx.commit()

            # 清理工作
            cursor.close()
            cnx.close()
            os.remove(temp_image_path)

            return jsonify({'message': 'Image and OCR result uploaded successfully'}), 200

        except mysql.connector.Error as err:
            print("SQL Error:", err)
            return jsonify({'error': str(err)}), 500
        except Exception as e:
            print("Exception:", e)
            return jsonify({'error': str(e)}), 500

    return jsonify({'error': 'No file provided'}), 400
