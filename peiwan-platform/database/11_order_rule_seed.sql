-- 订单确认规则初始化：远程已有数据库只需执行本文件，无需重跑 01_full_schema.sql。
USE `peiwan_platform`;
SET NAMES utf8mb4;
START TRANSACTION;

INSERT INTO `pw_order_rule` (`customer_confirm_hours`,`auto_complete_enabled`)
SELECT 24, 1
WHERE NOT EXISTS (SELECT 1 FROM `pw_order_rule`);

COMMIT;

SELECT `id`,`customer_confirm_hours`,`auto_complete_enabled`,`updated_at`
FROM `pw_order_rule`
ORDER BY `id`
LIMIT 1;
