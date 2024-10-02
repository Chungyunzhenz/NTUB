from flask import Flask, request, abort, jsonify
from linebot import LineBotApi, WebhookHandler
from linebot.exceptions import InvalidSignatureError, LineBotApiError
from linebot.models import MessageEvent, TextMessage, TextSendMessage, ImageSendMessage
import mysql.connector
import json
import datetime
import random
import string
import uuid

app = Flask(__name__)

# 初始化 LINE API
access_token = 'dR5DUxxKiPFiEASDv0/zoPdZmdez6WBuOPkQ8Wl8/Z7+jqFX3GbqQMrTgKlYvuUZHmK+AoecJuN3p/b/SMvT8sGkiWz6Rd1gs/bNT3az/gcL+ldIjC7DDHes6FANIiHJkWEInHT/JnEX/ylthJia/wdB04t89/1O/w1cDnyilFU='
secret = '1c7f860beafc6a9f6a49ab75f49d4987'
line_bot_api = LineBotApi(access_token)
handler = WebhookHandler(secret)

# MySQL 連線設定
db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'Nttub$Eas0nZct',
    'database': '113-Ntub_113205DB'
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

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS UserImages (
        image_id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT,
        image_url VARCHAR(255),
        uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES UserInfo(user_id)
    )""")

    conn.commit()
    cursor.close()
    conn.close()

create_tables()

def generate_random_code(length=6):
    letters_and_digits = string.ascii_letters + string.digits
    return ''.join(random.choice(letters_and_digits) for _ in range(length))

@app.route('/generate_code', methods=['POST'])
def generate_code():
    verification_code = str(uuid.uuid4())
    conn = mysql.connector.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute("INSERT INTO VerificationCodes (verification_code) VALUES (%s)", (verification_code,))
    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'verification_code': verification_code})

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

@app.route("/callback", methods=['POST'])
def linebot():
    body = request.get_data(as_text=True)  # 獲取請求的主體
    signature = request.headers.get('X-Line-Signature', '')  # 獲取簽名
    try:
        handler.handle(body, signature)  # 綁定訊息回傳的相關資訊
        json_data = json.loads(body)  # 將主體內容轉為JSON格式
        tk = json_data['events'][0]['replyToken']  # 獲取回傳訊息的Token
        msg_type = json_data['events'][0]['message']['type']  # 獲取訊息類型

        conn = mysql.connector.connect(**db_config)
        cursor = conn.cursor()

        if msg_type == 'text':
            msg = json_data['events'][0]['message']['text']  # 獲取文字訊息
            code = msg.strip()  # 獲取編號，移除空白字符

            cursor.execute("SELECT image_url FROM UserImages WHERE user_id IN (SELECT user_id FROM UserInfo WHERE verification_code = %s)", (code,))
            images = cursor.fetchall()
            if images:
                for image in images:
                    line_bot_api.reply_message(tk, ImageSendMessage(original_content_url=image[0], preview_image_url=image[0]))
            else:
                reply = "找不到編號對應的圖片。"
                line_bot_api.reply_message(tk, TextSendMessage(reply))
        elif msg_type == 'image':
            msgID = json_data['events'][0]['message']['id']  # 獲取訊息ID
            message_content = line_bot_api.get_message_content(msgID)  # 根據訊息ID獲取訊息內容
            image_data = message_content.content
            
            # 生成隨機編號
            code = generate_random_code()
            now = datetime.datetime.now()
            image_url = f'/path/to/images/{code}.jpg'  # 修改為實際存儲位置

            cursor.execute("INSERT INTO UserImages (user_id, image_url, uploaded_at) VALUES ((SELECT user_id FROM UserInfo WHERE verification_code = %s), %s, %s)", (code, image_url, now))
            conn.commit()
            
            # 保存圖片到伺服器
            with open(image_url, 'wb') as f:
                f.write(image_data)

            reply = f'圖片儲存完成！編號：{code}'
            line_bot_api.reply_message(tk, TextSendMessage(reply))
        else:
            reply = '請發送包含編號的文字訊息來查詢圖片。'
            line_bot_api.reply_message(tk, TextSendMessage(reply))
        
        cursor.close()
        conn.close()

    except LineBotApiError as e:
        print(f"LineBotApiError: {e.status_code} {e.error.message}")
    except InvalidSignatureError:
        abort(400)
    except Exception as e:
        print(f"Error: {e}")
        print(body)  # 如果發生錯誤，印出收到的內容
    return 'OK'  # 驗證Webhook使用，不能省略

if __name__ == "__main__":
    app.run()
