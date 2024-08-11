from ckiptagger import WS, POS, NER

# 載入模型
ws = WS("./data")

# 定義自訂字典
custom_dict = {
    "台灣大學": 1,
    "人工智慧": 1,
    "機器學習": 1
}

# 分詞範例
sentence_list = [
    "台灣大學正在發展人工智慧與機器學習技術。"
]

# 使用自訂字典進行分詞
word_sentence_list = ws(
    sentence_list,
    recommend_dictionary=custom_dict
)

# 輸出結果
print(word_sentence_list)

# 關閉 CKIPtagger
ws.close()
