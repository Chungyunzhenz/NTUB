from flask import Flask, request, jsonify
import pymysql
from flask_cors import CORS
import time

app = Flask(__name__)
CORS(app)  # 允許所有請求

# 設定資料庫連線
db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'Nttub$Eas0nZct',
    'database': '113-Ntub_113205DB',
}

db = None

# 自動重連 MySQL 資料庫
def handle_disconnect():
    global db
    while True:
        try:
            db = pymysql.connect(**db_config)
            print("MySQL Connected...")
            break
        except pymysql.MySQLError as err:
            print("Error connecting to MySQL:", err)
            time.sleep(2)  # 2秒後重新連線

handle_disconnect()

# 檢查資料庫連線的中間件
@app.before_request
def check_db_connection():
    global db
    try:
        db.ping(reconnect=True)
    except pymysql.MySQLError as err:
        print("Database is disconnected:", err)
        return jsonify({
            'success': False,
            'message': 'Database connection lost. Please try again later.'
        }), 500

# API 1: 獲取歷史紀錄
@app.route('/history', methods=['GET'])
def get_history():
    try:
        with db.cursor(pymysql.cursors.DictCursor) as cursor:
            query = 'SELECT * FROM history_records'
            cursor.execute(query)
            results = cursor.fetchall()
        return jsonify(results)
    except pymysql.MySQLError as err:
        print('Error executing query:', err)
        return 'Server error', 500

# API 2: 根據條件篩選歷史紀錄
@app.route('/filter_history', methods=['POST'])
def filter_history():
    keyword = request.json.get('keyword')
    search_type = request.json.get('type')
    
    valid_columns = ['academic_year', 'period', 'date', 'course_name', 'leave_reason', 'description', 'title']
    if search_type not in valid_columns:
        return 'Invalid search type', 400

    try:
        with db.cursor(pymysql.cursors.DictCursor) as cursor:
            query = f"SELECT * FROM history_records WHERE {search_type} LIKE %s"
            cursor.execute(query, ('%' + keyword + '%',))
            results = cursor.fetchall()
        return jsonify(results)
    except pymysql.MySQLError as err:
        print('Error executing query:', err)
        return 'Error executing query', 500

# API 3: 獲取請假單或選課單根據不同狀態和類型
@app.route('/getLeaveRequests', methods=['GET'])
def get_leave_requests():
    status = request.args.get('status')
    title = request.args.get('title')

    try:
        with db.cursor(pymysql.cursors.DictCursor) as cursor:
            sql = "SELECT * FROM ReviewProgress WHERE TRIM(review_status) = %s AND TRIM(title) = %s"
            cursor.execute(sql, (status, title))
            results = cursor.fetchall()
        print(f"{title} requests fetched successfully. Count:", len(results))
        return jsonify(results)
    except pymysql.MySQLError as err:
        print('Error fetching requests:', err)
        return jsonify({
            'success': False,
            'message': 'Error fetching requests',
            'error': err.args[0]
        }), 500

# API 4: 更新審核狀態，包含退回原因和操作角色
@app.route('/updateReviewStatus', methods=['POST'])
def update_review_status():
    data = request.json
    id = data.get('id')
    status = data.get('status')
    return_reason = data.get('return_reason')
    returned_by = data.get('returned_by')

    if not id or not status:
        return jsonify({
            'success': False,
            'message': 'ID and status are required'
        }), 400

    try:
        with db.cursor() as cursor:
            sql = """
                UPDATE ReviewProgress 
                SET review_status = %s, review_date = NOW(), return_reason = %s, returned_by = %s 
                WHERE id = %s
            """
            cursor.execute(sql, (status, return_reason, returned_by, id))
            db.commit()
            if cursor.rowcount == 0:
                return jsonify({
                    'success': False,
                    'message': f'No record found with ID {id}'
                }), 404
        print(f"Review status for ID {id} updated to {status}")
        return jsonify({
            'success': True,
            'message': f'Review status updated successfully for ID {id}',
            'affectedRows': cursor.rowcount
        })
    except pymysql.MySQLError as err:
        print('Error updating review status:', err)
        return jsonify({
            'success': False,
            'message': 'Error updating review status',
            'error': err.args[0]
        }), 500

# 啟動伺服器
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4000)
