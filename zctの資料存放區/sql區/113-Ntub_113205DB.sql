-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- 主機： 140.131.114.242
-- 產生時間： 
-- 伺服器版本： 8.0.36-0ubuntu0.22.04.1
-- PHP 版本： 7.3.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+08:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫： `113-Ntub_113205DB`
--

-- --------------------------------------------------------

--
-- 資料表結構 `announcement`
--

CREATE TABLE `announcement` (
  `id` int NOT NULL,
  `Purpose` varchar(666) NOT NULL,
  `content` varchar(666) DEFAULT NULL,
  `sender` varchar(666) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `ImageUploads`
--

CREATE TABLE `ImageUploads` (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Image` longblob NOT NULL,
  `UploadDate` date NOT NULL,
  `UploadedBy` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `state` varchar(666) COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- 觸發器 `ImageUploads`
--
DELIMITER $$
CREATE TRIGGER `GenerateID1` BEFORE INSERT ON `ImageUploads` FOR EACH ROW BEGIN
    DECLARE random_string VARCHAR(32);
    DECLARE id_exists INT;
    
    REPEAT
        SET random_string = '';
        SET @charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        SET @length = 32;
        
        
        WHILE @length > 0 DO
            SET random_string = CONCAT(random_string, SUBSTRING(@charset, FLOOR(RAND() * LENGTH(@charset) + 1), 1));
            SET @length = @length - 1;
        END WHILE;
        SET NEW.ID = CONCAT(NEW.UploadedBy, '-', DATE_FORMAT(NEW.UploadDate, '%Y%m%d'), '-', random_string,'-IMG');
    
        
        
        SELECT COUNT(*) INTO id_exists FROM ImageUploads WHERE ID = NEW.ID;
    UNTIL id_exists = 0 END REPEAT;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- 資料表結構 `json_data`
--

CREATE TABLE `json_data` (
  `id` bigint UNSIGNED NOT NULL,
  `data` json NOT NULL,
  `UploadDate` date NOT NULL,
  `UploadedBy` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `Users`
--

CREATE TABLE `Users` (
  `StudentID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `BirthDate` date NOT NULL,
  `NationalID` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Role` enum('Teacher','Teaching Assistant','Student','Administrator') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Academic` varchar(555) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Department` varchar(555) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `user_messages`
--

CREATE TABLE `user_messages` (
  `id` int NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `message` text,
  `timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- 傾印資料表的資料 `user_messages`
--



-- --------------------------------------------------------

--
-- 資料表結構 `WordUploads`
--

CREATE TABLE `WordUploads` (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Document` longblob NOT NULL,
  `UploadDate` date NOT NULL,
  `UploadedBy` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- 觸發器 `WordUploads`
--
DELIMITER $$
CREATE TRIGGER `GenerateID2` BEFORE INSERT ON `WordUploads` FOR EACH ROW BEGIN
    DECLARE random_string VARCHAR(32);
    DECLARE id_exists INT;
    
    REPEAT
        SET random_string = '';
        SET @charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        SET @length = 32;
        
        
        WHILE @length > 0 DO
            SET random_string = CONCAT(random_string, SUBSTRING(@charset, FLOOR(RAND() * LENGTH(@charset) + 1), 1));
            SET @length = @length - 1;
        END WHILE;
        
        SET NEW.ID = CONCAT(NEW.UploadedBy, '-', DATE_FORMAT(NEW.UploadDate, '%Y%m%d'), '-', random_string,'-DOC');
        
        
        SELECT COUNT(*) INTO id_exists FROM WordUploads WHERE ID = NEW.ID;
    UNTIL id_exists = 0 END REPEAT;
END
$$
DELIMITER ;

--
-- 已傾印資料表的索引
--

--
-- 資料表索引 `announcement`
--
ALTER TABLE `announcement`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `ImageUploads`
--
ALTER TABLE `ImageUploads`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `unique_id` (`ID`),
  ADD KEY `UploadedBy` (`UploadedBy`);

--
-- 資料表索引 `json_data`
--
ALTER TABLE `json_data`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`),
  ADD KEY `UploadedBy` (`UploadedBy`);

--
-- 資料表索引 `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`StudentID`),
  ADD UNIQUE KEY `StudentID` (`StudentID`),
  ADD UNIQUE KEY `NationalID` (`NationalID`);

--
-- 資料表索引 `user_messages`
--
ALTER TABLE `user_messages`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `WordUploads`
--
ALTER TABLE `WordUploads`
  ADD PRIMARY KEY (`ID`),
  ADD UNIQUE KEY `unique_id` (`ID`),
  ADD KEY `UploadedBy` (`UploadedBy`);

--
-- 在傾印的資料表使用自動遞增(AUTO_INCREMENT)
--

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `announcement`
--
ALTER TABLE `announcement`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `json_data`
--
ALTER TABLE `json_data`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `user_messages`
--
ALTER TABLE `user_messages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- 已傾印資料表的限制式
--

--
-- 資料表的限制式 `ImageUploads`
--
ALTER TABLE `ImageUploads`
  ADD CONSTRAINT `ImageUploads_ibfk_1` FOREIGN KEY (`UploadedBy`) REFERENCES `Users` (`StudentID`);

--
-- 資料表的限制式 `json_data`
--
ALTER TABLE `json_data`
  ADD CONSTRAINT `json_data_ibfk_1` FOREIGN KEY (`UploadedBy`) REFERENCES `Users` (`StudentID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
