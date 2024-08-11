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

# 定義自訂字典
custom_dict = {
    "生活藝術賞析": 1,
    "文化資產與藝術產業經營": 1,
    "資料庫管理": 1
}

# 數據庫配置
db_config = {
    'host': '...',
    'user': '',
    'password': '',
    'database': '-'
}

neo4j_config = {
    'uri': 'neo4j://localhost:7687',
    'user': '',
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
    
    # 使用 CKIPtagger 進行 NER 和 POS
    try:
        ws_results = ws([sentence], recommend_dictionary=custom_dict)  # 使用自訂字典
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
    
    # 確保 NER 結果是有效的
    if not ner_results or not isinstance(ner_results, list) or not ner_results[0]:
        app.logger.error("No valid NER results.")
        return jsonify({'error': 'No valid NER results'}), 500
    
    # 確保 POS 結果是有效的
    if not any(pos in pos_results[0] for pos in ['Neu', 'COLONCATEGORY']):
        app.logger.error("No valid POS results.")
        return jsonify({'error': 'No valid POS results'}), 500

    # 處理 NER 和 POS 結果
    persons = [entity[3] for entity in ner_results[0] if entity[2] == 'PERSON']
    dates = [entity[3] for entity in ner_results[0] if entity[2] == 'DATE']
    neu_categories = [word for i, word in enumerate(ws_results[0]) if pos_results[0][i] == 'Neu']
    

    # 查找 PERSON、DATE 實體和 Neu 類型並查詢 Neo4j
    driver = connect_neo4j()
    if driver is None:
        return jsonify({'error': 'Failed to connect to Neo4j'}), 500

    persons = [entity[3] for entity in ner_results[0] if entity[2] == 'PERSON']
    dates = [entity[3] for entity in ner_results[0] if entity[2] == 'DATE']
    neu_categories = [word for i, word in enumerate(ws_results[0]) if pos_results[0][i] == 'Neu']
    neo4j_results = []

    with driver.session() as session:
        # 查詢 PERSON 節點
        for person in persons:
            result = session.run(
                """
                MATCH (p:Teacher {name: $name})
                OPTIONAL MATCH (p)-[r]-(related)
                RETURN p, collect(r) as relations, collect(related) as related_nodes, type(r) as relation_type
                """, name=person
            )
            if result.peek():  # Check if there is at least one result
                for record in result:
                    node = dict(record["p"].items())
                    relations = [{"relation_type": record["relation_type"], **dict(rel.items())} for rel in record["relations"]]
                    related_nodes = [dict(node.items()) for node in record["related_nodes"]]
                    neo4j_results.append({
                        'node': node,
                        'relations': relations,
                        'related_nodes': related_nodes
                    })
            else:
                neo4j_results.append(f"No result found for {person}")

        # 查詢 DATE 節點
        for date in dates:
            result = session.run(
                """
                MATCH (c:Ctime {name: $name})
                OPTIONAL MATCH (c)-[r]-(related)
                RETURN c, collect(r) as relations, collect(related) as related_nodes, type(r) as relation_type
                """, name=date
            )
            if result.peek():  # Check if there is at least one result
                for record in result:
                    node = dict(record["c"].items())
                    relations = [{"relation_type": record["relation_type"], **dict(rel.items())} for rel in record["relations"]]
                    related_nodes = [dict(node.items()) for node in record["related_nodes"]]
                    neo4j_results.append({
                        'node': node,
                        'relations': relations,
                        'related_nodes': related_nodes
                    })
            else:
                neo4j_results.append(f"No result found for {date}")

        # 查詢 Neu 類型的數字
        for neu_category in neu_categories:
            result = session.run(
                """
                MATCH (t:Table {name: $name})
                OPTIONAL MATCH (t)-[r]-(related)
                RETURN t, collect(r) as relations, collect(related) as related_nodes, type(r) as relation_type
                """, name=neu_category
            )
            if result.peek():  # Check if there is at least one result
                for record in result:
                    node = dict(record["t"].items())
                    relations = [{"relation_type": record["relation_type"], **dict(rel.items())} for rel in record["relations"]]
                    related_nodes = [dict(node.items()) for node in record["related_nodes"]]
                    neo4j_results.append({
                        'node': node,
                        'relations': relations,
                        'related_nodes': related_nodes
                    })
            else:
                neo4j_results.append(f"No result found for {neu_category}")

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
