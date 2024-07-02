<?php

// Various internal requests

switch ($_GET['action']) {
    case 'votingStatus':
        $CCompetitions = new competitions();
        $votingOpen = array();
        foreach ($CCompetitions->getRecords(array('filter' => array('event_id' => $_GET['event_id']))) as $c) {
            if ($c['voting_status']['available'] && $c['voting_works']) {
                $votingOpen[] = [
                    'title' => $c['title'],
                    'url' => NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'],
                    'statusText' => $c['voting_status']['desc'],
                ];
            }
        }
        NFWX::i()->jsonSuccess(['votingOpen' => $votingOpen]);
        break;
    default:
        NFWX::i()->jsonError("400", "Unknown action");
}
