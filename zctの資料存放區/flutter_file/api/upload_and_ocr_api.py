from flask import Flask, request, jsonify
import mysql.connector
from datetime import datetime
import os
import subprocess
import pandas as pd
import json

app = Flask(__name__)

app.config['MYSQL_HOST'] = '0.0.0.127'
app.config['MYSQL_USER'] = '0'
app.config['MYSQL_PASSWORD'] = '0'
app.config['MYSQL_DB'] = '0'

IMG_INPUT_DIR = 'imginput'
OUTPUT_DIR = 'G:/PaddleOCR-2.7.5/output'

if not os.path.exists(IMG_INPUT_DIR):
    os.makedirs(IMG_INPUT_DIR)

def get_db_connection():
    connection = mysql.connector.connect(
        host=app.config['MYSQL_HOST'],
        user=app.config['MYSQL_USER'],
        password=app.config['MYSQL_PASSWORD'],
        database=app.config['MYSQL_DB']
    )
    return connection

@app.route('/upload_image', methods=['POST'])
def upload_image():
    image_file = request.files['image']
    if not image_file:
        return jsonify({'error': 'No image provided'}), 400

    upload_date = datetime.now()
    uploaded_by = 'WET8644G3S46'

    # 保存图片到本地
    image_path = os.path.join(IMG_INPUT_DIR, image_file.filename)
    image_file.save(image_path)

    # 重新读取图片数据
    with open(image_path, 'rb') as file:
        image_data = file.read()

    # 将图片数据插入数据库
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("INSERT INTO ImageUploads (Image, UploadDate, UploadedBy) VALUES (%s, %s, %s)",
                   (image_data, upload_date, uploaded_by))
    connection.commit()
    cursor.execute("SELECT id FROM ImageUploads WHERE UploadedBy = %s ORDER BY UploadDate DESC LIMIT 1",
                   ( uploaded_by,))
    image_id = cursor.fetchone()[0]



    cursor.close()
    connection.close()

    # 调用其他 Python 文件
    script_path = 'table/predict_table.py'
    det_model_dir = 'inference/ch_PP-OCRv3_det_infer'
    rec_model_dir = 'inference/ch_PP-OCRv3_rec_infer'
    table_model_dir = 'inference/ch_ppstructure_mobile_v2.0_SLANet_infer'
    rec_char_dict_path = '../ppocr/utils/ppocr_keys_v1.txt'
    table_char_dict_path = '../ppocr/utils/dict/table_structure_dict_ch.txt'

    command = [
        'python', script_path,
        '--det_model_dir', det_model_dir,
        '--rec_model_dir', rec_model_dir,
        '--table_model_dir', table_model_dir,
        '--rec_char_dict_path', rec_char_dict_path,
        '--table_char_dict_path', table_char_dict_path,
        '--image_dir', image_path,
        '--output', OUTPUT_DIR
    ]

    subprocess.run(command, check=True)

    # 查找并转换生成的 .xlsx 文件
    image_base_name = os.path.basename(image_path)
    image_name_without_ext = os.path.splitext(image_base_name)[0]
    xlsx_path = os.path.join(OUTPUT_DIR, f"{image_name_without_ext}.xlsx")
    json_path = os.path.join(OUTPUT_DIR, f"{image_name_without_ext}.json")

    print(f"Looking for .xlsx file at: {xlsx_path}")  # Debug information

    if os.path.exists(xlsx_path):
        df = pd.read_excel(xlsx_path)
        df.to_json(json_path, orient='records', force_ascii=False)
        print(f"Converted {xlsx_path} to {json_path}")

        # 读取 JSON 文件内容并插入到数据库
        with open(json_path, 'r', encoding='utf-8') as json_file:
            json_data = json_file.read()

        connection = get_db_connection()
        cursor = connection.cursor()
        print("///"+image_id+"///")
        cursor.execute("INSERT INTO json_data (id,data, UploadDate, UploadedBy) VALUES (%s, %s, %s, %s)", 
                       (image_id, json_data, upload_date, uploaded_by))
        connection.commit()

        cursor.close()
        connection.close()

    else:
        print(f"{xlsx_path} does not exist.")  # Debug information

    return jsonify({'message': 'Image uploaded and processed successfully!', 'image_path': image_path})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
