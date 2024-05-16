from flask import Flask, request, jsonify
import mysql.connector
from datetime import datetime

app = Flask(__name__)

app.config['MYSQL_HOST'] = '34.80.115.127'
app.config['MYSQL_USER'] = 'zc1'
app.config['MYSQL_PASSWORD'] = 'zctool0204'
app.config['MYSQL_DB'] = 'zc_sql1'

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
    image = request.files['image'].read()
    upload_date = datetime.now()
    uploaded_by = '00000000001'
    
    connection = get_db_connection()
    cursor = connection.cursor()
    
    cursor.execute("INSERT INTO ImageUploads (Image, UploadDate, UploadedBy) VALUES (%s, %s, %s)", 
                   (image, upload_date, uploaded_by))
    connection.commit()
    
    cursor.close()
    connection.close()
    
    return jsonify({'message': 'Image uploaded successfully!'})

if __name__ == '__main__':
    app.run(debug=True)
