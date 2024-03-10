ALTER TABLE `works` ADD `status_reason` varchar(512) COLLATE 'utf8_general_ci' NULL AFTER `status`;

DROP TABLE `elements`;

UPDATE `settings`
SET `attributes` = 'meta_description.desc = SEO: meta_description\nmeta_description.type=str\n\nmeta_keywords.desc = SEO: meta_keywords\nmeta_keywords.type=str\n\nemail_from.desc = e-mail in notifies\nemail_from.type=str\n\nemail_from_name.desc = Sender name in notifies\nemail_from_name.type=str\n\ncountdown_date.desc = Countdown date (Mon DD, YYYY)\ncountdown_date.type = str\n\ncountdown_desc.desc = Countdown description (HTML, nl2br)\ncountdown_desc.type = textarea\n\nworks_youtube_tpl.desc = YouTube HTML template<br />Use %id% for videoID\nworks_youtube_tpl.type = textarea\n\n53c_competition_id.desc = 53c competition ID\n53c_competition_id.type = int'
WHERE `id` = '1';
