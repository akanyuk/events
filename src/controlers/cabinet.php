<?php
if (NFW::i()->user['is_guest']) {
	header('Location: '.NFW::i()->absolute_path);
}
elseif (NFW::i()->user['is_blocked']) {
	NFW::i()->stop('User\'s profile disabled by administration.', 'error-page');
}
	
$CPages = new pages();
if (!$page = $CPages->loadPage('cabinet')) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}

NFW::i()->current_controler = 'cabinet';
NFWX::i()->main_search_box = false;

// Determine module, disable subdirectories
@list($foo, $bar, $module, $wrong) = explode('/', parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
if ($wrong) {
	NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'error-page');
}

if (!$module) {
	NFW::i()->assign('page', $page);
	NFW::i()->display('main.tpl');
}

$classname = NFW::i()->getClass($module, true);

if (!class_exists($classname)) {
	NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'error-page');
}

$CModule = new $classname();
$CModule->action = $_GET['action'] ?? 'main';

$action_func = 'actionCabinet'.str_replace(' ', '', ucwords(str_replace('_', ' ', $CModule->action)));
if (!method_exists($CModule, $action_func)) {
	NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'error-page');
}

NFW::i()->assign('Module', $CModule);
$page['content'] = call_user_func(array($CModule, $action_func), $_POST);
if ($CModule->error) {
	NFW::i()->stop($CModule->last_msg, $CModule->error_report_type ? $CModule->error_report_type : 'error-page');
}

NFW::i()->registerResource('base');
NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');
