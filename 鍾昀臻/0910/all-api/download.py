from flask import Flask, jsonify, request
from flask_cors import CORS
import pymysql

app = Flask(__name__)
CORS(app)

# 資料庫連接配置
db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'Nttub$Eas0nZct',
    'database': '113-Ntub_113205DB'
}

@app.route('/api/class_data', methods=['GET'])
def get_class_data():
    try:
        # 連接資料庫
        connection = pymysql.connect(
            host=db_config['host'],
            user=db_config['user'],
            password=db_config['password'],
            database=db_config['database'],
            cursorclass=pymysql.cursors.DictCursor
        )

        with connection.cursor() as cursor:
            # SQL 查詢指令，獲取 ReviewProgress 資料表的所有欄位
            sql_query = """
            SELECT * FROM ReviewProgress
            """
            cursor.execute(sql_query)
            result = cursor.fetchall()

        # 關閉連接
        connection.close()

        # 返回查詢結果
        return jsonify(result)

    except Exception as e:
        # 錯誤處理
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)

