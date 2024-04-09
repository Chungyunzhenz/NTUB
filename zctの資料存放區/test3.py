import cv2
import numpy as np

image_path = 'G:/263_0.jpg'
image = cv2.imread(image_path)
if image is None:
    print(f"无法加载图像: {image_path}")
    exit()

# 应用高斯滤波去除噪声
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
blurred = cv2.GaussianBlur(gray, (5, 5), 0)

# Canny边缘检测
edges = cv2.Canny(blurred, 50, 150, apertureSize=3)

# 应用形态学变换强化线条
kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (5, 5))
dilated = cv2.dilate(edges, kernel, iterations=2)

# 查找轮廓
contours, hierarchy = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# 绘制表格边界
for contour in contours:
    perimeter = cv2.arcLength(contour, True)
    approx = cv2.approxPolyDP(contour, 0.02 * perimeter, True)
    if len(approx) == 4:  # 假定表格边界近似为四边形
        cv2.drawContours(image, [approx], -1, (0, 255, 0), 2)

# 显示并保存结果图像
cv2.imshow('Table Boundaries', image)
cv2.imwrite('table_boundaries.jpg', image)
cv2.waitKey(0)
cv2.destroyAllWindows()
