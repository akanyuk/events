-- from v2.10.0
ALTER TABLE `timeline` ADD `uid` varchar(64) COLLATE 'utf8mb3_general_ci' NOT NULL FIRST, CHANGE `place` `location` varchar(256) COLLATE 'utf8mb3_general_ci' NOT NULL AFTER `type`;
