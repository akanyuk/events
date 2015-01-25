<?php
NFW::i()->setUI('bootstrap');

$CPages = new pages();
$CEvents = new events();
$CCompetitions = new competitions();

$CEvents->path_prefix = 'main';
$CCompetitions->path_prefix = 'main';

$lang_main = NFW::i()->getLang('main');

$chapters = explode('/', preg_replace('/(^\/)|(\/$)|(\?.*)|(\/\?.*)/', '', $_SERVER['REQUEST_URI']));

if (!isset($chapters[0]) || $chapters[0] == '' || $chapters[0] == '/' || $chapters[0] == 'index.php') {
	// Events list on index page
	if (!$page = $CPages->loadPage()) {
		NFW::i()->stop(404);
	}
	elseif (!$page['is_active']) {
		NFW::i()->stop('inactive');
	}
	
	$page['breadcrumb'] = array(
		array('desc' => $lang_main['events'])
	);
	$page['content'] .= $CEvents->renderAction(array(
		'events' => $CEvents->getRecords(array('load_media' => true))
	), 'list');
	
	NFW::i()->assign('page', $page);
	NFW::i()->display('main.tpl');	
}
elseif (isset($chapters[0]) && $CEvents->loadByAlias($chapters[0])) {
	// Event / Competition
	if (!$page = $CPages->loadPage('events')) {
		NFW::i()->stop(404);
	}
	elseif (!$page['is_active']) {
		NFW::i()->stop('inactive');
	}
	
	if (!isset($chapters[1])) {
		// Event page
		$page['breadcrumb'] = array(
			array('url' => 'events', 'desc' => $page['title']),
			array('desc' => $CEvents->record['title'])
		);
		$page['breadcrumb_status'] = '<span class="label '.$CEvents->record['status']['label-class'].'">'.($CEvents->record['is_one_day'] ? date('d.m.Y', $CEvents->record['date_from']) : date('d.m.Y', $CEvents->record['date_from']).' - '.date('d.m.Y', $CEvents->record['date_to'])).'</span>';
		
		$page['title'] = $CEvents->record['title'];
		$page['content'] = $CEvents->renderAction(array(
			'title' => $CEvents->record['title'],
			'content' => $CEvents->record['content'],
			'competitions' => $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))),
			'lang_main' => NFW::i()->getLang('main')
		), 'record');
		
		NFW::i()->assign('page', $page);
		NFW::i()->display('main.tpl');	
	}
		
	if (!$CCompetitions->loadByAlias($chapters[1], $CEvents->record['id'])) {
		NFW::i()->stop(404);
	}
		
	// Competition page
	$page['breadcrumb'] = array(
		array('url' => 'events', 'desc' => $page['title']),
		array('url' => $CEvents->record['alias'], 'desc' => $CEvents->record['title']),
		array('desc' => $CCompetitions->record['title'])
	);
	$page['breadcrumb_status'] = '<span class="label '.$CEvents->record['status']['label-class'].'">'.($CEvents->record['is_one_day'] ? date('d.m.Y', $CEvents->record['date_from']) : date('d.m.Y', $CEvents->record['date_from']).' - '.date('d.m.Y', $CEvents->record['date_to'])).'</span>';

	if ($CCompetitions->record['release_status']['available'] && $CCompetitions->record['release_works']) {
		$content = $CCompetitions->renderAction(array(
			'competition' => $CCompetitions->record,
		),'_release');
	}
	elseif ($CCompetitions->record['voting_status']['available'] && $CCompetitions->record['voting_works']) {
		NFW::i()->registerResource('jquery.activeForm', false, true);
		NFW::i()->registerResource('jquery.blockUI');
		NFW::i()->registerResource('jquery.cookie');
		NFW::i()->registerResource('base');
		
		$content = $CCompetitions->renderAction(array(
			'competition' => $CCompetitions->record,
		),'_voting');
	}
	else {
		$content = nl2br($CCompetitions->record['announcement']).'<hr /><br />';
	}
	
	$page['title'] = $CCompetitions->record['title'];
	$page['content'] = $CEvents->renderAction(array(
		'title' => $CCompetitions->record['title'],
		'content' => $content,
		'competitions' => $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))),
		'lang_main' => NFW::i()->getLang('main')
	), 'record');
	
	NFW::i()->assign('page', $page);
	NFW::i()->display('main.tpl');
}

// Normal page
if (!$page = $CPages->loadPage()) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');