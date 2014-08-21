<?php
NFW::i()->setUI('bootstrap');

$CPages = new pages();
if (!$page = $CPages->loadPage()) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}

if (isset($_GET['id'])) {
	if (!$result = NFW::i()->renderNews(array('id' => $_GET['id'],'template' => 'record'))) {
		NFW::i()->errorPage(404);
	}
	
	list ($page['title'], $page['content']) = $result;
}
else {
	$page['content'] .= NFW::i()->renderNews(array(
		'load_attachments' => true, 
		'template' => 'list',
//		'posted_from' => mktime(0,0,0,1,1,$y),
//		'posted_to' => mktime(23,59,59,12,31,$y),
	));
}

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');