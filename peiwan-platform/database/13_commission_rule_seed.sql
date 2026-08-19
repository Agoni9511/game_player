-- 抽佣规则初始化：远程已有数据库只需执行本文件，无需重跑 01_full_schema.sql。
USE `peiwan_platform`;
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO `pw_commission_rule`
  (`rule_code`,`rule_name`,`commission_rate`,`min_withdraw_amount`,`withdraw_weekday`,`enabled`)
SELECT 'DEFAULT','默认抽佣规则',0.2800,300.00,1,1
WHERE NOT EXISTS (SELECT 1 FROM `pw_commission_rule` WHERE `enabled`=1);

COMMIT;

SELECT `id`,`rule_code`,`rule_name`,`commission_rate`,`min_withdraw_amount`,`withdraw_weekday`,`enabled`
FROM `pw_commission_rule`
WHERE `enabled`=1 ORDER BY `id` LIMIT 1;
