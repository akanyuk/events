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

$CWorksComments = new works_comments();
if (!$records = $CWorksComments->getRecords(array(
	'records_on_page' => 20, 
	'page' => isset($_GET['p']) ? intval($_GET['p']) : 1, 
	'ORDER BY' => 'wc.id DESC'		
))) {
	NFW::i()->stop($CWorksComments->last_msg, 'error-page');
}

// Generate paging links
$paging_links = $CWorksComments->num_pages > 1 ? NFW::i()->paginate($CWorksComments->num_pages, $CWorksComments->cur_page, NFW::i()->absolute_path.'/comments.html', ' ') : '';

// Render page content
$page['content'] .= $CWorksComments->renderAction(array(
	'comments' => $records,
	'paging_links' => $paging_links,
), '_display_all_comments');

$page['title'] = $lang_main['comments'];

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');