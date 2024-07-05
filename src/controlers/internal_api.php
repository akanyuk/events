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
        $CVote = new vote();
        if (!$CVote->addLiveVoteByRegisteredUser($req->workID, $req->vote)) {
            NFWX::i()->jsonError("400", $CVote->last_msg);
        }
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
    foreach ($CCompetitions->getRecords(['filter' => ['event_id' => $eventID, 'open_voting' => true]]) as $c) {
        if ($c['voting_works']) {
            $result[] = [
                'title' => $c['title'],
                'url' => NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'],
                'statusText' => $c['voting_status']['desc'],
            ];
        }
    }

    return $result;
}