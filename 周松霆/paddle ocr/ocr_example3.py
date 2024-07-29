from paddleocr import PaddleOCR, draw_ocr
from matplotlib import pyplot as plt
import cv2

# 初始化OCR模型
ocr = PaddleOCR(use_angle_cls=True, lang='ch')  # 設置語言為中文

# 載入圖像
image_path = 'input_image.jpg'  # 確保您的圖片文件在此路徑下
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
font_path = './simhei.ttf'  # 確保字體文件與腳本在同一目錄中
im_show = draw_ocr(image, boxes, txts, scores, font_path=font_path)

# 顯示結果
plt.imshow(im_show)
plt.axis('off')
plt.show()

# 保存結果圖片
cv2.imwrite('ocr_result.jpg', cv2.cvtColor(im_show, cv2.COLOR_RGB2BGR))

# 打印標示框坐標 (x1, y1) 與 (x2, y2)
print("\n標示框的坐標 (x1, y1) 與 (x2, y2):")
for i, box in enumerate(boxes):
    x1, y1 = box[0]
    x2, y2 = box[2]
    print(f"文字: {txts[i]} -> (x1, y1) = ({x1:.1f}, {y1:.1f}), (x2, y2) = ({x2:.1f}, {y2:.1f})")
