import requests
from datetime import datetime

def upload_image(image_path):
    url = 'http://127.0.0.1:5000/upload_image'
    files = {'image': open(image_path, 'rb')}
    
    response = requests.post(url, files=files)
    
    if response.status_code == 200:
        print('Image uploaded successfully')
    else:
        print('Failed to upload image')

if __name__ == '__main__':
    # 替换为你的图片路径
    image_path = 'D:/NTUB/zctの資料存放區/sql區/imageuploads.png'
    upload_image(image_path)
