from flask import Flask, request, Response, jsonify
import datetime
import json
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# 設定資料庫連接
db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'Nttub$Eas0nZct',
    'database': '113-Ntub_113205DB'
}

def get_db_connection():
    connection = mysql.connector.connect(**db_config)
    return connection

# 定義允許的發送者名單
ALLOWED_SENDERS = ['WET8644GS346', 'ADMIN', 'SYSTEM']

# 獲取公告
@app.route('/announcement', methods=['GET'])
def get_announcements():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM announcement")
        announcements = cursor.fetchall()

        for announcement in announcements:
            if isinstance(announcement['time'], datetime.datetime):
                announcement['time'] = announcement['time'].strftime('%Y-%m-%d %H:%M:%S')

        cursor.close()
        conn.close()
        response_data = json.dumps({"announcement": announcements}, ensure_ascii=False)
        return Response(response_data, content_type='application/json; charset=utf-8')

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/save_announcement', methods=['POST'])
def save_announcement():
    try:
        data = request.get_json()
        purpose = data.get('Purpose')
        content = data.get('content')
        
        # 固定 sender 為指定的值
        sender = 'WET8644G3S46'

        # 檢查必填字段
        if not all([purpose, content]):
            return "Missing required fields", 400

        # 自動生成時間戳
        time = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        conn = get_db_connection()
        cursor = conn.cursor()

        # SQL 插入公告
        sql = "INSERT INTO announcement (Purpose, content, time, sender) VALUES (%s, %s, %s, %s)"
        cursor.execute(sql, (purpose, content, time, sender))
        conn.commit()

        announcement_id = cursor.lastrowid

        cursor.close()
        conn.close()

        announcement = {
            "id": announcement_id,
            "Purpose": purpose,
            "content": content,
            "time": time,
            "sender": sender
        }

        return jsonify({"message": "Announcement saved successfully", "announcement": announcement}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)
