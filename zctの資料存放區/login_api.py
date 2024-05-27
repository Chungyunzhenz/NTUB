from flask import Flask, request, jsonify
import mysql.connector
from passlib.hash import bcrypt

app = Flask(__name__)

# 设置MySQL连接
db_config = {
    'user': '0',
    'password': '0',
    'host': '0.0.0.0',
    'database': '0',
}

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    student_id = data.get('StudentID')
    password = data.get('Password')

    if not student_id or not password:
        return jsonify({'error': 'Missing StudentID or Password'}), 400

    try:
        cnx = mysql.connector.connect(**db_config)
        cursor = cnx.cursor(dictionary=True)
        query = "SELECT * FROM Users WHERE StudentID = %s"
        cursor.execute(query, (student_id,))
        user = cursor.fetchone()
        cnx.close()

        if user and bcrypt.verify(password, user['Password']):
            return jsonify({'message': 'Login successful', 'user': user}), 200
        else:
            return jsonify({'error': 'Invalid StudentID or Password'}), 401

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

