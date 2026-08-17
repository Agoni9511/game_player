-- 陪玩平台业务数据增量（MySQL 8.0+）
-- 生成日期：2026-08-17
-- 前置条件：目标 MySQL 数据库已存在，并具备当前 V51 表结构。
-- 本脚本可重复执行；测试账号密码统一为 123456。

USE `peiwan_platform`;
SET NAMES utf8mb4;
START TRANSACTION;

-- ============================================================
-- 1. 测试用户与角色
-- BCrypt(123456)：所有测试用户共用，仅用于测试环境。
-- ============================================================
SET @test_password = '$2a$10$VDP1913FqcSIMM05XARAVuZc3ewg3BRCtLDKjMKc/Mb6b9r660YA6';

INSERT INTO `sys_user`
  (`username`, `password`, `nickname`, `email`, `phone`, `gender`, `enabled`)
VALUES
  ('user01', @test_password, '测试用户01', 'user01@peiwan.local', '13900000001', 'UNKNOWN', TRUE),
  ('user02', @test_password, '测试用户02', 'user02@peiwan.local', '13900000002', 'UNKNOWN', TRUE),
  ('user03', @test_password, '测试用户03', 'user03@peiwan.local', '13900000003', 'UNKNOWN', TRUE),
  ('user04', @test_password, '测试用户04', 'user04@peiwan.local', '13900000004', 'UNKNOWN', TRUE),
  ('user05', @test_password, '测试用户05', 'user05@peiwan.local', '13900000005', 'UNKNOWN', TRUE),
  ('user06', @test_password, '测试用户06', 'user06@peiwan.local', '13900000006', 'UNKNOWN', TRUE),
  ('user07', @test_password, '测试用户07', 'user07@peiwan.local', '13900000007', 'UNKNOWN', TRUE),
  ('user08', @test_password, '测试用户08', 'user08@peiwan.local', '13900000008', 'UNKNOWN', TRUE),
  ('user09', @test_password, '测试用户09', 'user09@peiwan.local', '13900000009', 'UNKNOWN', TRUE),
  ('user10', @test_password, '测试用户10', 'user10@peiwan.local', '13900000010', 'UNKNOWN', TRUE)
ON DUPLICATE KEY UPDATE
  `password` = VALUES(`password`),
  `nickname` = VALUES(`nickname`),
  `email` = VALUES(`email`),
  `phone` = VALUES(`phone`),
  `gender` = VALUES(`gender`),
  `enabled` = VALUES(`enabled`),
  `updated_at` = CURRENT_TIMESTAMP;

INSERT IGNORE INTO `sys_user_role` (`user_id`, `role_id`)
SELECT u.`id`, r.`id`
FROM `sys_user` u
JOIN `sys_role` r ON r.`code` = 'customer'
WHERE u.`username` IN ('user01','user02','user03','user04','user05','user06','user07','user08','user09','user10');

INSERT IGNORE INTO `sys_user_role` (`user_id`, `role_id`)
SELECT u.`id`, r.`id`
FROM `sys_user` u
JOIN `sys_role` r ON r.`code` = 'player'
WHERE u.`username` IN ('user01','user02','user03','user04','user05');

-- ============================================================
-- 2. 陪玩师测试资料（user01～user05）
-- ============================================================
INSERT INTO `pw_player`
  (`player_no`, `user_id`, `nickname`, `real_name`, `gender`, `phone`, `email`,
   `avatar_url`, `cover_url`, `introduction`, `audit_status`, `work_status`,
   `enabled`, `approved_at`, `sort_no`, `remark`, `max_active_orders`)
SELECT 'PW000000000002', u.`id`, '陪玩01', '测试陪玩01', 'UNKNOWN', '13900000001',
       'user01@peiwan.local',
       'https://pw-test-1441391259.cos.ap-beijing.myqcloud.com/peiwan/image/2026/08/8f1c94e8fddb4de38f1bad6d879d1881.jpg',
       NULL, '测试陪玩师01', 'APPROVED', 'OFFLINE', TRUE, CURRENT_TIMESTAMP, 1,
       '批量测试账号，图片待替换为远程文件', 1
