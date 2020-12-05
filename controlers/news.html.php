<?php
$CPages = new pages();
if (!$page = $CPages->loadPage()) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}

NFW::i()->current_controler = 'main';

$lang_main = NFW::i()->getLang('main');

if (isset($_GET['id'])) {
	$CNews = new news($_GET['id']);
	if (!$CNews->record['id']) {
		NFW::i()->stop(404);
	}
		
	$page['content'] = $CNews->renderAction(array('record' => $CNews->record), 'record');
	$page['title'] = $CNews->record['title'];
	
	NFW::i()->breadcrumb = array(
		array('url' => 'news.html', 'desc' => $lang_main['news']),
		array('desc' => $page['title'])
	);
	NFW::i()->breadcrumb_status = '<span class="label label-info">'.date('d.m.Y', $CNews->record['posted']).'</span>';

	// Собираем `meta_keywords` из параметров новости и параметров страницы
	$meta_keywords = array();
	foreach (explode(',', $CNews->record['meta_keywords'].','.$page['meta_keywords']) as $keyword) {
		$keyword = trim($keyword);
		if (!$keyword) continue;
		$meta_keywords[] = $keyword;
	}
	$page['meta_keywords'] = implode(',',array_unique($meta_keywords));
}
else {
	$page['content'] .= NFW::i()->renderNews(array(
		'load_media' => true, 
		'template' => 'list',
		'page' => isset($_GET['p']) ? intval($_GET['p']) : 1,
		'records_on_page' => 10
	));
}

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');