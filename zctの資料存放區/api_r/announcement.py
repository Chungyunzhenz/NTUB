from flask import Blueprint, jsonify
import mysql.connector

announcement_bp = Blueprint('announcement_bp', __name__)

# 设置MySQL连接
db_config = {

}

@announcement_bp.route('/announcements_o', methods=['GET'])
def get_announcements():
    try:
        cnx = mysql.connector.connect(**db_config)
        cursor = cnx.cursor(dictionary=True)
        query = "SELECT Purpose, content, time FROM announcement"
        cursor.execute(query)
        announcements = cursor.fetchall()
        cnx.close()

        return jsonify({'announcements': announcements}), 200
    except mysql.connector.Error as err:
        return jsonify({'error': str(err)}), 500
