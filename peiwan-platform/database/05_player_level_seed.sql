-- 陪玩师等级数据增量（MySQL 8.0+）
-- 生成日期：2026-08-19
-- 前置条件：pw_game 中已经存在游戏编码 delta-force 和 valorant。
-- 目标数据：三角洲行动 1 个等级，无畏契约 4 个等级。
-- 本脚本基于 (game_id, level_code) 唯一键，可重复执行。

USE `peiwan_platform`;
SET NAMES utf8mb4;
START TRANSACTION;

SET @delta_game_id = (
  SELECT `id`
  FROM `pw_game`
  WHERE `game_code` = 'delta-force'
  LIMIT 1
);

SET @valorant_game_id = (
  SELECT `id`
  FROM `pw_game`
  WHERE `game_code` = 'valorant'
  LIMIT 1
);

-- 任一游戏不存在时，game_id 的 NOT NULL 约束会使整条语句失败，事务不会写入半套数据。
INSERT INTO `pw_player_level`
  (`game_id`, `level_code`, `level_name`, `description`, `sort_no`, `enabled`)
VALUES
  (@delta_game_id,    'STANDARD', '通用', '三角洲行动统一陪玩等级',       1, TRUE),
  (@valorant_game_id, 'GOLD',      '金牌',    '无畏契约金牌陪玩师',    1, TRUE),
  (@valorant_game_id, 'STAR',      '明星',    '无畏契约明星陪玩师',    2, TRUE),
  (@valorant_game_id, 'DEMON',     '魔王',    '无畏契约魔王陪玩师',    3, TRUE),
  (@valorant_game_id, 'DEMON_PRO', '魔王Pro', '无畏契约魔王Pro陪玩师', 4, TRUE)
ON DUPLICATE KEY UPDATE
  `level_name` = VALUES(`level_name`),
  `description` = VALUES(`description`),
  `sort_no` = VALUES(`sort_no`),
  `enabled` = VALUES(`enabled`),
  `updated_at` = CURRENT_TIMESTAMP;

COMMIT;

-- 执行结果应为：delta-force 1 条、valorant 4 条。
SELECT
  g.`game_code`,
  g.`game_name`,
  l.`level_code`,
  l.`level_name`,
  l.`sort_no`,
  l.`enabled`
FROM `pw_player_level` l
JOIN `pw_game` g ON g.`id` = l.`game_id`
WHERE g.`game_code` IN ('delta-force', 'valorant')
ORDER BY g.`game_code`, l.`sort_no`, l.`id`;
