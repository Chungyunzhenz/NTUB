from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # 允許所有請求

db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'thispass',
    'database': '113-Ntub_113205DB',
}

db = None

# 自動重連 MySQL 資料庫
def handle_disconnect():
    global db
    try:
        db = mysql.connector.connect(**db_config)
        if db.is_connected():
            print("MySQL Connected...")
    except Error as err:
        print(f"Error connecting to MySQL: {err}")
        db = None

    return db

# 啟動連接
handle_disconnect()

# 檢查資料庫連線的中間件
def check_db_connection():
    if db is None or not db.is_connected():
        print('Database is disconnected')
        return False
    return True

@app.route('/history', methods=['GET'])
def get_history():
    if not check_db_connection():
        return jsonify({'success': False, 'message': 'Database connection lost. Please try again later.'}), 500
    
    query = "SELECT * FROM history_records"
    try:
        cursor = db.cursor(dictionary=True)
        cursor.execute(query)
        results = cursor.fetchall()
        return jsonify(results)
    except Error as error:
        print(f"Error executing query: {error}")
        return 'Server error', 500

@app.route('/filter_history', methods=['POST'])
def filter_history():
    if not check_db_connection():
        return jsonify({'success': False, 'message': 'Database connection lost. Please try again later.'}), 500
    
    data = request.json
    keyword = data.get('keyword')
    search_type = data.get('type')

    valid_columns = ['academic_year', 'period', 'date', 'course_name', 'leave_reason', 'description', 'title']
    if search_type not in valid_columns:
        return 'Invalid search type', 400

    query = f"SELECT * FROM history_records WHERE {search_type} LIKE %s"
    keyword_with_wildcards = f"%{keyword}%"
    
    try:
        cursor = db.cursor(dictionary=True)
        cursor.execute(query, (keyword_with_wildcards,))
        results = cursor.fetchall()
        return jsonify(results)
    except Error as error:
        print(f"Error executing query: {error}")
        return 'Error executing query', 500

@app.route('/getLeaveRequests', methods=['GET'])
def get_leave_requests():
    if not check_db_connection():
        return jsonify({'success': False, 'message': 'Database connection lost. Please try again later.'}), 500
    
    status = request.args.get('status')
    title = request.args.get('title')

    query = "SELECT * FROM ReviewProgress WHERE TRIM(review_status) = %s AND TRIM(title) = %s"
    
    try:
        cursor = db.cursor(dictionary=True)
        cursor.execute(query, (status, title))
        results = cursor.fetchall()
        print(f"{title} requests fetched successfully. Count:", len(results))
        return jsonify(results)
    except Error as error:
        print(f"Error fetching requests: {error}")
        return jsonify({'success': False, 'message': 'Error fetching requests', 'error': str(error)}), 500

@app.route('/updateReviewStatus', methods=['POST'])
def update_review_status():
    if not check_db_connection():
        return jsonify({'success': False, 'message': 'Database connection lost. Please try again later.'}), 500
    
    data = request.json
    id = data.get('id')
    status = data.get('status')
    return_reason = data.get('return_reason')
    returned_by = data.get('returned_by')

    if not id or not status:
        return jsonify({'success': False, 'message': 'ID and status are required'}), 400

    query = """
    UPDATE ReviewProgress 
    SET review_status = %s, review_date = NOW(), return_reason = %s, returned_by = %s 
    WHERE id = %s
    """

    try:
        cursor = db.cursor()
        cursor.execute(query, (status, return_reason, returned_by, id))
        db.commit()

        if cursor.rowcount == 0:
            return jsonify({'success': False, 'message': f'No record found with ID {id}'}), 404

        print(f"Review status for ID {id} updated to {status}")
        return jsonify({'success': True, 'message': f'Review status updated successfully for ID {id}', 'affectedRows': cursor.rowcount})
    except Error as error:
        print(f"Error updating review status: {error}")
        return jsonify({'success': False, 'message': 'Error updating review status', 'error': str(error)}), 500

# 啟動伺服器
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=4000)
