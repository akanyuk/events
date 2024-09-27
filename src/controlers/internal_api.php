<?php

// Various internal requests

switch ($_GET['action']) {
    case 'votingStatus':
        $eventID = intval($_GET['event_id']);
        $state = live_voting::GetState($eventID);
        NFWX::i()->jsonSuccess([
            'votingOpen' => votingOpen($eventID),
            'liveVotingOpen' => !empty($state['works']) || !empty($state['comingAnnounce']) || !empty($state['endAnnounce']),
        ]);
        break;
    case 'liveVotingStatus':
        $eventID = intval($_GET['event_id']);
        NFWX::i()->jsonSuccess([
            'liveVoting' => liveVoting($eventID, live_voting::GetState($eventID)),
        ]);
        break;
    case 'liveVote':
        $req = json_decode(file_get_contents('php://input'));
        $CVote = new vote();
        if (!$CVote->addLiveVoteByRegisteredUser($req->workID, $req->vote)) {
            NFWX::i()->jsonError(400, $CVote->last_msg);
        }
        NFWX::i()->jsonSuccess();
        break;
    case 'requestVotekey':
        $CVotekey = new votekey();
        if (!$CVotekey->requestVotekey($_GET['event_id'], $_POST['email'])) {
            NFWX::i()->jsonError(400, $CVotekey->last_msg);
        }

        $langMain = NFW::i()->getLang('main');
        NFWX::i()->jsonSuccess(['message' => $langMain['votekey-request success note']]);
        break;
    default:
        NFWX::i()->jsonError(400, "Unknown action");
}

function liveVoting(int $eventID, $state) {
    if (NFW::i()->user['is_guest']) {
        return null;
    }

    if (empty($state['works'])) {
        return $state;
    }

    // Sorting by position
    usort($state['works'], function ($a, $b) {
        return $a['position'] > $b['position'];
    });

    $state['currentAnnounce'] = 'NOW: '.$state['works'][0]['competition_title'];

    // Fetching already voted
    $votekey = votekey::findOrCreateVotekey($eventID, NFW::i()->user['email']);
    if (!$votekey->error) {
        $ids = [];
        foreach ($state['works'] as $work) {
            $ids[] = $work['id'];
        }

        $CVote = new vote();
        $voted = $CVote->getWorksVotes($ids, $votekey);
        if (!empty($voted)) {
            foreach ($state['works'] as $k => $work) {
                if (isset($voted[$work['id']])) {
                    $state['works'][$k]['voted'] = intval($voted[$work['id']]);
                }
            }
        }
    }

    return $state;
}

function votingOpen($eventID): array {
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