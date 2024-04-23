
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
    UNIQUE KEY `unique_id` (`ID`),  -- 添加唯一鍵約束以確保 ID 不重複
    FOREIGN KEY (UploadedBy) REFERENCES Users(StudentID)
);

-- 創建Word檔案上傳資料表
CREATE TABLE IF NOT EXISTS WordUploads (
    ID VARCHAR(255) PRIMARY KEY,
    Document MEDIUMBLOB NOT NULL,
    UploadDate DATE NOT NULL,
    UploadedBy VARCHAR(255) NOT NULL,
    UNIQUE KEY `unique_id` (`ID`),  -- 添加唯一鍵約束以確保 ID 不重複
    FOREIGN KEY (UploadedBy) REFERENCES Users(StudentID)
);

-- 創建觸發器來自動生成ID
DELIMITER //

CREATE TRIGGER GenerateID1 BEFORE INSERT ON ImageUploads
FOR EACH ROW
BEGIN
    DECLARE random_string VARCHAR(32);
    DECLARE id_exists INT;
    
    REPEAT
        SET random_string = '';
        SET @charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        SET @length = 32;
        
        -- 生成隨機字符串
        WHILE @length > 0 DO
            SET random_string = CONCAT(random_string, SUBSTRING(@charset, FLOOR(RAND() * LENGTH(@charset) + 1), 1));
            SET @length = @length - 1;
        END WHILE;
        SET NEW.ID = CONCAT(NEW.UploadedBy, '-', DATE_FORMAT(NEW.UploadDate, '%Y%m%d'), '-', random_string,'-IMG');
    
        
        -- 檢查隨機生成的 ID 是否已存在
        SELECT COUNT(*) INTO id_exists FROM ImageUploads WHERE ID = NEW.ID;
    UNTIL id_exists = 0 END REPEAT;
END;
//

CREATE TRIGGER GenerateID2 BEFORE INSERT ON WordUploads
FOR EACH ROW
BEGIN
    DECLARE random_string VARCHAR(32);
    DECLARE id_exists INT;
    
    REPEAT
        SET random_string = '';
        SET @charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        SET @length = 32;
        
        -- 生成隨機字符串
        WHILE @length > 0 DO
            SET random_string = CONCAT(random_string, SUBSTRING(@charset, FLOOR(RAND() * LENGTH(@charset) + 1), 1));
            SET @length = @length - 1;
        END WHILE;
        
        SET NEW.ID = CONCAT(NEW.UploadedBy, '-', DATE_FORMAT(NEW.UploadDate, '%Y%m%d'), '-', random_string,'-DOC');
        
        -- 檢查隨機生成的 ID 是否已存在
        SELECT COUNT(*) INTO id_exists FROM WordUploads WHERE ID = NEW.ID;
    UNTIL id_exists = 0 END REPEAT;
END;
//

DELIMITER ;