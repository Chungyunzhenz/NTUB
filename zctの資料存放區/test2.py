import cv2
import numpy as np  # 导入numpy库

# 加载图像并预处理
# 确保使用一个有效的路径，并且路径中不包含特殊字符
image_path = r"g:/263_0.jpg"  # 更新为有效的路径
image = cv2.imread(image_path)  # 使用原始字符串

if image is None:
    print(f"Error: Unable to load image at {image_path}")
else:
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    thresh = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]

    # 定位表格区域
    edges = cv2.Canny(thresh, 50, 150, apertureSize=3)
    lines = cv2.HoughLines(edges, 1, np.pi/180, 200)
    if lines is not None:
        for line in lines:
            rho, theta = line[0]  # 正确解包
            a = np.cos(theta) * rho
            b = np.sin(theta) * rho
            x0 = a
            y0 = b
            x1 = int(x0 + 1000*(-b))
            y1 = int(y0 + 1000*(a))
            x2 = int(x0 - 1000*(-b))
            y2 = int(y0 - 1000*(a))
            cv2.line(image, (x1, y1), (x2, y2), (0, 0, 255), 2)

    cv2.imshow('Hough Lines', image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()
