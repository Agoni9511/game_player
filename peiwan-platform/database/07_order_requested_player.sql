USE `peiwan_platform`;

CREATE TABLE IF NOT EXISTS `pw_order_requested_player` (
  `id` BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `order_id` BIGINT NOT NULL,
  `player_id` BIGINT NOT NULL,
  `sort_no` INT DEFAULT 0 NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE KEY `uk_pw_order_requested_player` (`order_id`, `player_id`),
  KEY `ix_pw_order_requested_player_player` (`player_id`, `order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `pw_order_requested_player` (`order_id`, `player_id`, `sort_no`)
SELECT `order_id`, `requested_player_id`, 0
FROM `pw_service_order`
WHERE `requested_player_id` IS NOT NULL;

SELECT 'order_requested_player_ready' AS `result`;
