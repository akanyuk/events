<?php
/**
 * @desc Managing events
 */

class events extends active_record {
    static $action_aliases = array(
        'update' => array(
            array('module' => 'events', 'action' => 'media_upload'),
            array('module' => 'events', 'action' => 'media_modify'),
            array('module' => 'events_preview', 'action' => 'media_upload'),
            array('module' => 'events_preview', 'action' => 'media_modify'),
            array('module' => 'events_preview_large', 'action' => 'media_upload'),
            array('module' => 'events_preview_large', 'action' => 'media_modify'),
        ),
        'manage' => array(
            array('module' => 'events', 'action' => 'insert'),
        )
    );

    var $attributes = array(
        'title' => array('desc' => 'Title', 'type' => 'str', 'required' => true, 'minlength' => 4, 'maxlength' => 255),
        'announcement' => array('desc' => 'Announce', 'type' => 'textarea', 'maxlength' => 4096),
        'announcement_og' => array('desc' => 'Announcement for Open Graph', 'type' => 'str', 'maxlength' => 128),
        'options' => array('desc' => 'Options', 'type' => 'custom'),
        'content' => array('desc' => 'Description', 'type' => 'str', 'maxlength' => 1048576),
        'date_from' => array('desc' => 'Date from', 'type' => 'date', 'required' => true),
        'date_to' => array('desc' => 'Date to', 'type' => 'date', 'is_end' => true, 'required' => true),
        'hide_works_count' => array('desc' => 'Hide works count', 'type' => 'bool'),
        'voting_system' => ['type' => 'select', 'desc' => 'Voting system', 'options' => [
            ['id' => 'avg', 'desc' => 'Average'],
            ['id' => 'iqm', 'desc' => 'IQM'],
            ['id' => 'sum', 'desc' => 'Sum'],
        ]],
    );

    protected array $service_attributes = array(
        'is_hidden' => array('desc' => 'Event disabled', 'type' => 'bool'),
        'alias' => array('desc' => 'Event alias', 'type' => 'str', 'required' => true, 'minlength' => 2, 'maxlength' => 32),
        'alias_group' => array('desc' => 'Event alias group', 'type' => 'str', 'minlength' => 2, 'maxlength' => 32),
    );

    var array $options_attributes = array(
        'label_Russian' => array('desc' => 'Label [RU]', 'type' => 'str', 'style' => 'width: 300px;', 'required' => 0),
        'label_English' => array('desc' => 'Label [EN]', 'type' => 'str', 'style' => 'width: 300px;', 'required' => 0),
        'value' => array('desc' => 'Value', 'type' => 'str', 'style' => 'width: 100px;', 'required' => 1)
    );

    static function get_managed() {
        static $managed_records = false;

        if ($managed_records === false) {
            $managed_records = array();

            if (NFW::i()->checkPermissions('events', 'manage')) {
                $query = array('SELECT' => 'id', 'FROM' => 'events', 'ORDER BY' => 'date_from DESC');
            } else {
                $query = array(
                    'SELECT' => 'e.id',
                    'FROM' => 'events_managers AS m',
                    'JOINS' => array(
                        array(
                            'INNER JOIN' => 'events AS e',
                            'ON' => 'm.event_id=e.id'
                        ),
                    ),
                    'ORDER BY' => 'e.date_from DESC',
                    'WHERE' => 'm.user_id=' . NFW::i()->user['id']);
            }

            if (!$result = NFW::i()->db->query_build($query)) {
                return array();
            }

            while ($cur_record = NFW::i()->db->fetch_assoc($result)) {
                $managed_records[] = $cur_record['id'];
            }
        }

        return $managed_records;
    }

    private function formatRecord($record) {
        $record['options'] = NFW::i()->unserializeArray($this->record['options']);

        $record['date_from'] = mktime(0, 0, 0, date('m', $record['date_from']), date('d', $record['date_from']), date('Y', $record['date_from']));
        $record['date_to'] = mktime(23, 59, 59, date('m', $record['date_to']), date('d', $record['date_to']), date('Y', $record['date_to']));

        NFW::i()->registerFunction('word_suffix');
        $lang_main = NFW::i()->getLang('main');

        $record['dates_desc'] = date('d.m.Y', $record['date_from']) == date('d.m.Y', $record['date_to']) ? date('d.m.Y', $record['date_from']) : date('d.m.Y', $record['date_from']) . ' - ' . date('d.m.Y', $record['date_to']);

        $days_left = ceil(($record['date_from'] - NFWX::i()->actual_date) / 86400);
        if ($days_left >= 1) {
            $record['status_label'] = '+' . $days_left . ' ' . word_suffix($days_left, $lang_main['days suffix']);
            $record['status_type'] = 'upcoming';
        } elseif ($record['date_from'] < NFWX::i()->actual_date && $record['date_to'] > NFWX::i()->actual_date) {
            $record['status_label'] = 'NOW!';
            $record['status_type'] = 'current';
        } else {
            $record['status_label'] = '';
            $record['status_type'] = '';
        }

        // Prepare thumbnails

        if (isset($record['preview']['url']) && file_exists($record['preview']['fullpath'])) {
            $record['preview_img'] = $record['preview']['url'];
            $record['is_preview_img'] = true;
        } else {
            $record['preview_img'] = NFW::i()->assets('main/news-no-image.png');
            $record['is_preview_img'] = false;
        }

        if (isset($record['preview_large']['url']) && file_exists($record['preview_large']['fullpath'])) {
            $record['preview_img_large'] = $record['preview_large']['url'];
        } else {
            $record['preview_img_large'] = false;
        }

        return $record;
    }

