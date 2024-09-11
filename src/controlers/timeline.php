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

$CTimeline = new timeline();

if (isset($_GET['action']) && $_GET['action'] == "data") {
    $now = time();
    $result = [];
    foreach ($CTimeline->getRecords($CEvents->record['id']) as $record) {
        if (!$record['is_public'] || $record['begin'] < $now) {
            continue;
        }

        $result[] = [
            'countdown' => date('r', $record['begin']),
            'date' => date('d.m.Y H:i', $record['begin']),
            'html' => $record['title'],
        ];
    }
    NFW::i()->stop(json_encode($result));
}

NFW::i()->display('timeline.tpl');