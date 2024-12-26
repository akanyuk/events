-- Adminer 4.8.1 MySQL 9.1.0 dump

SET NAMES utf8;
SET time_zone = '+00:00';
SET foreign_key_checks = 0;
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

DROP TABLE IF EXISTS `all_comments_viewed`;
CREATE TABLE `all_comments_viewed` (
  `user_id` int unsigned NOT NULL,
  UNIQUE KEY `user_id` (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `competitions`;
CREATE TABLE `competitions` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int unsigned NOT NULL DEFAULT '0',
  `competitions_groups_id` int unsigned NOT NULL,
  `position` int unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `alias` varchar(32) NOT NULL DEFAULT '',
  `works_type` varchar(64) NOT NULL DEFAULT '',
  `announcement` text,
  `reception_from` int unsigned NOT NULL DEFAULT '0',
  `reception_to` int unsigned NOT NULL DEFAULT '0',
  `voting_from` int unsigned NOT NULL DEFAULT '0',
  `voting_to` int unsigned NOT NULL DEFAULT '0',
  `posted` int unsigned NOT NULL DEFAULT '0',
  `posted_by` int unsigned NOT NULL DEFAULT '1',
  `posted_username` varchar(128) NOT NULL DEFAULT '',
  `poster_ip` varchar(39) DEFAULT NULL,
  `edited` int unsigned DEFAULT NULL,
  `edited_by` int unsigned DEFAULT NULL,
  `edited_username` varchar(128) NOT NULL DEFAULT '',
  `edited_ip` varchar(39) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `competitions` (`id`, `event_id`, `competitions_groups_id`, `position`, `title`, `alias`, `works_type`, `announcement`, `reception_from`, `reception_to`, `voting_from`, `voting_to`, `posted`, `posted_by`, `posted_username`, `poster_ip`, `edited`, `edited_by`, `edited_username`, `edited_ip`) VALUES
(1,	1,	0,	1,	'The competition',	'the_competition',	'demo',	'The competition announce',	1726261200,	1726433700,	0,	0,	1652170492,	5,	'admin',	'192.168.0.1',	1726325980,	5,	'admin',	'172.21.0.1');

DROP TABLE IF EXISTS `competitions_groups`;
CREATE TABLE `competitions_groups` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int unsigned NOT NULL DEFAULT '0',
  `position` int unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `announcement` text,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `competitions_groups` (`id`, `event_id`, `position`, `title`, `announcement`) VALUES
(25,	68,	2,	'Graphics compos',	'<div class=\"hidden-lang-en\">\r\n    <ul>\r\n        <li>Применение технологий ИИ (в том числе искусственные нейронные сети, GAN и подобные технологии) допускается\r\n            только в конкурсе AI Graphics.</li>\r\n        <li>Изображения эротического/порнографического содержания будут отсеиваться во время предварительного отбора,\r\n            поскольку при голосовании могут иметь несправедливое преимущество над другими работами.</li>\r\n        <li>Просьба воздержаться от оскорблений в адрес конкретных фирм и личностей, а также нецензурной лексики.\r\n            Помните, что ваши работы будут публично демонстрироваться и распространяться.</li>\r\n        <li>Автор должен предоставить 4 промежуточных фазы создания работы (включая стадии рисунка на бумаге, если\r\n            таковой брался за основу) для подтверждения авторства и следования правилам (кроме конкурса AI Graphics).\r\n        </li>\r\n        <li>При показе работы организаторы вправе менять разрешение изображения, исходя из ограничений проекционного\r\n            оборудования. </li>\r\n    </ul>\r\n</div>\r\n<div class=\"hidden-lang-ru\">\r\n    <ul>\r\n        <li>Using AI tools are allowed only for AI Graphics compo!</li>\r\n        <li>Images with erotic/pornographic content will be screened out during pre-selection, as they may have an unfair advantage over other works in the voting process.</li>\r\n        <li>Please refrain from insults to specific companies and personalities, as well as foul language. Remember that your work will be publicly displayed and distributed.</li>\r\n        <li>The author must provide 4 intermediate phases of creation of the work (including the stages of drawing on paper, if it was taken as a basis) to confirm the authorship and adherence to the rules (except for AI Music compo).</li>\r\n        <li>When showing the work, the organisers have the right to change the resolution of the image based on the limitations of the projection equipment. </li>\r\n    </ul>\r\n</div>'),
(32,	68,	3,	'Various',	''),
(24,	68,	1,	'Music compos',	'<div class=\"hidden-lang-en\">\r\n    <ul>\r\n        <li>Общие правила для категории Music compos</li>\r\n        <li>Работы должны быть оригинальными, т.е. полностью придуманы и созданы самими участниками конкурса (кроме\r\n            конкурса AI Music).</li>\r\n        <li>Применение технологий ИИ (в том числе искусственные нейронные сети, GAN и подобные технологии)\r\n            допускается только в конкурсе AI Music.</li>\r\n        <li>Ремиксы/ремейки/каверы — запрещены. Также запрещено использование легко узнаваемых мелодических оборотов\r\n            из широко известных музыкальных композиций.</li>\r\n        <li>Не допускается использование одной и той же композиции или её фрагментов, в разных номинациях (например,\r\n            фрагмента из Chiptune music для .mp3 конкурсов).</li>\r\n        <li>Старайтесь выполнить нормализацию (normalize) под 0 дБ, чтобы избежать разброса громкости во время\r\n            показа.</li>\r\n        <li>Заимствованный вокал длиной более 1-й секунды не допускается, так как превышает предел цитирования\r\n            объектов авторских прав в РФ.</li>\r\n        <li>Участник должен предоставить организаторам 4 промежуточных этапа создания композиции или исходный файл\r\n            проекта в формате редактора, в качестве подтверждения авторства (кроме конкурса AI Music).</li>\r\n        <li>Битрейт файла для .mp3 — 320 Kbps (CBR).</li>\r\n        <li>ID_TAG и/или другие авторские поля должны быть заполнены.</li>\r\n        <li>Максимальное количество работ в каждой номинации — 20;</li>\r\n    </ul>\r\n</div>\r\n<div class=\"hidden-lang-ru\">\r\n    <ul>\r\n        <li>Using AI tools are allowed only for AI Music compo!</li>\r\n        <li>Works must be original, i.e. completely invented and created by the contestants themselves (except for AI Music compo).</li>\r\n        <li>Remixes/remakes/covers are forbidden. It is also forbidden to use easily recognisable melodic turns from well-known musical compositions.</li>        \r\n        <li>It is not allowed to use the same song or its fragments in different categories (for example, a fragment from Chiptune music for .mp3 contests).</li>        \r\n        <li>Try to normalise at 0dB to avoid volume scatter during the show.</li>\r\n        <li>Borrowed vocals longer than 1 second are not allowed, as they exceed the limit of copyright citations in the Russian Federation.</li>\r\n        <li>The participant must provide the organisers with 4 intermediate stages of composition creation or the original project file in editor format as proof of authorship (except for AI Music compo).</li>\r\n        <li>The file bitrate for .mp3 is 320 Kbps (CBR).</li>\r\n        <li>ID_TAG and/or other author fields must be filled in.</li>\r\n        <li>The maximum number of works in each category is 20;</li>\r\n    </ul>\r\n</div>');

DROP TABLE IF EXISTS `events`;
CREATE TABLE `events` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `is_hidden` tinyint unsigned NOT NULL DEFAULT '0',
  `title` varchar(255) NOT NULL,
  `alias` varchar(32) NOT NULL DEFAULT '',
  `alias_group` varchar(32) DEFAULT NULL,
  `announcement` text,
  `announcement_og` varchar(128) DEFAULT NULL COMMENT 'Announcement for Open Graph',
  `date_from` int unsigned NOT NULL DEFAULT '0',
  `date_to` int unsigned NOT NULL DEFAULT '0',
  `content` text,
  `content_column` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci COMMENT 'Content for column',
  `hide_works_count` tinyint unsigned NOT NULL DEFAULT '0',
  `voting_system` varchar(16) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'avg',
  `posted` int unsigned NOT NULL DEFAULT '0',
  `options` text NOT NULL,
  `posted_by` int unsigned NOT NULL DEFAULT '1',
  `posted_username` varchar(128) NOT NULL DEFAULT '',
  `poster_ip` varchar(39) DEFAULT NULL,
  `edited` int unsigned DEFAULT NULL,
  `edited_by` int unsigned DEFAULT NULL,
  `edited_username` varchar(128) NOT NULL DEFAULT '',
  `edited_ip` varchar(39) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `events` (`id`, `is_hidden`, `title`, `alias`, `alias_group`, `announcement`, `announcement_og`, `date_from`, `date_to`, `content`, `content_column`, `hide_works_count`, `voting_system`, `posted`, `options`, `posted_by`, `posted_username`, `poster_ip`, `edited`, `edited_by`, `edited_username`, `edited_ip`) VALUES
(1,	0,	'The event',	'the_event',	NULL,	'The event announce',	'',	1726261200,	1726433999,	'<p>The event description</p>',	'<p>Description in column</p>',	0,	'avg',	1652170374,	'YTowOnt9',	5,	'admin',	'192.168.0.1',	1731229960,	5,	'admin',	'172.19.0.1');

DROP TABLE IF EXISTS `events_managers`;
CREATE TABLE `events_managers` (
  `event_id` int unsigned NOT NULL,
  `user_id` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`event_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `logs`;
CREATE TABLE `logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `posted` int unsigned NOT NULL DEFAULT '0',
  `poster` int unsigned NOT NULL DEFAULT '0',
  `poster_username` varchar(64) DEFAULT NULL,
  `ip` varchar(39) NOT NULL DEFAULT '0',
  `url` varchar(255) NOT NULL DEFAULT '',
  `message` text NOT NULL,
  `additional` text,
  `kind` int unsigned NOT NULL DEFAULT '0',
  `user_agent` varchar(255) DEFAULT NULL,
  `browser` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `logs` (`id`, `posted`, `poster`, `poster_username`, `ip`, `url`, `message`, `additional`, `kind`, `user_agent`, `browser`) VALUES
(1,	1731228096,	5,	'admin',	'172.19.0.1',	'http://events.local/?action=login',	'',	NULL,	10,	'Mozilla/5.0 (X11; Linux x86_64; rv:132.0) Gecko/20100101 Firefox/132.0',	NULL),
(2,	1734942882,	5,	'admin',	'172.19.0.1',	'http://events.local/admin',	'',	NULL,	10,	'Mozilla/5.0 (X11; Linux x86_64; rv:133.0) Gecko/20100101 Firefox/133.0',	NULL);

DROP TABLE IF EXISTS `media`;
CREATE TABLE `media` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `position` int unsigned NOT NULL DEFAULT '0',
  `owner_id` int unsigned NOT NULL DEFAULT '0',
  `owner_class` varchar(32) NOT NULL DEFAULT '',
  `session_id` varchar(16) DEFAULT NULL,
  `secure_storage` tinyint unsigned NOT NULL DEFAULT '0',
  `basename` varchar(255) NOT NULL DEFAULT '',
  `filesize` int unsigned NOT NULL DEFAULT '0',
  `comment` text,
  `posted_by` int unsigned NOT NULL DEFAULT '0',
  `posted_username` varchar(128) NOT NULL DEFAULT '',
  `poster_ip` varchar(39) NOT NULL DEFAULT '',
  `posted` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `media` (`id`, `position`, `owner_id`, `owner_class`, `session_id`, `secure_storage`, `basename`, `filesize`, `comment`, `posted_by`, `posted_username`, `poster_ip`, `posted`) VALUES
(1,	0,	1,	'works',	NULL,	1,	'readme.md',	1052,	'',	5,	'admin',	'172.21.0.1',	1726326023);

DROP TABLE IF EXISTS `media_sessions`;
CREATE TABLE `media_sessions` (
  `session_id` varchar(16) CHARACTER SET utf8mb3 COLLATE utf8mb3_estonian_ci NOT NULL DEFAULT '',
  `data` text,
  `posted` int unsigned NOT NULL DEFAULT '0',
  `posted_by` int unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `session_id` (`session_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `media_sessions` (`session_id`, `data`, `posted`, `posted_by`) VALUES
('m213e4073de57ec0',	'YToxMzp7czoxNDoic2FmZV9maWxlbmFtZXMiO2I6MTtzOjEyOiJmb3JjZV9yZW5hbWUiO2I6MTtzOjExOiJpbWFnZXNfb25seSI7YjowO3M6OToidG1iX3dpZHRoIjtpOjEwMDtzOjEwOiJ0bWJfaGVpZ2h0IjtpOjEwMDtzOjExOiJpbWFnZV9tYXhfeCI7aToyMDQ4O3M6MTE6ImltYWdlX21heF95IjtpOjIwNDg7czoxMToib3duZXJfY2xhc3MiO3M6NjoiZXZlbnRzIjtzOjg6Im93bmVyX2lkIjtzOjE6IjEiO3M6MTQ6InNlY3VyZV9zdG9yYWdlIjtiOjA7czoxMzoiTUFYX0ZJTEVfU0laRSI7aTo2NzEwODg2NDtzOjE2OiJNQVhfU0VTU0lPTl9TSVpFIjtpOjY3MTA4ODY0O3M6MTA6InNlc3Npb25faWQiO3M6MTY6Im0yMTNlNDA3M2RlNTdlYzAiO30=',	1731229686,	5),
('m7075301f520793d',	'YToxNzp7czoxNDoic2FmZV9maWxlbmFtZXMiO2I6MTtzOjEyOiJmb3JjZV9yZW5hbWUiO2I6MTtzOjExOiJpbWFnZXNfb25seSI7YjoxO3M6OToidG1iX3dpZHRoIjtpOjEwMDtzOjEwOiJ0bWJfaGVpZ2h0IjtpOjEwMDtzOjExOiJpbWFnZV9tYXhfeCI7aToyMDQ4O3M6MTE6ImltYWdlX21heF95IjtpOjIwNDg7czoxMToib3duZXJfY2xhc3MiO3M6MjA6ImV2ZW50c19wcmV2aWV3X2xhcmdlIjtzOjg6Im93bmVyX2lkIjtzOjE6IjEiO3M6MTM6InNpbmdsZV91cGxvYWQiO2I6MTtzOjg6InRlbXBsYXRlIjtzOjI2OiJfYWRtaW5fZXZlbnRzX3ByZXZpZXdfZm9ybSI7czoxNToicHJldmlld19kZWZhdWx0IjtzOjQ5OiJodHRwOi8vZXZlbnRzLmxvY2FsL2Fzc2V0cy9tYWluL25ld3Mtbm8taW1hZ2UucG5nIjtzOjc6InByZXZpZXciO2E6Mjp7czoyOiJpZCI7YjowO3M6MzoidXJsIjtiOjA7fXM6MTQ6InNlY3VyZV9zdG9yYWdlIjtiOjA7czoxMzoiTUFYX0ZJTEVfU0laRSI7aTo2NzEwODg2NDtzOjE2OiJNQVhfU0VTU0lPTl9TSVpFIjtpOjY3MTA4ODY0O3M6MTA6InNlc3Npb25faWQiO3M6MTY6Im03MDc1MzAxZjUyMDc5M2QiO30=',	1731229686,	5),
('m474cb6862ec5a7b',	'YToxNzp7czoxNDoic2FmZV9maWxlbmFtZXMiO2I6MTtzOjEyOiJmb3JjZV9yZW5hbWUiO2I6MTtzOjExOiJpbWFnZXNfb25seSI7YjoxO3M6OToidG1iX3dpZHRoIjtpOjEwMDtzOjEwOiJ0bWJfaGVpZ2h0IjtpOjEwMDtzOjExOiJpbWFnZV9tYXhfeCI7aTo2NDtzOjExOiJpbWFnZV9tYXhfeSI7aTo2NDtzOjExOiJvd25lcl9jbGFzcyI7czoxNDoiZXZlbnRzX3ByZXZpZXciO3M6ODoib3duZXJfaWQiO3M6MToiMSI7czoxMzoic2luZ2xlX3VwbG9hZCI7YjoxO3M6ODoidGVtcGxhdGUiO3M6MjY6Il9hZG1pbl9ldmVudHNfcHJldmlld19mb3JtIjtzOjE1OiJwcmV2aWV3X2RlZmF1bHQiO3M6NDk6Imh0dHA6Ly9ldmVudHMubG9jYWwvYXNzZXRzL21haW4vbmV3cy1uby1pbWFnZS5wbmciO3M6NzoicHJldmlldyI7YToyOntzOjI6ImlkIjtiOjA7czozOiJ1cmwiO2I6MDt9czoxNDoic2VjdXJlX3N0b3JhZ2UiO2I6MDtzOjEzOiJNQVhfRklMRV9TSVpFIjtpOjY3MTA4ODY0O3M6MTY6Ik1BWF9TRVNTSU9OX1NJWkUiO2k6NjcxMDg4NjQ7czoxMDoic2Vzc2lvbl9pZCI7czoxNjoibTQ3NGNiNjg2MmVjNWE3YiI7fQ==',	1731229686,	5);

DROP TABLE IF EXISTS `pages`;
CREATE TABLE `pages` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text,
  `path` varchar(255) NOT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` varchar(255) DEFAULT NULL,
  `is_active` int unsigned NOT NULL DEFAULT '1' COMMENT 'Страница активна',
  `posted` int unsigned NOT NULL DEFAULT '0',
  `posted_username` varchar(128) NOT NULL DEFAULT '',
  `posted_by` int unsigned NOT NULL DEFAULT '1',
  `poster_ip` varchar(39) DEFAULT NULL,
  `edited` int unsigned DEFAULT NULL,
  `edited_username` varchar(128) NOT NULL DEFAULT '',
  `edited_by` int unsigned DEFAULT NULL,
  `edited_ip` varchar(39) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `pages` (`id`, `title`, `content`, `path`, `meta_keywords`, `meta_description`, `is_active`, `posted`, `posted_username`, `posted_by`, `poster_ip`, `edited`, `edited_username`, `edited_by`, `edited_ip`) VALUES
(1,	'Retroscene events',	'',	'',	NULL,	NULL,	1,	1350668388,	'',	3,	'127.0.0.1',	1517481585,	'nyuk',	2,	'176.126.53.120'),
(5,	'Новости',	'',	'news.html',	NULL,	NULL,	1,	1367867472,	'nyuk',	3,	'127.0.0.1',	1408806991,	'nyuk',	2,	'91.215.205.251'),
(7,	'Регистрация',	'',	'register.html',	NULL,	NULL,	1,	1378050219,	'nyuk',	3,	'127.0.0.1',	1406099938,	'nyuk',	2,	'95.53.248.34'),
(10,	'Private Office',	'',	'cabinet',	NULL,	NULL,	1,	1388433699,	'nyuk',	2,	'91.215.205.251',	NULL,	'',	NULL,	NULL),
(11,	'События',	'',	'events',	NULL,	NULL,	1,	1388434504,	'nyuk',	2,	'91.215.205.251',	1403068978,	'nyuk',	2,	'95.53.248.34'),
(13,	'Operator workflow',	'<h2>Панель администрирования</h2>\n\n<div class=\"alert alert-danger\">Функционал панели администрирования проверялся в браузерах Firefox и Chrome. Работа в других браузерах не гарантируется!</div>\n\n<h3>1. В разделе <strong>Events</strong> создать новую запись, где:</h3>\n\n<p><strong>Title</strong> - основной заголовок события.</p>\n\n<p><strong>alias</strong> - псевдоним, используемый в качестве имени каталога при формировании пака работ. Смену псевдонима необходимо согласовывать с администратором.</p>\n\n<p><strong>Date from / Date </strong><strong>to</strong> - даты начала и окончания события. Информационные поля, отображаемые в списке событий. На функционал сайта не влияют.</p>\n\n<p><strong>Announce</strong> - краткий анонс. Отображается в списке событий. Допустимо использование HTML-верстки. Перевод строки автоматически преобразуется в <em>&lt;</em><em>br /&gt;.</em></p>\n\n<p><strong>Disabled - </strong>временно скрыть мероприятие из списка событий.</p>\n\n<p>&nbsp;</p>\n\n<p>Ниже находится форма загрузки файлов. Загруженные файлы могут использоваться на усмотрение оператора. Если в качестве комментария к загруженному файлу указать &quot;<strong>announce&quot;</strong><strong>, </strong>то этот файл будет использоваться в качестве логотипа в списке событий. Загруженный файл должен быть изображением PNG/JPG/GIF размером 64х64 пикс.</p>\n\n<p>&nbsp;</p>\n\n<p><strong>Description -</strong> подробное описание события, отображаемое на сайте. Используется визуальный HTML-редактор. Загруженные ранее изображения и файлы можно автоматически прикреплять в текст: кнопка Image или Link, далее выбрать &quot;Browse Server&quot;.</p>\n\n<p><strong>Votelist -</strong> автоматическое формирование листов для голосования на патиплейс. Если был загружен логотип (см. выше), то он будет отобразится в листе голосования.</p>\n\n<p><strong>Builders </strong><strong>- </strong>раздел позволяет сформировать файл с результатами (results.txt) и пак работ. (см. ниже)</p>\n\n<p>&nbsp;</p>\n\n<h3>2. В разделе <strong>Competitions</strong> необходимые конкурсы.</h3>\n\n<p><strong>Title - </strong>название.</p>\n\n<p><strong>alias</strong> - псевдоним, используемый в качестве имени каталога при формировании пака работ.</p>\n\n<p><strong>Announce</strong> - краткий анонс. Отображается в разделе информации о номинации, при голосовании, при просмотре работ после голосования. Допустимо использование HTML-верстки. Перевод строки автоматически преобразуется в <em>&lt;</em><em>br /&gt;.</em></p>\n\n<p><strong>Works accepting start / Works accepting end</strong> - время начала и окончания приема работ. Если прием работ будет осуществляться не через сайт, например по электронной почте, то можно не указывать.</p>\n\n<p><strong>Voting start / Voting end </strong>- время голосования. До начала голосования просмотр работ посетителям сайта не доступен (кроме авторов). После окончания голосования работы остаются доступны для просмотра. Если не указаны ни время начала, ни время окончания голосования, то работы в этой номинации станут доступны для просмотра сразу после принятия (установки соответствующего статуса).</p>\n\n<p>&nbsp;</p>\n\n<h3>3. В разделе <strong>Works</strong> добавить работы.</h3>\n\n<p><strong>Title / </strong><strong>Author </strong>- название и автор работы (группа). Информация для отображения на сайте, в листах голосования, в файле результатов.</p>\n\n<p><strong>Platform - </strong>платформа. Можно выбрать из списка ранее введенных платформ или ввести вручную.</p>\n\n<p><strong>Format </strong>- необязательное поле для уточнения формата там, где это необходимо. Например, если в номинации участвует различная графика, то здесь можно указать SCR, GigaScreen, MGS...</p>\n\n<p><strong>Status</strong> - статус работы:</p>\n\n<p><em>Unchecked - статус, устанавливаемый при создании работы. Голосование: <strong>нет</strong>, релиз: <strong>нет</strong>.</em></p>\n\n<p><em>Checked - основной статус. Голосование: <strong>да</strong>, релиз: <strong>да</strong>.</em></p>\n\n<p><em>Disqualified - дисквалифицирована. Голосование: <strong>нет</strong>, релиз: <strong>нет</strong>.</em></p>\n\n<p><em>Feedback needed - ожидание. Голосование: <strong>нет</strong>, релиз: <strong>нет</strong>.</em></p>\n\n<p><em>Out of competition - вне конкурса. . Голосование: <strong>нет</strong>, релиз: <strong>да</strong>.</em></p>\n\n<p><strong>External HTML - </strong>вручную отформатированный HTML-код. Например, ролик на Youtube, ссылки на pouet.net, zxart.ee, zxaaa.net...</p>\n\n<p>Код, предоставляемая сервисом Youtube по умолчанию не совместима с дизайном сайта: будут перекрываться диалоговые окна. Чтобы этого не произошло необходимо использовать примерно такой код:</p>\n\n<pre>\n&lt;iframe width=&quot;640&quot; height=&quot;480&quot; src=&quot;//www.youtube.com/embed/2kNL8taPg5Q?wmode=transparent&quot; frameborder=&quot;0&quot; allowfullscreen&gt;&lt;/iframe&gt;</pre>\n\n<p>&nbsp;</p>\n\n<p><strong>Manage files</strong> - раздел для управления всеми загруженными файлами работы. Для каждого из файлов необходимо установить опции:</p>\n\n<p><strong>screenshot - </strong>отображается только в ЛК автора. Автоматически уменьшается по ширине до 160 пикс. Желательно не использовать слишком крупные изображения.</p>\n\n<p><strong>image - </strong>картинка, отображаемая при голосовании и при просмотре работы после голосования. Допустимые форматы: png, jpg, gif. Предпочтительный размер: 640х480 пикс. (2x-scale, small border в случае ZX Spectrum)</p>\n\n<p><strong>audio - </strong>файлы для прослушивания в браузере. Для лучшей совместимости желательно загрузить mp3 и ogg варианты.</p>\n\n<p><strong>voting - </strong>файл(ы), которые будут доступны для скачивания при голосовании.</p>\n\n<p><strong>release - </strong>файл(ы) для скачивания после голосования. Эти же файл будут упакованы в финальный пак работ. Предпочтительно загрузить zip-архив со всеми необходимыми файлами: сама работа, file_id.diz, steps... При создании пака такой архив будет автоматически &quot;перепакован&quot;.</p>\n\n<p>&nbsp;</p>\n\n<p><strong>Current permanent archive link</strong> - прямая ссылка на скачивание работы (если есть).<br />\nИмеет вид: <em>https://events.retroscene.org/files/%event_alias%/%competition_alias%/%title%.zip</em></p>\n\n<p>Ниже кнопка создания прямой ссылки. В архив попадут все файлы с опцией `release`. Можно автоматически сгенерировать и добавить в архив file_id.diz. Операция необратима!</p>\n\n<p>&nbsp;</p>\n\n<h3>4. Процесс голосования контролируется из раздела <strong>Voting.</strong></h3>\n\n<p><strong>Votekeys - </strong>все сгенерированные ключи голосование. Есть возможность добавить необходимое количество ключей.</p>\n\n<p><strong>Votes - </strong>все учтенные голоса. Здесь же нужно добавлять результаты голосования на патиплейс.</p>\n\n<p><strong>Results - </strong>предварительные результаты голосования. Кнопка &quot;Save results&quot; сохраняет результаты голосования в профиле работ. После этого результаты становятся видны посетителям сайта (при условии, что голосование закончилось). Действие отменить невозможно! Можно только перезаписать результаты более свежими.</p>\n\n<div class=\"alert alert-info\">Занятое работой место определяется значением &quot;Average&quot;. Если у двух работ одинаковый средний балл, то победитель выбирается по наибольшему значению &quot;Total&quot;. Если и общая сумма голосов одинакова, то работы считаются занявшими одно место.</div>\n\n<p>&nbsp;</p>\n\n<h2>Взаимодействие с автором</h2>\n\n<div class=\"alert alert-warning\">Желательно, чтобы работы загружались на сайт самим автором, а не оператором, т.к. в текущей версии сайта &quot;привязать&quot; работу к другому автору можно только вручную, по запросу администратору.</div>\n\n<p>При загрузке автор обязательно указывает заголовок, автора/группу (так, как это будет отображаться на сайте), платформу (выбирает из списка или вводит вручную).&nbsp; Остальные поля не обязательны.</p>\n\n<p>Отправить работу можно только загрузив хотя бы один файл. Если автор загрузил файлы, но не нажал кнопку &quot;Отправить работу&quot; и покинул страницу, то загруженные файлы будут потеряны. В текущей версии сайта автор не может дозагрузить файлы после отправки работы.</p>\n\n<p>В личном кабинете автор видит: название работы, автора, платформу, формат, статус, скриншот. Тремя отдельными списками отображаются: файлы, используемые при голосовании, файлы для релиза, все прочие файлы.</p>\n\n<p>Все файлы автор может скачать, но у незарегистрированных пользователей эти ссылки работать не будут.</p>\n\n<p>&nbsp;</p>\n\n<h2>Голосование</h2>\n\n<p>Голосование проводится на основной странице мероприятия: https://events.retroscene.org/%alias%</p>\n\n<p>Для участия в голосовании необходимо запросить ключ, который высылается на указанный e-mail адрес. Если посетитель повторно запросил ключ на тот же самый e-mail, то новый ключ сгенерирован не будет. Вместо этого будет отправлен тот же самый ключ.</p>\n\n<p>Голосовать за одни и те же работы можно сколько угодно раз, но учтен будет только последний сабмит. Сайт запоминает проставленные оценки. При повторном заходе на страницу оценки будут автоматически загружены (только если используется тот же самый компьютер и браузер). Последний использованный ключ голосования и указанное имя запоминаются после нажатия &quot;Проголосовать&quot;.</p>\n\n<p>&nbsp;</p>\n\n<h2>После голосования</h2>\n\n<p>После окончания голосования все работы останутся доступны для просмотра. После того, как оператор сохранит результаты голосования (кнопка &quot;Save results&quot;), эта будет доступна посетителям сайта.</p>\n\n<p>Перед сохранением файла results.txt оператор может вручную добавить в него необходимый текст: ASCII-арт и пр.</p>\n\n<p>При сборке пака работ файл с результатами добавляется только, если установлена галочка &quot; Attach `results.txt` into archive&quot;. &nbsp;В архив попадает не сохраненный ранее файл, а текущее содержимое поля &quot;results.txt&quot;.</p>\n\n<p>Все файлы сохраняются на сервер, в каталог <em>/files/%alias%. </em>После сохранения на экране отобразится ссылка для скачивания.</p>',	'operator-workflow.html',	NULL,	NULL,	1,	1402253332,	'nyuk',	2,	'91.215.205.251',	1402697562,	'nyuk',	2,	'91.215.205.251'),
(21,	'API help 0.03',	'<h1>API сайта events.retroscene.org</h1>\r\n\r\n<p>версия: 0.03<br />\r\nдата: 2019-01-11</p>\r\n\r\n<h3>1.1 Общая информация</h3>\r\n\r\n<p>Взаимодействие с API сайта производится по адресу <strong><a href=\"https://events.retroscene.org/api\">https://events.retroscene.org/api</a></strong><br />\r\nПараметры запроса со стороны клиента передаются с помощью POST-запроса. Ответ сервера по умолчанию &ndash; XML. Если в POST или GET запросе клиента установлен параметр <strong>ResponseType</strong> со значением json, то ответ сервера переформатируется в JSON.</p>\r\n\r\n<p>Для тестирования API можно использовать следующую страницу: <strong><a href=\"https://events.retroscene.org/api_test\">https://events.retroscene.org/api_test</a></strong></p>\r\n\r\n<h3>1.2 Общие поля ответа API</h3>\r\n\r\n<p>Каждый ответе серверв возвращает следующие обязательные поля:<br />\r\n<strong>Status: </strong>результат обработки запроса. success &ndash; успешно, error &ndash; ошибка.<br />\r\n<strong>IsGuest</strong> - признак авторизации на сайте. 0 - нет, 1 - да.<br />\r\n<strong>Username</strong> - имя пользователя, в данный момент авторизовнного на сайте.</p>\r\n\r\n<h3>1.3 Формат сообщения об ошибке</h3>\r\n\r\n<p>В случае ошибки сервер возвращает ответ следующего содержания:<br />\r\n<strong>Message</strong> - текстовое сообщение с ошибкой.</p>\r\n\r\n<pre>\r\n&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;\r\n&lt;Document&gt;\r\n&nbsp; &lt;Status&gt;error&lt;/Status&gt;\r\n&nbsp; &lt;Message&gt;&laquo;Title&raquo; is required field.&lt;/Message&gt;\r\n&nbsp; &lt;Username&gt;nyuk&lt;/Username&gt;\r\n&nbsp; &lt;IsGuest&gt;0&lt;/IsGuest&gt;\r\n&lt;/Document&gt;</pre>\r\n\r\n<h3>&nbsp;</h3>\r\n\r\n<h2>2. Запросы к API</h2>\r\n\r\n<h3>2.1 Получение статуса текущего компо 53c</h3>\r\n\r\n<p>URL запроса: <strong>https://events.retroscene.org/api/competitions/get53c</strong></p>\r\n\r\n<p>Возвращаемые поля:</p>\r\n\r\n<p><strong>Competition -&gt; Title</strong> &ndash; название компо<br />\r\n<strong>Competition -&gt; EventTitle</strong> &ndash; название события (пати)<br />\r\n<strong>Competition -&gt; ReceptionAvailable</strong> &ndash; прием работ открыт: 1, закрыт: 0<br />\r\n<strong>Competition -&gt; ReceptionFrom</strong> &ndash; начало приема работ, дата в формате UNIX TIMESTAMP<br />\r\n<strong>Competition -&gt; ReceptionTo</strong> &ndash; окончание приема работ, дата в формате UNIX TIMESTAMP<br />\r\n<strong>Competition -&gt; VotingFrom</strong> &ndash; начало голосования, дата в формате UNIX TIMESTAMP<br />\r\n<strong>Competition -&gt; VotingTo</strong> &ndash; окончание голосования, дата в формате UNIX TIMESTAMP</p>\r\n\r\n<p>Пример ответа сервера:</p>\r\n\r\n<pre>\r\n&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;\r\n&lt;Document&gt;\r\n&nbsp; &lt;Status&gt;success&lt;/Status&gt;\r\n&nbsp; &lt;Username&gt;nyuk&lt;/Username&gt;\r\n&nbsp; &lt;IsGuest&gt;0&lt;/IsGuest&gt;\r\n&nbsp; &lt;Competition&gt;\r\n&nbsp;&nbsp; &nbsp;&lt;Title&gt;Тестирование 53c&lt;/Title&gt; \r\n&nbsp;&nbsp;&nbsp; &lt;EventTitle&gt;Artfield 2016&lt;/EventTitle&gt;\r\n&nbsp;&nbsp; &nbsp;&lt;ReceptionAvailable&gt;1&lt;/ReceptionAvailable&gt;\r\n&nbsp;&nbsp; &nbsp;&lt;ReceptionFrom&gt;1476306000&lt;/ReceptionFrom&gt;\r\n&nbsp;&nbsp; &nbsp;&lt;ReceptionTo&gt;1483217940&lt;/ReceptionTo&gt;\r\n&nbsp;&nbsp; &nbsp;&lt;VotingFrom&gt;1483218000&lt;/VotingFrom&gt;\r\n&nbsp;&nbsp; &nbsp;&lt;VotingTo&gt;1483218000&lt;/VotingTo&gt;\r\n&nbsp; &lt;/Competition&gt;\r\n&lt;/Document&gt;</pre>\r\n\r\n<h3>2.2 Загрузка работы на 53c компо</h3>\r\n\r\n<p>URL запроса: <strong>https://events.retroscene.org/api/competitions/upload53c</strong></p>\r\n\r\n<p>Передаваемые POST-запросом поля:</p>\r\n\r\n<p><strong>Title </strong>&ndash; название работы.<br />\r\n<strong>Author</strong> &ndash; имя автора.</p>\r\n\r\n<p>Файл работы должен быть в формате <strong>атрибутной графики ZX Spectrum (768 байт)</strong></p>\r\n\r\n<p>Файл передается с помощью стандартной процедуры загрузки файла &ndash; multipart/form-data. Имя поля, содержащего данные &ndash; любое.</p>\r\n\r\n<p>В случае успешного добавления работы сервер возвращает статус <strong>success</strong></p>\r\n\r\n<h3>2.3 Получение списка текущих и предстоящих событий</h3>\r\n\r\n<p>URL запроса: <strong>https://events.retroscene.org/api/events/upcoming-current</strong></p>\r\n\r\n<p>Возвращаемые поля:</p>\r\n\r\n<p><strong>Events -&gt; Event::ID</strong> &ndash; идентификатор события<br />\r\n<strong>Events -&gt; Event -&gt; Title</strong> &ndash; название события<br />\r\n<strong>Events -&gt; Event -&gt; URL</strong> &ndash; основной адрес события<br />\r\n<strong>Events -&gt; Event -&gt; Announcement</strong> &ndash; анонс события<br />\r\n<strong>Events -&gt; Event -&gt; DateFrom</strong> &ndash; начало события, дата в формате UNIX TIMESTAMP<br />\r\n<strong>Events -&gt; Event -&gt; DateTo</strong> &ndash; окончание события, дата в формате UNIX TIMESTAMP<br />\r\n<strong>Events -&gt; Event -&gt; IsLogo</strong> &ndash; есть логотип: 1, нет логотипа: 0<br />\r\n<strong>Events -&gt; Event -&gt; Logo</strong> &ndash; URL логотипа</p>\r\n\r\n<p>Пример ответа сервера:</p>\r\n\r\n<pre>\r\n&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt; \r\n&lt;Document&gt; \r\n  &lt;Status&gt;success&lt;/Status&gt; \r\n  &lt;Username&gt;nyuk&lt;/Username&gt; \r\n  &lt;IsGuest&gt;0&lt;/IsGuest&gt; \r\n  &lt;Events&gt; \r\n    &lt;Event&gt; \r\n	  &lt;Title&gt;Multimatograf 2018&lt;/Title&gt; \r\n	  &lt;URL&gt;http://events.local/mf2018&lt;/URL&gt; \r\n	  &lt;Announcement&gt;Демопати для настоящих ценителей олдскула, демоспирита и просто хорошего общения. Oldscool aimed demoparty in Vologda city, Russia.&lt;/Announcement&gt; \r\n	  &lt;DateFrom&gt;1524862800&lt;/DateFrom&gt; \r\n	  &lt;DateTo&gt;1525035599&lt;/DateTo&gt; \r\n	  &lt;IsLogo&gt;&lt;/IsLogo&gt; \r\n	  &lt;Logo&gt;http://events.local/assets/main/news-no-image.png&lt;/Logo&gt; \r\n	&lt;/Event&gt; \r\n  &lt;/Events&gt; \r\n&lt;/Document&gt;</pre>\r\n\r\n<h3>2.4 Получение списка работ</h3>\r\n\r\n<p>URL запроса: <strong>https://events.retroscene.org/api/works/get</strong></p>\r\n\r\n<p>Передаваемые параметры:</p>\r\n\r\n<p><strong>EventID</strong><strong> </strong>&ndash; идентификатор события. Если не указан, или 0, то все события.<br />\r\n<strong>CompetitionID</strong><strong> </strong>&ndash; идентификатор компо. Если не указан, или 0, то все компо.<br />\r\n<strong>Limit</strong><strong> </strong>&ndash; количество возвращаемых работ. Максимальное значение 99.<br />\r\n<strong>Offset</strong><strong> </strong>&ndash; Смещение (возвращать работы начиная с указанной позиции).</p>\r\n\r\n<p><em>Параметры можно передавать как в GET, так и в POST-переменных.</em></p>\r\n\r\n<p>Возвращаемые поля:</p>\r\n\r\n<p><strong>Filtered</strong> &ndash; общее количество отфильтрованных работ<br />\r\n<strong>Fetched</strong> &ndash; количество возвращемых работ</p>\r\n\r\n<p><strong>Works -&gt; Work::ID</strong> &ndash; идентификатор работы<br />\r\n<strong>Works -&gt; Work-&gt; Title</strong> &ndash; название работы<br />\r\n<strong>Works -&gt; Work-&gt; Author</strong> &ndash; автор работы<br />\r\n<strong>Works -&gt; Work-&gt; URL</strong> &ndash; URL-адрес страницы работы на events.retroscene.org<br />\r\n<strong>Works -&gt; Work-&gt; ReleaseURL</strong> &ndash; URL-адрес ссылки для скачивания работы. Если адрес не указан, возвращается пустое значение</p>\r\n\r\n<p><strong>Works -&gt; Work-&gt; Competition::ID</strong> &ndash; идентификатор компо<br />\r\n<strong>Works -&gt; Work-&gt; Competition -&gt; Title</strong> &ndash; название компо<br />\r\n<strong>Works -&gt; Work-&gt; Competition -&gt; WorksType</strong> &ndash; тип работ. Возможные варианты: <em>demo, picture, music, other</em></p>\r\n\r\n<p><strong>Works -&gt; Work-&gt; Event::ID</strong> &ndash; идентификатор события<br />\r\n<strong>Works -&gt; Work-&gt; Event -&gt; Title</strong> &ndash; название события<br />\r\n<strong>Works -&gt; Work-&gt; Event -&gt; DateFrom</strong> &ndash; начало события, дата в формате UNIX TIMESTAMP<br />\r\n<strong>Works -&gt; Work-&gt; Event -&gt; DateTo</strong> &ndash; окончание события, дата в формате UNIX TIMESTAMP</p>\r\n\r\n<p>Пример ответа сервера:</p>\r\n\r\n<pre>\r\n&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt; \r\n&lt;Document&gt; \r\n  &lt;Status&gt;success&lt;/Status&gt; \r\n  &lt;Username&gt;nyuk&lt;/Username&gt; \r\n  &lt;IsGuest&gt;0&lt;/IsGuest&gt; \r\n&nbsp; &lt;Filtered&gt;1811&lt;/Filtered&gt;\r\n&nbsp; &lt;Fetched&gt;99&lt;/Fetched&gt;\r\n&nbsp; &lt;Works&gt;\r\n&nbsp;&nbsp;&nbsp; &lt;Work ID=&quot;2026&quot;&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;Title&gt;Dead President&lt;/Title&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;Author&gt;Dalthon ^ Joker&lt;/Author&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;URL&gt;https://events.retroscene.org/dhl2019/LowEnd_1k_gfx/2026&lt;/URL&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;ReleaseURL&gt;https://events.retroscene.org/files/dhl2019/LowEnd_1k_gfx/dead_president.zip&lt;/ReleaseURL&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;Competition ID=&quot;352&quot;&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;Title&gt;LowEnd 1kb Procedural Graphics&lt;/Title&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;WorksType&gt;picture&lt;/WorksType&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;/Competition&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;Event ID=&quot;39&quot;&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;Title&gt;DiHalt 2019 Lite&lt;/Title&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;DateFrom&gt;1546549200&lt;/DateFrom&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;DateTo&gt;1546808399&lt;/DateTo&gt;\r\n&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &lt;/Event&gt;\r\n&nbsp;&nbsp;&nbsp; &lt;/Work&gt;\r\n&nbsp; &lt;/Works&gt;\r\n&lt;/Document&gt;</pre>',	'api_help.html',	NULL,	NULL,	1,	1441644747,	'nyuk',	2,	'91.215.205.251',	1547156292,	'nyuk',	2,	'176.108.147.177'),
(24,	'Комментарии',	'',	'comments.html',	NULL,	NULL,	0,	1452493318,	'nyuk',	2,	'95.53.248.34',	1507499362,	'nyuk',	2,	'176.108.145.39');

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE `permissions` (
  `role` varchar(32) DEFAULT NULL,
  `module` varchar(32) NOT NULL DEFAULT '0',
  `action` varchar(32) NOT NULL DEFAULT '',
  `description` varchar(255) DEFAULT NULL,
  UNIQUE KEY `role` (`role`,`module`,`action`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `permissions` (`role`, `module`, `action`, `description`) VALUES
('dm-000.base',	'admin',	'',	'Entering in control panel'),
('dm-000.base',	'profile',	'admin',	'Editing own profile'),
('dm-000.base',	'events',	'admin',	'Events: view'),
('dm-000.base',	'users',	'read',	'Users: view'),
('dm-100.admin',	'events',	'manage',	'Events: full control'),
('dm-100.admin',	'pages',	'admin',	'Pages: administration'),
('dm-100.admin',	'permissions',	'update',	'Users permissions: edit'),
('dm-100.admin',	'settings',	'update',	'Settings: view and edit'),
('dm-100.admin',	'users',	'update',	'Users: edit'),
('dm-100.admin',	'view_logs',	'admin',	'View logs'),
('dm-100.admin',	'timeline',	'admin',	'Manage timeline');

DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `is_admin` tinyint unsigned NOT NULL DEFAULT '1',
  `name` varchar(255) NOT NULL,
  `varname` varchar(64) NOT NULL DEFAULT '',
  `attributes` text,
  `values` text,
  `edited` int unsigned NOT NULL DEFAULT '0',
  `edited_by` int unsigned NOT NULL DEFAULT '1',
  `edited_username` varchar(128) NOT NULL DEFAULT '',
  `edited_ip` varchar(39) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `settings` (`id`, `is_admin`, `name`, `varname`, `attributes`, `values`, `edited`, `edited_by`, `edited_username`, `edited_ip`) VALUES
(1,	1,	'Project Settings',	'project_settings',	'meta_description.desc = SEO: meta_description\r\nmeta_description.type=str\r\n\r\nmeta_keywords.desc = SEO: meta_keywords\r\nmeta_keywords.type=str\r\n\r\nemail_from.desc = e-mail in notifies\r\nemail_from.type=str\r\n\r\nemail_from_name.desc = Sender name in notifies\r\nemail_from_name.type=str\r\n\r\nfooter.desc = Footer content (HTML)\r\nfooter.type = textarea\r\n\r\n53c_competition_id.desc = 53c competition ID\r\n53c_competition_id.type = int',	'YToxOntpOjA7YTo2OntzOjE2OiJtZXRhX2Rlc2NyaXB0aW9uIjtzOjE2OiJEZW1vc2NlbmUgZXZlbnRzIjtzOjEzOiJtZXRhX2tleXdvcmRzIjtzOjg1OiJEZW1vc2NlbmUsINC00LXQvNC+0YHRhtC10L3QsCwg0LTQtdC80L7Qv9Cw0YLQuCwgWlgtU3BlY3RydW0sIEF0YXJpLCBDb21tb2RvcmUsIEFtaWdhIjtzOjEwOiJlbWFpbF9mcm9tIjtzOjE5OiJib290QHJldHJvc2NlbmUub3JnIjtzOjE1OiJlbWFpbF9mcm9tX25hbWUiO3M6MTk6ImJvb3RAcmV0cm9zY2VuZS5vcmciO3M6NjoiZm9vdGVyIjtzOjYzMjoiPGRpdiBjbGFzcz0iY29udGFpbmVyIj4NCiAgICA8Zm9vdGVyIGNsYXNzPSJkLWZsZXggZmxleC13cmFwIGp1c3RpZnktY29udGVudC1iZXR3ZWVuIGFsaWduLWl0ZW1zLWNlbnRlciBweS0zIG15LTQgYm9yZGVyLXRvcCI+DQogICAgICAgIDxwIGNsYXNzPSJjb2wtbWQtNCBtYi0wIj48YSBocmVmPSJodHRwczovL3JldHJvc2NlbmUub3JnIiBjbGFzcz0ibmF2LWxpbmsgcHgtMiB0ZXh0LWJvZHktc2Vjb25kYXJ5Ij7CqSAyMDI0PC9hPjwvcD4NCg0KICAgICAgICA8dWwgY2xhc3M9Im5hdiBjb2wtbWQtNCBqdXN0aWZ5LWNvbnRlbnQtZW5kIj4NCiAgICAgICAgICAgIDxsaSBjbGFzcz0ibmF2LWl0ZW0iPjxhIGhyZWY9Imh0dHBzOi8vZ2l0aHViLmNvbS9ha2FueXVrL2V2ZW50cyIgY2xhc3M9Im5hdi1saW5rIHB4LTIgdGV4dC1ib2R5LXNlY29uZGFyeSI+U291cmNlczwvYT4NCiAgICAgICAgICAgIDwvbGk+DQogICAgICAgICAgICA8bGkgY2xhc3M9Im5hdi1pdGVtIj48YSBocmVmPSJodHRwczovL3QubWUvcmV0cm9zY2VuZV9ldmVudHMiIGNsYXNzPSJuYXYtbGluayBweC0yIHRleHQtYm9keS1zZWNvbmRhcnkiPlRlbGVncmFtPC9hPjwvbGk+DQogICAgICAgIDwvdWw+DQogICAgPC9mb290ZXI+DQo8L2Rpdj4iO3M6MTg6IjUzY19jb21wZXRpdGlvbl9pZCI7aToxO319',	1731229333,	5,	'admin',	'172.19.0.1');

DROP TABLE IF EXISTS `timeline`;
CREATE TABLE `timeline` (
  `position` int unsigned NOT NULL DEFAULT '0',
  `event_id` int unsigned NOT NULL,
  `competition_id` int unsigned DEFAULT NULL,
  `begin` int unsigned NOT NULL DEFAULT '0',
  `begin_source` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `end` int unsigned NOT NULL DEFAULT '0',
  `end_source` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `title` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `description` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci,
  `type` varchar(32) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `place` varchar(256) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `is_public` tinyint unsigned NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `is_blocked` tinyint unsigned NOT NULL DEFAULT '0',
  `is_group` tinyint unsigned NOT NULL DEFAULT '0',
  `group_id` int unsigned NOT NULL DEFAULT '4',
  `username` varchar(200) NOT NULL DEFAULT '',
  `password` varchar(40) NOT NULL DEFAULT '',
  `salt` varchar(12) DEFAULT NULL,
  `email` varchar(80) NOT NULL DEFAULT '',
  `realname` varchar(40) DEFAULT NULL,
  `language` varchar(25) NOT NULL DEFAULT 'English',
  `country` varchar(2) NOT NULL,
  `city` varchar(100) NOT NULL,
  `registered` int unsigned NOT NULL DEFAULT '0',
  `registration_ip` varchar(39) NOT NULL DEFAULT '0.0.0.0',
  `activate_key` varchar(8) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dvs_users_registered_idx` (`registered`),
  KEY `dvs_users_username_idx` (`username`(8))
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `users` (`id`, `is_blocked`, `is_group`, `group_id`, `username`, `password`, `salt`, `email`, `realname`, `language`, `country`, `city`, `registered`, `registration_ip`, `activate_key`) VALUES
(3,	0,	1,	0,	'Users',	'users',	NULL,	'admins',	NULL,	'English',	'',	'',	0,	'0.0.0.0',	NULL),
(4,	0,	1,	0,	'Unverified',	'users',	NULL,	'admins',	NULL,	'English',	'',	'',	0,	'0.0.0.0',	NULL),
(5,	0,	0,	3,	'admin',	'620a4b8ea9427ba7c1319ace975a7ebb6aaa12ac',	'jl8AxfdLhVVN',	'',	'Administrator',	'English',	'',	'',	1382809375,	'127.0.0.1',	NULL);

DROP TABLE IF EXISTS `users_role`;
CREATE TABLE `users_role` (
  `user_id` int unsigned NOT NULL,
  `role` varchar(32) NOT NULL DEFAULT '',
  UNIQUE KEY `user_id` (`user_id`,`role`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `users_role` (`user_id`, `role`) VALUES
(5,	'dm-000.base'),
(5,	'dm-100.admin');

DROP TABLE IF EXISTS `votekeys`;
CREATE TABLE `votekeys` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int unsigned NOT NULL DEFAULT '0',
  `votekey` varchar(20) NOT NULL DEFAULT '',
  `email` varchar(80) NOT NULL DEFAULT '',
  `useragent` varchar(255) NOT NULL DEFAULT '',
  `posted` int unsigned NOT NULL DEFAULT '0',
  `poster_ip` varchar(39) NOT NULL DEFAULT '0.0.0.0',
  `is_used` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `event_id` (`event_id`),
  KEY `posted` (`posted`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `votekeys` (`id`, `event_id`, `votekey`, `email`, `useragent`, `posted`, `poster_ip`, `is_used`) VALUES
(1,	1,	'97233940',	'',	'Mozilla/5.0 (X11; Linux x86_64; rv:132.0) Gecko/20100101 Firefox/132.0',	1731229539,	'172.19.0.1',	0);

DROP TABLE IF EXISTS `votes`;
CREATE TABLE `votes` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int unsigned NOT NULL DEFAULT '0',
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `votekey_id` int unsigned NOT NULL DEFAULT '0',
  `vote` int NOT NULL DEFAULT '0',
  `username` varchar(200) NOT NULL DEFAULT '',
  `useragent` varchar(255) NOT NULL DEFAULT '',
  `posted` int unsigned NOT NULL DEFAULT '0',
  `poster_ip` varchar(39) NOT NULL DEFAULT '0.0.0.0',
  PRIMARY KEY (`id`),
  KEY `event_id` (`event_id`),
  KEY `posted` (`posted`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `works`;
CREATE TABLE `works` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `competition_id` int NOT NULL DEFAULT '0',
  `status` int unsigned NOT NULL DEFAULT '0',
  `status_reason` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci DEFAULT NULL,
  `position` int unsigned NOT NULL DEFAULT '0',
  `title` varchar(200) NOT NULL DEFAULT '',
  `author` varchar(200) NOT NULL DEFAULT '',
  `author_note` text,
  `description` text,
  `platform` varchar(64) NOT NULL DEFAULT '',
  `format` varchar(128) DEFAULT NULL,
  `external_html` text COMMENT 'Внешний HTML (youtube, vimeo)',
  `media_info` text,
  `release_basename` varchar(255) DEFAULT NULL,
  `place` int unsigned DEFAULT NULL,
  `num_votes` int unsigned DEFAULT NULL,
  `total_scores` int DEFAULT NULL,
  `average_vote` decimal(5,2) DEFAULT NULL,
  `iqm_vote` decimal(5,2) DEFAULT NULL,
  `posted` int unsigned NOT NULL DEFAULT '0',
  `posted_by` int unsigned NOT NULL DEFAULT '1',
  `posted_username` varchar(128) DEFAULT NULL,
  `poster_ip` varchar(39) DEFAULT NULL,
  `edited` int unsigned DEFAULT NULL,
  `edited_by` varchar(200) DEFAULT NULL,
  `edited_username` varchar(128) DEFAULT NULL,
  `edited_ip` varchar(39) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;

INSERT INTO `works` (`id`, `competition_id`, `status`, `status_reason`, `position`, `title`, `author`, `author_note`, `description`, `platform`, `format`, `external_html`, `media_info`, `release_basename`, `place`, `num_votes`, `total_scores`, `average_vote`, `iqm_vote`, `posted`, `posted_by`, `posted_username`, `poster_ip`, `edited`, `edited_by`, `edited_username`, `edited_ip`) VALUES
(1,	1,	0,	'',	1,	'The Prod',	'The Author',	'',	'Display additional: Yes',	'ZX Spectrum',	'',	'',	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	NULL,	1726326025,	5,	'admin',	'172.21.0.1',	NULL,	NULL,	NULL,	NULL);

DROP TABLE IF EXISTS `works_comments`;
CREATE TABLE `works_comments` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `votekey_id` int unsigned NOT NULL,
  `message` text,
  `posted` int unsigned NOT NULL DEFAULT '0',
  `posted_username` varchar(128) NOT NULL DEFAULT '',
  `posted_by` int unsigned NOT NULL DEFAULT '1',
  `poster_ip` varchar(39) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `works_activity`;
CREATE TABLE `works_activity` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `type` int unsigned NOT NULL DEFAULT '0',
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `message` text,
  `metadata` text,
  `posted` int unsigned NOT NULL DEFAULT '0',
  `posted_by` int unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `works_activity_last_read`;
CREATE TABLE `works_activity_last_read` (
  `activity_id` int unsigned NOT NULL DEFAULT '0',
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `user_id` int unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `activity_id_work_id_user_id` (`activity_id`,`work_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `works_activity_unread`;
CREATE TABLE `works_activity_unread` (
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `user_id` int unsigned NOT NULL DEFAULT '0',
  UNIQUE KEY `work_id_user_id` (`work_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `works_links`;
CREATE TABLE `works_links` (
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `position` int unsigned NOT NULL DEFAULT '0',
  `url` varchar(255) NOT NULL DEFAULT '',
  `title` varchar(64) NOT NULL DEFAULT '',
  PRIMARY KEY (`work_id`,`url`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


DROP TABLE IF EXISTS `works_managers_notes`;
CREATE TABLE `works_managers_notes` (
  `work_id` int unsigned NOT NULL DEFAULT '0',
  `user_id` int unsigned NOT NULL DEFAULT '0',
  `comment` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`work_id`,`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3;


-- 2024-12-23 08:35:00
