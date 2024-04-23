<?php

require '../vendor/autoload.php';

@include '../debug.php';

define('SRC_ROOT', dirname(__DIR__) . '/src');
define('VAR_ROOT', dirname(__DIR__) . '/var');
define('NFW_ROOT', dirname(__DIR__) . '/vendor/akanyuk/nfw/');
const PUBLIC_HTML = __DIR__;

// Used by NFW framework. Must be pointed to www root
const PROJECT_ROOT = __DIR__ . '/';

$config = include(SRC_ROOT . '/configs/config.php');
if (file_exists(dirname(__DIR__) . '/config.local.php')) {
    $config = array_merge($config, include(dirname(__DIR__) . '/config.local.php'));
}

$config['include_paths'] = array(
    SRC_ROOT . '/',
    NFW_ROOT . '/',
);
$config['media']['secure_storage_full_path'] = VAR_ROOT . '/protected_media';
$config['media']['images_cache_full_path'] = VAR_ROOT . '/images_cache';
$config['admin_top_menu'] = SRC_ROOT . '/configs/admin_top_menu.php';
$config['SxGeo.dat'] = VAR_ROOT . '/SxGeo.dat';
$config['SxGeoCity.dat'] = VAR_ROOT . '/SxGeoCity.dat';

require SRC_ROOT . '/nfw_extended.php';
NFWX::run($config);