FROM `sys_user` u WHERE u.`username` = 'user01'
ON DUPLICATE KEY UPDATE
  `user_id`=VALUES(`user_id`), `nickname`=VALUES(`nickname`), `real_name`=VALUES(`real_name`),
  `gender`=VALUES(`gender`), `phone`=VALUES(`phone`), `email`=VALUES(`email`),
  `avatar_url`=VALUES(`avatar_url`), `cover_url`=VALUES(`cover_url`),
  `introduction`=VALUES(`introduction`), `audit_status`=VALUES(`audit_status`),
  `work_status`=VALUES(`work_status`), `enabled`=VALUES(`enabled`), `sort_no`=VALUES(`sort_no`),
  `remark`=VALUES(`remark`), `max_active_orders`=VALUES(`max_active_orders`),
  `updated_at`=CURRENT_TIMESTAMP;

INSERT INTO `pw_player`
  (`player_no`, `user_id`, `nickname`, `real_name`, `gender`, `phone`, `email`,
   `introduction`, `audit_status`, `work_status`, `enabled`, `sort_no`, `remark`, `max_active_orders`)
SELECT CONCAT('PW00000000000', n.`seq`), u.`id`, CONCAT('陪玩0', n.`seq` - 1),
       CONCAT('测试陪玩0', n.`seq` - 1), 'UNKNOWN', CONCAT('1390000000', n.`seq` - 1),
       CONCAT('user0', n.`seq` - 1, '@peiwan.local'), CONCAT('测试陪玩师0', n.`seq` - 1),
       'DRAFT', 'OFFLINE', TRUE, n.`seq` - 1, '批量测试账号，图片待替换为远程文件', 1
FROM (
  SELECT 3 AS `seq` UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6
) n
JOIN `sys_user` u ON u.`username` = CONCAT('user0', n.`seq` - 1)
ON DUPLICATE KEY UPDATE
  `user_id`=VALUES(`user_id`), `nickname`=VALUES(`nickname`), `real_name`=VALUES(`real_name`),
  `gender`=VALUES(`gender`), `phone`=VALUES(`phone`), `email`=VALUES(`email`),
  `introduction`=VALUES(`introduction`), `audit_status`=VALUES(`audit_status`),
  `work_status`=VALUES(`work_status`), `enabled`=VALUES(`enabled`), `sort_no`=VALUES(`sort_no`),
  `remark`=VALUES(`remark`), `max_active_orders`=VALUES(`max_active_orders`),
  `updated_at`=CURRENT_TIMESTAMP;

-- ============================================================
-- 3. 陪玩师标签
-- ============================================================
INSERT INTO `pw_player_tag`
  (`tag_code`, `tag_name`, `tag_color`, `tag_group`, `sort_no`, `enabled`)