    protected function save($attributes = array()) {
        $is_update = !$this->record['id'];

        $result = parent::save($attributes);
        if ($is_update || $result) {
            // Add service information
            $query = array(
                'UPDATE' => $this->db_table,
                'SET' => '`edited_by`=' . NFW::i()->user['id'] . ', `edited_username`=\'' . NFW::i()->db->escape(NFW::i()->user['username']) . '\', `edited_ip`=\'' . logs::get_remote_address() . '\', `edited`=' . time(),
                'WHERE' => '`id`=' . $this->record['id']
            );
            if (!NFW::i()->db->query_build($query)) {
                $this->error('Unable to update record', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
        }

        return $result;
    }

    public function load($id, $load_by_alias = false) {
        $query = array(
            'SELECT' => '*',
            'FROM' => $this->db_table,
            'WHERE' => $load_by_alias ? 'alias="' . NFW::i()->db->escape($id) . '"' : 'id=' . intval($id)
        );
        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to fetch record', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (!NFW::i()->db->num_rows($result)) {
            $this->error('Record not found.', __FILE__, __LINE__);
            return false;
        }
        $this->db_record = $this->record = NFW::i()->db->fetch_assoc($result);

        $CMedia = new media();

        $this->record['attachments'] = array();
        foreach ($CMedia->getFiles(get_class($this), $this->record['id']) as $a) {
            $this->record['attachments'][] = $a;
        }

        $result = $CMedia->getFiles('events_preview', $this->record['id']);
        $this->record['preview'] = empty($result) ? false : reset($result);

        $result = $CMedia->getFiles('events_preview_large', $this->record['id']);
        $this->record['preview_large'] = empty($result) ? false : reset($result);

        $this->record = $this->formatRecord($this->record);
        return $this->record;
    }

    public function loadByAlias($alias) {
        $result = $this->load(urldecode($alias), true);

        if ($this->error || $this->record['is_hidden']) {
            $this->error('Record not found.', __FILE__, __LINE__);
            return false;
        }

        return $result;
    }

    function votingOptions(): array {
        $result = [];

        if (!empty($this->record['options'])) {
            foreach ($this->record['options'] as $v) {
                if ($v['value']) {
                    $result[] = $v['value'];
                }
            }
        }

        $langMain = NFW::i()->getLang('main');
        foreach ($langMain['voting votes'] as $k => $v) {
            if ($k) {
                $result[] = $k;
            }
        }

        return $result;
    }

    function getRecords($options = array()) {
        $where = array();
        $filter = $options['filter'] ?? array();

        if (isset($filter['managed_events']) && $filter['managed_events']) {
            $managed_events = events::get_managed();
            if (empty($managed_events)) return array();

            $where[] = 'e.id IN(' . implode(',', $managed_events) . ')';
        } else {
            $where[] = 'e.is_hidden=0';
        }

        if (!empty($filter['ids'])) {
            $where[] = 'e.id IN (' . implode(', ', $filter['ids']) . ')';
        }

        if (isset($filter['upcoming-current']) && $filter['upcoming-current']) {
            $where[] = 'e.date_to > ' . time();
        }

        if (isset($filter['alias_group']) && $filter['alias_group']) {
            $where[] = 'e.alias_group = "' . NFW::i()->db->escape($filter['alias_group']) . '"';
        }

        $query = array(
            'SELECT' => 'e.id, e.is_hidden, e.title, e.alias, e.announcement, e.date_from, e.date_to, e.posted',
            'FROM' => $this->db_table . ' AS e',
            'WHERE' => empty($where) ? null : implode(' AND ', $where),
            'LIMIT' => isset($options['limit']) && $options['limit'] ? intval($options['limit']) : null,
            'OFFSET' => isset($options['offset']) && $options['offset'] ? intval($options['offset']) : null,
            'ORDER BY' => $options['order'] ?? 'date_from DESC'
        );

        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (!NFW::i()->db->num_rows($result)) {
            return array();
        }

        $records = $ids = $previews = $preview_larges = array();
        while ($cur_record = NFW::i()->db->fetch_assoc($result)) {
            $records[] = $cur_record;
            $ids[] = $cur_record['id'];
        }

        // load images
        if (isset($options['load_media']) && $options['load_media']) {
            // Load records previews
            $CMedia = new media();

            foreach ($CMedia->getFiles(
                'events_preview',
                $ids,
                array('skipLoadIcons' => true)) as $a) {
                $previews[$a['owner_id']] = $a;
            }

            foreach ($CMedia->getFiles(
                'events_preview_large',
                $ids,
                array('skipLoadIcons' => true)) as $a) {
                $preview_larges[$a['owner_id']] = $a;
            }
        }

        foreach ($records as $key => $record) {
            $record['preview'] = $previews[$record['id']] ?? false;
            $record['preview_large'] = $preview_larges[$record['id']] ?? false;
            $records[$key] = $this->formatRecord($record);
        }

        return $records;
    }

    public function validate($record = false, $attributes = false) {
        $errors = parent::validate($record ? $record : $this->record, $attributes ? $attributes : $this->attributes);

        // Validate 'alias' unique
        $query = array(
            'SELECT' => '*',
            'FROM' => $this->db_table,
            'WHERE' => 'alias=\'' . NFW::i()->db->escape($this->record['alias']) . '\''
        );
        if ($this->record['id']) {
            $query['WHERE'] .= ' AND id<>' . $this->record['id'];
        }
        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to validate alias', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        if (NFW::i()->db->num_rows($result)) {
            $errors['alias'] = 'Дублирование поля «' . $this->attributes['alias']['desc'] . '» недопустимо.';
        }

        return $errors;
    }

