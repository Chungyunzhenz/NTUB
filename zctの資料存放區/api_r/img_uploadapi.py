import os
import tempfile
import mysql.connector
from flask import Flask, request, jsonify, Blueprint
from werkzeug.utils import secure_filename
from datetime import datetime
from paddleocr import PaddleOCR
import json

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

@img_uploadapi.route('/upload', methods=['POST'])
def upload_file():
    file = request.files.get('file')
    if file:
        filename = secure_filename(file.filename)

        try:
            # 读取文件内容
            content = file.read()  # 读取文件内容

            # 确保内容是二进制
            if not isinstance(content, bytes):
                return jsonify({'error': 'File content is not in binary format'}), 400

            # 强制转换为二进制
            content = bytes(content)  # 确保以字节格式存储

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

            # 通过查询获取上一个插入的 ID
            cursor.execute("SELECT id FROM imageuploads ORDER BY UploadDate DESC LIMIT 1")
            result = cursor.fetchone()  # 获取最近插入记录的 ID
            if result is None:
                return jsonify({'error': 'Failed to retrieve the last inserted ID'}), 500

            imageupload_id = result[0]  # 获取 ID
            print(f"Image upload ID: {imageupload_id}")  # 调试输出，确认 ID

            # 使用 tempfile 创建临时文件
            with tempfile.NamedTemporaryFile(delete=False, suffix='.jpg') as temp_file:
                temp_image_path = temp_file.name  # 获取临时文件的路径
                temp_file.write(content)  # 写入文件内容

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
            data_json = (json_data, datetime.now(), uploaded_by, imageupload_id)  # 使用上面获取的ID

            print(f"Inserting JSON data with ID: {imageupload_id}")  # 调试输出，确认要插入的 ID
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
            print("Exception:", e)  # 添加异常调试输出
            return jsonify({'error': str(e)}), 500

    return jsonify({'error': 'No file provided'}), 400
