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
    case 'vote':
        $req = json_decode(file_get_contents('php://input'));
        $CVote = new vote();
        if (!$CVote->addVote($req->workID, $req->vote, $req->username, $req->votekey)) {
            NFWX::i()->jsonError(400, $CVote->errors, $CVote->last_msg);
        }
        NFWX::i()->jsonSuccess();
        break;
    case 'requestVotekey':
        $req = json_decode(file_get_contents('php://input'));
        $CVotekeys = new votekeys();
        if (!$CVotekeys->requestVotekey($_GET['event_id'], $req->email)) {
            NFWX::i()->jsonError(400, $CVotekeys->last_msg);
        }

        $langMain = NFW::i()->getLang('main');
        NFWX::i()->jsonSuccess(['message' => $langMain['votekey-request success note']]);
        break;
    case 'commentsList':
        $CWorksComments = new works_comments();
        $result = $CWorksComments->workComments(intval($_GET['work_id']));
        if ($result === false) {
            NFWX::i()->jsonError(400, $CWorksComments->last_msg);
        }
        NFWX::i()->jsonSuccess(['comments' => $result]);
        break;
    case 'addComment':
        if (!NFWX::i()->checkPermissions('works_comments', 'add_comment')) {
            NFWX::i()->jsonError(403, 'No permissions');
        }

        $req = json_decode(file_get_contents('php://input'));

        $CWorksComments = new works_comments();
        if (!$CWorksComments->addComment($req->workID, $req->message)) {
            NFWX::i()->jsonError(400, $CWorksComments->errors, $CWorksComments->last_msg);
        }
        NFWX::i()->jsonSuccess();
        break;
    case 'deleteComment':
        $req = json_decode(file_get_contents('php://input'));

        $CWorksComments = new works_comments($req->commentID);
        if (!$CWorksComments->record['id']) {
            NFWX::i()->jsonError(400, $CWorksComments->last_msg);
        }

        if (!NFWX::i()->checkPermissions(
            'works_comments',
            'delete',
            ['work_id' => $CWorksComments->record['work_id']],
        )) {
            NFWX::i()->jsonError(403, 'No permissions');
        }

        if (!$CWorksComments->delete()) {
            NFWX::i()->jsonError(400, $CWorksComments->last_msg);
        }
        NFWX::i()->jsonSuccess();
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

    $state['currentAnnounce'] = 'NOW: ' . $state['works'][0]['competition_title'];

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