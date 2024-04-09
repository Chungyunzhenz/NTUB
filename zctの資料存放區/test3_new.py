import cv2
import numpy as np

image_path = 'G:/287.jpg'
image = cv2.imread(image_path)
if image is None:
    print(f"无法加载图像: {image_path}")
    exit()

# 图像预处理
gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
blurred = cv2.GaussianBlur(gray, (5, 5), 0)
_, thresh = cv2.threshold(blurred, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

# 边缘检测
edges = cv2.Canny(thresh, 50, 150, apertureSize=3)

# 形态学变换
kernel = np.ones((5, 5), np.uint8)
dilated = cv2.dilate(edges, kernel, iterations=2)

# 寻找轮廓
contours, hierarchy = cv2.findContours(dilated, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# 寻找最大的轮廓（假设最大的轮廓为包含所有文字的表格）
if contours:
    max_contour = max(contours, key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(max_contour)
    cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)

# 显示并保存结果图像
cv2.imshow('Table Boundaries', image)
cv2.imwrite('optimized_table_boundaries.jpg', image)
cv2.waitKey(0)
cv2.destroyAllWindows()
