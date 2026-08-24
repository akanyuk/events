-- from v2.11.0

UPDATE `settings` SET
`attributes` = 'meta_description.desc = SEO: meta_description\r\nmeta_description.type=str\r\n\r\nmeta_keywords.desc = SEO: meta_keywords\r\nmeta_keywords.type=str\r\n\r\nemail_from.desc = e-mail in notifies\r\nemail_from.type=str\r\n\r\nemail_from_name.desc = Sender name in notifies\r\nemail_from_name.type=str\r\n\r\nfooter.desc = Footer content (HTML)\r\nfooter.type = textarea\r\n\r\ndisable_activities.desc = Disable recording of activities\r\ndisable_activities.type = bool\r\n\r\n53c_competition_id.desc = 53c competition ID\r\n53c_competition_id.type = int',
WHERE `id` = '1';