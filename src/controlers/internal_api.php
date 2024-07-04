<?php

// Various internal requests

switch ($_GET['action']) {
    case 'indexVotingStatus':
        NFWX::i()->jsonSuccess([
            'votingOpen' => indexVotingOpen($_GET['event_id']),
            'liveVoting' => indexVotingState(live_voting::GetState($_GET['event_id'])),
        ]);
        break;
    case 'indexLiveVote':
        $req = json_decode(file_get_contents('php://input'));
        $CWorks = new works($req->workID);
        if (!$CWorks->record['id']) {
            NFWX::i()->jsonError("400", $CWorks->last_msg);
        }

        if (!live_voting::IsAllowed($CWorks->record['event_id'], $CWorks->record['id'])) {
            NFWX::i()->jsonError("400", "Live voting not allowed");
        }

        $CVote = new vote();
        $result = $CVote->getVotekey($CWorks->record['event_id'], NFW::i()->user['email']);
        if (!$result) {
            NFWX::i()->jsonError("400", "Votekey create failed");
        }

        $votekey = $result;
        NFW::i()->setCookie('votekey', $votekey);

        ChromePhp::log([
            'vote' => $req->vote,
            'votekey' => $votekey,
        ]);

        NFWX::i()->jsonSuccess();
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