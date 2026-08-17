-- 陪玩平台全量表结构（MySQL 8.0+）
-- 数据库：peiwan_platform
-- 本文件仅创建最终表结构、索引和必要内置角色，不包含演示业务数据。
-- 仅用于空数据库首次初始化；已有业务库请使用经过审核的增量迁移。

CREATE DATABASE IF NOT EXISTS `peiwan_platform` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `peiwan_platform`;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `sys_user`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(64) NOT NULL,
    `password` VARCHAR(100) NOT NULL,
    `nickname` VARCHAR(64) NOT NULL,
    `email` VARCHAR(128),
    `phone` VARCHAR(32),
    `gender` VARCHAR(16),
    `avatar` VARCHAR(512),
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sys_menu`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `parent_id` BIGINT,
    `type` VARCHAR(16) NOT NULL,
    `name` VARCHAR(64) NOT NULL,
    `path` VARCHAR(255),
    `component` VARCHAR(255),
    `title` VARCHAR(64) NOT NULL,
    `icon` VARCHAR(128),
    `auth_mark` VARCHAR(128),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `hidden` TINYINT(1) DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `keep_alive` TINYINT(1) DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_sys_menu_parent` ON `sys_menu`(`parent_id`);
CREATE UNIQUE INDEX `ux_sys_menu_auth_mark` ON `sys_menu`(`auth_mark`);
CREATE TABLE `sys_login_log`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(64),
    `success` TINYINT(1) NOT NULL,
    `ip_address` VARCHAR(64),
    `user_agent` VARCHAR(512),
    `message` VARCHAR(255),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sys_user_role`(
    `user_id` BIGINT NOT NULL,
    `role_id` BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `sys_user_role` ADD CONSTRAINT `CONSTRAINT_6` PRIMARY KEY(`user_id`, `role_id`);
CREATE INDEX `ix_sys_user_role_role` ON `sys_user_role`(`role_id`);
CREATE TABLE `sys_role_menu`(
    `role_id` BIGINT NOT NULL,
    `menu_id` BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `sys_role_menu` ADD CONSTRAINT `CONSTRAINT_65` PRIMARY KEY(`role_id`, `menu_id`);
CREATE INDEX `ix_sys_role_menu_menu` ON `sys_role_menu`(`menu_id`);
CREATE TABLE `sys_role`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(64) NOT NULL,
    `code` VARCHAR(64) NOT NULL,
    `description` VARCHAR(255),
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `built_in` TINYINT(1) DEFAULT 0 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `sys_operation_log`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `operator_id` BIGINT,
    `operation` VARCHAR(128) NOT NULL,
    `target_type` VARCHAR(64) NOT NULL,
    `target_id` VARCHAR(64),
    `detail` VARCHAR(1000),
    `ip_address` VARCHAR(64),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_game`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `game_code` VARCHAR(64) NOT NULL,
    `game_name` VARCHAR(64) NOT NULL,
    `icon_url` VARCHAR(512),
    `cover_url` VARCHAR(512),
    `platform_type` VARCHAR(16) NOT NULL,
    `description` VARCHAR(500),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_game_position`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `game_id` BIGINT NOT NULL,
    `position_code` VARCHAR(64) NOT NULL,
    `position_name` VARCHAR(64) NOT NULL,
    `icon_url` VARCHAR(512),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_order_item`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `product_id` BIGINT NOT NULL,
    `sku_id` BIGINT NOT NULL,
    `product_code` VARCHAR(64) NOT NULL,
    `product_name` VARCHAR(128) NOT NULL,
    `sku_code` VARCHAR(64) NOT NULL,
    `sku_name` VARCHAR(128) NOT NULL,
    `product_type` VARCHAR(32) NOT NULL,
    `unit_price` DECIMAL(12, 2) NOT NULL,
    `quantity` INT NOT NULL,
    `subtotal_amount` DECIMAL(12, 2) NOT NULL,
    `service_snapshot` LONGTEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `pricing_rule_id` BIGINT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_order_item_order` ON `pw_order_item`(`order_id`);
CREATE TABLE `pw_player_level`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `game_id` BIGINT NOT NULL,
    `level_code` VARCHAR(32) NOT NULL,
    `level_name` VARCHAR(64) NOT NULL,
    `description` VARCHAR(255),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_player_level_game` ON `pw_player_level`(`game_id`);
