DROP TABLE `news`;
UPDATE `pages` SET `is_active` = '0' WHERE `id` = '24';

CREATE TABLE `all_comments_viewed` (
  `user_id` int unsigned NOT NULL,
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;