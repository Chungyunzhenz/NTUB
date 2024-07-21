import pandas as pd

def xlsx_to_json(input_file_path, output_file_path):
    # 使用 pandas 讀取 Excel 文件
    df = pd.read_excel(input_file_path, sheet_name=0, header=0)

    # 填補合併儲存格的空缺值
    df.ffill(inplace=True)

    # 將 DataFrame 轉換為 JSON 格式
    # orient='records' 表示每個記錄作為 JSON 中的物件
    df.to_json(output_file_path, orient='records', force_ascii=False, indent=4)

# 輸入和輸出文件的路徑
input_path = "C:/Users/zct/Documents/GitHub/NTUB/zctの資料存放區/測試輸出/263_0_繁體版.xlsx"
output_path = 'output3.json'

# 呼叫函數進行轉換
xlsx_to_json(input_path, output_path)
