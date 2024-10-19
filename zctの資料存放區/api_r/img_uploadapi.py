import os
import tempfile
import mysql.connector
from flask import Flask, request, jsonify, Blueprint, Response
from werkzeug.utils import secure_filename
from datetime import datetime
from paddleocr import PaddleOCR
import json
import numpy as np
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense, Flatten, Lambda
from tensorflow.keras.optimizers import Adam
from tensorflow.keras import backend as K
import cv2
import random
import io
import tensorflow as tf
from tensorflow.keras.applications import ResNet50
from PIL import Image, ImageDraw, ImageFont
import opencc  # 用於簡體轉繁體

# 初始化 Flask API
img_uploadapi = Blueprint('img_uploadapi', __name__)

# 数据库配置
config = {

}

# 設定隨機種子
seed = 42
tf.random.set_seed(seed)
np.random.seed(seed)
random.seed(seed)

# 初始化 PaddleOCR
ocr = PaddleOCR(use_angle_cls=True, lang='ch')

# 定義卷積神經網絡及相似度模型
def create_base_network(input_shape):
    base_model = ResNet50(weights='imagenet', include_top=False, input_shape=input_shape)
    x = base_model.output
    x = Flatten()(x)
    x = Dense(128, activation='relu')(x)
    return Model(base_model.input, x)

def cosine_distance(vects):
    x, y = vects
    x = K.l2_normalize(x, axis=-1)
    y = K.l2_normalize(y, axis=-1)
    return 1 - K.sum(x * y, axis=-1, keepdims=True)

def load_and_preprocess_image(image_path, img_width=224, img_height=224):
    # 嘗試讀取圖像
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    
    # 檢查圖像是否成功讀取
    if img is None:
        return None, "Failed to load image or invalid image format"
    
    try:
        # 調整圖像大小
        img_resized = cv2.resize(img, (img_width, img_height))

        # 重複通道數以符合 ResNet 的輸入格式（RGB 三通道）
        img_resized = np.stack((img_resized,) * 3, axis=-1)

        # 歸一化 [0, 1]
        img_resized = img_resized.astype('float32') / 255.0
        return img_resized, None
    except Exception as e:
        return None, str(e)

# 設定相似度模型
img_height, img_width = 224, 224
input_shape = (img_height, img_width, 3)
base_network = create_base_network(input_shape)

# 創建孿生網絡的輸入層
input_a = Input(shape=input_shape)
input_b = Input(shape=input_shape)

# 基礎網絡處理兩個輸入
processed_a = base_network(input_a)
processed_b = base_network(input_b)

# 計算 Cosine 距離
distance = Lambda(cosine_distance, output_shape=(1,))([processed_a, processed_b])

# 定義完整模型
model = Model([input_a, input_b], distance)
model.compile(loss='binary_crossentropy', optimizer=Adam(), metrics=['accuracy'])

# 設置字體路徑，假設使用 mingliu.ttc
font_path = "C:/Windows/Fonts/mingliu.ttc"
if not os.path.exists(font_path):
    raise OSError(f"字體檔案不存在，請檢查路徑: {font_path}")
font = ImageFont.truetype(font_path, 20)

# 初始化簡繁轉換器
converter = opencc.OpenCC('s2t')  # 簡體轉繁體

@img_uploadapi.route('/upload', methods=['POST'])
def upload_file():
    file = request.files.get('file')
    if file:
        filename = secure_filename(file.filename)
        
        try:
            content = file.read()
            if not isinstance(content, bytes):
                return jsonify({'error': 'File content is not in binary format'}), 400
            content = bytes(content)
            uploaded_by = '213030'
            cnx = mysql.connector.connect(**config)
            cursor = cnx.cursor()

            # 檢查 UploadedBy 是否存在
            cursor.execute("SELECT * FROM users WHERE NationalID = %s", (uploaded_by,))
            if cursor.fetchone() is None:
                return jsonify({'error': 'UploadedBy not found in users'}), 400

            # 使用 tempfile 创建临时文件
            with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as temp_file:
                temp_image_path = temp_file.name
                temp_file.write(content)

            # 預處理上傳的圖像與參考圖像
            ocr_image, error = load_and_preprocess_image(temp_image_path)
            if error:
                return jsonify({'error': error}), 400

            reference_image_path = '263_0.jpg'  # 替換為你的參考圖像
            reference_image, error = load_and_preprocess_image(reference_image_path)
            if error:
                return jsonify({'error': error}), 400

            # 預測兩張圖像的距離
            prediction = model.predict([np.expand_dims(ocr_image, axis=0), np.expand_dims(reference_image, axis=0)])
            threshold = 0.010
            image_type = '選課單' if prediction[0][0] < threshold else '請假單'

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

            # 進行 OCR 識別
            ocr_result = ocr.ocr(temp_image_path, cls=True)
            ocr_data = []
            for line in ocr_result[0]:
                box = line[0]
                text = line[1][0]

                # 將簡體字轉為繁體字
                text_traditional = converter.convert(text)
                
                ocr_data.append({
                    'text': text_traditional,  # 使用轉換後的繁體中文
                    'box': {
                        'top_left': box[0],
                        'bottom_right': box[2]
                    }
                })

            # 保存 OCR 結果為 JSON 格式
            json_data = json.dumps(ocr_data, ensure_ascii=False)
            add_json_data = (
                "INSERT INTO json_data (data, UploadDate, UploadedBy, id) VALUES (%s, %s, %s, %s)"
            )
            data_json = (json_data, datetime.now(), uploaded_by, imageupload_id)
            cursor.execute(add_json_data, data_json)
            cnx.commit()

            # 根據 OCR 結果進行繪製
            image = Image.new("RGB", (1200, 1500), "white")
            draw = ImageDraw.Draw(image)
            for entry in ocr_data:
                top_left = tuple(entry['box']['top_left'])
                bottom_right = tuple(entry['box']['bottom_right'])

                # 確保 y1 >= y0 和 x1 >= x0，避免繪製錯誤
                if top_left[1] > bottom_right[1]:
                    top_left, bottom_right = (top_left[0], bottom_right[1]), (bottom_right[0], top_left[1])

                if top_left[0] > bottom_right[0]:
                    top_left, bottom_right = (bottom_right[0], top_left[1]), (top_left[0], bottom_right[1])

                text = entry['text']
                
                draw.text((top_left[0], top_left[1] - 30), text, font=font, fill="black")

            # 將圖片轉換為二進制數據（long blob）
            img_byte_arr = io.BytesIO()
            image.save(img_byte_arr, format='PNG')
            img_blob = img_byte_arr.getvalue()

            # 清理工作
            cursor.close()
            cnx.close()
            os.remove(temp_image_path)

            # 將結果圖片以二進制回傳
            return Response(img_blob, mimetype='image/png')

        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    return jsonify({'error': 'No file provided'}), 400
