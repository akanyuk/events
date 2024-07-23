DROP TABLE IF EXISTS `timeline`;
CREATE TABLE `timeline`
(
    `event_id`       int unsigned NOT NULL,
    `competition_id` int unsigned DEFAULT NULL,
    `ts`             int unsigned NOT NULL DEFAULT '0',
    `title`          text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
    `type`           varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
    `ts_source`      varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions`
(
    `role`        varchar(32)          DEFAULT NULL,
    `module`      varchar(32) NOT NULL DEFAULT '0',
    `action`      varchar(32) NOT NULL DEFAULT '',
    `description` varchar(255)         DEFAULT NULL,
    UNIQUE KEY `role` (`role`,`module`,`action`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `permissions` (`role`, `module`, `action`, `description`)
VALUES ('dm-000.base', 'admin', '', 'Entering in control panel'),
       ('dm-000.base', 'profile', 'admin', 'Editing own profile'),
       ('dm-000.base', 'events', 'admin', 'Events: view'),
       ('dm-000.base', 'users', 'read', 'Users: view'),
       ('dm-100.admin', 'events', 'manage', 'Events: full control'),
       ('dm-100.admin', 'pages', 'advanced-admin', 'Pages: updating and removing'),
       ('dm-100.admin', 'permissions', 'update', 'Users permissions: edit'),
       ('dm-100.admin', 'settings', 'update', 'Settings: view and edit'),
       ('dm-100.admin', 'users', 'update', 'Users: edit'),
       ('dm-100.admin', 'view_logs', 'admin', 'View logs'),
       ('dm-100.admin', 'timeline', 'admin', 'Manage timeline');