VALUES
  ('aim-strong','枪法在线','#F56C6C','SKILL',1,TRUE),
  ('game-sense','游戏意识','#E74C3C','SKILL',2,TRUE),
  ('all-rounder','全能补位','#9B59B6','SKILL',3,TRUE),
  ('fast-rank','上分效率','#FF6B6B','SKILL',4,TRUE),
  ('good-command','指挥清晰','#409EFF','STYLE',5,TRUE),
  ('patient','耐心教学','#67C23A','STYLE',6,TRUE),
  ('funny','氛围活跃','#E6A23C','STYLE',7,TRUE),
  ('beginner-friendly','新手友好','#2ECC71','STYLE',8,TRUE),
  ('no-pressure','不压力队友','#1ABC9C','STYLE',9,TRUE),
  ('good-communication','沟通积极','#3498DB','STYLE',10,TRUE),
  ('sweet-voice','声音甜美','#FF69B4','VOICE',11,TRUE),
  ('clear-voice','音色清晰','#8E44AD','VOICE',12,TRUE),
  ('late-night','深夜在线','#909399','TIME',13,TRUE),
  ('weekend','周末在线','#5C6BC0','TIME',14,TRUE),
  ('long-session','长时稳定','#607D8B','TIME',15,TRUE),
  ('sniper-specialist','狙击专精','#D32F2F','SKILL',16,TRUE),
  ('assault-specialist','突击专精','#E53935','SKILL',17,TRUE),
  ('support-specialist','辅助专精','#43A047','SKILL',18,TRUE),
  ('tactical-operator','战术运营','#3949AB','SKILL',19,TRUE),
  ('map-expert','地图熟练','#00897B','SKILL',20,TRUE),
  ('utility-master','道具大师','#7B1FA2','SKILL',21,TRUE),
  ('review-coach','复盘指导','#5E35B1','SKILL',22,TRUE),
  ('stable-performance','稳定发挥','#546E7A','SKILL',23,TRUE),
  ('quick-reaction','反应迅速','#F4511E','SKILL',24,TRUE),
  ('team-coordination','团队配合','#039BE5','SKILL',25,TRUE),
  ('gentle-patient','温柔耐心','#EC407A','STYLE',26,TRUE),
  ('humorous-talkative','幽默健谈','#FFA726','STYLE',27,TRUE),
  ('calm-steady','沉稳冷静','#5C6BC0','STYLE',28,TRUE),
  ('emotionally-stable','情绪稳定','#26A69A','STYLE',29,TRUE),
  ('active-callout','主动报点','#42A5F5','STYLE',30,TRUE),
  ('follow-command','服从指挥','#78909C','STYLE',31,TRUE),
  ('team-leader','擅长带队','#AB47BC','STYLE',32,TRUE),
  ('quiet-company','安静陪伴','#8D6E63','STYLE',33,TRUE),
  ('positive-energy','正能量','#66BB6A','STYLE',34,TRUE),
  ('never-blame','从不甩锅','#29B6F6','STYLE',35,TRUE),
  ('mature-voice','御姐音','#AD1457','VOICE',36,TRUE),
  ('girl-voice','少女音','#F06292','VOICE',37,TRUE),
  ('magnetic-voice','磁性嗓音','#6A1B9A','VOICE',38,TRUE),
  ('healing-voice','治愈声线','#BA68C8','VOICE',39,TRUE),
  ('daytime-online','白天在线','#FFB300','TIME',40,TRUE),
  ('afternoon-online','下午在线','#FB8C00','TIME',41,TRUE),
  ('evening-online','晚间在线','#3F51B5','TIME',42,TRUE),
  ('holiday-online','节假日在线','#009688','TIME',43,TRUE),
  ('fast-response','极速响应','#00ACC1','SERVICE',44,TRUE),
  ('continuous-service','可连续包时','#7CB342','SERVICE',45,TRUE)
ON DUPLICATE KEY UPDATE
  `tag_name`=VALUES(`tag_name`), `tag_color`=VALUES(`tag_color`),
  `tag_group`=VALUES(`tag_group`), `sort_no`=VALUES(`sort_no`),
  `enabled`=VALUES(`enabled`), `updated_at`=CURRENT_TIMESTAMP;

-- ============================================================
-- 4. 游戏、图片与国服区服
-- COS 对象必须保持可读，否则前端图片会返回 AccessDenied。
-- ============================================================
INSERT INTO `pw_game`
  (`game_code`, `game_name`, `icon_url`, `cover_url`, `platform_type`, `description`, `sort_no`, `enabled`)
