from flask import Flask, request, jsonify, Blueprint
import mysql.connector
from werkzeug.utils import secure_filename
from datetime import datetime
from paddleocr import PaddleOCR
import cv2
import json
import numpy as np

file_uploadapi = Blueprint('file_uploadapi', __name__)

# 数据库配置
config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'thispass',
    'database': '113-Ntub_113205DB',
    'raise_on_warnings': True,
    'charset': 'binary'
}

# 初始化OCR模型
ocr = PaddleOCR(use_angle_cls=True, lang='ch')  # 设置语言为中文

@file_uploadapi.route('/upload', methods=['POST'])
def upload_file():
    file = request.files.get('file')
    if file:
        filename = secure_filename(file.filename)
        content = file.read()

        # 保存文件到本地
        image_path = f"./{filename}"
        with open(image_path, 'wb') as f:
            f.write(content)

        try:
            # 连接数据库
            cnx = mysql.connector.connect(**config)
            cursor = cnx.cursor()

            # 插入图像文件到 imageuploads 表
            add_image = ("INSERT INTO imageuploads (Image, UploadDate, UploadedBy) VALUES (%s, %s, %s)")
            data_image = (content, datetime.now().date(), '213030')
            cursor.execute(add_image, data_image)

            # OCR 处理
            image = cv2.imread(image_path)
            h, w, _ = image.shape
            white_background = np.ones((h, w, 3), dtype=np.uint8) * 255
            result = ocr.ocr(image_path, cls=True)

            boxes = [elements[0] for elements in result[0]]
            txts = [elements[1][0] for elements in result[0]]
            ocr_data = []
            for i, box in enumerate(boxes):
                x1, y1 = map(int, box[0])
                x2, y2 = map(int, box[2])
                cropped = image[y1:y2, x1:x2]
                white_background[y1:y2, x1:x2] = cropped
                cv2.rectangle(white_background, (x1, y1), (x2, y2), (0, 0, 255), 2)

                # 将OCR结果保存为字典
                ocr_data.append({
                    'text': txts[i],
                    'box': {
                        'top_left': [x1, y1],
                        'bottom_right': [x2, y2]
                    }
                })

            # 将OCR结果保存到JSON文件并作为字符串
            json_data = json.dumps(ocr_data, ensure_ascii=False)

            # 插入OCR结果到 json_data 表
            add_json_data = ("INSERT INTO json_data (data, UploadDate, UploadedBy) VALUES (%s, %s, %s)")
            data_json = (json_data, datetime.now().date(), '213030')
            cursor.execute(add_json_data, data_json)

            # 提交事务并关闭连接
            cnx.commit()
            cursor.close()
            cnx.close()

            return jsonify({'message': 'Image and OCR result uploaded successfully'}), 200

        except mysql.connector.Error as err:
            print("SQL Error:", err)
            return jsonify({'error': str(err)}), 500

    return jsonify({'error': 'No file provided'}), 400