CREATE TABLE `pw_product`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `game_id` BIGINT NOT NULL,
    `category_id` BIGINT NOT NULL,
    `product_code` VARCHAR(64) NOT NULL,
    `product_name` VARCHAR(128) NOT NULL,
    `subtitle` VARCHAR(255),
    `description` VARCHAR(2000),
    `cover_url` VARCHAR(512),
    `product_type` VARCHAR(32) DEFAULT 'SERVICE' NOT NULL,
    `status` VARCHAR(32) DEFAULT 'DRAFT' NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `validity_days` INT,
    `purchase_limit` INT,
    `pricing_mode` VARCHAR(32) DEFAULT 'FIXED_SKU' NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_product_game` ON `pw_product`(`game_id`);
CREATE INDEX `ix_pw_product_category` ON `pw_product`(`category_id`);
CREATE TABLE `pw_player_game_position`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_game_id` BIGINT NOT NULL,
    `position_id` BIGINT NOT NULL,
    `skill_level` VARCHAR(32),
    `is_primary` TINYINT(1) DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_player_tag`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `tag_code` VARCHAR(64) NOT NULL,
    `tag_name` VARCHAR(64) NOT NULL,
    `tag_color` VARCHAR(32),
    `tag_group` VARCHAR(16) DEFAULT 'OTHER' NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_player_tag_rel`(
    `player_id` BIGINT NOT NULL,
    `tag_id` BIGINT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `pw_player_tag_rel` ADD CONSTRAINT `CONSTRAINT_C` PRIMARY KEY(`player_id`, `tag_id`);
CREATE TABLE `pw_player_media`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_id` BIGINT NOT NULL,
    `media_type` VARCHAR(32) NOT NULL,
    `media_url` VARCHAR(512) NOT NULL,
    `thumbnail_url` VARCHAR(512),
    `title` VARCHAR(128),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `audit_status` VARCHAR(16) DEFAULT 'PENDING' NOT NULL,
    `audit_remark` VARCHAR(500),
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_player_media_player` ON `pw_player_media`(`player_id`);
CREATE TABLE `pw_player_audit`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_id` BIGINT NOT NULL,
    `audit_type` VARCHAR(16) NOT NULL,
    `before_status` VARCHAR(16),
    `after_status` VARCHAR(16) NOT NULL,
    `result` VARCHAR(16) NOT NULL,
    `reason` VARCHAR(500),
    `snapshot_data` VARCHAR(4000),
    `auditor_id` BIGINT,
    `audited_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_player_audit_player` ON `pw_player_audit`(`player_id`);
CREATE TABLE `pw_player_status_log`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_id` BIGINT NOT NULL,
    `status_type` VARCHAR(32) NOT NULL,
    `before_value` VARCHAR(32),
    `after_value` VARCHAR(32) NOT NULL,
    `reason` VARCHAR(500),
    `operator_type` VARCHAR(16) NOT NULL,
    `operator_id` BIGINT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_player_status_log_player` ON `pw_player_status_log`(`player_id`);
CREATE TABLE `pw_product_category`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `game_id` BIGINT,
    `parent_id` BIGINT,
    `category_code` VARCHAR(64) NOT NULL,
    `category_name` VARCHAR(64) NOT NULL,
    `icon_url` VARCHAR(512),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_product_category_parent` ON `pw_product_category`(`parent_id`);
CREATE INDEX `ix_pw_product_category_game` ON `pw_product_category`(`game_id`);
CREATE TABLE `pw_sku_commitment`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `sku_id` BIGINT NOT NULL,
    `rule_type` VARCHAR(32) NOT NULL,
    `title` VARCHAR(128) NOT NULL,
    `target_value` DECIMAL(18, 2),
    `target_unit` VARCHAR(32),
    `description` VARCHAR(1000),
    `failure_action` VARCHAR(500),
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_sku_commitment_sku` ON `pw_sku_commitment`(`sku_id`);
CREATE TABLE `pw_order_commitment`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `order_item_id` BIGINT NOT NULL,
    `source_commitment_id` BIGINT,
    `rule_type` VARCHAR(32) NOT NULL,
    `title` VARCHAR(128) NOT NULL,
    `target_value` DECIMAL(18, 2),
    `target_unit` VARCHAR(32),
    `description` VARCHAR(1000),
    `failure_action` VARCHAR(500),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_order_commitment_order` ON `pw_order_commitment`(`order_id`);
CREATE INDEX `ix_pw_order_commitment_item` ON `pw_order_commitment`(`order_item_id`);
CREATE TABLE `pw_game_server`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `game_id` BIGINT NOT NULL,
    `server_code` VARCHAR(64) NOT NULL,
    `server_name` VARCHAR(64) NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_game_server_game` ON `pw_game_server`(`game_id`);
CREATE TABLE `pw_product_sku`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `product_id` BIGINT NOT NULL,
    `sku_code` VARCHAR(64) NOT NULL,
    `sku_name` VARCHAR(128) NOT NULL,
    `price` DECIMAL(12, 2) NOT NULL,
    `unit_type` VARCHAR(32) NOT NULL,
    `unit_count` DECIMAL(10, 2) DEFAULT 1 NOT NULL,
    `min_quantity` INT DEFAULT 1 NOT NULL,
    `max_quantity` INT,
    `stock_mode` VARCHAR(16) DEFAULT 'UNLIMITED' NOT NULL,
    `stock_quantity` INT,
    `service_minutes` INT,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `market_price` DECIMAL(12, 2),
    `player_count` INT DEFAULT 1 NOT NULL,
    `price_type` VARCHAR(20) DEFAULT 'PER_PLAYER' NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_product_sku_product` ON `pw_product_sku`(`product_id`);
CREATE TABLE `pw_fulfillment`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `order_member_id` BIGINT NOT NULL,
    `player_id` BIGINT NOT NULL,
    `fulfillment_status` VARCHAR(24) DEFAULT 'IN_SERVICE' NOT NULL,
    `completion_note` VARCHAR(1000),
    `actual_quantity` DECIMAL(10, 2),
    `submitted_at` TIMESTAMP,
    `reviewed_by` BIGINT,
    `reviewed_at` TIMESTAMP,
    `review_remark` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_fulfillment_order` ON `pw_fulfillment`(`order_id`, `fulfillment_status`);
CREATE INDEX `ix_pw_fulfillment_player` ON `pw_fulfillment`(`player_id`, `fulfillment_status`);
CREATE TABLE `pw_service_exception_request`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `request_no` VARCHAR(48) NOT NULL,
    `order_id` BIGINT NOT NULL,
    `request_type` VARCHAR(16) NOT NULL,
    `source_order_member_id` BIGINT,
    `target_player_id` BIGINT,
    `applicant_type` VARCHAR(16) NOT NULL,
    `applicant_user_id` BIGINT NOT NULL,
    `reason` VARCHAR(1000) NOT NULL,
    `proof_urls` LONGTEXT,
    `request_status` VARCHAR(32) NOT NULL,
    `review_remark` VARCHAR(1000),
    `reviewed_by` BIGINT,
    `reviewed_at` TIMESTAMP,
    `replacement_order_member_id` BIGINT,
    `resolved_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_service_exception_order` ON `pw_service_exception_request`(`order_id`, `request_status`, `id`);
CREATE INDEX `ix_pw_service_exception_target` ON `pw_service_exception_request`(`target_player_id`, `request_status`, `id`);
CREATE TABLE `pw_product_service`(
    `product_id` BIGINT NOT NULL,
    `service_id` BIGINT NOT NULL,
    `service_quantity` DECIMAL(10, 2) DEFAULT 1 NOT NULL,
    `unit_type` VARCHAR(32) DEFAULT 'ORDER' NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `pw_product_service` ADD CONSTRAINT `CONSTRAINT_3` PRIMARY KEY(`product_id`, `service_id`);
CREATE INDEX `ix_pw_product_service_service` ON `pw_product_service`(`service_id`);
CREATE TABLE `pw_fulfillment_proof`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `fulfillment_id` BIGINT NOT NULL,
    `proof_type` VARCHAR(16) NOT NULL,
    `proof_url` VARCHAR(512) NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_sku_level_price`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `sku_id` BIGINT NOT NULL,
    `player_level_id` BIGINT NOT NULL,
    `price` DECIMAL(12, 2) NOT NULL,
    `market_price` DECIMAL(12, 2),
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_sku_level_price_sku` ON `pw_sku_level_price`(`sku_id`);
CREATE INDEX `ix_pw_sku_level_price_level` ON `pw_sku_level_price`(`player_level_id`);
CREATE TABLE `pw_order_game_profile`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `game_id` BIGINT NOT NULL,
    `game_name` VARCHAR(64) NOT NULL,
    `game_account` VARCHAR(128),
    `game_nickname` VARCHAR(128),
    `server_name` VARCHAR(128),
    `rank_name` VARCHAR(128),
    `extra_requirement` VARCHAR(1000),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `customer_game_profile_id` BIGINT,
    `server_id` BIGINT,
    `current_rank_id` BIGINT,
    `target_rank_id` BIGINT,
    `current_rank_name` VARCHAR(128),
    `target_rank_name` VARCHAR(128)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_order_profile_order` ON `pw_order_game_profile`(`order_id`);
CREATE TABLE `pw_order_status_log`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `from_status` VARCHAR(32),
    `to_status` VARCHAR(32) NOT NULL,
    `operator_id` BIGINT,
    `reason` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_order_status_log_order` ON `pw_order_status_log`(`order_id`);
CREATE TABLE `pw_dispatch_rule`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `rule_name` VARCHAR(64) NOT NULL,
    `grab_minutes` INT DEFAULT 10 NOT NULL,
    `max_candidates` INT DEFAULT 10 NOT NULL,
    `allow_busy` TINYINT(1) DEFAULT 0 NOT NULL,
    `max_active_orders` INT DEFAULT 1 NOT NULL,
    `allow_reoffer_after_reject` TINYINT(1) DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_dispatch_task`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `task_no` VARCHAR(40) NOT NULL,
    `order_id` BIGINT NOT NULL,
    `dispatch_mode` VARCHAR(16) NOT NULL,
    `task_status` VARCHAR(24) NOT NULL,
    `target_player_id` BIGINT,
    `accepted_player_id` BIGINT,
    `attempt_no` INT DEFAULT 1 NOT NULL,
    `candidate_count` INT DEFAULT 0 NOT NULL,
    `deadline_at` TIMESTAMP NOT NULL,
    `created_by` BIGINT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `accepted_at` TIMESTAMP,
    `cancelled_at` TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_dispatch_task_order` ON `pw_dispatch_task`(`order_id`);
CREATE INDEX `ix_pw_dispatch_task_status` ON `pw_dispatch_task`(`task_status`);
CREATE TABLE `pw_dispatch_candidate`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `task_id` BIGINT NOT NULL,
    `player_id` BIGINT NOT NULL,
    `match_score` DECIMAL(8, 2) DEFAULT 0 NOT NULL,
    `active_order_count` INT DEFAULT 0 NOT NULL,
    `candidate_status` VARCHAR(24) DEFAULT 'PENDING' NOT NULL,
    `notified` TINYINT(1) DEFAULT 0 NOT NULL,
    `responded_at` TIMESTAMP,
    `reject_reason` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_dispatch_candidate_task` ON `pw_dispatch_candidate`(`task_id`);
CREATE TABLE `pw_dispatch_action_log`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `task_id` BIGINT NOT NULL,
    `order_id` BIGINT NOT NULL,
    `player_id` BIGINT,
    `action_type` VARCHAR(24) NOT NULL,
    `from_status` VARCHAR(24),
    `to_status` VARCHAR(24),
    `operator_id` BIGINT,
    `reason` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_dispatch_action_task` ON `pw_dispatch_action_log`(`task_id`);
CREATE TABLE `pw_player`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_no` VARCHAR(32) NOT NULL,
    `user_id` BIGINT,
    `nickname` VARCHAR(64) NOT NULL,
    `real_name` VARCHAR(64),
    `gender` VARCHAR(16) DEFAULT 'UNKNOWN' NOT NULL,
    `phone` VARCHAR(32),
    `email` VARCHAR(128),
    `avatar_url` VARCHAR(512),
    `cover_url` VARCHAR(512),
    `introduction` VARCHAR(1000),
    `voice_url` VARCHAR(512),
    `audit_status` VARCHAR(16) DEFAULT 'DRAFT' NOT NULL,
    `work_status` VARCHAR(16) DEFAULT 'OFFLINE' NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `audit_remark` VARCHAR(500),
    `approved_at` TIMESTAMP,
    `last_online_at` TIMESTAMP,
    `order_count` INT DEFAULT 0 NOT NULL,
    `rating_score` DECIMAL(4, 2) DEFAULT 0 NOT NULL,
    `rating_count` INT DEFAULT 0 NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `remark` VARCHAR(500),
    `created_by` BIGINT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_by` BIGINT,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `max_active_orders` INT DEFAULT 1 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_player_status` ON `pw_player`(`audit_status`, `work_status`, `enabled`);
CREATE TABLE `pw_fulfillment_audit`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `fulfillment_id` BIGINT NOT NULL,
    `action` VARCHAR(16) NOT NULL,
    `before_status` VARCHAR(24),
    `after_status` VARCHAR(24) NOT NULL,
    `remark` VARCHAR(500),
    `operator_id` BIGINT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_order_rule`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `customer_confirm_hours` INT DEFAULT 24 NOT NULL,
    `auto_complete_enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_after_sale`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `after_sale_no` VARCHAR(40) NOT NULL,
    `order_id` BIGINT NOT NULL,
    `customer_id` BIGINT NOT NULL,
    `reason_type` VARCHAR(32) NOT NULL,
    `description` VARCHAR(1000) NOT NULL,
    `after_sale_status` VARCHAR(24) DEFAULT 'PENDING' NOT NULL,
    `result_type` VARCHAR(24),
    `result_remark` VARCHAR(1000),
    `handled_by` BIGINT,
    `handled_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_after_sale_order` ON `pw_after_sale`(`order_id`);
CREATE INDEX `ix_pw_after_sale_status` ON `pw_after_sale`(`after_sale_status`);
CREATE TABLE `pw_after_sale_proof`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `after_sale_id` BIGINT NOT NULL,
    `proof_url` VARCHAR(512) NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_after_sale_log`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `after_sale_id` BIGINT NOT NULL,
    `action` VARCHAR(24) NOT NULL,
    `from_status` VARCHAR(24),
    `to_status` VARCHAR(24) NOT NULL,
    `remark` VARCHAR(1000),
    `operator_id` BIGINT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_member_level`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `level_code` VARCHAR(32) NOT NULL,
    `level_name` VARCHAR(64) NOT NULL,
    `level_no` INT NOT NULL,
    `min_recharge_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `discount_rate` DECIMAL(6, 4) DEFAULT 1 NOT NULL,
    `benefit_description` VARCHAR(1000),
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_user_member`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `level_id` BIGINT NOT NULL,
    `growth_value` BIGINT DEFAULT 0 NOT NULL,
    `total_recharge_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `started_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `expired_at` TIMESTAMP,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_recharge_plan`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `plan_code` VARCHAR(40) NOT NULL,
    `plan_name` VARCHAR(80) NOT NULL,
    `recharge_amount` DECIMAL(14, 2) NOT NULL,
    `bonus_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `member_days` INT,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_wallet_account`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `owner_type` VARCHAR(16) NOT NULL,
    `owner_id` BIGINT NOT NULL,
    `cash_balance` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `bonus_balance` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `frozen_balance` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `version` BIGINT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_trade_payment`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `payment_no` VARCHAR(48) NOT NULL,
    `request_no` VARCHAR(64) NOT NULL,
    `order_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `payment_channel` VARCHAR(24) NOT NULL,
    `payment_status` VARCHAR(24) NOT NULL,
    `payable_amount` DECIMAL(14, 2) NOT NULL,
    `cash_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `bonus_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `refunded_cash_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `refunded_bonus_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `paid_at` TIMESTAMP,
    `refunded_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_trade_payment_user` ON `pw_trade_payment`(`user_id`, `id`);
CREATE TABLE `pw_wallet_transaction`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `transaction_no` VARCHAR(48) NOT NULL,
    `account_id` BIGINT NOT NULL,
    `owner_type` VARCHAR(16) NOT NULL,
    `owner_id` BIGINT NOT NULL,
    `balance_type` VARCHAR(16) NOT NULL,
    `direction` VARCHAR(8) NOT NULL,
    `business_type` VARCHAR(32) NOT NULL,
    `business_no` VARCHAR(48) NOT NULL,
    `amount` DECIMAL(14, 2) NOT NULL,
    `balance_before` DECIMAL(14, 2) NOT NULL,
    `balance_after` DECIMAL(14, 2) NOT NULL,
    `remark` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_wallet_tx_owner` ON `pw_wallet_transaction`(`owner_type`, `owner_id`, `id`);
CREATE INDEX `ix_pw_wallet_tx_business` ON `pw_wallet_transaction`(`business_type`, `business_no`);
CREATE TABLE `pw_order_settlement`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `settlement_no` VARCHAR(48) NOT NULL,
    `order_id` BIGINT NOT NULL,
    `order_amount` DECIMAL(14, 2) NOT NULL,
    `platform_amount` DECIMAL(14, 2) NOT NULL,
    `distributable_amount` DECIMAL(14, 2) NOT NULL,
    `settlement_status` VARCHAR(24) NOT NULL,
    `settled_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_service_level_price`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `service_id` BIGINT NOT NULL,
    `player_level_id` BIGINT NOT NULL,
    `unit_type` VARCHAR(16) NOT NULL,
    `price` DECIMAL(12, 2) NOT NULL,
    `market_price` DECIMAL(12, 2),
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_service_level_price_service` ON `pw_service_level_price`(`service_id`);
CREATE INDEX `ix_pw_service_level_price_level` ON `pw_service_level_price`(`player_level_id`);
CREATE TABLE `pw_commission_rule`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `rule_code` VARCHAR(32) NOT NULL,
    `rule_name` VARCHAR(64) NOT NULL,
    `commission_rate` DECIMAL(6, 4) NOT NULL,
    `min_withdraw_amount` DECIMAL(14, 2) NOT NULL,
    `withdraw_weekday` INT NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_player_account`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_id` BIGINT NOT NULL,
    `available_balance` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `frozen_balance` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `total_income` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `total_withdrawn` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `version` BIGINT DEFAULT 0 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_service_member_transfer`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `exception_request_id` BIGINT NOT NULL,
    `from_order_member_id` BIGINT NOT NULL,
    `to_order_member_id` BIGINT NOT NULL,
    `transferred_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_service_transfer_order` ON `pw_service_member_transfer`(`order_id`, `id`);
CREATE TABLE `pw_withdrawal_request`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `withdrawal_no` VARCHAR(48) NOT NULL,
    `player_id` BIGINT NOT NULL,
    `amount` DECIMAL(14, 2) NOT NULL,
    `payout_method` VARCHAR(32) NOT NULL,
    `account_name` VARCHAR(64) NOT NULL,
    `account_no` VARCHAR(128) NOT NULL,
    `withdrawal_status` VARCHAR(20) NOT NULL,
    `review_remark` VARCHAR(500),
    `reviewed_by` BIGINT,
    `reviewed_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_withdrawal_player` ON `pw_withdrawal_request`(`player_id`, `id`);
CREATE TABLE `pw_player_account_transaction`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `transaction_no` VARCHAR(48) NOT NULL,
    `account_id` BIGINT NOT NULL,
    `player_id` BIGINT NOT NULL,
    `balance_type` VARCHAR(16) NOT NULL,
    `direction` VARCHAR(8) NOT NULL,
    `business_type` VARCHAR(32) NOT NULL,
    `business_no` VARCHAR(48) NOT NULL,
    `amount` DECIMAL(14, 2) NOT NULL,
    `balance_before` DECIMAL(14, 2) NOT NULL,
    `balance_after` DECIMAL(14, 2) NOT NULL,
    `remark` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_player_account_tx` ON `pw_player_account_transaction`(`player_id`, `id`);
CREATE TABLE `pw_player_profile_draft`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_id` BIGINT NOT NULL,
    `profile_data` LONGTEXT NOT NULL,
    `draft_status` VARCHAR(16) DEFAULT 'DRAFT' NOT NULL,
    `review_remark` VARCHAR(500),
    `submitted_at` TIMESTAMP,
    `reviewed_by` BIGINT,
    `reviewed_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_player_profile_draft_status` ON `pw_player_profile_draft`(`draft_status`, `submitted_at`);
CREATE TABLE `pw_game_rank_system`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `game_id` BIGINT NOT NULL,
    `system_code` VARCHAR(64) NOT NULL,
    `system_name` VARCHAR(64) NOT NULL,
    `description` VARCHAR(255),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_game_rank_system_game` ON `pw_game_rank_system`(`game_id`);
CREATE TABLE `pw_player_game`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `player_id` BIGINT NOT NULL,
    `game_id` BIGINT NOT NULL,
    `game_nickname` VARCHAR(64),
    `game_account` VARCHAR(128),
    `server_name` VARCHAR(128),
    `rank_name` VARCHAR(64),
    `rank_level` INT,
    `experience_years` INT,
    `introduction` VARCHAR(500),
    `proof_url` VARCHAR(512),
    `is_primary` TINYINT(1) DEFAULT 0 NOT NULL,
    `audit_status` VARCHAR(16) DEFAULT 'PENDING' NOT NULL,
    `audit_remark` VARCHAR(500),
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `price_level_id` BIGINT,
    `server_id` BIGINT,
    `rank_id` BIGINT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_player_game_player` ON `pw_player_game`(`player_id`);
CREATE TABLE `pw_order_member`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `player_id` BIGINT NOT NULL,
    `member_status` VARCHAR(24) DEFAULT 'ACCEPTED' NOT NULL,
    `join_source` VARCHAR(24) DEFAULT 'LEGACY' NOT NULL,
    `dispatch_task_id` BIGINT,
    `joined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `service_started_at` TIMESTAMP,
    `completed_at` TIMESTAMP,
    `cancelled_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_order_member_order` ON `pw_order_member`(`order_id`, `member_status`);
CREATE INDEX `ix_pw_order_member_player` ON `pw_order_member`(`player_id`, `member_status`);
CREATE TABLE `pw_game_rank`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `rank_system_id` BIGINT NOT NULL,
    `rank_code` VARCHAR(64) NOT NULL,
    `rank_name` VARCHAR(64) NOT NULL,
    `tier_no` INT DEFAULT 0 NOT NULL,
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_game_rank_system` ON `pw_game_rank`(`rank_system_id`);
CREATE TABLE `pw_customer_game_profile`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `game_id` BIGINT NOT NULL,
    `server_id` BIGINT,
    `game_account` VARCHAR(128) NOT NULL,
    `game_nickname` VARCHAR(128) NOT NULL,
    `is_default` TINYINT(1) DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_customer_game_profile_user` ON `pw_customer_game_profile`(`user_id`, `game_id`);
CREATE TABLE `pw_customer_game_rank`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `profile_id` BIGINT NOT NULL,
    `rank_system_id` BIGINT NOT NULL,
    `rank_id` BIGINT NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_customer_game_rank_profile` ON `pw_customer_game_rank`(`profile_id`);
CREATE TABLE `pw_order_settlement_detail`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `settlement_id` BIGINT NOT NULL,
    `order_id` BIGINT NOT NULL,
    `order_member_id` BIGINT,
    `player_id` BIGINT,
    `detail_type` VARCHAR(32) NOT NULL,
    `amount` DECIMAL(14, 2) NOT NULL,
    `calculation_base` DECIMAL(14, 2),
    `rate` DECIMAL(8, 4),
    `remark` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX `uk_pw_settlement_member_type` ON `pw_order_settlement_detail`(`settlement_id`, `order_member_id`, `detail_type`);
CREATE INDEX `ix_pw_settlement_detail_order` ON `pw_order_settlement_detail`(`order_id`, `id`);
CREATE TABLE `pw_trade_order`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_no` VARCHAR(40) NOT NULL,
    `customer_id` BIGINT NOT NULL,
    `business_type` VARCHAR(32) NOT NULL,
    `trade_status` VARCHAR(32) NOT NULL,
    `title` VARCHAR(128),
    `total_amount` DECIMAL(14, 2) NOT NULL,
    `discount_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `payable_amount` DECIMAL(14, 2) NOT NULL,
    `paid_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `refunded_amount` DECIMAL(14, 2) DEFAULT 0 NOT NULL,
    `payment_status` VARCHAR(24) DEFAULT 'UNPAID' NOT NULL,
    `refund_status` VARCHAR(24) DEFAULT 'NONE' NOT NULL,
    `customer_remark` VARCHAR(1000),
    `cancel_reason` VARCHAR(500),
    `paid_at` TIMESTAMP,
    `completed_at` TIMESTAMP,
    `cancelled_at` TIMESTAMP,
    `created_by` BIGINT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_trade_order_customer` ON `pw_trade_order`(`customer_id`, `business_type`, `id`);
CREATE INDEX `ix_pw_trade_order_status` ON `pw_trade_order`(`business_type`, `trade_status`, `id`);
CREATE TABLE `pw_service_order`(
    `order_id` BIGINT NOT NULL,
    `requested_player_id` BIGINT,
    `requested_player_level_id` BIGINT,
    `player_level_code` VARCHAR(32),
    `player_level_name` VARCHAR(64),
    `required_player_count` INT DEFAULT 1 NOT NULL,
    `pricing_mode` VARCHAR(32) DEFAULT 'FIXED_SKU' NOT NULL,
    `price_type` VARCHAR(20) DEFAULT 'PER_PLAYER' NOT NULL,
    `base_unit_price` DECIMAL(14, 2),
    `contact_name` VARCHAR(64),
    `contact_phone` VARCHAR(32),
    `service_status` VARCHAR(32) NOT NULL,
    `assigned_at` TIMESTAMP,
    `service_started_at` TIMESTAMP,
    `completion_submitted_at` TIMESTAMP,
    `customer_confirm_deadline` TIMESTAMP,
    `customer_confirmed_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE `pw_service_order` ADD CONSTRAINT `CONSTRAINT_DF` PRIMARY KEY(`order_id`);
CREATE INDEX `ix_pw_service_order_status` ON `pw_service_order`(`service_status`, `order_id`);
CREATE INDEX `ix_pw_service_order_requested_player` ON `pw_service_order`(`requested_player_id`, `order_id`);
CREATE TABLE `pw_recharge_order`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `recharge_no` VARCHAR(40) NOT NULL,
    `request_no` VARCHAR(64) NOT NULL,
    `user_id` BIGINT NOT NULL,
    `plan_id` BIGINT NOT NULL,
    `recharge_amount` DECIMAL(14, 2) NOT NULL,
    `bonus_amount` DECIMAL(14, 2) NOT NULL,
    `recharge_status` VARCHAR(20) NOT NULL,
    `paid_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `trade_order_id` BIGINT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX `uk_pw_recharge_trade_order` ON `pw_recharge_order`(`trade_order_id`);
CREATE TABLE `pw_platform_ledger`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ledger_no` VARCHAR(48) NOT NULL,
    `order_id` BIGINT,
    `settlement_detail_id` BIGINT,
    `business_type` VARCHAR(32) NOT NULL,
    `direction` VARCHAR(8) NOT NULL,
    `amount` DECIMAL(14, 2) NOT NULL,
    `remark` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_platform_ledger_order` ON `pw_platform_ledger`(`order_id`, `id`);
CREATE TABLE `pw_player_earning`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `earning_no` VARCHAR(48) NOT NULL,
    `order_id` BIGINT NOT NULL,
    `order_member_id` BIGINT,
    `settlement_detail_id` BIGINT,
    `player_id` BIGINT NOT NULL,
    `order_amount` DECIMAL(14, 2) NOT NULL,
    `commission_rate` DECIMAL(6, 4) NOT NULL,
    `commission_amount` DECIMAL(14, 2) NOT NULL,
    `player_amount` DECIMAL(14, 2) NOT NULL,
    `earning_status` VARCHAR(20) NOT NULL,
    `settled_at` TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX `uk_pw_player_earning_member` ON `pw_player_earning`(`order_member_id`);
CREATE INDEX `ix_pw_player_earning_order` ON `pw_player_earning`(`order_id`, `id`);
CREATE TABLE `pw_service_liability`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `liability_no` VARCHAR(48) NOT NULL,
    `order_id` BIGINT NOT NULL,
    `exception_request_id` BIGINT,
    `liability_type` VARCHAR(32) NOT NULL,
    `root_order_member_id` BIGINT,
    `liable_order_member_id` BIGINT NOT NULL,
    `beneficiary_order_member_id` BIGINT,
    `liable_player_id` BIGINT NOT NULL,
    `beneficiary_player_id` BIGINT,
    `calculation_base` DECIMAL(14, 2) NOT NULL,
    `rate` DECIMAL(8, 4) NOT NULL,
    `amount` DECIMAL(14, 2) NOT NULL,
    `liability_status` VARCHAR(24) NOT NULL,
    `determined_by` BIGINT,
    `determined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `remark` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX `uk_pw_service_liability_member` ON `pw_service_liability`(`order_id`, `liability_type`, `liable_order_member_id`);
CREATE INDEX `ix_pw_service_liability_order` ON `pw_service_liability`(`order_id`, `id`);
CREATE TABLE `pw_service_penalty_ledger`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ledger_no` VARCHAR(48) NOT NULL,
    `liability_id` BIGINT NOT NULL,
    `order_id` BIGINT NOT NULL,
    `player_id` BIGINT NOT NULL,
    `counterparty_player_id` BIGINT,
    `entry_type` VARCHAR(32) NOT NULL,
    `direction` VARCHAR(8) NOT NULL,
    `amount` DECIMAL(14, 2) NOT NULL,
    `balance_before` DECIMAL(14, 2) NOT NULL,
    `balance_after` DECIMAL(14, 2) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE UNIQUE INDEX `uk_pw_service_penalty_entry` ON `pw_service_penalty_ledger`(`liability_id`, `player_id`, `direction`);
CREATE INDEX `ix_pw_service_penalty_order` ON `pw_service_penalty_ledger`(`order_id`, `id`);
CREATE TABLE `pw_service_item`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `game_id` BIGINT NOT NULL,
    `service_code` VARCHAR(64) NOT NULL,
    `service_name` VARCHAR(64) NOT NULL,
    `service_type` VARCHAR(32) NOT NULL,
    `description` VARCHAR(1000),
    `sort_no` INT DEFAULT 0 NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `usage_type` VARCHAR(32) DEFAULT 'STANDALONE' NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_service_item_game` ON `pw_service_item`(`game_id`);
CREATE TABLE `pw_service_pause_record`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `order_id` BIGINT NOT NULL,
    `pause_request_id` BIGINT NOT NULL,
    `resume_request_id` BIGINT,
    `pause_reason` VARCHAR(1000) NOT NULL,
    `resume_reason` VARCHAR(1000),
    `paused_at` TIMESTAMP NOT NULL,
    `resumed_at` TIMESTAMP,
    `paused_by` BIGINT NOT NULL,
    `resumed_by` BIGINT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE INDEX `ix_pw_service_pause_order` ON `pw_service_pause_record`(`order_id`, `paused_at`, `id`);
ALTER TABLE `pw_player_level` ADD CONSTRAINT `CONSTRAINT_D5B1CB` UNIQUE (`game_id`, `level_code`);
ALTER TABLE `pw_player` ADD CONSTRAINT `CONSTRAINT_8E` UNIQUE (`player_no`);
ALTER TABLE `pw_recharge_plan` ADD CONSTRAINT `CONSTRAINT_C27` UNIQUE (`plan_code`);
ALTER TABLE `pw_service_exception_request` ADD CONSTRAINT `CONSTRAINT_20F` UNIQUE (`request_no`);
ALTER TABLE `pw_player` ADD CONSTRAINT `CONSTRAINT_8E4` UNIQUE (`user_id`);
ALTER TABLE `pw_withdrawal_request` ADD CONSTRAINT `CONSTRAINT_2A4` UNIQUE (`withdrawal_no`);
ALTER TABLE `pw_service_item` ADD CONSTRAINT `CONSTRAINT_E62` UNIQUE (`service_code`);
ALTER TABLE `pw_order_member` ADD CONSTRAINT `CONSTRAINT_3BD` UNIQUE (`order_id`, `player_id`);
ALTER TABLE `pw_service_pause_record` ADD CONSTRAINT `CONSTRAINT_E5D` UNIQUE (`pause_request_id`);
ALTER TABLE `pw_order_settlement` ADD CONSTRAINT `CONSTRAINT_220D` UNIQUE (`order_id`);
ALTER TABLE `pw_trade_payment` ADD CONSTRAINT `CONSTRAINT_7A9B6` UNIQUE (`user_id`, `request_no`);
ALTER TABLE `pw_product_sku` ADD CONSTRAINT `CONSTRAINT_31F` UNIQUE (`sku_code`);
ALTER TABLE `pw_member_level` ADD CONSTRAINT `CONSTRAINT_CDA7` UNIQUE (`level_no`);
ALTER TABLE `pw_player_account_transaction` ADD CONSTRAINT `CONSTRAINT_8D0` UNIQUE (`transaction_no`);
ALTER TABLE `pw_service_member_transfer` ADD CONSTRAINT `CONSTRAINT_2CB3` UNIQUE (`from_order_member_id`);
ALTER TABLE `pw_wallet_account` ADD CONSTRAINT `CONSTRAINT_C11` UNIQUE (`owner_type`, `owner_id`);
ALTER TABLE `pw_sku_level_price` ADD CONSTRAINT `CONSTRAINT_5470C` UNIQUE (`sku_id`, `player_level_id`);
ALTER TABLE `pw_service_pause_record` ADD CONSTRAINT `CONSTRAINT_E5D8` UNIQUE (`resume_request_id`);
ALTER TABLE `pw_service_level_price` ADD CONSTRAINT `CONSTRAINT_277` UNIQUE (`service_id`, `player_level_id`, `unit_type`);
ALTER TABLE `pw_trade_payment` ADD CONSTRAINT `CONSTRAINT_7A9` UNIQUE (`payment_no`);
ALTER TABLE `pw_service_penalty_ledger` ADD CONSTRAINT `CONSTRAINT_5E6` UNIQUE (`ledger_no`);
ALTER TABLE `pw_recharge_order` ADD CONSTRAINT `CONSTRAINT_8BC` UNIQUE (`recharge_no`);
ALTER TABLE `pw_player_game` ADD CONSTRAINT `CONSTRAINT_AC` UNIQUE (`player_id`, `game_id`);
ALTER TABLE `pw_trade_order` ADD CONSTRAINT `CONSTRAINT_145` UNIQUE (`order_no`);
ALTER TABLE `pw_customer_game_rank` ADD CONSTRAINT `CONSTRAINT_262` UNIQUE (`profile_id`, `rank_system_id`);
ALTER TABLE `pw_dispatch_task` ADD CONSTRAINT `CONSTRAINT_C7EE` UNIQUE (`task_no`);
ALTER TABLE `pw_game_position` ADD CONSTRAINT `CONSTRAINT_1F` UNIQUE (`game_id`, `position_code`);
ALTER TABLE `pw_after_sale` ADD CONSTRAINT `CONSTRAINT_89B` UNIQUE (`after_sale_no`);
ALTER TABLE `pw_player_game_position` ADD CONSTRAINT `CONSTRAINT_DC` UNIQUE (`player_game_id`, `position_id`);
ALTER TABLE `pw_product` ADD CONSTRAINT `CONSTRAINT_46` UNIQUE (`product_code`);
ALTER TABLE `sys_role` ADD CONSTRAINT `CONSTRAINT_74A6` UNIQUE (`code`);
ALTER TABLE `pw_dispatch_candidate` ADD CONSTRAINT `CONSTRAINT_E924` UNIQUE (`task_id`, `player_id`);
ALTER TABLE `pw_player_earning` ADD CONSTRAINT `CONSTRAINT_12E` UNIQUE (`earning_no`);
ALTER TABLE `pw_user_member` ADD CONSTRAINT `CONSTRAINT_76D` UNIQUE (`user_id`);
ALTER TABLE `pw_game_rank_system` ADD CONSTRAINT `CONSTRAINT_A20` UNIQUE (`game_id`, `system_code`);
ALTER TABLE `pw_recharge_order` ADD CONSTRAINT `CONSTRAINT_8BC6` UNIQUE (`user_id`, `request_no`);
ALTER TABLE `pw_service_member_transfer` ADD CONSTRAINT `CONSTRAINT_2CB3E` UNIQUE (`to_order_member_id`);
ALTER TABLE `sys_menu` ADD CONSTRAINT `CONSTRAINT_74A44` UNIQUE (`name`);
ALTER TABLE `pw_product_category` ADD CONSTRAINT `CONSTRAINT_E994` UNIQUE (`category_code`);
ALTER TABLE `pw_game_server` ADD CONSTRAINT `CONSTRAINT_8B20` UNIQUE (`game_id`, `server_code`);
ALTER TABLE `pw_game_rank` ADD CONSTRAINT `CONSTRAINT_76F3` UNIQUE (`rank_system_id`, `rank_code`);
ALTER TABLE `pw_wallet_transaction` ADD CONSTRAINT `CONSTRAINT_E14` UNIQUE (`transaction_no`);
ALTER TABLE `pw_commission_rule` ADD CONSTRAINT `CONSTRAINT_6D3` UNIQUE (`rule_code`);
ALTER TABLE `pw_player_tag` ADD CONSTRAINT `CONSTRAINT_AAB` UNIQUE (`tag_code`);
ALTER TABLE `pw_service_liability` ADD CONSTRAINT `CONSTRAINT_518` UNIQUE (`liability_no`);
ALTER TABLE `pw_fulfillment` ADD CONSTRAINT `CONSTRAINT_756` UNIQUE (`order_member_id`);
ALTER TABLE `pw_customer_game_profile` ADD CONSTRAINT `CONSTRAINT_EA5` UNIQUE (`user_id`, `game_id`, `game_account`);
ALTER TABLE `pw_service_member_transfer` ADD CONSTRAINT `CONSTRAINT_2CB` UNIQUE (`exception_request_id`);
ALTER TABLE `sys_user` ADD CONSTRAINT `CONSTRAINT_74` UNIQUE (`username`);
ALTER TABLE `pw_member_level` ADD CONSTRAINT `CONSTRAINT_CDA` UNIQUE (`level_code`);
ALTER TABLE `pw_player_profile_draft` ADD CONSTRAINT `CONSTRAINT_902` UNIQUE (`player_id`);
ALTER TABLE `pw_trade_payment` ADD CONSTRAINT `CONSTRAINT_7A9B` UNIQUE (`order_id`);
ALTER TABLE `pw_order_settlement` ADD CONSTRAINT `CONSTRAINT_220` UNIQUE (`settlement_no`);
ALTER TABLE `pw_game` ADD CONSTRAINT `CONSTRAINT_F5` UNIQUE (`game_code`);
ALTER TABLE `pw_player_account` ADD CONSTRAINT `CONSTRAINT_E619` UNIQUE (`player_id`);
ALTER TABLE `pw_platform_ledger` ADD CONSTRAINT `CONSTRAINT_8968` UNIQUE (`ledger_no`);

-- V51：陪玩师入驻申请（当前开发库尚未执行，按项目最新迁移补齐）
CREATE TABLE `pw_player_application` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT NOT NULL,
  `real_name` VARCHAR(64) NOT NULL,
  `phone` VARCHAR(32) NOT NULL,
  `address` VARCHAR(500) NOT NULL,
  `application_status` VARCHAR(16) NOT NULL DEFAULT 'PENDING',
  `follow_up_remark` VARCHAR(500),
  `handled_by` BIGINT,
  `handled_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `ix_pw_player_application_user` (`user_id`, `application_status`),
  KEY `ix_pw_player_application_status` (`application_status`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- V52：平台客服工单与会话消息
CREATE TABLE `pw_customer_service_ticket` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `ticket_no` VARCHAR(40) NOT NULL,
  `user_id` BIGINT NOT NULL,
  `order_id` BIGINT,
  `category` VARCHAR(32) NOT NULL,
  `subject` VARCHAR(120) NOT NULL,
  `ticket_status` VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  `priority` VARCHAR(16) NOT NULL DEFAULT 'NORMAL',
  `assigned_admin_id` BIGINT,
  `admin_unread_count` INT NOT NULL DEFAULT 0,
  `customer_unread_count` INT NOT NULL DEFAULT 0,
  `last_message_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` TIMESTAMP NULL,
  `closed_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `uk_customer_service_ticket_no` (`ticket_no`),
  KEY `idx_customer_service_ticket_user` (`user_id`, `id`),
  KEY `idx_customer_service_ticket_status` (`ticket_status`, `last_message_at`),
  KEY `idx_customer_service_ticket_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `pw_customer_service_message` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `ticket_id` BIGINT NOT NULL,
  `sender_id` BIGINT NOT NULL,
  `sender_role` VARCHAR(16) NOT NULL,
  `content` TEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_customer_service_message_ticket` (`ticket_id`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 后端启动依赖的内置角色；管理员密码由 ADMIN_INITIAL_PASSWORD 环境变量生成。
INSERT INTO `sys_role` (`name`, `code`, `description`, `enabled`, `built_in`) VALUES
  ('超级管理员', 'admin', '平台超级管理员', 1, 1),
  ('普通用户', 'customer', '小程序普通用户', 1, 1),
  ('陪玩师', 'player', '陪玩师工作台角色', 1, 1)
ON DUPLICATE KEY UPDATE `name`=VALUES(`name`), `description`=VALUES(`description`), `enabled`=VALUES(`enabled`), `built_in`=VALUES(`built_in`);

SET FOREIGN_KEY_CHECKS = 1;

