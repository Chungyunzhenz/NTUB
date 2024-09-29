import os
from flask import Flask, request, jsonify, Blueprint
import mysql.connector
from werkzeug.utils import secure_filename
from datetime import datetime
from paddleocr import PaddleOCR
import json

img_uploadapi = Blueprint('img_uploadapi', __name__)

# 数据库配置
config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'thispass',
    'database': '113-Ntub_113205DB',
    'raise_on_warnings': True,
}

# 初始化OCR模型
ocr = PaddleOCR(use_angle_cls=True, lang='ch')

@img_uploadapi.route('/upload', methods=['POST'])
def upload_file():
    file = request.files.get('file')
    if file:
        filename = secure_filename(file.filename)

        # 强制将文件内容读取为二进制格式
        try:
            content = file.read()  # 读取文件内容

            # 确保内容是二进制
            if not isinstance(content, bytes):
                return jsonify({'error': 'File content is not in binary format'}), 400

            uploaded_by = '213030'  # 假设此值有效
            cnx = mysql.connector.connect(**config)
            cursor = cnx.cursor()

            # 检查 UploadedBy 是否存在
            cursor.execute("SELECT * FROM users WHERE NationalID = %s", (uploaded_by,))
            if cursor.fetchone() is None:
                return jsonify({'error': 'UploadedBy not found in users'}), 400

            # 插入图像数据
            add_document = (
                "INSERT INTO imageuploads (Image, UploadDate, UploadedBy) VALUES (%s, %s, %s)"
            )
            data_document = (content, datetime.now(), uploaded_by)

            cursor.execute(add_document, data_document)
            cnx.commit()

            imageupload_id = cursor.lastrowid  # 获取插入的ID

            # 使用当前工作目录创建临时图像路径
            temp_image_path = os.path.join(os.getcwd(), 'temp', filename)
            os.makedirs(os.path.dirname(temp_image_path), exist_ok=True)  # 确保临时目录存在

            # 保存接收到的图像到临时目录
            with open(temp_image_path, 'wb') as temp_file:
                temp_file.write(content)

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

            cursor.execute(add_json_data, data_json)
            cnx.commit()

            # 清理工作
            cursor.close()
            cnx.close()
            os.remove(temp_image_path)  # 删除临时文件

            return jsonify({'message': 'Image and OCR result uploaded successfully'}), 200

        except mysql.connector.Error as err:
            print("SQL Error:", err)
            return jsonify({'error': str(err)}), 500
        except Exception as e:
            return jsonify({'error': str(e)}), 500

    return jsonify({'error': 'No file provided'}), 400
