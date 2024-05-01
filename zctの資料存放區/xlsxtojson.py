import pandas as pd

def xlsx_to_json(input_file_path, output_file_path):
    # 使用pandas讀取Excel文件
    df = pd.read_excel(input_file_path)

    # 將DataFrame轉換為JSON格式
    # orient='records'表示列表中包含記錄（可以根據需要更改）
    df.to_json(output_file_path, orient='records', force_ascii=False, indent=4)

# 輸入和輸出文件的路徑
input_path = "C:/Users/zct/Documents/GitHub/NTUB/zctの資料存放區/測試輸出/263_0_繁體版.xlsx"
output_path = 'output.json'

# 呼叫函數進行轉換
xlsx_to_json(input_path, output_path)
