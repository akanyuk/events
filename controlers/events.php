<?php
// Normal page with events list

$CPages = new pages();
if (!$page = $CPages->loadPage()) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}

NFW::i()->current_controler = 'main';

$CEvents = new events();

$lang_main = NFW::i()->getLang('main');

$page['title'] = $lang_main['events'];
$page['content'] .= $CEvents->renderAction(array(
	'events' => $CEvents->getRecords(array('load_media' => true))
), 'list');

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');	