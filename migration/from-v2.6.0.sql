UPDATE `works` SET `external_html` = '' WHERE `external_html` LIKE '%iframe%';
ALTER TABLE `events` DROP `one_compo_event`;