    function actionAdminAdmin() {
        $this->error_report_type = 'plain';

        $this->loadServicettributes();

        return $this->renderAction(array(
            'records' => $this->getRecords(array('filter' => array('managed_events' => true)))
        ));
    }

    function actionAdminInsert() {
        if (empty($_POST)) return false;

        $this->loadServicettributes();

        $this->error_report_type = 'active_form';
        $this->formatAttributes($_POST);
        $errors = $this->validate();
        if (!empty($errors)) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
        }

        $this->save();
        if ($this->error) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $this->last_msg)));
        }

        NFW::i()->renderJSON(array('result' => 'success', 'record_id' => $this->record['id']));
    }

    function actionAdminUpdate() {
        $this->error_report_type = empty($_POST) ? 'default' : 'active_form';

        if (!$this->load($_GET['record_id'])) {
            return false;
        }

        $this->loadServicettributes();

        if (empty($_POST) || (isset($_REQUEST['force-render']) && $_REQUEST['force-render'])) {
            return $this->renderAction();
        }

        if (isset($_POST['save_results_txt']) && $_POST['save_results_txt']) {
            if (!file_exists(PUBLIC_HTML . '/files/' . $this->record['alias'])) {
                mkdir(PUBLIC_HTML . '/files/' . $this->record['alias'], 0777);
            }

            $results_txt = $_POST['results_txt'];
            $results_filename = $_POST['results_filename'] ? htmlspecialchars($_POST['results_filename']) : 'results.txt';

            if (!$fp = fopen(PUBLIC_HTML . '/files/' . $this->record['alias'] . '/' . $results_filename, 'w')) {
                $this->error('Unable to open results file', __FILE__, __LINE__);
                return false;
            }
            fwrite($fp, $results_txt);
            fclose($fp);

            NFW::i()->renderJSON(array('result' => 'success', 'url' => NFW::i()->absolute_path . '/files/' . $this->record['alias'] . '/' . $results_filename));
        }

        // Save
        $this->formatAttributes($_POST);

        // Format `options`
        if (isset($_POST['update_record_options']) && $_POST['update_record_options']) {
            $values = array();
            if (isset($_POST['options'])) {
                foreach ($this->options_attributes as $varname => $a) {
                    foreach ($_POST['options'][$varname] as $index => $cur_val) {
                        $values[$index][$varname] = $this->formatAttribute($cur_val, $a);
                    }
                }
            }
            $this->record['options'] = NFW::i()->serializeArray($values);
        } else {
            $this->record['options'] = NFW::i()->serializeArray($this->record['options']);
        }

        $errors = $this->validate();
        if (!empty($errors)) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
        }

        $is_updated = $this->save();
        if ($this->error) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $this->last_msg)));
        }

        NFW::i()->renderJSON(array('result' => 'success', 'is_updated' => $is_updated));
    }

    function actionAdminManage() {
        $this->error_report_type = 'active_form';

        if (empty($_POST) || !$this->load($_GET['record_id'])) return false;

        // Update main table
        $this->loadServicettributes();
        $this->formatAttributes($_POST);

        $errors = $this->validate();
        if (!empty($errors)) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
        }

        $this->save();
        if ($this->error) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $this->last_msg)));
        }

        // Update managers table
        if (!NFW::i()->db->query('DELETE FROM ' . NFW::i()->db->prefix . 'events_managers WHERE event_id=' . $this->record['id'])) {
            $this->error('Unable to delete old event managers', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (isset($_POST['managers']) && is_array($_POST['managers'])) foreach ($_POST['managers'] as $a) {
            if (!NFW::i()->db->query('INSERT INTO ' . NFW::i()->db->prefix . 'events_managers (user_id, event_id) VALUES (' . intval($a) . ',' . $this->record['id'] . ')')) {
                $this->error('Unable to insert event managers', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
        }

        NFW::i()->renderJSON(array('result' => 'success'));
    }
}