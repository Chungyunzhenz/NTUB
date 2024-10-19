from flask import Blueprint, request, jsonify
import mysql.connector
from flask_cors import CORS
import threading
import time

stu = Blueprint('stu', __name__)

# 資料庫連接配置
db_config = {

}

def get_db_connection():
    try:
        conn = mysql.connector.connect(**db_config)
        print("資料庫連接成功")
        return conn
    except mysql.connector.Error as err:
        print(f"資料庫連接失敗: {err}")
        raise

@stu.route('/api/history', methods=['GET'])
def get_history():
    user_id = request.args.get('user_id', type=int)
    user_role = request.args.get('user_role')
    academic_year = request.args.get('academic_year')
    course_name = request.args.get('course_name')
    title = request.args.get('title')
    
    # 建立資料庫連接
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # 查詢歷史紀錄
        query = "SELECT id, submission_date, academic_year, period, course_name, leave_reason, title, description, review_status, return_reason, returned_by, reviewer, review_date, user_role, teacher_comments, ta_comments, course_info, userid FROM ReviewProgress WHERE 1=1"
        params = []
        if user_id is not None:
            query += " AND userid = %s"
            params.append(user_id)
        if user_role is not None:
            query += " AND user_role = %s"
            params.append(user_role)
        if academic_year is not None:
            query += " AND academic_year = %s"
            params.append(academic_year)
        if course_name is not None:
            query += " AND course_name = %s"
            params.append(course_name)
        if title is not None:
            query += " AND title = %s"
            params.append(title)
        
        cursor.execute(query, params)
        records = cursor.fetchall()
        
        # 關閉清單和連接
        cursor.close()
        conn.close()
        
        return jsonify(records)
    except mysql.connector.Error as err:
        return jsonify({'error': f'資料庫查詢失敗: {err}'}), 500
