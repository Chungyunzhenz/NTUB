from flask import Flask, jsonify, request
from flask_cors import CORS
import pymysql
from flask import Blueprint, jsonify
import mysql.connector

download = Blueprint('download', __name__)
# 資料庫連接配置
db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'Nttub$Eas0nZct',
    'database': '113-Ntub_113205DB'
}

@download.route('/api/class_data', methods=['GET'])
def get_class_data():
    connection = None
    try:
        # 連接資料庫並查詢數據
        connection = pymysql.connect(**db_config)
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        query = "SELECT DISTINCT class_name FROM history_records"
        cursor.execute(query)
        rows = cursor.fetchall()
        
        response = [{'class_name': row['class_name']} for row in rows]
        return jsonify(response)
    except pymysql.MySQLError as e:
        return jsonify({'error': f'資料庫連線或查詢時發生錯誤: {str(e)}'}), 500
    finally:
        if connection:
            connection.close()

@download.route('/api/class_students/<class_name>', methods=['GET'])
def get_class_students(class_name):
    connection = None
    user_role = request.args.get('user_role')  # 獲取用戶角色
    try:
        # 連接資料庫並查詢特定班級的學生數據
        connection = pymysql.connect(**db_config)
        cursor = connection.cursor(pymysql.cursors.DictCursor)

        # 根據 user_role 確定查詢條件
        if user_role == 'teacher':
            query = "SELECT * FROM history_records WHERE class_name = %s AND title = '請假單'"
        elif user_role == 'assistant':
            query = "SELECT * FROM history_records WHERE class_name = %s AND title = '選課單'"
        else:
            return jsonify({'error': '無效的用戶角色'}), 400

        cursor.execute(query, (class_name,))
        rows = cursor.fetchall()

        response = [{'student_name': row['student_name'],
                     'description': row['description'],
                     'title': row['title']} for row in rows]
        return jsonify(response)
    except pymysql.MySQLError as e:
        return jsonify({'error': f'資料庫查詢過程中發生錯誤: {str(e)}'}), 500
    finally:
        if connection:
            connection.close()


@download.route('/api/download_history', methods=['GET'])
def download_history():
    connection = None
    try:
        # 假設我們要返回某些歷史數據記錄而不是檔案
        connection = pymysql.connect(**db_config)
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        # 查詢歷史資料
        query = "SELECT * FROM history_records"
        cursor.execute(query)
        records = cursor.fetchall()

        # 返回 JSON 格式的記錄
        return jsonify(records)
    except pymysql.MySQLError as e:
        return jsonify({'error': f'資料庫查詢過程中發生錯誤: {str(e)}'}), 500
    finally:
        if connection:
            connection.close()