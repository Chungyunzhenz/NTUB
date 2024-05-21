from flask import Flask, request, abort
from linebot import LineBotApi, WebhookHandler
from linebot.exceptions import InvalidSignatureError
from linebot.models import MessageEvent, TextMessage, TextSendMessage
import openai
import mysql.connector
import logging

# 设置日志记录器
logging.basicConfig(level=logging.INFO)

openai.api_key = ''

# MySQL 連線設定
db = mysql.connector.connect(
    host="",
    user="",
    password="",
    database=""    
)

# 初始化 LINE Messaging API 和 WebhookHandler
line_bot_api = LineBotApi('')
handler = WebhookHandler('')

# 初始化 Flask 应用
app = Flask(__name__)

# 定义与 OpenAI 的聊天功能
def chatgpt_QA(Q):
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",  # 或者 "gpt-4"
            messages=[
                {"role": "system", "content": "你是台北商業大學小助手，擅長回答任何北商相關的問題與規定"},
                {"role": "user", "content": Q}
            ],
            max_tokens=500,
            temperature=0.7
        )
        logging.info(f"OpenAI response: {response}")
        return response["choices"][0]["message"]["content"]
    except Exception as e:
        logging.error(f"OpenAI API call failed: {e}")
        return "An error occurred while accessing the OpenAI API."
    
@app.route("/test", methods=['GET'])
def test():
    return 'test'

# 设置 /callback 路由以接收来自 LINE 的 Webhook 请求
@app.route("/callback", methods=['POST'])
def callback():
    signature = request.headers['X-Line-Signature']
    body = request.get_data(as_text=True)
    app.logger.info("Request body: " + body)

    try:
        handler.handle(body, signature)
    except InvalidSignatureError:
        abort(400)

    return 'OK'

@handler.add(MessageEvent, message=TextMessage)
def handle_message(event):
    user_id = event.source.user_id
    user_message = event.message.text
    response = chatgpt_QA(user_message) if user_message.startswith("Q:") else "Please provide your question starting with 'Q:'"

    # 將資訊存入資料庫
    try:
        cursor = db.cursor()
        query = "INSERT INTO user_messages (user_id, message, timestamp) VALUES (%s, %s, NOW())"
        cursor.execute(query, (user_id, user_message))

        db.commit()
    except Exception as e:
        logging.error(f"Failed to insert into database: {e}")
        db.rollback()
    finally:   
        cursor.close()

    logging.info(f"Sending response to LINE: {response}")
    line_bot_api.reply_message(event.reply_token, TextSendMessage(response))

# 启动 Flask 应用
if __name__ == "__main__":
    app.run()
