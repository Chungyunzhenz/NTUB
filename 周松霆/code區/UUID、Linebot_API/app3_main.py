from flask import Flask, request, jsonify, abort
from linebot import LineBotApi, WebhookHandler
from linebot.exceptions import InvalidSignatureError, LineBotApiError
from linebot.models import MessageEvent, TextMessage, TextSendMessage
import mysql.connector
import json
import uuid

app = Flask(__name__)

# LINE API 初始化
access_token = ''
secret = ''
line_bot_api = LineBotApi(access_token)
handler = WebhookHandler(secret)

# MySQL 連線設定
db_config = {
    'host': '',
    'user': '',
    'password': '',
    'database': ''
}

# 創建資料表
def create_tables():
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS VerificationCodes (
        verification_code CHAR(36) PRIMARY KEY
    )""")

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS UserInfo (
        user_id INT AUTO_INCREMENT PRIMARY KEY,
        verification_code CHAR(36),
        user_name VARCHAR(255),
        email VARCHAR(255),
        other_info TEXT,
        FOREIGN KEY (verification_code) REFERENCES VerificationCodes(verification_code)
    )""")

    conn.commit()
    cursor.close()
    conn.close()

create_tables()

# 生成 UUID 並保存到資料庫
@app.route('/generate_code', methods=['POST'])
def generate_code():
    verification_code = str(uuid.uuid4())
    user_name = request.json.get('user_name')
    email = request.json.get('email')

    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO VerificationCodes (verification_code) VALUES (%s)", (verification_code,))
    cursor.execute("INSERT INTO UserInfo (verification_code, user_name, email) VALUES (%s, %s, %s)", 
                   (verification_code, user_name, email))
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'verification_code': verification_code})

# 保存用戶信息
@app.route('/save_user_info', methods=['POST'])
def save_user_info():
    data = request.json
    verification_code = data.get('verification_code')
    user_name = data.get('user_name')
    email = data.get('email')
    other_info = data.get('other_info')
    
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("""
        INSERT INTO UserInfo (verification_code, user_name, email, other_info)
        VALUES (%s, %s, %s, %s)
    """, (verification_code, user_name, email, other_info))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'User info saved successfully'})

# 根據 UUID 獲取用戶信息
@app.route('/get_user_info/<verification_code>', methods=['GET'])
def get_user_info(verification_code):
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM UserInfo WHERE verification_code = %s", (verification_code,))
    user_info = cursor.fetchone()
    cursor.close()
    conn.close()

    if user_info:
        return jsonify({
            'user_id': user_info[0],
            'verification_code': user_info[1],
            'user_name': user_info[2],
            'email': user_info[3],
            'other_info': user_info[4]
        })
    else:
        return jsonify({'message': 'User not found'}), 404

# LINE Bot 回調處理
@app.route("/callback", methods=['POST'])
def linebot():
    body = request.get_data(as_text=True)
    signature = request.headers.get('X-Line-Signature', '')
    try:
        handler.handle(body, signature)
        json_data = json.loads(body)
        tk = json_data['events'][0]['replyToken']
        msg_type = json_data['events'][0]['message']['type']

        if msg_type == 'text':
            msg = json_data['events'][0]['message']['text']
            code = msg.strip()

            # 查詢用戶信息
            conn = mysql.connector.connect(**db_config)
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM UserInfo WHERE verification_code = %s", (code,))
            user_info = cursor.fetchone()
            cursor.close()
            conn.close()

            if user_info:
                reply = f"用戶名：{user_info[2]}, 電子郵件：{user_info[3]}, 其他信息：{user_info[4]}"
            else:
                reply = "找不到編號對應的用戶信息。"

            line_bot_api.reply_message(tk, TextSendMessage(reply))
        else:
            reply = '請發送包含編號的文字訊息來查詢用戶信息。'
            line_bot_api.reply_message(tk, TextSendMessage(reply))

    except LineBotApiError as e:
        print(f"LineBotApiError: {e.status_code} {e.error.message}")
    except InvalidSignatureError:
        abort(400)
    except Exception as e:
        print(f"Error: {e}")
        print(body)
    return 'OK'

if __name__ == "__main__":
    app.run(debug=True)
