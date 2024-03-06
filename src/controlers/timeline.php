<?php
$CTimeline = new timeline();

if (isset($_GET['action']) && $_GET['action'] == "data") {
    $result = [];
    foreach ($CTimeline->getRecords() as $record) {
        $result[] = [
            'countdown' => date('r', $record['date_from']),
            'date' => date('d.m.Y H:i', $record['date_from']),
            'html' => str_replace('<br', '<hr', nl2br($record['content'])),
        ];
    }
    NFW::i()->stop(json_encode($result));
}

NFW::i()->display('timeline.tpl');