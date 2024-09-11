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
        'begin' => array('desc' => 'begin', 'type' => 'date', 'withTime' => true, 'startDate' => 1, 'endDate' => -365),
        'begin_source' => array('desc' => 'Begin source', 'type' => 'select', 'options' => [
            ['val' => '', 'text' => 'Manual input'],
            ['val' => 'reception_from', 'text' => 'Reception from'],
            ['val' => 'reception_to', 'text' => 'Reception to'],
            ['val' => 'voting_from', 'text' => 'Voting from'],
            ['val' => 'voting_to', 'text' => 'Voting to'],
        ]),
        'end' => array('desc' => 'begin', 'type' => 'date', 'withTime' => true, 'startDate' => 1, 'endDate' => -365),
        'end_source' => array('desc' => 'End source', 'type' => 'select', 'options' => [
            ['val' => '', 'text' => 'Manual input'],
            ['val' => 'reception_from', 'text' => 'Reception from'],
            ['val' => 'reception_to', 'text' => 'Reception to'],
            ['val' => 'voting_from', 'text' => 'Voting from'],
            ['val' => 'voting_to', 'text' => 'Voting to'],
        ]),
        'title' => array('desc' => 'Title', 'type' => 'str', 'required' => true, 'minlength' => 4, 'maxlength' => 255),
        'description' => array('desc' => 'Description (multilanguage HTML)', 'type' => 'textarea', 'minlength' => 4, 'maxlength' => 2048),
        'type' => array('desc' => 'Type', 'type' => 'string', 'maxlength' => 32),
        'place' => array('desc' => 'Place', 'type' => 'string', 'maxlength' => 255),
        'is_public' => array('desc' => 'Public', 'type' => 'bool'),
    );

    function beginSources() {
        return $this->attributes['begin_source']['options'];
    }

    function endSources() {
        return $this->attributes['end_source']['options'];
    }

    function getRecords(int $eventID) {
        if (!$result = NFW::i()->db->query_build([
            'SELECT' => 't.*, c.title AS competition_title, c.reception_from, c.reception_to, c.voting_from, c.voting_to',
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
                $key,
                $CEvents->record['id'],
                intval($_POST['competition_id'][$key]),
                strtotime($_POST['begin'][$key]),
                strtotime($_POST['end'][$key]),
                intval($_POST['is_public'][$key]),
                '\'' . NFW::i()->db->escape($title) . '\'',
                '\'' . NFW::i()->db->escape($_POST['description'][$key]) . '\'',
                '\'' . NFW::i()->db->escape($_POST['type'][$key]) . '\'',
                '\'' . NFW::i()->db->escape($_POST['place'][$key]) . '\'',
                '\'' . NFW::i()->db->escape($_POST['begin_source'][$key]) . '\'',
                '\'' . NFW::i()->db->escape($_POST['end_source'][$key]) . '\'',
            ];
            $query = array(
                'INSERT' => '`position`, `event_id`, `competition_id`, `begin`, `end`, `is_public`, `title`, `description`, `type`, `place`, `begin_source`, `end_source`',
                'INTO' => $this->db_table,
                'VALUES' => implode(', ', $values),
            );
            if (!NFW::i()->db->query_build($query)) {
                $this->error('Unable to insert new timeline record', __FILE__, __LINE__, NFW::i()->db->error());
                NFWX::i()->jsonError(400, $this->last_msg);
            }
        }

        NFWX::i()->jsonSuccess();
    }
}

function formatTimelineRecord($item): array {
    switch ($item['begin_source']) {
        case 'reception_from':
            $item['begin'] = intval($item['reception_from']);
            break;
        case 'reception_to':
            $item['begin'] = intval($item['reception_to']);
            break;
        case 'voting_from':
            $item['begin'] = intval($item['voting_from']);
            break;
        case 'voting_to':
            $item['begin'] = intval($item['voting_to']);
            break;
        default:
            $item['begin'] = intval($item['begin']);
    }

    switch ($item['end_source']) {
        case 'reception_from':
            $item['end'] = intval($item['reception_from']);
            break;
        case 'reception_to':
            $item['end'] = intval($item['reception_to']);
            break;
        case 'voting_from':
            $item['end'] = intval($item['voting_from']);
            break;
        case 'voting_to':
            $item['end'] = intval($item['voting_to']);
            break;
        default:
            $item['end'] = intval($item['end']);
    }

    unset($item['reception_from'], $item['reception_to'], $item['voting_from'], $item['voting_to']);

    return $item;
}

function sortTimeline($a, $b): int {
    if ($a['begin'] != $b['begin']) {
        return $a['begin'] > $b['begin'] ? 1 : -1;
    }

    return $a['position'] > $b['position'] ? 1 : -1;
}
