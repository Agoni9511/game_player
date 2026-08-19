-- 服务责任规则配置页增量：远程已有数据库只需执行本文件，无需重跑 01_full_schema.sql。
USE `peiwan_platform`;
SET NAMES utf8mb4;
START TRANSACTION;

CREATE TABLE IF NOT EXISTS `pw_service_liability_rule`(
    `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `rule_code` VARCHAR(32) NOT NULL,
    `rule_name` VARCHAR(64) NOT NULL,
    `transfer_rate` DECIMAL(6, 4) NOT NULL,
    `abort_rate` DECIMAL(6, 4) NOT NULL,
    `enabled` TINYINT(1) DEFAULT 1 NOT NULL,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    UNIQUE KEY `uk_pw_service_liability_rule_code` (`rule_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `pw_service_liability_rule`
  (`rule_code`,`rule_name`,`transfer_rate`,`abort_rate`,`enabled`)
SELECT 'DEFAULT','默认服务责任规则',0.1600,0.2000,1
WHERE NOT EXISTS (SELECT 1 FROM `pw_service_liability_rule` WHERE `enabled`=1);

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'MENU','ServiceLiabilityRule','service-liability-rule','/business/service-liability-rule','服务责任规则','ri:scales-3-line',NULL,9,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p
WHERE p.`name`='BasicConfig'
  AND NOT EXISTS (SELECT 1 FROM `sys_menu` m WHERE m.`name`='ServiceLiabilityRule');

UPDATE `sys_menu` m
JOIN `sys_menu` p ON p.`name`='BasicConfig'
SET m.`parent_id`=p.`id`,m.`path`='service-liability-rule',m.`component`='/business/service-liability-rule',m.`title`='服务责任规则',
    m.`icon`='ri:scales-3-line',m.`sort_no`=9,m.`enabled`=1,m.`updated_at`=CURRENT_TIMESTAMP
WHERE m.`name`='ServiceLiabilityRule';

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'BUTTON','ServiceLiabilityRuleView',NULL,NULL,'查看服务责任规则',NULL,'business:service-liability-rule:view',1,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p
WHERE p.`name`='ServiceLiabilityRule'
  AND NOT EXISTS (SELECT 1 FROM `sys_menu` m WHERE m.`name`='ServiceLiabilityRuleView');

UPDATE `sys_menu` m
JOIN `sys_menu` p ON p.`name`='ServiceLiabilityRule'
SET m.`parent_id`=p.`id`,m.`title`='查看服务责任规则',m.`auth_mark`='business:service-liability-rule:view',m.`enabled`=1,m.`updated_at`=CURRENT_TIMESTAMP
WHERE m.`name`='ServiceLiabilityRuleView';

INSERT INTO `sys_menu`
  (`parent_id`,`type`,`name`,`path`,`component`,`title`,`icon`,`auth_mark`,`sort_no`,`hidden`,`enabled`,`keep_alive`,`created_at`,`updated_at`)
SELECT p.`id`,'BUTTON','ServiceLiabilityRuleUpdate',NULL,NULL,'修改服务责任规则',NULL,'business:service-liability-rule:update',2,0,1,0,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP
FROM `sys_menu` p
WHERE p.`name`='ServiceLiabilityRule'
  AND NOT EXISTS (SELECT 1 FROM `sys_menu` m WHERE m.`name`='ServiceLiabilityRuleUpdate');

UPDATE `sys_menu` m
JOIN `sys_menu` p ON p.`name`='ServiceLiabilityRule'
SET m.`parent_id`=p.`id`,m.`title`='修改服务责任规则',m.`auth_mark`='business:service-liability-rule:update',m.`enabled`=1,m.`updated_at`=CURRENT_TIMESTAMP
WHERE m.`name`='ServiceLiabilityRuleUpdate';

INSERT IGNORE INTO `sys_role_menu` (`role_id`,`menu_id`)
SELECT r.`id`,m.`id`
FROM `sys_role` r JOIN `sys_menu` m
  ON m.`name` IN ('BasicConfig','ServiceLiabilityRule','ServiceLiabilityRuleView','ServiceLiabilityRuleUpdate')
WHERE r.`code`='admin';

COMMIT;

SELECT `id`,`parent_id`,`name`,`path`,`component`,`title`,`enabled`
FROM `sys_menu` WHERE `name`='ServiceLiabilityRule';
