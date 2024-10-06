from flask import Flask
from announcement import announcement_bp
from app import login_bp
from z5 import z5
from zuz import zuz
from img_uploadapi import img_uploadapi
app = Flask(__name__)

# 注册蓝图，不使用URL前缀
app.register_blueprint(announcement_bp)
app.register_blueprint(login_bp)
app.register_blueprint(z5)
app.register_blueprint(img_uploadapi)
app.register_blueprint(zuz)
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5005)
