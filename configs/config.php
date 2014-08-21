<?php

$config = array (
	# e-mail адреса, на которые будут отправляться оповещения администрации (массив)
	'notify_emails' => array('aka.nyuk@gmail.com', 'diver4d@gmail.com'),
	'email_from' => 'demoscene@multimatograf.ru',
	
	'countdown' => 'Apr 25, 2014',
	'countdown_when' => '25-27 апреля 2014',
	'countdown_where' => 'г. Вологда',

	'meta_description' => 'Demoscene events',
	'meta_keywords' => 'Demoscene, демосцена, демопати, ZX-Spectrum',
	
	'db' => array (
		'type' => 'mysql',
		'host' => 'localhost',
		'name' => 'retroscene_events',
		'username' => '',
		'password' => '',
		'prefix' => 'events_',
		'p_connect' => false,
	),
	
	'cookie' => array(
		'name' => 'dmf1209',	
		'domain' => '.events.retroscene.local',
		'path' => '/',
		'secure' => 0,
		'expire' => 1209600	// The cookie expires after 14 days
	),

	'write_logs' => true,
	
	'media' => array(
		//'storage_path' => 'media',
		'MAX_FILE_SIZE' => 8388608,			// MAX_FILE_SIZE # 8Mb
		'MAX_SESSION_SIZE' => 33554432,		// MAX_SESSION_SIZE # 32Mb
		'fs_encoding' => 'cp1251',			// Кодировка файловой системы сервера
	),
		
	'jqueryui_css' => 'jquery.ui.smoothness',
	
	'admin' => array (
		'title' => 'Events Control Panel',
	),
);