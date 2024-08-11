from flask import Flask, request, jsonify
from ckiptagger import data_utils, WS, POS, NER
import pymysql
import logging
import tensorflow as tf
import json
from neo4j import GraphDatabase

# 設置 TensorFlow 記錄級別
tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)

app = Flask(__name__)

# 下載並加載 CKIPtagger 模型
try:
    data_utils.download_data_url("./")
    ws = WS("./data")
    pos = POS("./data")
    ner = NER("./data")
except Exception as e:
    app.logger.error(f"Failed to load CKIPtagger models: {e}")
    raise

# 數據庫配置
db_config = {
    'host': '',
    'user': '',
    'password': '',
    'database': '113'
}

neo4j_config = {
    'uri': 'neo4j://localhost:7687',
    'user': 'neo4j',
    'password': ''
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

def connect_neo4j():
    try:
        driver = GraphDatabase.driver(
            neo4j_config['uri'],
            auth=(neo4j_config['user'], neo4j_config['password'])
        )
        return driver
    except Exception as e:
        app.logger.error(f"Neo4j connection failed: {e}")
        return None

@app.route('/predict', methods=['POST'])
def predict():
    # 從請求中獲取句子
    data = request.json
    app.logger.info(f"Received data: {data}")
    
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

    # 查找 PERSON 實體並查詢 Neo4j
    driver = connect_neo4j()
    if driver is None:
        return jsonify({'error': 'Failed to connect to Neo4j'}), 500

    persons = [entity[3] for entity in ner_results[0] if entity[2] == 'PERSON']
    neo4j_results = []

    with driver.session() as session:
        for person in persons:
            result = session.run(
                """
                MATCH (p:Teacher {name: $name})
                OPTIONAL MATCH (p)-[r]-(related)
                RETURN p, collect(r) as relations, collect(related) as related_nodes
                """, name=person
            )
            if result.peek():  # Check if there is at least one result
                for record in result:
                    node = record["p"]
                    relations = [dict(rel) for rel in record["relations"]]
                    related_nodes = [dict(node) for node in record["related_nodes"]]
                    neo4j_results.append({
                        'node': dict(node),
                        'relations': relations,
                        'related_nodes': related_nodes
                    })
            else:
                neo4j_results.append(f"No result found for {person}")

    driver.close()

    # 將 NER 結果轉換為 JSON 字符串
    ner_results_str = json.dumps([{'start_pos': entity[0], 'end_pos': entity[1], 'type': entity[2], 'entity': entity[3]} for entity in ner_results[0]])

    # 連接到數據庫
    connection = connect_db()
    if connection is None:
        return jsonify({'error': 'Failed to connect to the database'}), 500

    cursor = connection.cursor()
    
    try:
        # 保存句子和 NER 結果到數據庫
        cursor.execute(
            "INSERT INTO ner_results (sentence, ner_result) VALUES (%s, %s)",
            (sentence, ner_results_str)
        )
        connection.commit()
    except pymysql.MySQLError as e:
        app.logger.error(f"Failed to insert data into the database: {e}")
        return jsonify({'error': 'Failed to insert data into the database'}), 500
    finally:
        cursor.close()
        connection.close()
    
    return jsonify({'message': 'Prediction saved', 'result': json.loads(ner_results_str), 'neo4j_results': neo4j_results}), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True)
