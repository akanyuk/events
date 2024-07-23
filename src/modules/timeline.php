<?php

class timeline extends active_record {
    static $action_aliases = array(
        'admin' => array(
            array('module' => 'timeline', 'action' => 'update'),
        ),
    );

    var $attributes = array(
        'event_id' => array('desc' => 'Event', 'type' => 'select', 'options' => array()),
        'competition_id' => array('desc' => 'Competition', 'type' => 'select', 'options' => array()),
        'ts' => array('desc' => 'Date/time', 'type' => 'date', 'withTime' => true, 'startDate' => 1, 'endDate' => -365),
        'title' => array('desc' => 'Title', 'type' => 'str', 'required' => true, 'minlength' => 4, 'maxlength' => 255),
        'type' => array('desc' => 'Type', 'type' => 'string', 'maxlength' => 32),
        'ts_source' => array('desc' => 'Competition', 'type' => 'select', 'options' => [
            ['val' => '', 'text' => 'Manual input'],
            ['val' => 'reception_from', 'text' => 'Reception from'],
            ['val' => 'reception_to', 'text' => 'Reception to'],
            ['val' => 'voting_from', 'text' => 'Voting from'],
            ['val' => 'voting_to', 'text' => 'Voting to'],
        ]),
    );

    function tsSources() {
        return $this->attributes['ts_source']['options'];
    }

    function getRecords(int $eventID) {
        if (!$result = NFW::i()->db->query_build([
            'SELECT' => 't.*, c.reception_from, c.reception_to, c.voting_from, c.voting_to',
            'FROM' => $this->db_table . ' AS t',
            'JOINS' => array(
                array(
                    'LEFT JOIN' => 'competitions AS c',
                    'ON' => 't.competition_id=c.id'
                ),
            ),
            'WHERE' => 't.event_id=' . $eventID,
        ])) {
            $this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (!NFW::i()->db->num_rows($result)) {
            return array();
        }

        $records = array();
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $records[] = formatTimelineRecord($record);
        }

        usort($records, 'sortTimeline');
        return $records;
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

        $CCompetitions = new competitions();
        return $this->renderAction([
            'event' => $CEvents->record,
            'competitions' => $CCompetitions->getRecords(['filter' => ['event_id' => $CEvents->record['id']]]),
            'records' => $this->getRecords($CEvents->record['id']),
        ]);
    }

    function actionAdminUpdate() {
        if (!isset($_GET['event_id'])) {
            $this->error(NFW::i()->lang['Errors']['Bad_request'], __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $CEvents = new events($_GET['event_id']);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        // Prune previous timeline
        NFW::i()->db->query_build(array('DELETE' => $this->db_table, 'WHERE' => 'event_id=' . $CEvents->record['id']));

        foreach ($_POST['title'] as $key => $title) {
            $values = [
                $CEvents->record['id'],
                intval($_POST['competition_id'][$key]),
                intval($_POST['ts'][$key]),
                '\'' . NFW::i()->db->escape($title) . '\'',
                '\'' . NFW::i()->db->escape($_POST['type'][$key]) . '\'',
                '\'' . NFW::i()->db->escape($_POST['ts_source'][$key]) . '\'',
            ];
            $query = array(
                'INSERT' => '`event_id`, `competition_id`, `ts`, `title`, `type`, `ts_source`',
                'INTO' => $this->db_table,
                'VALUES' => implode(', ', $values),
            );
            if (!NFW::i()->db->query_build($query)) {
                $this->error('Unable to insert new timeline', __FILE__, __LINE__, NFW::i()->db->error());
                NFWX::i()->jsonError(400, $this->last_msg);
            }
        }

        NFWX::i()->jsonSuccess();
    }
}

function formatTimelineRecord($item): array {
    if ($item['competition_id']) {
        switch ($item['ts_source']) {
            case 'reception_from':
                $item['ts'] = intval($item['reception_from']);
                break;
            case 'reception_to':
                $item['ts'] = intval($item['reception_to']);
                break;
            case 'voting_from':
                $item['ts'] = intval($item['voting_from']);
                break;
            case 'voting_to':
                $item['ts'] = intval($item['voting_to']);
                break;
        }
    } else {
        $item['ts'] = intval($item['ts']);
    }

    unset($item['reception_from'], $item['reception_to'], $item['voting_from'], $item['voting_to']);

    return $item;
}

function sortTimeline($a, $b): int {
    return $a['ts'] > $b['ts'] ? 1 : -1;
}
