from flask import Flask, request, jsonify
from ckiptagger import data_utils, WS, POS, NER
import pymysql
import logging
import tensorflow as tf

# 設置 TensorFlow 記錄級別
tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)

app = Flask(__name__)

# 下載並加載 CKIPtagger 模型
data_utils.download_data_url("./")
ws = WS("./data")
pos = POS("./data")
ner = NER("./data")

# 數據庫配置
db_config = {
    'host': '140...',
    'user': '',
    'password': '$',
    'database': '113-'
}

def connect_db():
    try:
        connection = pymysql.connect(
            host=db_config['host'],
            user=db_config['user'],
            password=db_config['password'],
            database=db_config['database']
        )
        return connection
    except pymysql.MySQLError as e:
        app.logger.error(f"Database connection failed: {e}")
        return None

@app.route('/predict', methods=['POST'])
def predict():
    # 從請求中獲取句子
    data = request.json
    sentence = data.get('sentence')
    
    if not sentence:
        return jsonify({'error': 'No sentence provided'}), 400
    
    # 使用 CKIPtagger 進行 NER
    try:
        ws_results = ws([sentence])
        pos_results = pos(ws_results)
        
        # 記錄 WS 和 POS 結果以便調試
        app.logger.info(f"WS results: {ws_results}")
        app.logger.info(f"POS results: {pos_results}")
        
        # 執行 NER
        ner_results = ner(ws_results, pos_results)
        app.logger.info(f"NER results: {ner_results}")
    except Exception as e:
        app.logger.error(f"NER prediction failed: {e}")
        return jsonify({'error': 'NER prediction failed'}), 500
    
    # 檢查 ner_results 的結構
    if not ner_results or not isinstance(ner_results, list) or not ner_results[0]:
        app.logger.error("NER result is empty or has an unexpected structure.")
        return jsonify({'error': 'NER result is empty or has an unexpected structure.'}), 500

    # 連接到數據庫
    connection = connect_db()
    if connection is None:
        return jsonify({'error': 'Failed to connect to the database'}), 500

    cursor = connection.cursor()
    
    try:
        # 將結果保存到數據庫
        for entity in ner_results[0]:
            word, ner_type, start_pos, end_pos = entity
            app.logger.info(f"Inserting entity: {word}, type: {ner_type}")
            cursor.execute(
                "INSERT INTO ner_results (sentence, entity, entity_type) VALUES (%s, %s, %s)",
                (sentence, word, ner_type)
            )
        connection.commit()
    except pymysql.MySQLError as e:
        app.logger.error(f"Failed to insert data into the database: {e}")
        return jsonify({'error': 'Failed to insert data into the database'}), 500
    finally:
        cursor.close()
        connection.close()
    
    return jsonify({'message': 'Prediction saved', 'result': [{'entity': entity[0], 'type': entity[1]} for entity in ner_results[0]]}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=True)
