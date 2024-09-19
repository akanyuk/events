<?php

// Determine event, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));

if (count($pathParts) > 2) {
    NFW::i()->stop(404);
}

$eventAlias = count($pathParts) == 2 ? $pathParts[1] : false;
if ($eventAlias === false) {
    NFW::i()->stop(404);
}
$CEvents = new events();
if (!$CEvents->loadByAlias($eventAlias)) {
    NFW::i()->stop(404);
}

$pageTitle = htmlspecialchars($CEvents->record['title']) . " / Live voting";

NFWX::i()->main_og['title'] = $pageTitle;
NFWX::i()->main_og['description'] = $CEvents->record['announcement_og'] ?: strip_tags($CEvents->record['announcement']);
if ($CEvents->record['preview_img_large']) {
    NFWX::i()->main_og['image'] = tmb($CEvents->record['preview_large'], 500, 500, array('complementary' => true));
}

if (NFW::i()->user['is_guest']) {
    NFW::i()->registerFunction('login_required');
    $lang_main = NFW::i()->getLang("main");
    login_required($pageTitle, $lang_main['live voting info']);
}

NFW::i()->assign('page', array(
    'title' => $pageTitle,
    'path' => implode("/", $pathParts),
    'content' => NFW::i()->fetch(SRC_ROOT . '/templates/live_voting/main/live_voting.tpl',
        [
            "event" => $CEvents->record,
            "title" => $pageTitle,
        ]
    ),
));
NFW::i()->display('main.tpl');
