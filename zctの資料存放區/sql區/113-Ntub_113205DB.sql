-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- 主機： 140.131.114.242
-- 產生時間： 
-- 伺服器版本： 8.0.39-0ubuntu0.22.04.1
-- PHP 版本： 7.3.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


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

DROP TABLE IF EXISTS `announcement`;
CREATE TABLE `announcement` (
  `id` int NOT NULL,
  `Purpose` varchar(4096) NOT NULL,
  `content` varchar(4096) DEFAULT NULL,
  `sender` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `history_records`
--

DROP TABLE IF EXISTS `history_records`;
CREATE TABLE `history_records` (
  `id` int NOT NULL,
  `academic_year` varchar(255) NOT NULL,
  `period` varchar(255) NOT NULL,
  `date` date NOT NULL,
  `course_name` varchar(255) NOT NULL,
  `leave_reason` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `images`
--

DROP TABLE IF EXISTS `images`;
CREATE TABLE `images` (
  `id` int NOT NULL,
  `code` varchar(255) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `image` longblob
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `ImageUploads`
--

DROP TABLE IF EXISTS `ImageUploads`;
CREATE TABLE `ImageUploads` (
  `id` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Image` longblob NOT NULL,
  `UploadDate` datetime NOT NULL,
  `UploadedBy` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `state` enum('upload finish','upload fail','rejrct','error','success') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- 觸發器 `ImageUploads`
--
DROP TRIGGER IF EXISTS `GenerateID1`;
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

DROP TABLE IF EXISTS `json_data`;
CREATE TABLE `json_data` (
  `id` varchar(1024) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `data` json NOT NULL,
  `UploadDate` date NOT NULL,
  `UploadedBy` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `ner_results`
--

DROP TABLE IF EXISTS `ner_results`;
CREATE TABLE `ner_results` (
  `id` int NOT NULL,
  `sentence` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `ner_result` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `entity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `entity_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `ReviewProgress`
--

DROP TABLE IF EXISTS `ReviewProgress`;
CREATE TABLE `ReviewProgress` (
  `id` int NOT NULL,
  `submission_date` date NOT NULL,
  `academic_year` int NOT NULL,
  `period` int NOT NULL,
  `course_name` varchar(100) NOT NULL,
  `leave_reason` varchar(100) NOT NULL,
  `title` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `review_status` enum('審查中','通過','退回') NOT NULL DEFAULT '審查中',
  `return_reason` text,
  `returned_by` enum('teacher','ta') DEFAULT NULL,
  `reviewer` varchar(100) DEFAULT NULL,
  `review_date` date DEFAULT NULL,
  `user_role` enum('teacher','ta','admin') NOT NULL,
  `teacher_comments` text,
  `ta_comments` text,
  `course_info` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `UserImages`
--

DROP TABLE IF EXISTS `UserImages`;
CREATE TABLE `UserImages` (
  `image_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `UserInfo`
--

DROP TABLE IF EXISTS `UserInfo`;
CREATE TABLE `UserInfo` (
  `user_id` int NOT NULL,
  `verification_code` char(36) DEFAULT NULL,
  `user_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `other_info` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `Users`
--

DROP TABLE IF EXISTS `Users`;
CREATE TABLE `Users` (
  `NationalID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Phone` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `BirthDate` date NOT NULL,
  `StudentID` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Role` enum('老師','助教','管理員','學生') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Academic` enum('四技','二技','五專','夜四技','夜二技','空中大學') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Department` enum('會計資訊系','財務金融系','財政稅務系','國際商務系','應用外語系','企業管理系','資訊管理系','數位多媒體設計系','商業設計管理系','創意科技與產品設計系') CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `line_id` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `UserSessions`
--

DROP TABLE IF EXISTS `UserSessions`;
CREATE TABLE `UserSessions` (
  `session_id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `verification_code` char(36) DEFAULT NULL,
  `session_active` tinyint(1) DEFAULT '1',
  `line_user_id` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `user_messages`
--

DROP TABLE IF EXISTS `user_messages`;
CREATE TABLE `user_messages` (
  `id` int NOT NULL,
  `user_id` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `message` text,
  `timestamp` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `VerificationCodes`
--

DROP TABLE IF EXISTS `VerificationCodes`;
CREATE TABLE `VerificationCodes` (
  `verification_code` char(36) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- 資料表結構 `WordUploads`
--

DROP TABLE IF EXISTS `WordUploads`;
CREATE TABLE `WordUploads` (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  `Document` longblob NOT NULL,
  `UploadDate` date NOT NULL,
  `UploadedBy` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- 觸發器 `WordUploads`
--
DROP TRIGGER IF EXISTS `GenerateID2`;
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
  ADD PRIMARY KEY (`id`),
  ADD KEY `announcement_fk` (`sender`);

--
-- 資料表索引 `history_records`
--
ALTER TABLE `history_records`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `images`
--
ALTER TABLE `images`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `ImageUploads`
--
ALTER TABLE `ImageUploads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `UploadedBy` (`UploadedBy`);

--
-- 資料表索引 `json_data`
--
ALTER TABLE `json_data`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `id` (`id`),
  ADD KEY `json_data_fk` (`UploadedBy`);

--
-- 資料表索引 `ner_results`
--
ALTER TABLE `ner_results`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `ReviewProgress`
--
ALTER TABLE `ReviewProgress`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `UserImages`
--
ALTER TABLE `UserImages`
  ADD PRIMARY KEY (`image_id`),
  ADD KEY `user_id` (`user_id`);

--
-- 資料表索引 `UserInfo`
--
ALTER TABLE `UserInfo`
  ADD PRIMARY KEY (`user_id`),
  ADD KEY `verification_code` (`verification_code`);

--
-- 資料表索引 `Users`
--
ALTER TABLE `Users`
  ADD PRIMARY KEY (`NationalID`),
  ADD UNIQUE KEY `StudentID` (`NationalID`),
  ADD UNIQUE KEY `NationalID` (`StudentID`),
  ADD KEY `idx_line_id` (`line_id`);

--
-- 資料表索引 `UserSessions`
--
ALTER TABLE `UserSessions`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `user_id` (`user_id`);

--
-- 資料表索引 `user_messages`
--
ALTER TABLE `user_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_messages_fk` (`user_id`);

--
-- 資料表索引 `VerificationCodes`
--
ALTER TABLE `VerificationCodes`
  ADD PRIMARY KEY (`verification_code`);

--
-- 資料表索引 `WordUploads`
--
ALTER TABLE `WordUploads`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_id` (`id`),
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
-- 使用資料表自動遞增(AUTO_INCREMENT) `history_records`
--
ALTER TABLE `history_records`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `images`
--
ALTER TABLE `images`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `ner_results`
--
ALTER TABLE `ner_results`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `ReviewProgress`
--
ALTER TABLE `ReviewProgress`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `UserImages`
--
ALTER TABLE `UserImages`
  MODIFY `image_id` int NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `UserInfo`
--
ALTER TABLE `UserInfo`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `UserSessions`
--
ALTER TABLE `UserSessions`
  MODIFY `session_id` int NOT NULL AUTO_INCREMENT;

--
-- 使用資料表自動遞增(AUTO_INCREMENT) `user_messages`
--
ALTER TABLE `user_messages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- 已傾印資料表的限制式
--

--
-- 資料表的限制式 `announcement`
--
ALTER TABLE `announcement`
  ADD CONSTRAINT `announcement_fk` FOREIGN KEY (`sender`) REFERENCES `Users` (`NationalID`);

--
-- 資料表的限制式 `ImageUploads`
--
ALTER TABLE `ImageUploads`
  ADD CONSTRAINT `ImageUploads_ibfk_1` FOREIGN KEY (`UploadedBy`) REFERENCES `Users` (`NationalID`);

--
-- 資料表的限制式 `json_data`
--
ALTER TABLE `json_data`
  ADD CONSTRAINT `json_data_fk` FOREIGN KEY (`UploadedBy`) REFERENCES `Users` (`NationalID`),
  ADD CONSTRAINT `json_data_fk2` FOREIGN KEY (`id`) REFERENCES `ImageUploads` (`id`);

--
-- 資料表的限制式 `UserImages`
--
ALTER TABLE `UserImages`
  ADD CONSTRAINT `UserImages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `UserInfo` (`user_id`);

--
-- 資料表的限制式 `UserInfo`
--
ALTER TABLE `UserInfo`
  ADD CONSTRAINT `UserInfo_ibfk_1` FOREIGN KEY (`verification_code`) REFERENCES `VerificationCodes` (`verification_code`);

--
-- 資料表的限制式 `UserSessions`
--
ALTER TABLE `UserSessions`
  ADD CONSTRAINT `UserSessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `UserInfo` (`user_id`);

--
-- 資料表的限制式 `user_messages`
--
ALTER TABLE `user_messages`
  ADD CONSTRAINT `user_messages_fk` FOREIGN KEY (`user_id`) REFERENCES `Users` (`line_id`);

--
-- 資料表的限制式 `WordUploads`
--
ALTER TABLE `WordUploads`
  ADD CONSTRAINT `WordUploads_fk1` FOREIGN KEY (`UploadedBy`) REFERENCES `Users` (`NationalID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
