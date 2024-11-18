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
