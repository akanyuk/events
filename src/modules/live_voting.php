<?php

const storageKeyPrefix = "live-voting-storage-key";
const memoryStorageTtlSec = 3600;

class live_voting extends active_record {
    public static function IsAllowed($eventID, $workID): bool {
        $state = apcu_fetch(storageKeyPrefix . $eventID);
        if ($state === false) {
            return false;
        }

        foreach ($state['all'] as $item) {
            if ($item['id'] === $workID) {
                return true;
            }
        }

        return false;
    }

    public static function GetState($eventID): array {
        $result = apcu_fetch(storageKeyPrefix . $eventID);
        if ($result === false) {
            return [];
        }

        return $result;
    }

    function actionAdminAdmin() {
        if (!isset($_GET['event_id'])) {
            $this->error(NFW::i()->lang['Errors']['Bad_request'], __FILE__, __LINE__);
            return false;
        }

        $CEvents = new events($_GET['event_id']);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        $CWorks = new works();
        $works = $CWorks->getRecords(array(
            'filter' => array(
                'event_id' => $CEvents->record['id'],
                'voting_only' => true,
            ),
            'ORDER BY' => 'c.position, w.position',
            'load_attachments' => true,
            'skip_pagination' => true,
        ));

        // Create tree of works by competition
        $records = [];
        $_curCompo = 0;
        $firstCompo = 0;
        foreach ($works as $work) {
            if ($firstCompo == 0) {
                $firstCompo = $work['competition_id'];
            }

            if ($_curCompo != $work['competition_id']) {
                $_curCompo = $work['competition_id'];

                $records[$_curCompo] = array(
                    'title' => $work['competition_title'],
                    'works_type' => $work['works_type'],
                    'works' => array(),
                );
            }

            $records[$_curCompo]['works'][] = $work;
        }

        return $this->renderAction([
            'event' => $CEvents->record,
            'records' => $records,
            'firstCompo' => $firstCompo,
        ]);
    }

    function actionAdminReadState() {
        NFWX::i()->jsonSuccess(apcu_fetch(storageKeyPrefix . $_GET['event_id']));
    }

    function actionAdminUpdateState() {
        if (!isset($_GET['event_id'])) {
            $this->error(NFW::i()->lang['Errors']['Bad_request'], __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $CEvents = new events($_GET['event_id']);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (isset($_POST['stopAllLiveVoting']) && $_POST['stopAllLiveVoting']) {
            apcu_delete(storageKeyPrefix . $_GET['event_id']);
            NFWX::i()->jsonSuccess();
        }

        $stopLiveVotingID = isset($_POST['stopLiveVoting']) ? intval($_POST['stopLiveVoting']) : 0;

        $state = apcu_fetch(storageKeyPrefix . $_GET['event_id']);
        $current = isset($state['current']['id']) && $state['current']['id'] != $stopLiveVotingID ? $state['current'] : [];
        $all = $state['all'] ?? [];

        if (isset($_POST['startLiveVoting'])) {
            $CWorks = new works($_POST['startLiveVoting']);
            if ($CWorks->record['id'] && $CWorks->record['id'] != $stopLiveVotingID) {
                $current = [
                    'competition_id' => $CWorks->record['competition_id'],
                    'id' => $CWorks->record['id'],
                    'position' => $CWorks->record['position'],
                    'title' => $CWorks->record['title'],
                    'competition_title' => $CWorks->record['competition_title'],
                    'screenshot' => $CWorks->record['screenshot']['url'] ?? '',
                    'voting_options' => extractVotingVariants($CEvents->record['options']),
                ];
                $all[] = $current;
            }
        }

        $currentCompetitionID = 0;
        if (isset($current['competition_id'])) {
            $currentCompetitionID = $current['competition_id'];
        } else if (count($all) > 0) {
            $currentCompetitionID = end($all)['competition_id'];
        }

        // Removing dupes and stopped
        $newAll = [];
        foreach ($all as $s) {
            if (!isset($_processed[$s['id']]) && $s['id'] != $stopLiveVotingID && $s['competition_id'] == $currentCompetitionID) {
                $newAll[] = $s;
                $_processed[$s['id']] = true;
            }
        }

        $newState = [
            'current' => $current,
            'all' => $newAll,
        ];

        apcu_store(storageKeyPrefix . $_GET['event_id'], $newState, memoryStorageTtlSec);
        NFWX::i()->jsonSuccess($newState);
    }


    function actionAdminOpenVoting() {
        $CCompetition = new competitions($_POST['competition_id']);
        if (!$CCompetition->record['id']) {
            $this->error($CCompetition->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $CCompetition->record['voting_from'] = time();
        $CCompetition->save();
        if ($CCompetition->error) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $CCompetition->last_msg)));
        }

        NFWX::i()->jsonSuccess(['message' => "Voting opened from now"]);
    }
}

function extractVotingVariants($come): array {
    $result = [];

    if (empty($come)) {
        $langMain = NFW::i()->getLang('main');
        foreach ($langMain['voting votes'] as $k => $v) {
            if ($k) {
                $result[] = $k;
            }
        }
    }

    foreach ($come as $v) {
        if ($v['value']) {
            $result[] = $v['value'];
        }
    }

    return $result;
}
