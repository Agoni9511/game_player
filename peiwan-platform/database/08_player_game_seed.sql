USE `peiwan_platform`;

UPDATE `pw_player` p
JOIN `sys_user` u ON u.`id` = p.`user_id`
SET p.`audit_status` = 'APPROVED',
    p.`enabled` = 1,
    p.`work_status` = 'AVAILABLE',
    p.`updated_at` = CURRENT_TIMESTAMP
WHERE u.`username` REGEXP '^user0[1-5]$';

INSERT INTO `pw_player_game`
  (`player_id`, `game_id`, `game_nickname`, `game_account`, `is_primary`, `audit_status`, `enabled`, `price_level_id`)
SELECT p.`id`, g.`id`, CONCAT('三角洲陪玩', RIGHT(u.`username`, 2)), CONCAT('DELTA-', UPPER(u.`username`)), 1, 'APPROVED', 1, l.`id`
FROM `pw_player` p
JOIN `sys_user` u ON u.`id` = p.`user_id`
JOIN `pw_game` g ON g.`game_code` = 'delta-force'
JOIN `pw_player_level` l ON l.`game_id` = g.`id` AND l.`level_code` = 'STANDARD'
WHERE u.`username` REGEXP '^user0[1-5]$'
ON DUPLICATE KEY UPDATE
  `game_nickname` = VALUES(`game_nickname`),
  `game_account` = VALUES(`game_account`),
  `is_primary` = VALUES(`is_primary`),
  `audit_status` = 'APPROVED',
  `enabled` = 1,
  `price_level_id` = VALUES(`price_level_id`),
  `updated_at` = CURRENT_TIMESTAMP;

INSERT INTO `pw_player_game`
  (`player_id`, `game_id`, `game_nickname`, `game_account`, `is_primary`, `audit_status`, `enabled`, `price_level_id`)
SELECT p.`id`, g.`id`, CONCAT('无畏陪玩', RIGHT(u.`username`, 2)), CONCAT('VAL-', UPPER(u.`username`)), 0, 'APPROVED', 1,
       CASE MOD(CAST(RIGHT(u.`username`, 2) AS UNSIGNED) - 1, 4)
         WHEN 0 THEN gold.`id` WHEN 1 THEN star.`id` WHEN 2 THEN demon.`id` ELSE pro.`id` END
FROM `pw_player` p
JOIN `sys_user` u ON u.`id` = p.`user_id`
JOIN `pw_game` g ON g.`game_code` = 'valorant'
JOIN `pw_player_level` gold ON gold.`game_id` = g.`id` AND gold.`level_code` = 'GOLD'
JOIN `pw_player_level` star ON star.`game_id` = g.`id` AND star.`level_code` = 'STAR'
JOIN `pw_player_level` demon ON demon.`game_id` = g.`id` AND demon.`level_code` = 'DEMON'
JOIN `pw_player_level` pro ON pro.`game_id` = g.`id` AND pro.`level_code` = 'DEMON_PRO'
WHERE u.`username` REGEXP '^user0[1-5]$'
ON DUPLICATE KEY UPDATE
  `game_nickname` = VALUES(`game_nickname`),
  `game_account` = VALUES(`game_account`),
  `is_primary` = VALUES(`is_primary`),
  `audit_status` = 'APPROVED',
  `enabled` = 1,
  `price_level_id` = VALUES(`price_level_id`),
  `updated_at` = CURRENT_TIMESTAMP;

SELECT g.`game_code`, COUNT(*) AS `approved_player_count`
FROM `pw_player_game` pg
JOIN `pw_game` g ON g.`id` = pg.`game_id`
WHERE pg.`audit_status` = 'APPROVED' AND pg.`enabled` = 1
GROUP BY g.`game_code`
ORDER BY g.`game_code`;
