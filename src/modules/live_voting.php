<?php

const storageKeyPrefix = "live-voting-storage-key";
const memoryStorageTtlSec = 3600;

NFW::i()->registerFunction('cache_media');

class live_voting extends active_record {
    public static function IsAllowed($eventID, $workID): bool {
        $state = apcu_fetch(storageKeyPrefix . $eventID);
        if ($state === false) {
            return false;
        }

        foreach ($state['works'] as $item) {
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

        if (isset($_POST['stopAll']) && $_POST['stopAll']) {
            apcu_delete(storageKeyPrefix . $_GET['event_id']);
            NFWX::i()->jsonSuccess();
        }

        $state = apcu_fetch(storageKeyPrefix . $_GET['event_id']);

        if (isset($_POST['comingAnnounce']) && $_POST['comingAnnounce']) {
            $state['comingAnnounce'] = [
                'title' => $_POST['comingAnnounce']['title'],
                'description' => $_POST['comingAnnounce']['description'],
            ];
            unset($state['endAnnounce']);
            $state['works'] = [];
            apcu_store(storageKeyPrefix . $_GET['event_id'], $state, memoryStorageTtlSec);
            NFWX::i()->jsonSuccess($state);
        }

        if (isset($_POST['comingAnnounceStop']) && $_POST['comingAnnounceStop']) {
            unset($state['comingAnnounce']);
            apcu_store(storageKeyPrefix . $_GET['event_id'], $state, memoryStorageTtlSec);
            NFWX::i()->jsonSuccess($state);
        }

        if (isset($_POST['endAnnounce']) && $_POST['endAnnounce']) {
            $state['endAnnounce'] = [
                'title' => $_POST['endAnnounce']['title'],
                'description' => $_POST['endAnnounce']['description'],
            ];
            unset($state['comingAnnounce']);
            apcu_store(storageKeyPrefix . $_GET['event_id'], $state, memoryStorageTtlSec);
            NFWX::i()->jsonSuccess($state);
        }

        if (isset($_POST['endAnnounceStop']) && $_POST['endAnnounceStop']) {
            unset($state['endAnnounce']);
            apcu_store(storageKeyPrefix . $_GET['event_id'], $state, memoryStorageTtlSec);
            NFWX::i()->jsonSuccess($state);
        }

        $state['works'] = isset($state['works']) && is_array($state['works']) ? $state['works'] : [];

        if (isset($_POST['start'])) {
            $CWorks = new works($_POST['start']);
            if ($CWorks->record['id']) {
                $state['works'][$CWorks->record['id']] = [
                    'competition_id' => $CWorks->record['competition_id'],
                    'id' => $CWorks->record['id'],
                    'position' => intval($_POST['position']),
                    'title' => $CWorks->record['title'],
                    'competition_title' => $CWorks->record['competition_title'],
                    'screenshot' => $CWorks->record['screenshot'] ? cache_media($CWorks->record['screenshot'], 640, 0) : '',
                    'voting_options' => $CEvents->votingOptions(),
                ];

                foreach ($state['works'] as $key => $work) {
                    if ($work['competition_id'] != $CWorks->record['competition_id']) {
                        unset($state['works'][$key]);
                    }
                }

                // Stopping announces on voting start
                unset($state['comingAnnounce']);
                unset($state['endAnnounce']);
            }
        }

        if (isset($_POST['stop'])) {
            unset($state['works'][intval($_POST['stop'])]);
        }

        apcu_store(storageKeyPrefix . $_GET['event_id'], $state, memoryStorageTtlSec);
        NFWX::i()->jsonSuccess($state);
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

