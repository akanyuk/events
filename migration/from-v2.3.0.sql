CREATE TABLE `competitions_groups` (
   `id` int unsigned NOT NULL AUTO_INCREMENT,
   `event_id` int unsigned NOT NULL DEFAULT '0',
   `position` int unsigned NOT NULL,
   `title` varchar(255) NOT NULL,
   `announcement` text,
   PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

ALTER TABLE `competitions` ADD `competitions_groups_id` int unsigned NOT NULL AFTER `event_id`;