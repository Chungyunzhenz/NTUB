from paddleocr import PaddleOCR, draw_ocr
from matplotlib import pyplot as plt
import cv2
import numpy as np
import json

# 初始化OCR模型
ocr = PaddleOCR(use_angle_cls=True, lang='ch')  # 设置语言为中文

# 载入图像
image_path = 'course_S.jpg'  # 确保图片文件在此路径下
image = cv2.imread(image_path)  # 使用 OpenCV 的 cv2.imread() 函数读入图像。

# 获取图像的宽高
h, w, _ = image.shape

# 创建白色背景图像，尺寸与原图相同
white_background = np.ones((h, w, 3), dtype=np.uint8) * 255  # 生成全白图像

# 进行OCR识别
result = ocr.ocr(image_path, cls=True)

# 打印结果
for line in result:
    print(line)

# 获取文字框和内容
boxes = [elements[0] for elements in result[0]]
txts = [elements[1][0] for elements in result[0]]

# 将每个文字框的内容从原图中剪切，并贴到白色背景图上
ocr_data = []
for i, box in enumerate(boxes):
    # 获取文字框的左上角和右下角坐标
    x1, y1 = map(int, box[0])
    x2, y2 = map(int, box[2])

    # 剪切出原图中文字框中的区域
    cropped = image[y1:y2, x1:x2]

    # 将剪切的区域贴到白色背景上对应位置
    white_background[y1:y2, x1:x2] = cropped

    # 在白色背景上绘制红色框
    cv2.rectangle(white_background, (x1, y1), (x2, y2), (0, 0, 255), 2)  # 红色框，线条宽度为2

    # 保存OCR结果数据到字典中
    ocr_data.append({
        'text': txts[i],
        'box': {
            'top_left': [x1, y1],
            'bottom_right': [x2, y2]
        }
    })

# 将OCR结果保存到JSON文件
json_output_path = 'ocr_result.json'
with open(json_output_path, 'w', encoding='utf-8') as f:
    json.dump(ocr_data, f, ensure_ascii=False, indent=4)  # ensure_ascii=False 保证中文字符正常输出

# 显示最终结果
plt.figure(figsize=(10, 10))
plt.imshow(cv2.cvtColor(white_background, cv2.COLOR_BGR2RGB))
plt.axis('off')
plt.show()

# 保存最终结果图像
cv2.imwrite('ocr_white_background_red_box_result.jpg', white_background)
