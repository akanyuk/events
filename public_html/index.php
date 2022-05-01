<?php

require '../vendor/autoload.php';

@include '../debug.php';

define('SRC_ROOT', dirname(__DIR__) . '/src');
define('VAR_ROOT', dirname(__DIR__) . '/var');
define('NFW_ROOT', dirname(__DIR__) . '/vendor/akanyuk/nfw/');
define('PUBLIC_HTML', __DIR__);

// Used by NFW framework. Must be pointed to www root
define('PROJECT_ROOT', __DIR__ . '/');

$config = include(SRC_ROOT . '/configs/config.php');
$config['include_paths'] = array(
    SRC_ROOT . '/',
    NFW_ROOT . '/',
);
$config['media']['secure_storage_full_path'] = VAR_ROOT . '/protected_media';

require SRC_ROOT . '/nfw_extended.php';
NFWX::run(array_merge($config, include(dirname(__DIR__) . '/config.local.php')));
