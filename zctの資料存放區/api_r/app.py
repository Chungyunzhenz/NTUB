from flask import Blueprint, request, jsonify
import mysql.connector
from passlib.hash import bcrypt

login_bp = Blueprint('login_bp', __name__)

# 设置MySQL连接
db_config = {

}

@login_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    student_id = data.get('StudentID')
    password = data.get('Password')

    if not student_id or not password:
        return jsonify({'error': 'Missing StudentID or Password'}), 400

    try:
        cnx = mysql.connector.connect(**db_config)
        cursor = cnx.cursor(dictionary=True)
        query = "SELECT * FROM users WHERE StudentID = %s"
        cursor.execute(query, (student_id,))
        user = cursor.fetchone()

        if user and user['Password'] and bcrypt.verify(password, user['Password']):
            cnx.close()
            return jsonify({
                'message': 'Login successful',
                'user': {
                    'Name': user['Name'],
                    'StudentID': user['StudentID'],
                    'Role': user['Role'],
                    'Academic': user['Academic'],
                    'Department': user['Department']
                }
            }), 200
        else:
            cnx.close()
            return jsonify({'error': 'Invalid StudentID or Password'}), 401

    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
