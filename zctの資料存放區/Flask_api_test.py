from flask import Flask, request, jsonify
import mysql.connector
from datetime import datetime
import os
import subprocess

app = Flask(__name__)

app.config['MYSQL_HOST'] = '34.80.115.127'
app.config['MYSQL_USER'] = 'zc1'
app.config['MYSQL_PASSWORD'] = 'zctool0204'
app.config['MYSQL_DB'] = 'zc_sql1'

IMG_INPUT_DIR = 'imginput'

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
    uploaded_by = '00000000001'

    image_path = os.path.join(IMG_INPUT_DIR, image_file.filename)
    image_file.save(image_path)

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("INSERT INTO ImageUploads (Image, UploadDate, UploadedBy) VALUES (%s, %s, %s)", 
                   (image_file.read(), upload_date, uploaded_by))
    connection.commit()

    cursor.close()
    connection.close()

    # 调用其他 Python 文件
    output_dir = '../output/table'
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
        '--output', output_dir
    ]

    subprocess.run(command, check=True)

    return jsonify({'message': 'Image uploaded and processed successfully!', 'image_path': image_path})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
