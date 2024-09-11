UPDATE `works` SET `external_html` = '' WHERE `external_html` LIKE '%iframe%';
ALTER TABLE `events` DROP `one_compo_event`;
ALTER TABLE `events` ADD `voting_system` varchar(16) COLLATE 'utf8mb3_general_ci' NOT NULL DEFAULT 'avg' AFTER `hide_works_count`;
UPDATE `permissions` SET `action` = 'admin', `description` = 'Pages: administration' WHERE `role` = 'dm-100.admin' AND `module` = 'pages';
ALTER TABLE `timeline` ADD `place` varchar(256) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `type`;