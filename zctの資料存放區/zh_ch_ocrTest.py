from wired_table_rec import WiredTableRecognition


table_rec = WiredTableRecognition()

img_path = "c:/Users/zct/Documents/GitHub/NTUB/zctの資料存放區/測試資料集一/263_0.jpg"
table_str, elapse = table_rec(img_path)
print(table_str)
print(elapse)