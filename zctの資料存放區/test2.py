import cv2
import numpy as np
from PIL import Image
import pytesseract
import xml.etree.ElementTree as ET
import os
from docx import Document

# 确保这里的路径指向你的Tesseract安装目录
pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'
# 如果Tesseract和tessdata配置正确，可能不需要额外的tessdata_dir配置
tessdata_dir_config = '--tessdata-dir "C:\\Program Files\\Tesseract-OCR\\tessdata"'
lang = 'chi_tra+eng'  # 支持繁体中文和英文

image_path = 'G:/263_0.jpg'
image = cv2.imread(image_path)
if image is None:
    print(f"无法加载图像: {image_path}")
    exit()

# 图像预处理以提高OCR识别准确度
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
gray = cv2.medianBlur(gray, 3)
_, threshold = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

# 这里插入表格识别和解析的代码
# 注意：表格识别和解析需要根据具体情况定制

root = ET.Element("document")
doc = Document()  # 创建WORD文档对象

# 这里是处理非表格文本的代码示例
# 假设所有识别的文本暂时都当作非表格文本处理
text = pytesseract.image_to_string(threshold, lang=lang, config=tessdata_dir_config)
doc.add_paragraph(text)  # 向WORD文档添加整个图像的文本

# 保存处理结果
annotated_image_path = 'annotated_image.jpg'
output_xml_path = "output.xml"
output_docx_path = "output.docx"  # WORD文件保存路径

try:
    cv2.imwrite(annotated_image_path, image)
    # XML和WORD文件的写入
    tree = ET.ElementTree(root)
    tree.write(output_xml_path, encoding="utf-8", xml_declaration=True)
    doc.save(output_docx_path)  # 保存WORD文档
    print(f"处理完成，已生成XML、WORD文档和标注图像。")
    print(f"标注图像已保存至: {os.path.abspath(annotated_image_path)}")
    print(f"XML文件已保存至: {os.path.abspath(output_xml_path)}")
    print(f"WORD文档已保存至: {os.path.abspath(output_docx_path)}")
except IOError as e:
    print(f"文件写入错误: {e}")