-- 订单确认规则配置页增量：远程已有数据库只需执行本文件，无需重跑 01_full_schema.sql。
USE `peiwan_platform`;
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'MENU','OrderRule','order-rule','/business/order-rule','订单确认规则','ri:timer-line',NULL,8,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p
WHERE p.`name`='BasicConfig'
  AND NOT EXISTS (SELECT 1 FROM `sys_menu` m WHERE m.`name`='OrderRule');

UPDATE `sys_menu` m
JOIN `sys_menu` p ON p.`name`='BasicConfig'
SET m.`parent_id`=p.`id`,m.`path`='order-rule',m.`component`='/business/order-rule',m.`title`='订单确认规则',
    m.`icon`='ri:timer-line',m.`sort_no`=8,m.`enabled`=1,m.`updated_at`=CURRENT_TIMESTAMP
WHERE m.`name`='OrderRule';

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'BUTTON','OrderRuleView',NULL,NULL,'查看订单确认规则',NULL,'business:order-rule:view',1,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p
WHERE p.`name`='OrderRule'
  AND NOT EXISTS (SELECT 1 FROM `sys_menu` m WHERE m.`name`='OrderRuleView');

UPDATE `sys_menu` m
JOIN `sys_menu` p ON p.`name`='OrderRule'
SET m.`parent_id`=p.`id`,m.`title`='查看订单确认规则',m.`auth_mark`='business:order-rule:view',m.`enabled`=1,m.`updated_at`=CURRENT_TIMESTAMP
WHERE m.`name`='OrderRuleView';

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'BUTTON','OrderRuleUpdate',NULL,NULL,'修改订单确认规则',NULL,'business:order-rule:update',2,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p
WHERE p.`name`='OrderRule'
  AND NOT EXISTS (SELECT 1 FROM `sys_menu` m WHERE m.`name`='OrderRuleUpdate');

UPDATE `sys_menu` m
JOIN `sys_menu` p ON p.`name`='OrderRule'
SET m.`parent_id`=p.`id`,m.`title`='修改订单确认规则',m.`auth_mark`='business:order-rule:update',m.`enabled`=1,m.`updated_at`=CURRENT_TIMESTAMP
WHERE m.`name`='OrderRuleUpdate';

INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`)
SELECT r.`id`,m.`id`
FROM `sys_role` r JOIN `sys_menu` m
  ON m.`name` IN ('BasicConfig','OrderRule','OrderRuleView','OrderRuleUpdate')
WHERE r.`code`='admin';

COMMIT;

SELECT `id`,`parent_id`,`name`,`path`,`component`,`title`,`enabled`
FROM `sys_menu` WHERE `name`='OrderRule';
