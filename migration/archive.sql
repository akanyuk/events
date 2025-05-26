-- from v2.0.1
ALTER TABLE `works_comments` ADD `votekey_id` int(10) unsigned NOT NULL AFTER `work_id`;

-- from v2.2.0
ALTER TABLE `works` ADD `status_reason` varchar(512) COLLATE 'utf8_general_ci' NULL AFTER `status`;
DROP TABLE `elements`;
UPDATE `settings` SET `attributes` = 'meta_description.desc = SEO: meta_description\nmeta_description.type=str\n\nmeta_keywords.desc = SEO: meta_keywords\nmeta_keywords.type=str\n\nemail_from.desc = e-mail in notifies\nemail_from.type=str\n\nemail_from_name.desc = Sender name in notifies\nemail_from_name.type=str\n\ncountdown_date.desc = Countdown date (Mon DD, YYYY)\ncountdown_date.type = str\n\ncountdown_desc.desc = Countdown description (HTML, nl2br)\ncountdown_desc.type = textarea\n\nworks_youtube_tpl.desc = YouTube HTML template<br />Use %id% for videoID\nworks_youtube_tpl.type = textarea\n\n53c_competition_id.desc = 53c competition ID\n53c_competition_id.type = int' WHERE `id` = '1';
ALTER TABLE `events` ADD `alias_group` varchar(32) NULL AFTER `alias`;

-- from v2.3.0
CREATE TABLE `competitions_groups` (`id` int unsigned NOT NULL AUTO_INCREMENT, `event_id` int unsigned NOT NULL DEFAULT '0', `position` int unsigned NOT NULL, `title` varchar(255) NOT NULL, `announcement` text, PRIMARY KEY (`id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
ALTER TABLE `competitions` ADD `competitions_groups_id` int unsigned NOT NULL AFTER `event_id`;

-- from v2.5.0
DROP TABLE IF EXISTS `timeline`; CREATE TABLE `timeline` (`event_id` int unsigned NOT NULL, `competition_id` int unsigned DEFAULT NULL, `begin` int unsigned NOT NULL DEFAULT '0', `begin_source` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL, `end` int unsigned NOT NULL DEFAULT '0', `end_source` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL, `title` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci, `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci, `type` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL, `is_public` tinyint unsigned NOT NULL) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (`role` varchar(32) DEFAULT NULL, `module` varchar(32) NOT NULL DEFAULT '0', `action` varchar(32) NOT NULL DEFAULT '', `description` varchar(255) DEFAULT NULL, UNIQUE KEY `role` (`role`,`module`,`action`)) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
INSERT INTO `permissions` (`role`, `module`, `action`, `description`) VALUES ('dm-000.base', 'admin', '', 'Entering in control panel'), ('dm-000.base', 'profile', 'admin', 'Editing own profile'), ('dm-000.base', 'events', 'admin', 'Events: view'), ('dm-000.base', 'users', 'read', 'Users: view'), ('dm-100.admin', 'events', 'manage', 'Events: full control'), ('dm-100.admin', 'pages', 'advanced-admin', 'Pages: updating and removing'), ('dm-100.admin', 'permissions', 'update', 'Users permissions: edit'), ('dm-100.admin', 'settings', 'update', 'Settings: view and edit'), ('dm-100.admin', 'users', 'update', 'Users: edit'), ('dm-100.admin', 'view_logs', 'admin', 'View logs'), ('dm-100.admin', 'timeline', 'admin', 'Manage timeline');
ALTER TABLE `votekeys` ADD INDEX `event_id` (`event_id`);
ALTER TABLE `votekeys` ADD INDEX `posted` (`posted`);
ALTER TABLE `votes` ADD INDEX `event_id` (`event_id`);
ALTER TABLE `votes` ADD INDEX `posted` (`posted`);

-- from v2.6.0
UPDATE `works` SET `external_html` = '' WHERE `external_html` LIKE '%iframe%';
ALTER TABLE `events` DROP `one_compo_event`;
ALTER TABLE `events` ADD `voting_system` varchar(16) COLLATE 'utf8mb3_general_ci' NOT NULL DEFAULT 'avg' AFTER `hide_works_count`;
UPDATE `permissions` SET `action` = 'admin', `description` = 'Pages: administration' WHERE `role` = 'dm-100.admin' AND `module` = 'pages';
ALTER TABLE `timeline` ADD `place` varchar(256) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `type`;
ALTER TABLE `timeline` ADD `position` int unsigned NOT NULL DEFAULT '0' FIRST;

-- from v2.7.0
ALTER TABLE `events` ADD `content_column` text COLLATE 'utf8mb3_general_ci' NULL COMMENT 'Content for column' AFTER `content`;
DELETE FROM `settings` WHERE id=3;
UPDATE `settings` SET `attributes` = 'meta_description.desc = SEO: meta_description\r\nmeta_description.type=str\r\n\r\nmeta_keywords.desc = SEO: meta_keywords\r\nmeta_keywords.type=str\r\n\r\nemail_from.desc = e-mail in notifies\r\nemail_from.type=str\r\n\r\nemail_from_name.desc = Sender name in notifies\r\nemail_from_name.type=str\r\n\r\nfooter.desc = Footer content (HTML)\r\nfooter.type = textarea\r\n\r\n53c_competition_id.desc = 53c competition ID\r\n53c_competition_id.type = int' WHERE id=1;

-- from v2.8.0
DROP TABLE `news`;
UPDATE `pages` SET `is_active` = '0' WHERE `id` = '24';
DROP TABLE IF EXISTS `all_comments_viewed`;
CREATE TABLE `all_comments_viewed` (`user_id` int unsigned NOT NULL, UNIQUE KEY `user_id` (`user_id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
DROP TABLE IF EXISTS `works_activity`;
CREATE TABLE `works_activity`(`id` int unsigned NOT NULL AUTO_INCREMENT, `type` int unsigned NOT NULL DEFAULT '0', `work_id` int unsigned NOT NULL DEFAULT '0', `message` text, `metadata` text, `posted` int unsigned NOT NULL DEFAULT '0', `posted_by` int unsigned NOT NULL DEFAULT '1', PRIMARY KEY (`id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
DROP TABLE IF EXISTS `works_activity_unread`;
CREATE TABLE `works_activity_unread`(`work_id` int unsigned NOT NULL DEFAULT '0', `user_id` int unsigned NOT NULL DEFAULT '0',UNIQUE KEY `work_id_user_id` (`work_id`,`user_id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
DROP TABLE IF EXISTS `works_activity_last_read`;
CREATE TABLE `works_activity_last_read` (`activity_id` int unsigned NOT NULL DEFAULT '0', `work_id` int unsigned NOT NULL DEFAULT '0', `user_id` int unsigned NOT NULL DEFAULT '0', UNIQUE KEY `activity_id_work_id_user_id` (`activity_id`,`work_id`,`user_id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;
UPDATE works_managers_notes SET comment = "" WHERE is_marked = 0;
ALTER TABLE `works_managers_notes` DROP `is_checked`, DROP `is_marked`, CHANGE `comment` `comment` text COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `user_id`;
ALTER TABLE `events` ADD `content_column` text COLLATE 'utf8mb3_general_ci' NULL AFTER `content`;

-- from v2.9.0
DELETE FROM works_managers_notes WHERE comment="";