VALUES
  ('delta-force','三角洲行动',
   'https://pw-test-1441391259.cos.ap-beijing.myqcloud.com/peiwan/image/2026/08/2ba13722516442b9b5244fceb79d543a.jpg',
   'https://pw-test-1441391259.cos.ap-beijing.myqcloud.com/peiwan/image/2026/08/acfe1a2c1752414ca2f9995eccab0b15.jpg',
   'PC','战术射击、烽火地带与全面战场陪玩',1,TRUE),
  ('valorant','无畏契约',
   'https://pw-test-1441391259.cos.ap-beijing.myqcloud.com/peiwan/image/2026/08/56d6ee5b2fb64f789ed9e50a82174ac4.jpg',
   'https://pw-test-1441391259.cos.ap-beijing.myqcloud.com/peiwan/image/2026/08/309345c9a93f42608159632522cd038a.jpg',
   'PC','竞技射击、排位上分与娱乐陪玩',2,TRUE)
ON DUPLICATE KEY UPDATE
  `game_name`=VALUES(`game_name`), `icon_url`=VALUES(`icon_url`),
  `cover_url`=VALUES(`cover_url`), `platform_type`=VALUES(`platform_type`),
  `description`=VALUES(`description`), `sort_no`=VALUES(`sort_no`),
  `enabled`=VALUES(`enabled`), `updated_at`=CURRENT_TIMESTAMP;

SET @delta_id = (SELECT `id` FROM `pw_game` WHERE `game_code`='delta-force');
SET @valorant_id = (SELECT `id` FROM `pw_game` WHERE `game_code`='valorant');

INSERT INTO `pw_game_server` (`game_id`,`server_code`,`server_name`,`sort_no`,`enabled`)
VALUES (@delta_id,'CN','国服',1,TRUE), (@valorant_id,'CN','国服',1,TRUE)
ON DUPLICATE KEY UPDATE
  `server_name`=VALUES(`server_name`), `sort_no`=VALUES(`sort_no`),
  `enabled`=VALUES(`enabled`), `updated_at`=CURRENT_TIMESTAMP;

-- ============================================================
-- 5. 游戏位置/职责
-- ============================================================
INSERT INTO `pw_game_position`
  (`game_id`,`position_code`,`position_name`,`sort_no`,`enabled`)
VALUES
  (@delta_id,'ASSAULT','突击',1,TRUE),
  (@delta_id,'SUPPORT','支援',2,TRUE),
  (@delta_id,'ENGINEER','工程',3,TRUE),
  (@delta_id,'RECON','侦察',4,TRUE),
  (@valorant_id,'DUELIST','决斗',1,TRUE),
  (@valorant_id,'INITIATOR','先锋',2,TRUE),
  (@valorant_id,'CONTROLLER','控场',3,TRUE),
  (@valorant_id,'SENTINEL','哨卫',4,TRUE)
ON DUPLICATE KEY UPDATE
  `position_name`=VALUES(`position_name`), `sort_no`=VALUES(`sort_no`),
  `enabled`=VALUES(`enabled`), `updated_at`=CURRENT_TIMESTAMP;

-- ============================================================
-- 6. 段位体系
-- 兼容旧库中由默认初始化生成的 DEFAULT 体系，优先原位升级以保留 ID。
-- ============================================================
UPDATE `pw_game_rank_system` old_system
LEFT JOIN `pw_game_rank_system` target
  ON target.`game_id`=old_system.`game_id` AND target.`system_code`='OPERATIONS'
SET old_system.`system_code`='OPERATIONS', old_system.`updated_at`=CURRENT_TIMESTAMP
WHERE old_system.`game_id`=@delta_id AND old_system.`system_code`='DEFAULT' AND target.`id` IS NULL;

UPDATE `pw_game_rank_system` old_system
LEFT JOIN `pw_game_rank_system` target
  ON target.`game_id`=old_system.`game_id` AND target.`system_code`='COMPETITIVE'
SET old_system.`system_code`='COMPETITIVE', old_system.`updated_at`=CURRENT_TIMESTAMP
WHERE old_system.`game_id`=@valorant_id AND old_system.`system_code`='DEFAULT' AND target.`id` IS NULL;

INSERT INTO `pw_game_rank_system`
  (`game_id`,`system_code`,`system_name`,`description`,`sort_no`,`enabled`)
