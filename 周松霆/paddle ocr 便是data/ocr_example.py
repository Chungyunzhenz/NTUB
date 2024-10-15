from paddleocr import PaddleOCR, draw_ocr
from matplotlib import pyplot as plt
import cv2
import os

# 初始化OCR模型
ocr = PaddleOCR(use_angle_cls=True, lang='ch')  # 設置語言為中文

# 載入圖像
image_path = 'images/input_image.jpg'
image = cv2.imread(image_path)

# 進行OCR識別
result = ocr.ocr(image_path, cls=True)

# 打印結果
for line in result:
    print(line)

# 畫出識別結果
boxes = [elements[0] for elements in result[0]]
txts = [elements[1][0] for elements in result[0]]
scores = [elements[1][1] for elements in result[0]]

# 使用draw_ocr畫出識別結果
image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
im_show = draw_ocr(image, boxes, txts, scores, font_path='path_to_your_font.ttf')

# 顯示結果
plt.imshow(im_show)
plt.axis('off')
plt.show()
