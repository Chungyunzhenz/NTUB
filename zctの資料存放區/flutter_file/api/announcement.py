from flask import Flask, jsonify
import mysql.connector

app = Flask(__name__)

# 设置MySQL连接
db_config = {
    'user': '0',
    'password': '0',
    'host': '0.0.0.0',
    'database': '0',
}

@app.route('/announcements', methods=['GET'])
def get_announcements():
    try:
        cnx = mysql.connector.connect(**db_config)
        cursor = cnx.cursor(dictionary=True)
        query = "SELECT Purpose, content FROM announcement"
        cursor.execute(query)
        announcements = cursor.fetchall()
        cnx.close()

        return jsonify({'announcements': announcements}), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
