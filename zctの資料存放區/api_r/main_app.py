

from flask import Flask
from flask_cors import CORS
from announcement import announcement_bp
from app import login_bp
from z5 import z5
from zuz import zuz
from img_uploadapi import img_uploadapi
from student_review import student_review_bp  # 引入學生評審藍圖
from new_announcement import new_announcement_bp  # 引入新的公告藍圖
from download import download
from stu import stu

app = Flask(__name__)

# Enable CORS for all routes
CORS(app, resources={r"/*": {"origins": "*"}})

# 注册蓝图
app.register_blueprint(announcement_bp)
app.register_blueprint(login_bp)
app.register_blueprint(z5)
app.register_blueprint(img_uploadapi)
app.register_blueprint(zuz)
app.register_blueprint(student_review_bp)  # 注册學生評審藍圖
app.register_blueprint(new_announcement_bp)  # 注册新的公告藍图
app.register_blueprint(download)
app.register_blueprint(stu)
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)