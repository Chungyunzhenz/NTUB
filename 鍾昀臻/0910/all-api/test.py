import pymysql

db_config = {
    'host': '140.131.114.242',
    'user': 'ntub_finalProject',
    'password': 'Nttub$Eas0nZct',
    'database': '113-Ntub_113205DB'
}

try:
    connection = pymysql.connect(**db_config)
    print("資料庫連接成功")
    connection.close()
except pymysql.MySQLError as e:
    print(f"資料庫連接失敗: {str(e)}")
