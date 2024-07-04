<?php

// Various internal requests

switch ($_GET['action']) {
    case 'indexVotingStatus':
        NFWX::i()->jsonSuccess([
            'votingOpen' => indexVotingOpen($_GET['event_id']),
            'liveVoting' => indexVotingState(live_voting::GetState($_GET['event_id'])),
        ]);
        break;
    default:
        NFWX::i()->jsonError("400", "Unknown action");
}

function indexVotingState($state) {
    if (empty($state['current'])) {
        return null;
    }

    return $state['current'];
}

function indexVotingOpen($eventID): array {
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