VALUES
  (@delta_id,'OPERATIONS','烽火地带段位','烽火地带竞技排名体系',1,TRUE),
  (@delta_id,'WARFARE','全面战场段位','全面战场功勋军衔体系',2,TRUE),
  (@valorant_id,'COMPETITIVE','竞技模式段位','无畏契约竞技模式排位体系',1,TRUE)
ON DUPLICATE KEY UPDATE
  `system_name`=VALUES(`system_name`), `description`=VALUES(`description`),
  `sort_no`=VALUES(`sort_no`), `enabled`=VALUES(`enabled`),
  `updated_at`=CURRENT_TIMESTAMP;

SET @delta_operations = (SELECT `id` FROM `pw_game_rank_system` WHERE `game_id`=@delta_id AND `system_code`='OPERATIONS');
SET @delta_warfare = (SELECT `id` FROM `pw_game_rank_system` WHERE `game_id`=@delta_id AND `system_code`='WARFARE');
SET @valorant_competitive = (SELECT `id` FROM `pw_game_rank_system` WHERE `game_id`=@valorant_id AND `system_code`='COMPETITIVE');

-- 将旧默认段位原位改名，避免破坏可能存在的外键引用。
UPDATE `pw_game_rank` old_rank
LEFT JOIN `pw_game_rank` target
  ON target.`rank_system_id`=old_rank.`rank_system_id` AND target.`rank_code`='BLACK_HAWK'
SET old_rank.`rank_code`='BLACK_HAWK', old_rank.`rank_name`='黑鹰',
    old_rank.`tier_no`=6, old_rank.`sort_no`=6, old_rank.`updated_at`=CURRENT_TIMESTAMP
WHERE old_rank.`rank_system_id`=@delta_operations AND old_rank.`rank_code`='MASTER' AND target.`id` IS NULL;

UPDATE `pw_game_rank` old_rank
LEFT JOIN `pw_game_rank` target
  ON target.`rank_system_id`=old_rank.`rank_system_id` AND target.`rank_code`='DELTA_PINNACLE'
SET old_rank.`rank_code`='DELTA_PINNACLE', old_rank.`rank_name`='三角洲巅峰',
    old_rank.`tier_no`=7, old_rank.`sort_no`=7, old_rank.`updated_at`=CURRENT_TIMESTAMP
WHERE old_rank.`rank_system_id`=@delta_operations AND old_rank.`rank_code`='TOP' AND target.`id` IS NULL;

UPDATE `pw_game_rank` old_rank
LEFT JOIN `pw_game_rank` target
  ON target.`rank_system_id`=old_rank.`rank_system_id` AND target.`rank_code`='IMMORTAL'
SET old_rank.`rank_code`='IMMORTAL', old_rank.`rank_name`='神话',
    old_rank.`tier_no`=8, old_rank.`sort_no`=8, old_rank.`updated_at`=CURRENT_TIMESTAMP
WHERE old_rank.`rank_system_id`=@valorant_competitive AND old_rank.`rank_code`='MASTER' AND target.`id` IS NULL;

UPDATE `pw_game_rank` old_rank
LEFT JOIN `pw_game_rank` target
  ON target.`rank_system_id`=old_rank.`rank_system_id` AND target.`rank_code`='RADIANT'
SET old_rank.`rank_code`='RADIANT', old_rank.`rank_name`='无畏战魂',
    old_rank.`tier_no`=9, old_rank.`sort_no`=9, old_rank.`updated_at`=CURRENT_TIMESTAMP
WHERE old_rank.`rank_system_id`=@valorant_competitive AND old_rank.`rank_code`='TOP' AND target.`id` IS NULL;

INSERT INTO `pw_game_rank`
  (`rank_system_id`,`rank_code`,`rank_name`,`tier_no`,`sort_no`,`enabled`)
