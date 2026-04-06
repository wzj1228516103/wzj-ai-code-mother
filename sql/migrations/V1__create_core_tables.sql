-- Migration: create core tables for wzj-ai-code-mother
-- Dialect: MySQL

CREATE DATABASE IF NOT EXISTS `wzj_ai_code` DEFAULT CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
USE `wzj_ai_code`;

-- user table
CREATE TABLE IF NOT EXISTS `user` (
  `id` BIGINT NOT NULL PRIMARY KEY,
  `userAccount` VARCHAR(256) NOT NULL,
  `userPassword` VARCHAR(512) NOT NULL,
  `userName` VARCHAR(256),
  `userAvatar` VARCHAR(1024),
  `userProfile` VARCHAR(512),
  `userRole` VARCHAR(256) NOT NULL DEFAULT 'user',
  `editTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updateTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `isDelete` TINYINT NOT NULL DEFAULT 0,
  UNIQUE KEY `uk_userAccount` (`userAccount`),
  INDEX `idx_userName` (`userName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- app table
CREATE TABLE IF NOT EXISTS `app` (
  `id` BIGINT NOT NULL PRIMARY KEY,
  `appName` VARCHAR(256),
  `cover` VARCHAR(512),
  `initPrompt` TEXT,
  `codeGenType` VARCHAR(64),
  `deployKey` VARCHAR(64),
  `deployedTime` DATETIME,
  `priority` INT NOT NULL DEFAULT 0,
  `userId` BIGINT NOT NULL,
  `editTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updateTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `isDelete` TINYINT NOT NULL DEFAULT 0,
  UNIQUE KEY `uk_deployKey` (`deployKey`),
  INDEX `idx_appName` (`appName`),
  INDEX `idx_userId` (`userId`),
  CONSTRAINT `fk_app_user` FOREIGN KEY (`userId`) REFERENCES `user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- chat_history table
CREATE TABLE IF NOT EXISTS `chat_history` (
  `id` BIGINT NOT NULL PRIMARY KEY,
  `message` TEXT NOT NULL,
  `messageType` VARCHAR(32) NOT NULL,
  `appId` BIGINT NOT NULL,
  `userId` BIGINT NOT NULL,
  `createTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updateTime` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `isDelete` TINYINT NOT NULL DEFAULT 0,
  INDEX `idx_appId` (`appId`),
  INDEX `idx_createTime` (`createTime`),
  INDEX `idx_appId_createTime` (`appId`, `createTime`),
  CONSTRAINT `fk_chat_app` FOREIGN KEY (`appId`) REFERENCES `app`(`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_chat_user` FOREIGN KEY (`userId`) REFERENCES `user`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- sample seed: admin user (replace password with hashed value)
INSERT INTO `user` (`id`, `userAccount`, `userPassword`, `userName`, `userRole`, `createTime`) VALUES
(1000000000000000001, 'admin', '<replace-with-hashed-password>', 'admin', 'admin', NOW());

