<?php
/**
 * @desc Managing groups of competitions
 */

class competitions_groups extends active_record {
    static $action_aliases = array(
        'admin' => array(
            array('module' => 'competitions', 'action' => 'update'),
        ),
        'update' => array(
            array('module' => 'competitions', 'action' => 'update'),
        ),
    );

    var $attributes = array(
        'event_id' => array('desc' => 'Event', 'type' => 'int', 'required' => true),
        'position' => array('desc' => 'Position', 'type' => 'int', 'required' => true),
        'title' => array('desc' => 'Title', 'type' => 'str', 'required' => true, 'minlength' => 4, 'maxlength' => 255),
        'announcement' => array('desc' => 'Announce (multilanguage HTML)', 'type' => 'textarea', 'maxlength' => 4096),
    );

    public function getRecords($eventID): array {
        $query = array(
            'SELECT' => '*',
            'FROM' => $this->db_table,
            'WHERE' => 'event_id=' . intval($eventID),
            'ORDER BY' => 'position'
        );
        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
            return [];
        }

        $records = array();
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $records[] = $record;
        }

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

        $records = $this->getRecords($CEvents->record['id']);
        if ($records === false) {
            $this->error('Unable to get groups of competitions', __FILE__, __LINE__);
            return false;
        }

        return $this->renderAction([
            'event' => $CEvents->record,
            'records' => $records,
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

        if (!NFW::i()->checkPermissions('check_manage_event', $CEvents->record['id'])) {
            $this->error('No permissions', __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (!NFW::i()->db->query_build(array('DELETE' => $this->db_table, 'WHERE' => 'event_id=' . $CEvents->record['id']))) {
            $this->error('Unable to delete old competitions groups info', __FILE__, __LINE__, NFW::i()->db->error());
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (empty($_POST['title'])) {
            NFWX::i()->jsonSuccess();
        }

        $pos = 1;
        foreach ($_POST['title'] as $i => $title) {
            $this->formatAttributes([
                'event_id' => $CEvents->record['id'],
                'position' => $pos++,
                'title' => $title,
                'announcement' => $_POST['announcement'][$i],
            ]);
            $errors = $this->validate();
            if (!empty($errors)) {
                NFWX::i()->jsonError(400, $errors);
            }

            $this->record['id'] = false; // Force insert
            $this->save();
            if ($this->error) {
                NFWX::i()->jsonError(400, $this->last_msg);
            }

            if ($_POST['id'][$i]) {
                // Restore previous ID
                if (!NFW::i()->db->query_build([
                    'UPDATE' => $this->db_table,
                    'SET' => 'id=' . intval($_POST['id'][$i]),
                    'WHERE' => 'id=' . $this->record['id'],
                ])) {
                    $this->error('Unable to restore previous ID', __FILE__, __LINE__, NFW::i()->db->error());
                    return false;
                }
            }

        }

        NFWX::i()->jsonSuccess();
    }
}