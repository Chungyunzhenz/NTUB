import cv2
import numpy as np

image_path = 'G:/263_0.jpg'
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

# 寻找最大的轮廓
if contours:
    max_contour = max(contours, key=cv2.contourArea)
    x, y, w, h = cv2.boundingRect(max_contour)
    # 裁剪图像
    cropped_image = image[y:y+h, x:x+w]

    # 如果需要，可以调整裁剪后图像的大小来满足特定的长宽比要求，例如保持原图比例或设置为固定大小
    # 这里以保持原图比例为例
    # cropped_image = cv2.resize(cropped_image, (desired_width, desired_height), interpolation=cv2.INTER_AREA)

    cv2.imshow('Cropped Table', cropped_image)
    cv2.imwrite('cropped_table.jpg', cropped_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
