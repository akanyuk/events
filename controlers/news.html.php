<?php
NFW::i()->setUI('bootstrap');

$CPages = new pages();
if (!$page = $CPages->loadPage()) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}

$lang_main = NFW::i()->getLang('main');

if (isset($_GET['id'])) {
	if (!$result = NFW::i()->renderNews(array('id' => $_GET['id'],'template' => 'record'))) {
		NFW::i()->errorPage(404);
	}
	
	list ($page['title'], $page['content'], $posted) = $result;
	
	$page['breadcrumb'] = array(
		array('url' => 'news.html', 'desc' => $lang_main['news']),
		array('desc' => $page['title'])
	);
	$page['breadcrumb_status'] = '<span class="label label-info">'.date('d.m.Y', $posted).'</span>';
}
else {
	$page['content'] .= NFW::i()->renderNews(array(
		'load_attachments' => true, 
		'template' => 'list',
		'records_on_page' => 10
	));
	
	$page['breadcrumb'] = array(
		array('desc' => $lang_main['news']),
	);
}

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');