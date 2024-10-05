from flask import Flask, request, Response, jsonify
import datetime
import json
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Announcement storage
announcements = []

# Route to get all announcements
@app.route('/announcements', methods=['GET'])
def get_announcements():
    # 使用 json.dumps 並設置 ensure_ascii=False
    response_data = json.dumps({"announcements": announcements}, ensure_ascii=False)
    return Response(response_data, content_type='application/json; charset=utf-8')

# Route to save or update an announcement
@app.route('/save_announcement', methods=['POST'])
def save_announcement():
    data = request.get_json()
    purpose = data.get('Purpose')
    content = data.get('content')
    time = data.get('time')
    sender = data.get('sender')

    # Validate required fields
    if not all([purpose, content, time, sender]):
        return "Missing required fields", 400

    # Parse the time
    try:
        time = datetime.datetime.strptime(time, '%a, %d %b %Y %H:%M:%S %Z')
    except ValueError:
        return "Invalid time format", 400

    # Save the announcement
    announcement = {
        "Purpose": purpose,
        "content": content,
        "time": time.strftime('%a, %d %b %Y %H:%M:%S %Z'),
        "sender": sender
    }
    announcements.append(announcement)

    return jsonify({"message": "Announcement saved successfully", "announcements": announcements}), 200

if __name__ == '__main__':
    #app.run(host='zct.us.kg', port=5000, debug=True)
    app.run(host='0.0.0.0', port=5001, debug=True)
