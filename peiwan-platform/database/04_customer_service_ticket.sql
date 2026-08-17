-- 客服工单增量（MySQL 8.0+）
-- 前置条件：目标数据库已具备当前 V51 表结构。
-- 可重复执行。

USE `peiwan_platform`;
SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `pw_customer_service_ticket` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `ticket_no` VARCHAR(40) NOT NULL,
  `user_id` BIGINT NOT NULL,
  `order_id` BIGINT NULL,
  `category` VARCHAR(32) NOT NULL,
  `subject` VARCHAR(120) NOT NULL,
  `ticket_status` VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  `priority` VARCHAR(16) NOT NULL DEFAULT 'NORMAL',
  `assigned_admin_id` BIGINT NULL,
  `admin_unread_count` INT NOT NULL DEFAULT 0,
  `customer_unread_count` INT NOT NULL DEFAULT 0,
  `last_message_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` TIMESTAMP NULL,
  `closed_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_customer_service_ticket_no` (`ticket_no`),
  KEY `idx_customer_service_ticket_user` (`user_id`, `id`),
  KEY `idx_customer_service_ticket_status` (`ticket_status`, `last_message_at`),
  KEY `idx_customer_service_ticket_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `pw_customer_service_message` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `ticket_id` BIGINT NOT NULL,
  `sender_id` BIGINT NOT NULL,
  `sender_role` VARCHAR(16) NOT NULL,
  `content` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_customer_service_message_ticket` (`ticket_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `sys_menu`
  (`id`,`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
VALUES
  (300,163,'MENU','CustomerServiceTicket','customer-service-ticket','/business/customer-service-ticket','客服工单','ri:customer-service-2-line',NULL,5,0,1,1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
  (301,300,'BUTTON','CustomerServiceTicketList',NULL,NULL,'查询客服工单',NULL,'business:customer-service:list',1,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
  (302,300,'BUTTON','CustomerServiceTicketReply',NULL,NULL,'回复客服工单',NULL,'business:customer-service:reply',2,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP),
  (303,300,'BUTTON','CustomerServiceTicketStatus',NULL,NULL,'更新工单状态',NULL,'business:customer-service:status',3,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)
ON DUPLICATE KEY UPDATE
  `parent_id`=VALUES(`parent_id`),`type`=VALUES(`type`),`path`=VALUES(`path`),
  `component`=VALUES(`component`),`title`=VALUES(`title`),`icon`=VALUES(`icon`),
  `auth_mark`=VALUES(`auth_mark`),`sort_no`=VALUES(`sort_no`),`hidden`=VALUES(`hidden`),
  `enabled`=VALUES(`enabled`),`keep_alive`=VALUES(`keep_alive`),`updated_at`=CURRENT_TIMESTAMP;

INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`)
SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`id` IN (300,301,302,303)
WHERE r.`code`='admin';

SELECT 'customer_service_ticket_ready' AS `result`;
