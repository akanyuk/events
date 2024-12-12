DROP TABLE IF EXISTS `works_interaction`;
CREATE TABLE `works_interaction` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `type` int unsigned NOT NULL DEFAULT '0',
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `message` text,
  `metadata` text,
  `posted` int unsigned NOT NULL DEFAULT '0',
  `posted_by` int unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `works_interaction_unread`;
CREATE TABLE `works_interaction_unread` (
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `user_id` int unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `work_id_user_id` (`work_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `works_interaction_last_read`;
CREATE TABLE `works_interaction_last_read` (
  `interaction_id` int unsigned NOT NULL DEFAULT '0',
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `user_id` int unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `interaction_id_work_id_user_id` (`interaction_id`,`work_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
