import os
import json
from PIL import Image, ImageDraw, ImageFont
import matplotlib.pyplot as plt
import io

# 確保字體路徑存在
font_path = "C:/Windows/Fonts/mingliu.ttc"  # 明體字體，確認此字體存在於系統中
if not os.path.exists(font_path):
    raise OSError(f"字體檔案不存在，請檢查路徑: {font_path}")

# 讀取 JSON 檔
with open('C:/Users/zct/Documents/GitHub/NTUB/zctの資料存放區/sql區/data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 設置圖片大小
image_width = 1200
image_height = 1500
image = Image.new("RGB", (image_width, image_height), "white")
draw = ImageDraw.Draw(image)

# 載入中文字體
font = ImageFont.truetype(font_path, 20)  # 字體大小可調整

# 繪製每個文本的框架和內容
for entry in data:
    top_left = tuple(entry['box']['top_left'])
    bottom_right = tuple(entry['box']['bottom_right'])
    text = entry['text']
    
    # 繪製矩形框
    
    
    # 在框的上方或者框內繪製文字，使用支持中文字體的 font
    draw.text((top_left[0], top_left[1] - 30), text, font=font, fill="black")

# 將圖片存入本地
local_image_path = 'output_image.png'
image.save(local_image_path)
print(f"圖片已儲存至 {local_image_path}")

# 將圖片轉為 long blob 並存入變數
img_byte_arr = io.BytesIO()
image.save(img_byte_arr, format='PNG')
img_blob = img_byte_arr.getvalue()  # 這是存為 long blob 的變數
print(f"圖片已成功轉換為 long blob 格式，大小為: {len(img_blob)} bytes")

# 如果需要在 flask 中存入資料庫，img_blob 可以用作 blob 資料
