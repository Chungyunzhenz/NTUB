from flask import Flask, request, jsonify
import mysql.connector

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

@app.route('/upload_data', methods=['POST'])
def upload_data():
    data = request.get_json()
    Image = data.get('Image')
    UploadDate = data.get('UploadDate')
    UploadedBy = data.get('UploadedBy')
    
    connection = get_db_connection()
    cursor = connection.cursor()
    
    cursor.execute("INSERT INTO users (Image, UploadDate, UploadedBy) VALUES (%s, %s, %s)", (Image, UploadDate, UploadedBy))
    connection.commit()
    
    cursor.close()
    connection.close()
    
    return jsonify({'message': 'Data uploaded successfully!'})

if __name__ == '__main__':
    app.run(debug=True)
