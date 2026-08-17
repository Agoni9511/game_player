-- 陪玩平台 MySQL 数据库初始化脚本
-- 适用版本：MySQL 8.0+
-- 推荐数据库名：peiwan_platform

CREATE DATABASE IF NOT EXISTS `peiwan_platform`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `peiwan_platform`;

-- 推荐为应用创建独立账号，不要让生产应用直接使用 root。
-- 执行前请把 CHANGE_ME_TO_A_STRONG_PASSWORD 替换为高强度随机密码，
-- 并按实际部署方式把 '%' 改成后端服务器的固定 IP（更安全）。
-- CREATE USER IF NOT EXISTS 'peiwan_app'@'%'
--   IDENTIFIED BY 'CHANGE_ME_TO_A_STRONG_PASSWORD';
-- GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP
--   ON `peiwan_platform`.* TO 'peiwan_app'@'%';
-- FLUSH PRIVILEGES;

-- 创建数据库后，请继续执行 database/01_full_schema.sql 创建全部业务表，
-- 再执行 database/02_seed_menu_data.sql 初始化菜单、按钮权限和角色授权。
-- 该全量脚本仅用于空数据库首次初始化；已有数据库不要重复执行。
