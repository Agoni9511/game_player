-- 商品分类数据增量（MySQL 8.0+）
-- 生成日期：2026-08-19
--
-- 设计口径：
--   商品分类用于前台按“游戏模式 / 消费场景”找商品；
--   基础服务用于定义实际交付内容及等级价格。
-- 两者不是同一维度。例如“竞技模式”分类下可以同时出售排位陪练、
-- 保段护航、复盘教学等不同基础服务。
--
-- 前置条件：先执行 03_incremental_business_data.sql，确保 pw_game 中存在
-- delta-force 和 valorant。分类编码为全局唯一，本脚本可重复执行。

USE `peiwan_platform`;
SET NAMES utf8mb4;

DROP TEMPORARY TABLE IF EXISTS `tmp_required_category_games`;
CREATE TEMPORARY TABLE `tmp_required_category_games` (
  `game_code` VARCHAR(64) NOT NULL PRIMARY KEY,
  `game_id` BIGINT NOT NULL
) ENGINE=InnoDB;

-- 标量子查询查不到游戏时会得到 NULL，并由 game_id 的 NOT NULL 约束阻止继续执行，
-- 避免远程库只写入一部分分类。
INSERT INTO `tmp_required_category_games` (`game_code`, `game_id`)
VALUES
  ('delta-force', (SELECT `id` FROM `pw_game` WHERE `game_code` = 'delta-force' LIMIT 1)),
  ('valorant',     (SELECT `id` FROM `pw_game` WHERE `game_code` = 'valorant' LIMIT 1));

SET @delta_game_id = (
  SELECT `game_id` FROM `tmp_required_category_games` WHERE `game_code` = 'delta-force'
);
SET @valorant_game_id = (
  SELECT `game_id` FROM `tmp_required_category_games` WHERE `game_code` = 'valorant'
);

START TRANSACTION;

INSERT INTO `pw_product_category`
  (`game_id`, `parent_id`, `category_code`, `category_name`, `icon_url`, `sort_no`, `enabled`)
VALUES
  (@delta_game_id,    NULL, 'DELTA_OPERATIONS',       '烽火地带', NULL, 10, TRUE),
  (@delta_game_id,    NULL, 'DELTA_WARFARE',          '全面战场', NULL, 20, TRUE),
  (@delta_game_id,    NULL, 'DELTA_BLACK_HAWK_DOWN',  '黑鹰坠落', NULL, 30, TRUE),
  (@valorant_game_id, NULL, 'VALORANT_UNRATED',       '普通娱乐', NULL, 10, TRUE),
  (@valorant_game_id, NULL, 'VALORANT_COMPETITIVE',   '竞技排位', NULL, 20, TRUE),
  (@valorant_game_id, NULL, 'VALORANT_SWIFTPLAY',     '极速对战', NULL, 30, TRUE),
  (@valorant_game_id, NULL, 'VALORANT_DEATHMATCH',    '死斗练枪', NULL, 40, TRUE)
ON DUPLICATE KEY UPDATE
  `game_id` = VALUES(`game_id`),
  `parent_id` = VALUES(`parent_id`),
  `category_name` = VALUES(`category_name`),
  `sort_no` = VALUES(`sort_no`),
  `enabled` = VALUES(`enabled`),
  `updated_at` = CURRENT_TIMESTAMP;

COMMIT;

DROP TEMPORARY TABLE `tmp_required_category_games`;

-- 执行结果应为：delta-force 3 条、valorant 4 条。
SELECT
  g.`game_code`,
  g.`game_name`,
  c.`category_code`,
  c.`category_name`,
  c.`sort_no`,
  c.`enabled`
FROM `pw_product_category` c
JOIN `pw_game` g ON g.`id` = c.`game_id`
WHERE c.`category_code` IN (
  'DELTA_OPERATIONS',
  'DELTA_WARFARE',
  'DELTA_BLACK_HAWK_DOWN',
  'VALORANT_UNRATED',
  'VALORANT_COMPETITIVE',
  'VALORANT_SWIFTPLAY',
  'VALORANT_DEATHMATCH'
)
ORDER BY g.`game_code`, c.`sort_no`, c.`id`;
