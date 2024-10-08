from flask import Flask, request, Response, jsonify
import datetime
import json
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# 公告存儲
announcements = []

# 路由：獲取所有公告
@app.route('/announcements', methods=['GET'])
def get_announcements():
    # 使用 json.dumps 並設置 ensure_ascii=False 以保證中文字符顯示正常
    response_data = json.dumps({"announcements": announcements}, ensure_ascii=False)
    return Response(response_data, content_type='application/json; charset=utf-8')

# 路由：保存或更新公告
@app.route('/save_announcement', methods=['POST'])
def save_announcement():
    data = request.get_json()  # 獲取請求中的 JSON 數據
    purpose = data.get('Purpose')  # 公告標題
    content = data.get('content')  # 公告內容
    sender = data.get('sender')  # 發送者

    # 驗證必填字段是否存在
    if not all([purpose, content, sender]):
        return "Missing required fields", 400

    # 創建當前時間作為公告時間
    time = datetime.datetime.now().strftime('%a, %d %b %Y %H:%M:%S %Z')

    # 生成公告的唯一 ID
    announcement_id = len(announcements) + 1

    # 保存公告
    announcement = {
        "id": announcement_id,
        "Purpose": purpose,
        "content": content,
        "time": time,
        "sender": sender
    }
    announcements.append(announcement)

    return jsonify({"message": "Announcement saved successfully", "announcement": announcement}), 200

if __name__ == '__main__':
    # app.run(host='zct.us.kg', port=5000, debug=True)
    app.run(host='0.0.0.0', port=5001, debug=True)