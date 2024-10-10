<?php
$action = $_GET['action'] ?? 'update_profile';

$classname = NFW::i()->getClass('users', true);
$CUsers = new $classname ();

NFW::i()->assign('Module', $CUsers);

$page = array(
	'path' => parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH),
	'content' => $CUsers->action($action)
);
if ($CUsers->error) {
	NFW::i()->stop($CUsers->last_msg, $CUsers->error_report_type);
}

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');