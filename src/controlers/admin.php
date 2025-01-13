<?php
if (NFW::i()->user['is_guest']) {
    header('HTTP/1.0 403 Forbidden');
    NFW::i()->login('form');
}

if (NFW::i()->user['is_blocked']) {
    NFW::i()->stop(NFW::i()->lang['Errors']['Account_disabled'], 'error-page');
}

// Set global 'admin' status
NFW::i()->current_controler = 'admin';

$top_menu = array();
if (isset(NFW::i()->cfg['admin_top_menu']) && file_exists(NFW::i()->cfg['admin_top_menu'])) {
    $topMenuCfg = require(NFW::i()->cfg['admin_top_menu']);

    foreach ($topMenuCfg as $i) {
        // Check permissions
        if (!isset($i['perm'])) {
            $top_menu[] = $i;
            continue;
        }
        
        list($module, $action) = explode(',', $i['perm']);
        if (NFW::i()->checkPermissions($module, $action)) {
            $top_menu[] = $i;
        }
    }
} else if (defined("PROJECT_ROOT") && file_exists(PROJECT_ROOT . 'include/configs/admin_menu.php')) {
    include(PROJECT_ROOT . 'include/configs/admin_menu.php');
    foreach ($top_menu as $key => $i) {
        // Check permissions
        if (isset($i['perm'])) {
            list($module, $action) = explode(',', $i['perm']);
            if (!NFW::i()->checkPermissions($module, $action)) {
                unset($top_menu[$key]);
            }
        }
    }
}

NFW::i()->assign('top_menu', $top_menu);
NFW::i()->assign('admin_help', $admin_help ?? array());

NFW::i()->registerResource('admin');
NFW::i()->registerResource('base');

$page = array(
    'title' => NFW::i()->cfg['admin']['title'],
    'content' => '',
    'is_welcome' => false
);

// Do action

// Determine module and action
@list($foo, $foo, $module) = explode('/', parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
$classname = NFW::i()->getClass($module, true);
$action = $_GET['action'] ?? 'admin';

if (!$module) {
    // Welcome page
    if (!NFW::i()->checkPermissions('admin')) {
        header('HTTP/1.0 403 Forbidden');
        NFW::i()->login('form');
    }

    $page['is_welcome'] = true;

    NFW::i()->assign('page', $page);
    NFW::i()->display('admin.tpl');
} else if (!class_exists($classname)) {
    NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'error-page');
}

$CModule = new $classname ();
// Check module_name->action permissions 
if (!NFW::i()->checkPermissions($module, $action, $CModule)) {
    header('HTTP/1.0 403 Forbidden');
    NFW::i()->login('form', array('redirect' => $_SERVER['REQUEST_URI']));
}

NFW::i()->assign('Module', $CModule);

$page['content'] = $CModule->action($action);
if ($CModule->error) {
    NFW::i()->stop($CModule->last_msg, $CModule->error_report_type);
}

NFW::i()->assign('page', $page);
NFW::i()->display('admin.tpl');