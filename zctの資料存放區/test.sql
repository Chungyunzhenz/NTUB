-- 建立資料庫
CREATE DATABASE 學生資料庫;

-- 使用該資料庫
USE 學生資料庫;

-- 建立圖片資料表
CREATE TABLE 圖片 (
    圖片ID INT PRIMARY KEY AUTO_INCREMENT,
    學號 INT,
    圖片類型 VARCHAR(50),
    圖片檔名 VARCHAR(100)
);

-- 建立學生資料表
CREATE TABLE 學生 (
    學號 INT PRIMARY KEY,
    學生姓名 VARCHAR(50),
    電話 VARCHAR(20),
    生日 DATE,
    身分證字號 VARCHAR(20)
);

-- 建立外鍵關係
ALTER TABLE 圖片
ADD CONSTRAINT fk_學號
FOREIGN KEY (學號) REFERENCES 學生(學號);
