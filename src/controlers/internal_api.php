<?php

// Various internal requests

switch ($_GET['action']) {
    case 'indexVotingStatus':
        $eventID = intval($_GET['event_id']);
        NFWX::i()->jsonSuccess([
            'votingOpen' => indexVotingOpen($eventID),
            'liveVoting' => indexVotingState($eventID, live_voting::GetState($eventID)),
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

function indexVotingState(int $eventID, $state) {
    if (empty($state['current'])) {
        return null;
    }

    $current = $state['current'];

    if (!NFW::i()->user['is_guest']) {
        $votekey = votekey::findOrCreateVotekey($eventID, NFW::i()->user['email']);
        if (!$votekey->error) {
            $CVote = new vote();
            $current['voted'] = $CVote->getWorkVote($current['id'], $votekey);
        }
    }

    return $current;
}

function indexVotingOpen($eventID): array {
    $CCompetitions = new competitions();
    $result = [];
    foreach ($CCompetitions->getRecords([
        'filter' => ['event_id' => $eventID, 'open_voting' => true],
        'ORDER BY' => 'c.voting_from DESC',
    ]) as $c) {
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