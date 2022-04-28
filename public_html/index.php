<?php

require '../vendor/autoload.php';

@include '../debug.php';

// Initialization and run
define('SRC_ROOT', dirname(__DIR__) . '/src');
define('VAR_ROOT', dirname(__DIR__) . '/var');
define('NFW_ROOT', dirname(__DIR__) . '/vendor/akanyuk/nfw/');
define('PROJECT_ROOT', __DIR__ . '/');

$config = include(SRC_ROOT.'/configs/config.php');
$config['include_paths'] = array(
    SRC_ROOT . '/',
    NFW_ROOT . '/',
);

require SRC_ROOT.'/nfw_extended.php';
NFWX::run(array_merge($config, include(dirname(__DIR__).'/config.local.php')));
