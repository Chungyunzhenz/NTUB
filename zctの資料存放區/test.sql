-- 創建資料庫
CREATE DATABASE IF NOT EXISTS SchoolDB;
USE SchoolDB;

-- 創建用戶資料表
CREATE TABLE IF NOT EXISTS Users (
    StudentID VARCHAR(255) PRIMARY KEY,
    Password VARCHAR(255) NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Phone VARCHAR(20),
    BirthDate DATE NOT NULL,
    NationalID VARCHAR(20) NOT NULL,
    Role ENUM('Teacher', 'Teaching Assistant', 'Student', 'Administrator') NOT NULL
);

-- 創建圖檔上傳資料表
CREATE TABLE IF NOT EXISTS ImageUploads (
    ID VARCHAR(255) PRIMARY KEY,
    Image MEDIUMBLOB NOT NULL,
    UploadDate DATE NOT NULL,
    UploadedBy VARCHAR(255) NOT NULL,
    FOREIGN KEY (UploadedBy) REFERENCES Users(StudentID)
);

-- 創建Word檔案上傳資料表
CREATE TABLE IF NOT EXISTS WordUploads (
    ID VARCHAR(255) PRIMARY KEY,
    Document MEDIUMBLOB NOT NULL,
    UploadDate DATE NOT NULL,
    UploadedBy VARCHAR(255) NOT NULL,
    FOREIGN KEY (UploadedBy) REFERENCES Users(StudentID)
);

-- 創建觸發器來自動生成ID
DELIMITER //
CREATE TRIGGER GenerateID1 BEFORE INSERT ON ImageUploads
FOR EACH ROW
BEGIN
    DECLARE random_num INT;
    SET random_num = FLOOR(RAND() * 1000); -- 生成 0 到 999 之間的隨機數
    SET NEW.ID = CONCAT(NEW.UploadedBy, '-', DATE_FORMAT(NEW.UploadDate, '%Y%m%d'), '-', LPAD(random_num, 3, '0'));
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER GenerateID2 BEFORE INSERT ON WordUploads
FOR EACH ROW
BEGIN
    DECLARE random_num INT;
    SET random_num = FLOOR(RAND() * 1000); -- 生成 0 到 999 之間的隨機數
    SET NEW.ID = CONCAT(NEW.UploadedBy, '-', DATE_FORMAT(NEW.UploadDate, '%Y%m%d'), '-', LPAD(random_num, 3, '0'));
END;
//
DELIMITER ;
