# Cell 1: 導入所需庫
import numpy as np
from tensorflow.keras.models import Model
from tensorflow.keras.layers import Input, Dense, Conv2D, MaxPooling2D, Flatten, Lambda
from tensorflow.keras.optimizers import Adam
from tensorflow.keras import backend as K
import cv2
import os
# Cell 2: 定義基礎卷積神經網絡
def create_base_network(input_shape):
    input = Input(shape=input_shape)
    x = Conv2D(32, (3, 3), activation='relu')(input)
    x = MaxPooling2D(pool_size=(2, 2))(x)
    x = Conv2D(64, (3, 3), activation='relu')(x)
    x = MaxPooling2D(pool_size=(2, 2))(x)
    x = Flatten()(x)
    x = Dense(128, activation='relu')(x)
    return Model(input, x)
# Cell 3: 定義歐幾里得距離函數
def euclidean_distance(vects):
    x, y = vects
    sum_square = K.sum(K.square(x - y), axis=1, keepdims=True)
    return K.sqrt(K.maximum(sum_square, K.epsilon()))
# Cell 4: 定義對比損失函數
def contrastive_loss(y_true, y_pred):
    margin = 1.0
    square_pred = K.square(y_pred)
    margin_square = K.square(K.maximum(margin - y_pred, 0))
    return K.mean(y_true * square_pred + (1 - y_true) * margin_square)
# Cell 5: 圖像預處理函數
def load_and_preprocess_image(image_path, img_width=224, img_height=224):
    # 讀取圖像 (灰度模式)
    img = cv2.imread(image_path, cv2.IMREAD_GRAYSCALE)

    # 調整圖像大小到 224x224
    img_resized = cv2.resize(img, (img_width, img_height))

    # 歸一化 [0, 1]
    img_resized = img_resized.astype('float32') / 255.0

    # 增加通道維度
    img_resized = np.expand_dims(img_resized, axis=-1)

    return img_resized
# Cell 6: 載入圖像資料
img_height, img_width = 224, 224
input_shape = (img_height, img_width, 1)  # 對應新的圖像尺寸
# Cell 7: 創建基礎網絡
base_network = create_base_network(input_shape)
# Cell 8: 創建孿生網絡的輸入層和計算距離
input_a = Input(shape=input_shape)
input_b = Input(shape=input_shape)

# 基礎網絡處理兩個輸入
processed_a = base_network(input_a)
processed_b = base_network(input_b)

# 計算歐幾里得距離
distance = Lambda(euclidean_distance, output_shape=(1,))([processed_a, processed_b])
# Cell 9: 定義完整模型
model = Model([input_a, input_b], distance)

# 編譯模型
model.compile(loss=contrastive_loss, optimizer=Adam(), metrics=['accuracy'])
# Cell 10: 顯示模型架構
model.summary()
# Cell 11: 使用圖像進行預測
# 載入你的 'ocr_white_background_red_box_result.jpg' 圖片
ocr_image_path = 'ocr_white_background_red_box_result.jpg'
ocr_image = load_and_preprocess_image(ocr_image_path)

# 載入另一張圖像進行比較（例如另一張請假單或選課單）
reference_image_path = '263_0.jpg'  # 替換成你想比較的圖像路徑
reference_image = load_and_preprocess_image(reference_image_path)

# 使用模型進行預測
prediction = model.predict([np.expand_dims(ocr_image, axis=0), np.expand_dims(reference_image, axis=0)])

# 打印結果
print(f"兩張圖片的距離: {prediction[0][0]}")
if prediction < 0.5:
    print("這兩張圖片相似（可能是同類型表單）")
else:
    print("這兩張圖片不同（可能是不同類型表單）")
