from flask import Flask, request, jsonify , Blueprint
import mysql.connector
from werkzeug.utils import secure_filename
from datetime import datetime

file_uploadapi = Blueprint('file_uploadapi', __name__)

# 数据库配置
config = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': 'nothispass',
    'database': '113-Ntub_113205DB',
    'raise_on_warnings': True,
    'charset': 'binary'  
}


@file_uploadapi.route('/upload', methods=['POST'])
def upload_file():
    file = request.files.get('file')
    if file:
        filename = secure_filename(file.filename)
        content = file.read()
        try:
            cnx = mysql.connector.connect(**config)
            cursor = cnx.cursor()
            add_document = ("INSERT INTO imageuploads "
                "(Image, UploadDate, UploadedBy) "
                "VALUES (%s, %s, %s)")
            data_document = (content, datetime.now().date(), '213030')

            cursor.execute(add_document, data_document)  # 确保这里不会改变二进制数据

            cnx.commit()
            cursor.close()
            cnx.close()
            return jsonify({'message': 'Image uploaded successfully'}), 200
        except mysql.connector.Error as err:
            print("SQL Error:", err)
            return jsonify({'error': str(err)}), 500
    return jsonify({'error': 'No file provided'}), 400

