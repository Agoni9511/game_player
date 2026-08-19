USE `peiwan_platform`;

INSERT INTO `pw_dispatch_rule`
  (`rule_name`,`grab_minutes`,`max_candidates`,`allow_busy`,`max_active_orders`,`allow_reoffer_after_reject`,`enabled`)
SELECT '默认派单规则', 10, 10, 0, 3, 0, 1
WHERE NOT EXISTS (SELECT 1 FROM `pw_dispatch_rule` WHERE `enabled` = 1);

SELECT `id`,`rule_name`,`grab_minutes`,`max_candidates`,`allow_busy`,`max_active_orders`,`enabled`
FROM `pw_dispatch_rule`
WHERE `enabled` = 1
ORDER BY `id`;
