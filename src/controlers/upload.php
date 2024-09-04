<?php

// Determine event, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));

if (count($pathParts) > 2) {
    NFW::i()->stop(404);
}

$event = count($pathParts) == 2 ? eventFromAlias($pathParts[1]) : false;

if (NFW::i()->user['is_guest']) {
    $lang_main = NFW::i()->getLang("main");

    NFWX::i()->main_search_box = false;
    NFWX::i()->main_right_pane = false;

    $pageTitle = $lang_main['cabinet add work'];
    $uploadLegend = $lang_main['cabinet add work'];
    $path = "upload";

    if ($event !== false) {
        $pageTitle = htmlspecialchars($event['title'])." / ".$pageTitle;
        $uploadLegend = htmlspecialchars($event['title'])." / ".$uploadLegend;
        $path .= "/".$event['alias'];

        NFWX::i()->main_og['title'] = $pageTitle;
        NFWX::i()->main_og['description'] = $event['announcement_og'] ?: strip_tags($event['announcement']);
        if ($event['preview_img_large']) {
            NFWX::i()->main_og['image'] = tmb($event['preview_large'], 500, 500, array('complementary' => true));
        }
    }

    NFW::i()->registerFunction('login_required');
    $lang_main = NFW::i()->getLang("main");
    login_required($pageTitle, $lang_main['upload info']);
}

header("Location:/cabinet/works?action=add".($event === false ? "" : "&event_id=".$event['id']));

/**
 * @param string $path
 * @return bool|array
 */
function eventFromAlias(string $path = "") {
    $CEvents = new events();
    if (!$CEvents->loadByAlias($path)) {
        return false;
    }

    $CCompetitions = new competitions();
    foreach ($CCompetitions->getRecords(array('filter' => array('open_reception' => true))) as $c) {
        if ($c['event_id'] == $CEvents->record['id']) {
            return $CEvents->record;
        }
    }

    return false;
}
