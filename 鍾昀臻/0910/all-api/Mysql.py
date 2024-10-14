# 使用 mysql.connector 和 Flask 的學生審查 API
from flask import Flask, request, jsonify
import mysql.connector
from flask_cors import CORS
import threading
import time

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# 資料庫配置
db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'Nttub$Eas0nZct',
    'database': '113-Ntub_113205DB'
}

# 全局變數來儲存學生更新
student_updates = {}

# 查詢學生審查狀況
@app.route('/getStudentReviews', methods=['GET'])
def get_student_reviews():
    review_status = request.args.get('review_status')

    # 驗證 review_status 參數
    valid_statuses = ["審查中", "退回", "通過", "撤回"]
    if review_status and review_status not in valid_statuses:
        return jsonify({'error': f'無效的 review_status 參數。允許的值為 {valid_statuses}'}), 400

    connection = None

    try:
        # 連接到資料庫
        print("嘗試連接到資料庫...")
        connection = mysql.connector.connect(**db_config)
        
        if not connection.is_connected():
            print("連接資料庫失敗")
            return jsonify({'error': '連接資料庫失敗'}), 500

        cursor = connection.cursor(dictionary=True)
        print("成功連接到資料庫")

        # 查詢學生審查資料，如果提供了審查狀態則過濾
        if review_status:
            query = "SELECT * FROM ReviewProgress WHERE review_status = %s"
            print(f"執行查詢: {query}，參數: {review_status}")
            cursor.execute(query, (review_status,))
        else:
            query = "SELECT * FROM ReviewProgress"
            print(f"執行查詢: {query}")
            cursor.execute(query)

        result = cursor.fetchall()
        print(f"查詢成功，共獲取 {len(result)} 條記錄")

        return jsonify(result)

    except mysql.connector.Error as err:
        print(f"資料庫錯誤: {err}")
        return jsonify({'error': str(err)}), 500
    except Exception as e:
        print(f"意外錯誤: {e}")
        return jsonify({'error': '發生了意外錯誤'}), 500

    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            print("資料庫連接已關閉")

# 更新審查狀態
@app.route('/updateReviewStatus', methods=['POST'])
def update_review_status():
    data = request.get_json()
    id = data.get('id')
    new_status = data.get('new_status')

    # 驗證新狀態
    valid_statuses = ["審查中", "退回", "通過", "撤回"]
    if new_status not in valid_statuses:
        return jsonify({'error': f'無效的 new_status 參數。允許的值為 {valid_statuses}'}), 400

    if not id:
        return jsonify({'error': '缺少 id 參數'}), 400

    connection = None

    try:
        # 連接到資料庫
        print("嘗試連接到資料庫...")
        connection = mysql.connector.connect(**db_config)
        
        if not connection.is_connected():
            print("連接資料庫失敗")
            return jsonify({'error': '連接資料庫失敗'}), 500

        cursor = connection.cursor()
        print("成功連接到資料庫")

        # 更新審查狀態
        update_query = "UPDATE ReviewProgress SET review_status = %s WHERE id = %s"
        cursor.execute(update_query, (new_status, id))
        connection.commit()

        if cursor.rowcount == 0:
            return jsonify({'error': '未找到具有給定 id 的審查'}), 404

        # 更新學生更新狀態
        student_updates[id] = {'status': new_status, 'timestamp': time.time()}

        print(f"審查狀態更新為 '{new_status}'")
        return jsonify({'message': f'審查狀態成功更新為 {new_status}'})

    except mysql.connector.Error as err:
        print(f"資料庫錯誤: {err}")
        return jsonify({'error': str(err)}), 500
    except Exception as e:
        print(f"意外錯誤: {e}")
        return jsonify({'error': '發生了意外錯誤'}), 500

    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            print("資料庫連接已關閉")

# 撤回審查
@app.route('/withdrawReview', methods=['POST'])
def withdraw_review():
    data = request.get_json()
    id = data.get('review_id')

    if not id:
        return jsonify({'error': '缺少 review_id 參數'}), 400

    connection = None

    try:
        # 連接到資料庫
        print("嘗試連接到資料庫...")
        connection = mysql.connector.connect(**db_config)
        
        if not connection.is_connected():
            print("連接資料庫失敗")
            return jsonify({'error': '連接資料庫失敗'}), 500

        cursor = connection.cursor()
        print("成功連接到資料庫")

        # 更新審查狀態為撤回
        update_query = "UPDATE ReviewProgress SET review_status = %s WHERE id = %s"
        cursor.execute(update_query, ("撤回", id))
        connection.commit()

        if cursor.rowcount == 0:
            return jsonify({'error': '未找到具有給定 id 的審查'}), 404

        # 更新學生更新狀態
        student_updates[id] = {'status': "撤回", 'timestamp': time.time()}

        print(f"審查狀態更新為 '撤回'")
        return jsonify({'message': '審查狀態成功撤回'})

    except mysql.connector.Error as err:
        print(f"資料庫錯誤: {err}")
        return jsonify({'error': str(err)}), 500
    except Exception as e:
        print(f"意外錯誤: {e}")
        return jsonify({'error': '發生了意外錯誤'}), 500

    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            print("資料庫連接已關閉")

# 查詢審查更新
@app.route('/getReviewUpdates', methods=['GET'])
def get_review_updates():
    id = request.args.get('id')
    
    if not id:
        return jsonify({'error': '缺少 id 參數'}), 400

    if id not in student_updates:
        return jsonify({'error': '給定 id 無可用更新'}), 404

    return jsonify(student_updates[id])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)