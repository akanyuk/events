<?php

// Determine event, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));

if (count($pathParts) > 3) {
    NFW::i()->stop(404);
}

$event = count($pathParts) >= 2 ? eventFromAlias($pathParts[1]) : false;
$compo = count($pathParts) == 3 && $event ? compoFromAlias($pathParts[2], $event['id']) : false;

if (NFW::i()->user['is_guest']) {
    $lang_main = NFW::i()->getLang("main");

    $pageTitle = $lang_main['cabinet add work'];
    $uploadLegend = $lang_main['cabinet add work'];
    $path = "upload";

    if ($event !== false) {
        NFW::i()->registerFunction('tmb');

        $pageTitle = htmlspecialchars($event['title']) . " / " . $pageTitle;
        $uploadLegend = htmlspecialchars($event['title']) . " / " . $uploadLegend;
        $path .= "/" . $event['alias'];

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

$suffix = $event === false ? "" : "?event=" . $event['alias'];
if ($compo) {
    $suffix .= '&competition=' . $compo['alias'];
}

header("Location:/cabinet/works_add" . $suffix);

/**
 * @param string $alias
 * @return bool|array
 */
function eventFromAlias(string $alias = "") {
    $CEvents = new events();
    if (!$CEvents->loadByAlias($alias)) {
        return false;
    }

    $CCompetitions = new competitions();
    return count($CCompetitions->getRecords(['filter' => [
        'open_reception' => true,
        'event_id' => $CEvents->record['id']]])) > 0 ? $CEvents->record : false;
}

/**
 * @param string $alias
 * @param int $eventID
 * @return bool|array
 */
function compoFromAlias(string $alias, int $eventID) {
    $CCompetitions = new competitions();
    if (!$CCompetitions->loadByAlias($alias, $eventID)) {
        return false;
    }

    return $CCompetitions->record['reception_status']['now'] ? $CCompetitions->record : false;
}
