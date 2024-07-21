from flask import Flask
from announcement import announcement_bp
from app import login_bp

app = Flask(__name__)

# 注册蓝图，不使用URL前缀
app.register_blueprint(announcement_bp)
app.register_blueprint(login_bp)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
