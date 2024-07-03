<?php

// Various internal requests

switch ($_GET['action']) {
    case 'votingStatus':
        NFWX::i()->jsonSuccess([
            'votingOpen' => votingOpen($_GET['event_id']),
            'liveVoting' => live_voting::GetWorks($_GET['event_id']),
        ]);
        break;
    default:
        NFWX::i()->jsonError("400", "Unknown action");
}

function votingOpen($eventID): array {
    $CCompetitions = new competitions();
    $result = [];
    foreach ($CCompetitions->getRecords(array('filter' => array('event_id' => $eventID))) as $c) {
        if ($c['voting_status']['available'] && $c['voting_works']) {
            $result[] = [
                'title' => $c['title'],
                'url' => NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'],
                'statusText' => $c['voting_status']['desc'],
            ];
        }
    }

    return $result;
}