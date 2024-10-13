from flask import Blueprint, request, Response, jsonify
import datetime
import json
from flask_cors import CORS

new_announcement_bp = Blueprint('new_announcement', __name__)
CORS(new_announcement_bp, resources={r"/*": {"origins": "*"}})


# 公告存儲
announcements = ['8787','qqqq']

# 路由：獲取所有公告
@new_announcement_bp.route('/announcements', methods=['GET'])
def get_announcements():
    # 使用 json.dumps 並設置 ensure_ascii=False 以保證中文字符顯示正常
    response_data = json.dumps({"announcements": announcements}, ensure_ascii=False)
    return Response(response_data, content_type='application/json; charset=utf-8')

# 路由：保存或更新公告
@new_announcement_bp.route('/save_announcement', methods=['POST'])
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