VALUES
  (@delta_operations,'BRONZE','青铜',1,1,TRUE),
  (@delta_operations,'SILVER','白银',2,2,TRUE),
  (@delta_operations,'GOLD','黄金',3,3,TRUE),
  (@delta_operations,'PLATINUM','铂金',4,4,TRUE),
  (@delta_operations,'DIAMOND','钻石',5,5,TRUE),
  (@delta_operations,'BLACK_HAWK','黑鹰',6,6,TRUE),
  (@delta_operations,'DELTA_PINNACLE','三角洲巅峰',7,7,TRUE),
  (@delta_warfare,'PRIVATE','列兵',1,1,TRUE),
  (@delta_warfare,'PRIVATE_FIRST_CLASS','上等兵',2,2,TRUE),
  (@delta_warfare,'SERGEANT_MAJOR','军士长',3,3,TRUE),
  (@delta_warfare,'OFFICER','尉官',4,4,TRUE),
  (@delta_warfare,'FIELD_OFFICER','校官',5,5,TRUE),
  (@delta_warfare,'GENERAL','将军',6,6,TRUE),
  (@delta_warfare,'MARSHAL','统帅',7,7,TRUE),
  (@valorant_competitive,'IRON','黑铁',1,1,TRUE),
  (@valorant_competitive,'BRONZE','青铜',2,2,TRUE),
  (@valorant_competitive,'SILVER','白银',3,3,TRUE),
  (@valorant_competitive,'GOLD','黄金',4,4,TRUE),
  (@valorant_competitive,'PLATINUM','铂金',5,5,TRUE),
  (@valorant_competitive,'DIAMOND','钻石',6,6,TRUE),
  (@valorant_competitive,'ASCENDANT','超凡',7,7,TRUE),
  (@valorant_competitive,'IMMORTAL','神话',8,8,TRUE),
  (@valorant_competitive,'RADIANT','无畏战魂',9,9,TRUE)
ON DUPLICATE KEY UPDATE
  `rank_name`=VALUES(`rank_name`), `tier_no`=VALUES(`tier_no`),
  `sort_no`=VALUES(`sort_no`), `enabled`=VALUES(`enabled`),
  `updated_at`=CURRENT_TIMESTAMP;

-- ============================================================
-- 7. 充值套餐
-- ============================================================
INSERT INTO `pw_recharge_plan`
  (`plan_code`,`plan_name`,`recharge_amount`,`bonus_amount`,`member_days`,`sort_no`,`enabled`)
VALUES
  ('RECHARGE_50','轻享充值',50.00,0.00,NULL,1,TRUE),
  ('RECHARGE_100','超值充值',100.00,5.00,NULL,2,TRUE),
  ('RECHARGE_300','畅玩充值',300.00,30.00,NULL,3,TRUE),
  ('RECHARGE_500','尊享充值',500.00,80.00,NULL,4,TRUE)
ON DUPLICATE KEY UPDATE
  `plan_name`=VALUES(`plan_name`), `recharge_amount`=VALUES(`recharge_amount`),
  `bonus_amount`=VALUES(`bonus_amount`), `member_days`=VALUES(`member_days`),
  `sort_no`=VALUES(`sort_no`), `enabled`=VALUES(`enabled`),
  `updated_at`=CURRENT_TIMESTAMP;

COMMIT;

-- 执行后核对
SELECT `game_code`,`game_name`,`enabled` FROM `pw_game`
WHERE `game_code` IN ('delta-force','valorant') ORDER BY `sort_no`;
SELECT `plan_code`,`plan_name`,`recharge_amount`,`bonus_amount`,`enabled`
FROM `pw_recharge_plan` WHERE `plan_code` LIKE 'RECHARGE_%' ORDER BY `sort_no`;
SELECT COUNT(*) AS `test_user_count` FROM `sys_user`
WHERE `username` IN ('user01','user02','user03','user04','user05','user06','user07','user08','user09','user10');
SELECT COUNT(*) AS `player_tag_count` FROM `pw_player_tag` WHERE `enabled`=TRUE;
