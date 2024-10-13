import openai
import json
from flask import Flask, jsonify
from py2neo import Graph
import os

app = Flask(__name__)

# 設定 OpenAI API 金鑰
openai.api_key = ''  

# 連接到 Neo4j 資料庫
graph = Graph("bolt://localhost:7687", auth=("", ""))  # 請使用你的 Neo4j 資料庫密碼

# 根據欄位和 OCR 結果生成 prompt
def generate_prompt(field_name, original_text, correct_text=None):
    if field_name == "學號":
        prompt = f"我有一個學號是「{original_text}」，你能幫我檢查是否正確嗎？如果有誤，請幫我修正。"
    elif field_name == "姓名":
        prompt = f"姓名 OCR 辨識出來的結果是「{original_text}」，但我不確定是否正確，請幫我檢查並修正。"
    elif field_name == "請假事由":
        prompt = f"請假事由 OCR 辨識出來的結果是「{original_text}」，請幫我檢查這是否是一個正當的事由。"
    elif field_name == "申請科目":
        prompt = f"我有一個選課單的科目名稱是「{original_text}」，幫我確認它是否正確，或提供修正。"
    else:
        prompt = f"我有一個欄位「{field_name}」的 OCR 結果是「{original_text}」，幫我檢查一下它是否正確，如果錯了請幫我修正。"
    
    return prompt

# 使用 ChatGPT API 進行文本修正
def correct_with_chatgpt(field_name, original_text, correct_text=None):
    prompt = generate_prompt(field_name, original_text, correct_text)
    
    # 使用 ChatCompletion 來調用 ChatGPT 模型
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "你是一個幫助修正 OCR 錯誤的助手。"},
            {"role": "user", "content": prompt}
        ]
    )
    
    # 返回 ChatGPT 的回應內容
    return response['choices'][0]['message']['content'].strip()

# 查詢 Neo4j 進行數據比對
def query_neo4j(field_name, original_text):
    if field_name == "學號":
        query = f"MATCH (n:User {{name: '{original_text}'}}) RETURN n"
    elif field_name == "科目":
        query = f"MATCH (n:Class {{name: '{original_text}'}}) RETURN n"
    else:
        return None
    
    result = graph.run(query).data()
    if result:
        return result[0]['n']['properties']['name']
    return None

# 主 API 路由：處理 OCR 表單比對與修正
@app.route('/check_form', methods=['GET'])
def check_form():
    try:
        # 指定 JSON 檔案的路徑
        json_file_path = os.path.join(os.getcwd(), 'ocr_data.json')
        
        # 讀取 JSON 檔案
        with open(json_file_path, 'r', encoding='utf-8') as json_file:
            data = json.load(json_file)
        
        # 定義需要檢查的欄位
        fields_to_check = ["學號", "姓名", "請假事由", "申請科目"]

        # 遍歷每個需要檢查的欄位
        for field in fields_to_check:
            ocr_result = None
            # 根據欄位名稱找到對應的 OCR 結果
            for item in data:
                if item['text'].startswith(field):
                    ocr_result = item['text']
                    break
            
            if ocr_result:
                # 先在 Neo4j 中查詢
                correct_text = query_neo4j(field, ocr_result)
                
                if correct_text:
                    # 如果 Neo4j 中有結果，則使用資料庫中的正確資料
                    item['corrected_text'] = correct_text
                else:
                    # 否則，使用 ChatGPT 進行修正
                    corrected_text = correct_with_chatgpt(field, ocr_result)
                    item['corrected_text'] = corrected_text

        # 儲存修正後的 JSON 檔案
        corrected_file_path = os.path.join(os.getcwd(), 'corrected_ocr_data.json')
        print(f"儲存修正後的檔案到: {corrected_file_path}")

        with open(corrected_file_path, 'w', encoding='utf-8') as corrected_file:
            json.dump(data, corrected_file, ensure_ascii=False, indent=4)
        # 打印確認訊息
        print(f"修正後的 JSON 檔案已成功寫入: {corrected_file_path}")

        

        # 返回最終結果
        return jsonify({
            "status": "success",
            "message": "表單內容檢查完畢，並已儲存修正後的 JSON 檔案",
            "corrected_data": data
        }), 200

    except Exception as e:
        # 處理錯誤，返回錯誤信息
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

# 啟動 Flask 應用程式
if __name__ == "__main__":
    app.run(host='0.0.0.0', debug=True, port=5005)

#http://127.0.0.1:5005/check_form

