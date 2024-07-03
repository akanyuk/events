<?php

const memoryStorageKey = "live-voting-storage-key";
const memoryStorageTtlSec = 3600;

class live_voting extends active_record {
    static $action_aliases = array(
        'admin' => array(
            array('module' => 'competitions', 'action' => 'update'),
        ),
    );

    public static function GetWorks($eventID): array {
        $result = apcu_fetch(memoryStorageKey);
        if ($result === false) {
            return [];
        }

        $works = [];
        foreach ($result as $work) {
            if ($work["event_id"] == $eventID) {
                $works[] = $work;
            }
        }

        return $works;
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

        return $this->renderAction([
            'event' => $CEvents->record,
            'works' => $works,
        ]);
    }

    function actionAdminReadState() {
        NFWX::i()->jsonSuccess(apcu_fetch(memoryStorageKey));
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
            apcu_delete(memoryStorageKey);
            NFWX::i()->jsonSuccess();
        }

        $stopLiveVotingID = isset($_POST['stopLiveVoting']) ? intval($_POST['stopLiveVoting']) : 0;

        $state = apcu_fetch(memoryStorageKey);
        $current = isset($state['current']['id']) && $state['current']['id'] != $stopLiveVotingID ? $state['current'] : [];
        $all = $state['all'] ?? [];

        if (isset($_POST['startLiveVoting'])) {
            $CWorks = new works($_POST['startLiveVoting']);
            if ($CWorks->record['id'] && $CWorks->record['id'] != $stopLiveVotingID) {
                $current = [
                    'id' => $CWorks->record['id'],
                    'competition_id' => $CWorks->record['competition_id'],
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

        apcu_store(memoryStorageKey, $newState, memoryStorageTtlSec);
        NFWX::i()->jsonSuccess($newState);
    }
}
