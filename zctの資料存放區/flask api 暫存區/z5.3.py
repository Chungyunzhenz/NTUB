from flask import Flask, request, jsonify
from ckiptagger import data_utils, WS, POS, NER, construct_dictionary
import pymysql
import logging
import tensorflow as tf
import json
from neo4j import GraphDatabase
import os
import time

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
    'database': ''
}

neo4j_config = {
    'uri': 'neo4j://localhost:7687',
    'user': '',
    'password': ''
}

# 跟踪 custom_dict.txt 文件的最後修改時間
custom_dict_last_modified = None
custom_dict_cache = None

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

def load_custom_dict(file_path):
    custom_dict = {}
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                word, pos, freq = line.strip().split(',')
                custom_dict[word] = (pos, int(freq))
    except Exception as e:
        app.logger.error(f"Failed to load custom dictionary: {e}")
    return custom_dict

def check_and_load_custom_dict(file_path):
    global custom_dict_last_modified, custom_dict_cache
    try:
        last_modified = os.path.getmtime(file_path)
        if custom_dict_last_modified is None or last_modified > custom_dict_last_modified:
            app.logger.info("Reloading custom dictionary due to file modification.")
            custom_dict_cache = load_custom_dict(file_path)
            custom_dict_last_modified = last_modified
    except Exception as e:
        app.logger.error(f"Failed to check custom dictionary file: {e}")

    return custom_dict_cache

@app.route('/predict', methods=['POST'])
def predict():
    # 從請求中獲取句子
    data = request.json
    app.logger.info(f"Received data: {data}")
    
    sentence = data.get('sentence')
    
    if not sentence:
        return jsonify({'error': 'No sentence provided'}), 400
    
    # 檢查並載入自定義字典
    custom_dict = check_and_load_custom_dict('custom_dict.txt')
    user_dict = construct_dictionary({word: freq for word, (pos, freq) in custom_dict.items()})

    # 使用 CKIPtagger 進行 NER 和 POS
    try:
        ws_results = ws([sentence], recommend_dictionary=user_dict)
        pos_results = pos(ws_results)
        
        # 将自定义词性的结果应用到分词和词性标注结果中
        for i, words in enumerate(ws_results):
            for j, word in enumerate(words):
                if word in custom_dict:
                    pos_results[i][j] = custom_dict[word][0]

        # 記錄 WS 和 POS 結果以便調試
        app.logger.info(f"WS results: {ws_results}")
        app.logger.info(f"POS results: {pos_results}")
        
        # 執行 NER
        ner_results = ner(ws_results, pos_results)
        app.logger.info(f"NER results: {ner_results}")
    except Exception as e:
        app.logger.error(f"NER prediction failed: {e}")
        return jsonify({'error': f'NER prediction failed: {e}'}), 500
    
    try:
        # 如果 NER 和 POS 結果都無法滿足要求，返回錯誤
        if (not ner_results or not isinstance(ner_results, list) or not ner_results[0]) and \
            (not any(pos in pos_results[0] for pos in ['Neu', 'COLONCATEGORY', 'class'])):
            app.logger.error("No valid NER or POS results.")
            return jsonify({'error': 'No valid NER or POS results'}), 500

        # 查找 PERSON、DATE 實體、Neu 和 class 類型並查詢 Neo4j
        driver = connect_neo4j()
        if driver is None:
            return jsonify({'error': 'Failed to connect to Neo4j'}), 500

        persons = [entity[3] for entity in ner_results[0] if entity[2] == 'PERSON']
        dates = [entity[3] for entity in ner_results[0] if entity[2] == 'DATE']
        neu_categories = [word for i, word in enumerate(ws_results[0]) if pos_results[0][i] == 'Neu']
        class_categories = [word for i, word in enumerate(ws_results[0]) if pos_results[0][i] == 'class']
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

            # 查詢 class 類型的詞
            for class_category in class_categories:
                result = session.run(
                    """
                    MATCH (c:Class {name: $name})
                    OPTIONAL MATCH (c)-[r]-(related)
                    RETURN c, collect(r) as relations, collect(related) as related_nodes, type(r) as relation_type
                    """, name=class_category
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
                    neo4j_results.append(f"No result found for {class_category}")

        driver.close()

        # 將 NER 結果轉換為 JSON 字符串
        ner_results_str = json.dumps([
            {
                'start_pos': entity[0],
                'end_pos': entity[1],
                'type': entity[2],
                'entity': str(entity[3])  # 確保 entity 轉換為字符串
            } for entity in ner_results[0]
        ])

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
    
    except Exception as e:
        app.logger.error(f"An error occurred during processing: {e}")
        return jsonify({'error': f"An error occurred during processing: {e}"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003, debug=True)
