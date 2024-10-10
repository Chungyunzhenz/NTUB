import json
from PIL import Image, ImageDraw, ImageFont
import matplotlib.pyplot as plt

# 讀取 JSON 檔
with open('C:/Users/zct/Documents/GitHub/NTUB/zctの資料存放區/sql區/data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# 假設我們有一個空白的背景圖片或設置圖片大小
image_width = 1200
image_height = 1500
image = Image.new("RGB", (image_width, image_height), "white")
draw = ImageDraw.Draw(image)

# 載入中文字體（需要替換成你系統中的字體檔案路徑）
font_path = "C:/Windows/Fonts/mingliu.ttc"  # SimHei 是常見的黑體字
font = ImageFont.truetype(font_path, 20)  # 字體大小可調整

# 繪製每個文本的框架和內容
for entry in data:
    # 確保座標轉換為 tuple
    top_left = tuple(entry['box']['top_left'])
    bottom_right = tuple(entry['box']['bottom_right'])
    text = entry['text']
    
    # 繪製矩形框
    
    
    # 在框的上方或者框內繪製文字，使用支持中文字體的 font
    draw.text((top_left[0], top_left[1] - 30), text, font=font, fill="black")

# 使用 Matplotlib 顯示結果
plt.figure(figsize=(10, 15))
plt.imshow(image)
plt.axis('off')  # 不顯示坐標軸
plt.show()
