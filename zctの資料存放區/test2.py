import cv2
import numpy as np
from PIL import Image
import pytesseract
import xml.etree.ElementTree as ET

# 确保这里的路径指向你的Tesseract安装目录
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
# 注意：这里的配置仅在需要时使用，如果Tesseract和tessdata配置正确，可能不需要额外的tessdata_dir配置
tessdata_dir_config = '--tessdata-dir "C:\\Program Files\\Tesseract-OCR\\tessdata"'
lang = 'chi_tra'  # 使用繁体中文

# 检查图像是否能被正确读取
image_path = 'G:/263_0.jpg'
image = cv2.imread(image_path)
if image is None:
    print(f"无法加载图像: {image_path}")
    exit()

gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
_, threshold = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (2, 2))
cleaned = cv2.morphologyEx(threshold, cv2.MORPH_CLOSE, kernel, iterations=1)
contours, hierarchy = cv2.findContours(cleaned, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

root = ET.Element("document")

for contour in contours:
    [x, y, w, h] = cv2.boundingRect(contour)
    cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
    roi = gray[y:y + h, x:x + w]  # 使用灰度图像来提高OCR的准确性
    pil_image = Image.fromarray(roi)
    text = pytesseract.image_to_string(pil_image, lang=lang, config=tessdata_dir_config)

    if text.strip() != '':  # 仅添加包含文本的元素
        text_element = ET.SubElement(root, "text")
        text_element.set("x", str(x))
        text_element.set("y", str(y))
        text_element.set("width", str(w))
        text_element.set("height", str(h))
        text_element.text = text

# 尝试保存图像和XML文件，检查是否有权限问题
try:
    cv2.imwrite('annotated_image.jpg', image)
    tree = ET.ElementTree(root)
    tree.write("output.xml", encoding="utf-8", xml_declaration=True)
    print("处理完成，已生成XML和标注图像。")
except IOError as e:
    print(f"文件写入错误: {e}")
