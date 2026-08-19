-- 派单规则配置页增量：远程已有数据库只需执行本文件，无需重跑 01_full_schema.sql。
USE `peiwan_platform`;
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO `pw_dispatch_rule`
  (`rule_name`,`grab_minutes`,`max_candidates`,`allow_busy`,`max_active_orders`,`allow_reoffer_after_reject`,`enabled`)
SELECT '默认派单规则', 10, 10, 0, 3, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM `pw_dispatch_rule` WHERE `enabled` = 1);

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'MENU','DispatchRule','dispatch-rule','/business/dispatch-rule','派单规则','ri:route-line',NULL,7,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p
WHERE p.`name`='BasicConfig'
  AND NOT EXISTS (SELECT 1 FROM `sys_menu` m WHERE m.`name`='DispatchRule');

UPDATE `sys_menu` m
JOIN `sys_menu` p ON p.`name`='BasicConfig'
SET m.`parent_id`=p.`id`,m.`path`='dispatch-rule',m.`component`='/business/dispatch-rule',m.`title`='派单规则',
    m.`icon`='ri:route-line',m.`sort_no`=7,m.`enabled`=1,m.`updated_at`=CURRENT_TIMESTAMP
WHERE m.`name`='DispatchRule';

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'BUTTON','DispatchRuleView',NULL,NULL,'查看派单规则',NULL,'business:dispatch-rule:view',1,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p WHERE p.`name`='DispatchRule'
ON DUPLICATE KEY UPDATE `parent_id`=VALUES(`parent_id`),`title`=VALUES(`title`),`auth_mark`=VALUES(`auth_mark`),`enabled`=1,`updated_at`=CURRENT_TIMESTAMP;

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'BUTTON','DispatchRuleUpdate',NULL,NULL,'修改派单规则',NULL,'business:dispatch-rule:update',2,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p WHERE p.`name`='DispatchRule'
ON DUPLICATE KEY UPDATE `parent_id`=VALUES(`parent_id`),`title`=VALUES(`title`),`auth_mark`=VALUES(`auth_mark`),`enabled`=1,`updated_at`=CURRENT_TIMESTAMP;

INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`)
SELECT r.`id`,m.`id` FROM `sys_role` r JOIN `sys_menu` m ON m.`name` IN ('BasicConfig','DispatchRule','DispatchRuleView','DispatchRuleUpdate') WHERE r.`code`='admin';

COMMIT;

SELECT `id`,`rule_name`,`grab_minutes`,`max_candidates`,`allow_busy`,`max_active_orders`,`allow_reoffer_after_reject`,`enabled`
FROM `pw_dispatch_rule` WHERE `enabled`=1 ORDER BY `id` LIMIT 1;
