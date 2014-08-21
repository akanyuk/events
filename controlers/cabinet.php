<?php
NFW::i()->setUI('bootstrap');

if (NFW::i()->user['is_guest']) {
	header('Location: '.NFW::i()->absolute_path);
}
elseif (NFW::i()->user['is_blocked']) {
	NFW::i()->stop('User\'s profile disabled by administration.', 'error-page');
}
	
$CPages = new pages();
if (!$page = $CPages->loadPage('cabinet')) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}

// Determine module and action
$chapters = explode('/', preg_replace('/(^\/)|(\/$)|(\?.*)|(\/\?.*)/', '', $_SERVER['REQUEST_URI']));
$module = isset($chapters[1]) ? $chapters[1] : false;
// Module mapping
if (isset(NFW::i()->cfg['module_map'][$module])) {
	$module = NFW::i()->cfg['module_map'][$module];
}

if (!$module) {
	// Главная страница ЛК
	$page['content'] = $page['content'];
	NFW::i()->assign('page', $page);
	NFW::i()->display('main.tpl');
}

if (!class_exists($module)) {
	NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'error-page');
}

$CModule = new $module ();
$CModule->path_prefix = 'cabinet';
$CModule->action = isset($_GET['action']) ?  $_GET['action'] : '';
NFW::i()->assign('Module', $CModule);

$action_func = 'cabinet'.str_replace(' ', '', ucwords(str_replace('_', ' ', $CModule->action)));
if (!method_exists($CModule, $action_func)) {
	NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'error-page');
}
$page['content'] = call_user_func(array($CModule, $action_func), $_POST);
if ($CModule->error) {
	NFW::i()->stop($CModule->last_msg, $CModule->error_report_type ? $CModule->error_report_type : 'error-page');
}

$page['breadcrumb'] = $CModule->breadcrumb;
 
NFW::i()->registerResource('base');
NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');