<?php

// Ajax & html responses
if (isset($_POST['action']) && $_POST['action'] == 'request_votekey') {
	$CVote = new vote();
	$result = $CVote->requestVotekey($_POST) ? 'success' : 'error';
	NFW::i()->renderJSON(array('result' => $result, 'message' => $CVote->last_msg));
}
elseif (isset($_POST['action']) && $_POST['action'] == 'vote') {
	$CVote = new vote();
	$result = $CVote->doVoting($_POST) ? 'success' : 'error';
	NFW::i()->renderJSON(array('result' => $result, 'errors' => $CVote->errors, 'message' => $CVote->last_msg));
}

NFW::i()->setUI('bootstrap');

// Normal page with events list
$CPages = new pages();
if (!$page = $CPages->loadPage()) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}
	
$CEvents = new events();
$CEvents->path_prefix = 'main';

$lang_main = NFW::i()->getLang('main');

$page['breadcrumb'] = array(
	array('desc' => $lang_main['events'])
);
$page['content'] .= $CEvents->renderAction(array(
	'events' => $CEvents->getRecords(array('load_media' => true))
), 'list');

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');	