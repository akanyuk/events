DROP TABLE `news`;
UPDATE `pages`
SET `is_active` = '0'
WHERE `id` = '24';

DROP TABLE IF EXISTS `all_comments_viewed`;
CREATE TABLE `all_comments_viewed`
(
    `user_id` int unsigned NOT NULL,
    UNIQUE KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `works_activity`;
CREATE TABLE `works_activity`
(
    `id`        int unsigned NOT NULL AUTO_INCREMENT,
    `type`      int unsigned NOT NULL DEFAULT '0',
    `work_id`   int unsigned NOT NULL DEFAULT '0',
    `message`   text,
    `metadata`  text,
    `posted`    int unsigned NOT NULL DEFAULT '0',
    `posted_by` int unsigned NOT NULL DEFAULT '1',
    PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `works_activity_unread`;
CREATE TABLE `works_activity_unread`
(
    `work_id` int unsigned NOT NULL DEFAULT '0',
    `user_id` int unsigned NOT NULL DEFAULT '0',
    UNIQUE KEY `work_id_user_id` (`work_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `works_activity_last_read`;
CREATE TABLE `works_activity_last_read`
(
    `activity_id` int unsigned NOT NULL DEFAULT '0',
    `work_id`        int unsigned NOT NULL DEFAULT '0',
    `user_id`        int unsigned NOT NULL DEFAULT '0',
    UNIQUE KEY `activity_id_work_id_user_id` (`activity_id`,`work_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

UPDATE works_managers_notes
SET comment = ""
WHERE is_marked = 0;
ALTER TABLE `works_managers_notes`
DROP
`is_checked`,
DROP
`is_marked`,
CHANGE `comment` `comment` text COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `user_id`;

ALTER TABLE `events`
    ADD `content_column` text COLLATE 'utf8mb3_general_ci' NULL AFTER `content`;