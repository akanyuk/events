<?php
$CCompetitions = new competitions(NFW::i()->project_settings['53c_competition_id']);
if ($CCompetitions->record['id']) {
	$reception_available = $CCompetitions->record['reception_from'] < NFW::i()->actual_date && $CCompetitions->record['reception_to'] > NFW::i()->actual_date ? true : false;
	$reception_future = $CCompetitions->record['reception_from'] > NFW::i()->actual_date ? true : false;
}
else {
	$reception_available = false;
	$reception_future = false;
}

$lang_main = NFW::i()->getLang('main');

if (empty($_POST)) {
	if (!NFW::i()->project_settings['53c_internal_editor']) {
		NFW::i()->stop('Please use improved 53c editor: <a href="http://53c.verve.space/">53c.verve.space</a>', 'error-page');
	}
	
	NFW::i()->assign('attributes', array(
		'title' => array('type' => 'str', 'desc' => $lang_main['works title'], 'required' => true, 'maxlength' => 200),
		'author' => array('type' => 'str', 'desc' => $lang_main['works author'], 'required' => true, 'maxlength' => 200)
	));
	NFW::i()->assign('reception_available', $reception_available);
	NFW::i()->assign('reception_future', $reception_future);
	NFW::i()->assign('competition', $CCompetitions->record);
	
	NFW::i()->display('53c.tpl');
}

// Start sending

if (!$reception_available) {
	NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => 'Reception unavailable.')));
}

$CWorks = new works53c();

if (!$CWorks->loadFromString(substr(urldecode($_POST['tap']), 175, 768))) {
	NFW::i()->renderJSON(array('result' => 'error', 'message' => $CWorks->last_msg));
}

if (!$CWorks->add53c($_POST)) {
	NFW::i()->renderJSON(array('result' => 'error', 'message' => $CWorks->last_msg));
}

NFW::i()->renderJSON(array('result' => 'success', 'message' => $lang_main['works upload success message']));