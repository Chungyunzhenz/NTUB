import openai
from py2neo import Graph

# 設定 OpenAI API 金鑰
openai.api_key = "your-openai-api-key"

# Neo4j 資料庫連接資訊（來自圖片）
neo4j_config = {
    'uri': 'neo4j://localhost:7687',  # 替換為虛擬機上的 URI
    'user': 'neo4j',  # 替換為用戶名
    'password': 'thispass'  # 替換為密碼
}

# 連接到 Neo4j 資料庫
graph = Graph(neo4j_config['uri'], auth=(neo4j_config['user'], neo4j_config['password']))

# 1. 查詢 Neo4j 知識庫的資料，根據 OCR 的輸入查詢學生課程和其他信息
def query_neo4j(ocr_data):
    query = """
    MATCH (u:User)-[:選擇課程]->(c:Class)-[:授課教師]->(t:Teacher), (u)-[:上課時間]->(ct:Ctime)
    WHERE u.name = $student_name AND c.name = $course_name
    RETURN u.name AS student_name, c.name AS course_name, t.name AS teacher_name, ct.time AS period
    """
    result = graph.run(query, student_name=ocr_data['student_name'], course_name=ocr_data['course_name']).data()
    return result[0] if result else None

# 2. 生成 prompt 並發送給 ChatGPT
def generate_prompt(ocr_text, neo4j_data):
    prompt = f"""
    這段文字是來自 OCR 的辨識結果：'{ocr_text}'。
    根據 Neo4j 知識庫中的資料，正確的欄位如下：
    - 課名: {neo4j_data['course_name']}
    - 姓名: {neo4j_data['student_name']}
    - 節次: {neo4j_data['period']}
    請檢查這段文字是否正確，並幫助修正錯誤的部分。
    """
    return prompt

# 3. 使用 ChatGPT 檢查並修正 OCR 輸出
def check_and_correct_text(ocr_text, neo4j_data):
    prompt = generate_prompt(ocr_text, neo4j_data)
    response = openai.Completion.create(
        model="text-davinci-003",
        prompt=prompt,
        max_tokens=500
    )
    return response['choices'][0]['text']

# 4. 主流程函數
def main(ocr_text, ocr_data):
    # 步驟 1: 根據 OCR 數據查詢 Neo4j 知識庫
    neo4j_data = query_neo4j(ocr_data)
    
    if neo4j_data:
        # 步驟 2: 使用 ChatGPT 檢查並修正 OCR 輸出
        corrected_text = check_and_correct_text(ocr_text, neo4j_data)
        print("修正後的文字:")
        print(corrected_text)
    else:
        print(f"在 Neo4j 中找不到與 {ocr_data['course_name']} 和 {ocr_data['student_name']} 相關的資料")

# 5. 執行範例
if __name__ == "__main__":
    # 假設 OCR 提取出的數據
    ocr_data = {
        'student_name': '王小明',
        'course_name': '數學',
        'period': '第一節'
    }

    # OCR 輸出的文本
    ocr_text = "王小明，術學，第一節"

    # 執行主流程，查詢 Neo4j 並使用 ChatGPT 修正結果
    main(ocr_text, ocr_data)
