<?php
/**
 *
 * @var array $config
 */
$config = array (
	'zxgfx' => array(
		'output_type' => 'png',
		'output_scale' => 2,
		'palette' => 'pulsar',
		'border' => 'small',
	),

	# Classes wrapping map
	'module_map' => array(
		'users_ext' => 'users'
	),

	'users_group_id_unverified' => 	4,
	'users_group_id' => 			3,
		
	// Language stuffs
	'default_language' => 'English',
	'available_languages' => array('Russian', 'English'),
	'set_language_by_cookie' => true,		# Разрешить смену языка через значение COOKIE
	'set_language_by_get' => true,			# Разрешить смену языка через GET-запрос
	'set_language_by_geoip' => true,		# Разрешить поиск подходящего языка через GeoIP
	'update_profile_language' => true,		# Обновлять язык в профиле пользователя одновременно с GET-запросом
	
	'db' => array (
		'type' => 'mysql',
		'host' => 'localhost',
		'name' => 'events',
		'username' => 'events',
		'password' => 'Hb45Fy5fzLxyQnrH',
		'prefix' => '',
		'p_connect' => false,
	),
	
	'cookie' => array(
		'name' => 'e1703',	
		'domain' => '.'.$_SERVER['HTTP_HOST'],
		'path' => '/',
		'secure' => 0,
		'expire' => 1209600	// The cookie expires after 14 days
	),

	'write_logs' => true,
	'use_browscap' => true,
	#'use_get_browser' => false,
		
	'media' => array(
		//'storage_path' => 'media',
		//'media_controler' => 'media',
		'MAX_FILE_SIZE' => 33554432,		// MAX_FILE_SIZE # 16Mb
		'MAX_SESSION_SIZE' => 33554432,		// MAX_SESSION_SIZE # 32Mb
		// Кодировка файловой системы сервера
		'fs_encoding' => defined('NFW_DEBUG') ? 'cp1251' : 'utf8',		
			
		//'tmb_max_width' => 2048,
		'tmb_max_height' => 10240,		// increase max height special for ascii/ansi images
		
		'defaults' => array(
			'safe_filenames' => true,
			'force_rename' => true,
			'images_only' => false,
			'tmb_width' => 100,
			'tmb_height' => 100,
			'image_max_x' => 2048,
			'image_max_y' => 2048,
		),
	),
		
	'admin' => array (
		'title' => 'Events Control Panel',
	),
);

if (!defined('NFW_DEBUG')) {
    $config['PHPMailer'] = array(
        'Mailer' => 'smtp',
        'Host' => 'smtp.yandex.com:465',
        'SMTPSecure' => 'ssl',
        'SMTPAuth' => true,
        'From'	=> 'boot@retroscene.org',
        'Username' => 'boot@retroscene.org',
        'Password' => '1IKUvsxN',
    );
}