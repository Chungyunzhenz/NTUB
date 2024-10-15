import openai
import json
import os
import tempfile
import mysql.connector
from flask import Flask, request, jsonify, Blueprint, Response
from werkzeug.utils import secure_filename
from datetime import datetime
from paddleocr import PaddleOCR
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
from py2neo import Graph
import redis
import time
import sys

# 設定 OpenAI API 金鑰
openai.api_key = 'sk--'  # 請使用你自己的 OpenAI API 金鑰

# 連接到 Neo4j 資料庫
graph = Graph("bolt://localhost:7687", auth=("neo4j", "thispass"))  # 請使用你的 Neo4j 資料庫密碼

# 連接到 Redis 緩存
redis_cache = redis.StrictRedis(host='localhost', port=6380, db=0)

# 正确 OCR 結果的功能
# 根據欄位和 OCR 結果生成 prompt
def generate_prompt(field_name, original_text):
    prompt = f"請幫我修正這段文字可能的錯誤或是錯別字，如果是簡體字請轉為繁體字，並避免過度解釋，僅返回修正後的文字：{original_text}"
    return prompt

# 使用 ChatGPT API 進行文本修正，並檢查緩存
def correct_with_chatgpt(original_text):
    # 先從 Redis 檢查是否有緩存結果
    cached_result = redis_cache.get(original_text)
    if cached_result:
        return cached_result.decode('utf-8')
    
    # 沒有緩存，調用 ChatGPT 進行修正
    prompt = generate_prompt("欄位", original_text)
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "你是一個幫助修正 OCR 錯誤的助手。"},
            {"role": "user", "content": prompt}
        ]
    )
    
    # 提取 ChatGPT 回應中的修正文本，並去掉多餘的描述
    corrected_text = response['choices'][0]['message']['content'].strip()
    
    # 將結果存入緩存，設置過期時間為 24 小時
    redis_cache.setex(original_text, 86400, corrected_text)
    
    return corrected_text

# 檢查 Neo4j 進行資料比對
def query_neo4j(field_name, original_text):
    if field_name == "學號":
        query = f"MATCH (n:User {{name: '{original_text}'}}) RETURN n"
    elif field_name == "科目":
        query = f"MATCH (n:Class {{name: '{original_text}'}}) RETURN n"
    else:
        return None
    
    result = graph.run(query).data()
    if result:
        return result[0]['n']['properties']['name']
    return None

# 設置 Flask API
img_uploadapi = Blueprint('img_uploadapi', __name__)

# 資料庫配置
config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'nothispass',
    'database': '113-Ntub_113205DB',
}

# 設定隨機種子
seed = 42
tf.random.set_seed(seed)
np.random.seed(seed)
random.seed(seed)

# 初始化 PaddleOCR
ocr = PaddleOCR(use_angle_cls=True, lang='ch')

# 建立基礎網絡的函數
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
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)
    img_resized = cv2.resize(img, (img_width, img_height))
    img_resized = np.stack((img_resized,) * 3, axis=-1)
    img_resized = img_resized.astype('float32') / 255.0
    return img_resized

# 設定相似度模型
img_height, img_width = 224, 224
input_shape = (img_height, img_width, 3)
base_network = create_base_network(input_shape)

# 建立子網絡的輸入層
input_a = Input(shape=input_shape)
input_b = Input(shape=input_shape)

# 基礎網絡處理兩個輸入
processed_a = base_network(input_a)
processed_b = base_network(input_b)

distance = Lambda(cosine_distance, output_shape=(1,))([processed_a, processed_b])

# 完整模型
model = Model([input_a, input_b], distance)
model.compile(loss='binary_crossentropy', optimizer=Adam(), metrics=['accuracy'])

font_path = "C:/Windows/Fonts/mingliu.ttc"
if not os.path.exists(font_path):
    raise OSError(f"字體檔案不存在，請檢查路徑: {font_path}")
font = ImageFont.truetype(font_path, 20)

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

            cursor.execute("SELECT * FROM users WHERE NationalID = %s", (uploaded_by,))
            if cursor.fetchone() is None:
                return jsonify({'error': 'UploadedBy not found in users'}), 400

            with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as temp_file:
                temp_image_path = temp_file.name
                temp_file.write(content)

            ocr_result = ocr.ocr(temp_image_path, cls=True)
            ocr_data = []
            for line in ocr_result[0]:
                box = line[0]
                text = line[1][0]

                text_traditional = converter.convert(text)
                
                ocr_data.append({
                    'text': text_traditional,
                    'box': {
                        'top_left': box[0],
                        'bottom_right': box[2]
                    }
                })

            # 使用 ChatGPT 進行 OCR 結果修正
            for item in ocr_data:
                original_text = item['text']
                correct_text = query_neo4j("欄位", original_text)
                
                if correct_text:
                    # 如果 Neo4j 有結果，使用資料庫中的正確值
                    item['corrected_text'] = correct_text
                else:
                    # 如果 Neo4j 沒有結果，使用 ChatGPT 修正
                    corrected_text = correct_with_chatgpt(original_text)
                    item['corrected_text'] = corrected_text

            json_data = json.dumps(ocr_data, ensure_ascii=False)
            add_document = (
                "INSERT INTO imageuploads (Image, UploadDate, UploadedBy, type) VALUES (%s, %s, %s, %s)"
            )
            data_document = (content, datetime.now(), uploaded_by, 'OCR')
            cursor.execute(add_document, data_document)
            cnx.commit()

            cursor.execute("SELECT id FROM imageuploads ORDER BY UploadDate DESC LIMIT 1")
            result = cursor.fetchone()
            if result is None:
                return jsonify({'error': 'Failed to retrieve the last inserted ID'}), 500

            imageupload_id = result[0]

            add_json_data = (
                "INSERT INTO json_data (data, UploadDate, UploadedBy, id) VALUES (%s, %s, %s, %s)"
            )
            data_json = (json_data, datetime.now(), uploaded_by, imageupload_id)
            cursor.execute(add_json_data, data_json)
            cnx.commit()

            image = Image.new("RGB", (1200, 1500), "white")
            draw = ImageDraw.Draw(image)
            for entry in ocr_data:
                top_left = tuple(entry['box']['top_left'])
                bottom_right = tuple(entry['box']['bottom_right'])

                if top_left[1] > bottom_right[1]:
                    top_left, bottom_right = (top_left[0], bottom_right[1]), (bottom_right[0], top_left[1])

                if top_left[0] > bottom_right[0]:
                    top_left, bottom_right = (bottom_right[0], top_left[1]), (top_left[0], bottom_right[1])

                text = entry['corrected_text'] if 'corrected_text' in entry else entry['text']
                
                draw.text((top_left[0], top_left[1] - 30), text, font=font, fill="black")

            img_byte_arr = io.BytesIO()
            image.save(img_byte_arr, format='PNG')
            img_blob = img_byte_arr.getvalue()

            cursor.close()
            cnx.close()
            os.remove(temp_image_path)

            return Response(img_blob, mimetype='image/png')

        except mysql.connector.Error as err:
            return jsonify({'error': str(err)}), 500
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    return jsonify({'error': 'No file provided'}), 400