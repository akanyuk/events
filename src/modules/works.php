<?php
/**
 * @desc Managing works
 */

class works extends active_record {
    var $attributes = array(
        'competition_id' => array('type' => 'select', 'desc' => 'Competition', 'required' => true, 'options' => array()),
        'position' => array('type' => 'int', 'desc' => 'Position'),
        'title' => array('type' => 'str', 'desc' => 'Title', 'required' => true, 'maxlength' => 200),
        'author' => array('type' => 'str', 'desc' => 'Author', 'required' => true, 'maxlength' => 200),
        'description' => array('type' => 'textarea', 'desc' => 'Description', 'maxlength' => 2048),
        'platform' => array('type' => 'str', 'desc' => 'Platform', 'required' => true, 'maxlength' => 128, 'options' => array()),
        'format' => array('type' => 'str', 'desc' => 'Format', 'maxlength' => 128),
        'external_html' => array('type' => 'textarea', 'desc' => 'Additional text (HTML)', 'maxlength' => 2048),

        'status' => array('type' => 'select', 'desc' => 'Status', 'options' => array(
            ['id' => 0, 'cnt' => false, 'voting' => false, 'release' => false, 'css-class' => 'warning', 'svg-icon' => 'status-unchecked'],      // Unchecked
            ['id' => 1, 'cnt' => true, 'voting' => true, 'release' => true, 'css-class' => 'success', 'svg-icon' => 'status-checked'],           // Checked
            ['id' => 2, 'cnt' => false, 'voting' => false, 'release' => false, 'css-class' => 'danger', 'svg-icon' => 'status-disqualified'],    // Disqualified
            ['id' => 3, 'cnt' => false, 'voting' => false, 'release' => false, 'css-class' => 'warning', 'svg-icon' => 'status-feedback-needed'],// Feedback needed
            ['id' => 4, 'cnt' => false, 'voting' => false, 'release' => true, 'css-class' => 'info', 'svg-icon' => 'status-out-of-compo'],       // Out of competition
            ['id' => 5, 'cnt' => true, 'voting' => false, 'release' => false, 'css-class' => 'info', 'svg-icon' => 'status-wait-preselection'],  // Wait preselect
        )),
        'status_reason' => array('type' => 'textarea', 'maxlength' => 512),

        'author_note' => array('type' => 'textarea', 'desc' => 'Author note', 'maxlength' => 512),
    );

    function __construct($record_id = false) {
        $lang_main = NFW::i()->getLang('main');

        foreach ($this->attributes['status']['options'] as &$o) {
            $o['desc'] = $lang_main['works status desc'][$o['id']];
            $o['desc_full'] = $lang_main['works status desc full'][$o['id']];
        }

        return parent::__construct($record_id);
    }

    private function formatRecord($record) {
        $record['display_title'] = $record['voting_to'] <= NFWX::i()->actual_date ? $record['title'] . ' by ' . $record['author'] : $record['title'];
        $record['status_info'] = $this->attributes['status']['options'][$record['status']];

        // Convert `media_info`
        $record['screenshot'] = false;
        $record['voting_files'] = $record['release_files'] = $record['audio_files'] = $record['image_files'] = [];

        $record['media_props'] = NFW::i()->unserializeArray($record['media_info']);
        $record['media_info'] = array();
        foreach ($record['attachments'] as $a) {
            $a['is_screenshot'] = $a['is_voting'] = $a['is_image'] = $a['is_audio'] = $a['is_release'] = false;

            if (isset($record['media_props'][$a['id']]['screenshot']) && $record['media_props'][$a['id']]['screenshot']) {
                $record['screenshot'] = $a;
                $a['is_screenshot'] = true;
            }
            if (isset($record['media_props'][$a['id']]['voting']) && $record['media_props'][$a['id']]['voting']) {
                $record['voting_files'][] = $a;
                $a['is_voting'] = true;
            }
            if (isset($record['media_props'][$a['id']]['image']) && $record['media_props'][$a['id']]['image']) {
                $record['image_files'][] = $a;
                $a['is_image'] = true;
            }
            if (isset($record['media_props'][$a['id']]['audio']) && $record['media_props'][$a['id']]['audio']) {
                $record['audio_files'][] = $a;
                $a['is_audio'] = true;
            }
            if (isset($record['media_props'][$a['id']]['release']) && $record['media_props'][$a['id']]['release']) {
                $record['release_files'][] = $a;
                $a['is_release'] = true;
            }

            $record['media_info'][] = $a;
        }
        unset($record['attachments']);

        $fs_basename = iconv("UTF-8", NFW::i()->cfg['media']['fs_encoding'], $record['release_basename']);
        if ($record['release_basename'] && file_exists(PUBLIC_HTML . '/files/' . $record['event_alias'] . '/' . $record['competition_alias'] . '/' . $fs_basename)) {
            NFW::i()->registerFunction('friendly_filesize');
            $record['release_link'] = array(
                'url' => NFW::i()->absolute_path . '/files/' . $record['event_alias'] . '/' . $record['competition_alias'] . '/' . $record['release_basename'],
                'filesize_str' => friendly_filesize(PUBLIC_HTML . '/files/' . $record['event_alias'] . '/' . $record['competition_alias'] . '/' . $fs_basename),
            );
        } else {
            $record['release_link'] = false;
        }

        $record['main_link'] = NFW::i()->absolute_path . '/' . $record['event_alias'] . '/' . $record['competition_alias'] . '/' . $record['id'];

        return $record;
    }

    protected function load($id, $options = array()) {
        $query = array(
            'SELECT' => 'w.*, c.title AS competition_title, c.position AS competition_pos, c.alias AS competition_alias, c.works_type, c.voting_from, c.voting_to, e.id AS event_id, e.title AS event_title, e.date_from AS event_from, e.date_to AS event_to, e.alias AS event_alias, u.email AS poster_email',
            'FROM' => $this->db_table . ' AS w',
            'JOINS' => array(
                array(
                    'INNER JOIN' => 'competitions AS c',
                    'ON' => 'w.competition_id=c.id'
                ),
                array(
                    'INNER JOIN' => 'events AS e',
                    'ON' => 'c.event_id=e.id'
                ),
                array(
                    'LEFT JOIN' => 'users AS u',
                    'ON' => 'w.posted_by=u.id'
                ),
            ),
            'WHERE' => 'w.id=' . intval($id),
        );
        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to fetch work', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        if (!NFW::i()->db->num_rows($result)) {
            $this->error('Work not found.', __FILE__, __LINE__);
            return false;
        }
        $this->db_record = $this->record = NFW::i()->db->fetch_assoc($result);

        $CMedia = new media();
        $this->record['attachments'] = $CMedia->getFiles(get_class($this), $this->record['id'], array('order_by' => 'position'));

        // Load links
        $this->record['links'] = array();
        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'url, title',
            'FROM' => 'works_links',
            'WHERE' => 'work_id=' . $this->record['id'],
            'ORDER BY' => 'position',
        ))) {
            $this->error('Unable to fetch record links', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        while ($link = NFW::i()->db->fetch_assoc($result)) {
            $this->record['links'][] = $link;
        }

        $this->record = $this->formatRecord($this->record);
        return $this->record;
    }

    protected function save($attributes = array()): bool {
        // Determine `position`
        if (!$this->record['position']) {
            if (!$result = NFW::i()->db->query_build(array('SELECT' => 'MAX(`position`)', 'FROM' => $this->db_table, 'WHERE' => 'competition_id=' . intval($this->record['competition_id'])))) {
                $this->error('Unable to determine `position`', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
            list($pos) = NFW::i()->db->fetch_row($result);
            $this->record['position'] = intval($pos) + 1;
        }

        return parent::save($attributes);
    }

    public function loadCounters(&$competitions) {
        $ids = $compo_by_id = array();
        if (is_array($competitions)) {
            foreach ($competitions as $c) {
                $ids[] = $c['id'];
                $compo_by_id[$c['id']] = ['counter_works' => 0, 'voting_works' => 0, 'release_works' => 0];
            }
            unset($c);
        } else {
            $ids[] = $competitions;
            $compo_by_id[$competitions] = ['counter_works' => 0, 'voting_works' => 0, 'release_works' => 0];
        }

        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'competition_id, status',
            'FROM' => $this->db_table,
            'WHERE' => 'competition_id IN(' . implode(',', $ids) . ')',
        ))) {
            $this->error('Unable to count status records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $status = $this->searchArrayAssoc($this->attributes['status']['options'], $record['status']);
            if ($status['cnt']) $compo_by_id[$record['competition_id']]['counter_works']++;
            if ($status['voting']) $compo_by_id[$record['competition_id']]['voting_works']++;
            if ($status['release']) $compo_by_id[$record['competition_id']]['release_works']++;
        }

        if (is_array($competitions)) {
            foreach ($competitions as &$c) {
                $c = array_merge($c, $compo_by_id[$c['id']]);
            }
            unset($c);
        } else {
            return $compo_by_id[$competitions];
        }

        return true;
    }

    public function getRecords($options = array()) {
        $filter = $options['filter'] ?? array();
        $limit = isset($options['limit']) ? intval($options['limit']) : false;
        $offset = isset($options['offset']) ? intval($options['offset']) : false;
        $skip_pagination = isset($options['skip_pagination']) && $options['skip_pagination'];
        $fetch_manager_note = isset($options['fetch_manager_note']) && $options['fetch_manager_note'];

        if (!$skip_pagination) {
            // Count total records
            $query = array('SELECT' => 'COUNT(*)', 'FROM' => $this->db_table);
            if (!$result = NFW::i()->db->query_build($query)) {
                $this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
            list($total_records) = NFW::i()->db->fetch_row($result);
        } else {
            $total_records = 0;
        }

        // Setup WHERE from filter
        $where = array();

        if (isset($filter['posted_by'])) {
            $where[] = 'w.posted_by=' . intval($filter['posted_by']);
        }

        if (isset($filter['event_id'])) {
            $where[] = 'c.event_id=' . intval($filter['event_id']);
        }

        if (isset($filter['competition_id'])) {
            $where[] = 'c.id=' . intval($filter['competition_id']);
        }

        if (isset($filter['work_id']) && is_array($filter['work_id'])) {
            if (empty($filter['work_id'])) {
                return $skip_pagination ? array() : array(array(), 0, 0);
            }

            $where[] = 'w.id IN (' . implode(',', $filter['work_id']) . ')';
        }

        if (!(isset($filter['allow_hidden']) && $filter['allow_hidden'])) {
            $where[] = 'e.is_hidden=0';
        }

        // Collect statuses
        $vs = $rs = array();
        foreach ($this->attributes['status']['options'] as $s) {
            if ($s['voting']) {
                $vs[] = $s['id'];
            }
            if ($s['release']) {
                $rs[] = $s['id'];
            }
        }

        if (isset($filter['voting_only']) && $filter['voting_only']) {
            $where[] = 'w.status IN (' . implode(',', $vs) . ')';
        }

        if (isset($filter['release_only']) && $filter['release_only']) {
            $where[] = 'w.status IN (' . implode(',', $rs) . ')';
        }

        if (isset($filter['released_only']) && $filter['released_only']) {
            $where[] = 'w.status IN (' . implode(',', $rs) . ')';
            $where[] = 'e.is_hidden=0';
            $where[] = 'c.voting_to<=' . NFWX::i()->actual_date;
        }

        if (isset($filter['search_main']) && $filter['search_main']) {
            $where[] = 'w.status IN (' . implode(',', array_unique(array_merge($vs, $rs))) . ')';
            $where[] = 'e.is_hidden=0';
            $where[] = 'c.voting_from<=' . NFWX::i()->actual_date;
            $where[] = '(w.title LIKE \'%' . NFW::i()->db->escape($filter['search_main']) . '%\' OR w.author LIKE \'%' . NFW::i()->db->escape($filter['search_main']) . '%\')';
        }

        $where = count($where) ? join(' AND ', array_unique($where)) : null;

        $joins = array(
            array(
                'INNER JOIN' => 'competitions AS c',
                'ON' => 'w.competition_id=c.id'
            ),
            array(
                'INNER JOIN' => 'events AS e',
                'ON' => 'c.event_id=e.id'
            ),
        );

        // Count filtered values
        if (!$skip_pagination) {
            $query = array(
                'SELECT' => 'COUNT(*)',
                'FROM' => $this->db_table . ' AS w',
                'JOINS' => $joins,
                'WHERE' => $where,
            );
            if (!$result = NFW::i()->db->query_build($query)) {
                $this->error('Unable to count filtered records', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
            list($num_filtered) = NFW::i()->db->fetch_row($result);
            if (!$num_filtered) {
                return array(array(), $total_records, 0);
            }
        } else {
            $num_filtered = 0;
        }

        $select = array('w.*', 'IFNULL(w.place,9999) AS sorting_place', 'c.title AS competition_title', 'c.position AS competition_pos', 'c.alias AS competition_alias', 'c.works_type', 'c.voting_from', 'c.voting_to', 'e.id AS event_id', 'e.title AS event_title', 'e.date_from AS event_from', 'e.date_to AS event_to', 'e.alias AS event_alias');

        if ($fetch_manager_note) {
            $joins[] = array(
                'LEFT JOIN' => 'works_managers_notes AS wmi',
                'ON' => 'wmi.work_id=w.id AND wmi.user_id=' . NFW::i()->user['id']
            );
            $select[] = 'wmi.comment AS managers_notes_comment';
        }

        // ----------------
        // Fetching records
        // ----------------
        $query = array(
            'SELECT' => implode(', ', $select),
            'FROM' => $this->db_table . ' AS w',
            'JOINS' => $joins,
            'WHERE' => $where,
            'ORDER BY' => $options['ORDER BY'] ?? 'e.date_from, c.position, w.position',
        );
        if ($limit) {
            $query['LIMIT'] = ($offset ? $offset . ',' : '') . $limit;
        }
        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (!NFW::i()->db->num_rows($result)) {
            return $skip_pagination ? array() : array(array(), $total_records, $num_filtered);
        }

        $records = $ids = $links = array();
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $ids[] = $record['id'];

            $links[$record['id']] = array();
            $record['attachments'] = array();
            $records[] = $record;
        }

        if (isset($options['load_attachments']) && $options['load_attachments']) {
            $CMedia = new media();
            $getFilesOptions = array(
                'order_by' => 'position',
                'skipLoadIcons' => isset($options['load_attachments_icons']) && !$options['load_attachments_icons'],
            );

            foreach ($CMedia->getFiles(get_class($this), $ids, $getFilesOptions) as $a) {
                foreach ($records as $key => $record) {
                    if ($record['id'] != $a['owner_id']) continue;

                    $records[$key]['attachments'][] = $a;
                    break;
                }
            }
        }

        // Load links
        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'work_id, url, title',
            'FROM' => 'works_links',
            'WHERE' => 'work_id IN (' . implode(',', $ids) . ')',
            'ORDER BY' => 'work_id, position',
        ))) {
            $this->error('Unable to fetch record links', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        while ($link = NFW::i()->db->fetch_assoc($result)) {
            $links[$link['work_id']][] = array('title' => $link['title'], 'url' => $link['url']);
        }

        foreach ($records as $key => $record) {
            $record['links'] = $links[$record['id']];

            $records[$key] = $this->formatRecord($record);
        }

        // Load comments count
        $CWorksComments = new works_comments();
        $CWorksComments->loadCounters($records);

        return $skip_pagination ? $records : array($records, $total_records, $num_filtered);
    }

    function validate($record = false, $attributes = false) {
        $errors = parent::validate($this->record, $this->attributes);
        if (!$this->searchArrayAssoc($this->attributes['competition_id']['options'], $this->record['competition_id'])) {
            $errors['competition_id'] = 'System error: wrong competition ID';
        }

        return $errors;
    }

    public function saveWork(): bool {
        return $this->save();
    }

    public function loadEditorOptions($event_id, $options = array()): bool {
        // Collect available platforms
        if (!$result = NFW::i()->db->query_build(array('SELECT' => 'DISTINCT platform', 'FROM' => 'works', 'ORDER BY' => 'platform'))) {
            $this->error('Unable to fetch platforms', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $this->attributes['platform']['options'][] = $record['platform'];
        }

        // Load competitions
        $filters = array(
            'event_id' => $event_id,
            'open_reception' => $options['open_reception'] ?? false
        );
        $Competitions = new competitions();
        foreach ($Competitions->getRecords(array('filter' => $filters)) as $c) {
            $this->attributes['competition_id']['options'][] = array('id' => $c['id'], 'desc' => $c['title']);
        }

        return true;
    }

    function actionAdminAdmin() {
        $CEvents = new events($_GET['event_id']);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        if (!$this->loadEditorOptions($CEvents->record['id'])) {
            return false;
        }

        $records = $this->getRecords(array(
            'filter' => array(
                'event_id' => $CEvents->record['id'],
                'allow_hidden' => true,
            ),
            'ORDER BY' => 'c.position, w.posted',
            'load_attachments' => true,
            'skip_pagination' => true,
        ));

        return $this->renderAction([
            'event' => $CEvents->record,
            'records' => $records,
            'defaultCompetition' => intval(reset($this->attributes['competition_id']['options'])['id']),
        ]);
    }

    function actionAdminGetPos() {
        $records = $this->getRecords(array(
            'filter' => array(
                'competition_id' => $_POST['competition_id'] ?? 0,
                'allow_hidden' => true,
                'voting_only' => true,
            ),
            'load_attachments' => true,
            'skip_pagination' => true,
        ));
        $result = [];
        foreach ($records as $r) {
            if (!NFW::i()->checkPermissions('check_manage_event', $r['event_id'])) {
                continue;
            }

            $result[] = [
                'id' => $r['id'],
                'title' => $r['title'],
                'author' => $r['author'],
                'icon' => $r['screenshot'] ? $r['screenshot']['tmb_prefix'] . '64' : NFW::i()->assets('main/news-no-image.png'),
            ];
        }

        NFWX::i()->jsonSuccess($result);
    }

    function actionAdminSetPos() {
        $pos = 1;
        foreach ($_POST['work'] as $id) {
            if (!$this->load($id)) {
                continue;
            }

            if (!NFW::i()->checkPermissions('check_manage_event', $this->record['event_id'])) {
                continue;
            }

            if (!NFW::i()->db->query_build(
                array(
                    'UPDATE' => $this->db_table,
                    'SET' => 'position=' . $pos++,
                    'WHERE' => 'id=' . $this->record['id'],
                )
            )) {
                $this->error('Unable to update positions', __FILE__, __LINE__, NFW::i()->db->error());
                NFWX::i()->jsonError(400, $this->last_msg);
            }
        }

        NFWX::i()->jsonSuccess();
    }

    function actionAdminInsert() {
        if (!$this->loadEditorOptions($_GET['event_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $this->formatAttributes([
            'title' => $_POST['title'],
            'author' => $_POST['author'],
            'platform' => $_POST['platform'],
            'competition_id' => intval($_POST['competition_id']),
        ]);
        $errors = $this->validate();
        if (!empty($errors)) {
            NFWX::i()->jsonError(400, $errors);
        }

        $this->save();
        if ($this->error) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        NFWX::i()->jsonSuccess(['record_id' => $this->record['id']]);
    }

    function actionAdminUpdate() {
        if (!$this->load($_GET['record_id']) || !$this->loadEditorOptions($this->record['event_id'])) {
            return false;
        }

        $CCompetitions = new competitions($this->record['competition_id']);
        if (!$CCompetitions->record['id']) {
            $this->error($CCompetitions->last_msg);
            return false;
        }

        if (!$this->load($_GET['record_id']) || !$this->loadEditorOptions($this->record['event_id'])) {
            return false;
        }

        // Fetch personal info
        if (!$result = NFW::i()->db->query_build(array('SELECT' => 'comment', 'FROM' => 'works_managers_notes', 'WHERE' => 'work_id=' . $this->record['id'] . ' AND user_id=' . NFW::i()->user['id']))) {
            return false;
        }
        if (NFW::i()->db->num_rows($result)) {
            $personalNote = NFW::i()->db->fetch_assoc($result);
        } else {
            $personalNote = array('is_checked' => false, 'is_marked' => false, 'comment' => '');
        }

        // Collect available links titles
        $linkTitles = array();
        if (!$result = NFW::i()->db->query_build(array('SELECT' => 'DISTINCT title', 'FROM' => 'works_links', 'ORDER BY' => 'title'))) {
            return false;
        }
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $linkTitles[] = $record['title'];
        }

        return $this->renderAction([
            'CCompetitions' => $CCompetitions,
            'personalNote' => $personalNote,
            'linkTitles' => $linkTitles,
        ]);
    }

    function actionAdminPreview() {
        if (!$this->load($_GET['record_id']) || !$this->loadEditorOptions($this->record['event_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $this->formatAttributes($_POST, array(
            'title' => $this->attributes['title'],
            'author' => $this->attributes['author'],
            'competition_id' => $this->attributes['competition_id'],
            'platform' => $this->attributes['platform'],
            'format' => $this->attributes['format'],
            'author_note' => $this->attributes['author_note'],
            'external_html' => $this->attributes['external_html'],
        ));

        NFW::i()->registerFunction("display_work_media");
        NFWX::i()->jsonSuccess(["content" =>
            NFWX::i()->renderPage(NFW::i()->fetch(SRC_ROOT . '/templates/works/admin/preview.tpl',
                ["record" => $this->record],
            )),
        ]);
    }

    function actionAdminUpdateWork() {
        if (!$this->load($_GET['record_id']) || !$this->loadEditorOptions($this->record['event_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $oldRecord = $this->record;

        $this->formatAttributes($_POST, array(
            'title' => $this->attributes['title'],
            'author' => $this->attributes['author'],
            'competition_id' => $this->attributes['competition_id'],
            'platform' => $this->attributes['platform'],
            'format' => $this->attributes['format'],
            'author_note' => $this->attributes['author_note'],
            'external_html' => $this->attributes['external_html'],
        ));

        $errors = $this->validate();
        if (!empty($errors)) {
            NFWX::i()->jsonError(400, $errors);
        }

        $this->save();
        if ($this->error) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $this->reload();

        foreach (['title', 'author', 'competition_id', 'platform', 'format', 'author_note', 'external_html'] as $field) {
            if ($oldRecord[$field] != $this->record[$field]) {
                if ($field == 'competition_id') {
                    $value = $this->record['competition_title'];
                } else {
                    $value = $this->record[$field];
                }
                works_activity::adminUpdate($this->record['id'], $field, $value);
            }
        }

        NFWX::i()->jsonSuccess();
    }

    function actionAdminUpdateStatus() {
        if (!$this->load($_GET['record_id']) || !$this->loadEditorOptions($this->record['event_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $oldStatus = $this->record['status'];
        $oldStatusReason = $this->record['status_reason'];

        $this->formatAttributes($_POST, array(
            'status' => $this->attributes['status'],
            'status_reason' => $this->attributes['status_reason'],
        ));

        $errors = $this->validate();
        if (!empty($errors)) {
            NFWX::i()->jsonError(400, $errors);
        }

        $this->save();
        if ($this->error) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if ($this->record['status'] != $oldStatus || $this->record['status_reason'] != $oldStatusReason) {
            works_activity::adminUpdateStatus($this->record['id'], $this->record['status'], $this->record['status_reason']);
        }

        NFWX::i()->jsonSuccess();
    }

    function actionAdminUpdateLinks() {
        if (!$this->load($_GET['record_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $newLinks = array();
        if (isset($_POST['links'])) foreach ($_POST['links']['url'] as $pos => $url) {
            if (!$url) continue;

            $newLinks[] = array('url' => $url, 'title' => $_POST['links']['title'][$pos]);
        }
        $isLinksUpdated = !(NFW::i()->serializeArray($this->record['links']) == NFW::i()->serializeArray($newLinks));

        if ($isLinksUpdated) {
            // Prune all old links
            if (!NFW::i()->db->query_build(array('DELETE' => 'works_links', 'WHERE' => 'work_id=' . $this->record['id']))) {
                $this->error('Unable to delete old links', __FILE__, __LINE__, NFW::i()->db->error());
                NFWX::i()->jsonError(400, $this->last_msg);
            }

            foreach ($newLinks as $key => $link) {
                if (!NFW::i()->db->query_build(array(
                    'INSERT' => '`work_id`, `position`, `title`, `url`',
                    'INTO' => 'works_links',
                    'VALUES' => $this->record['id'] . ',' . $key . ',\'' . NFW::i()->db->escape($link['title']) . '\',\'' . NFW::i()->db->escape($link['url']) . '\''
                ))) {
                    $this->error('Unable to insert link', __FILE__, __LINE__, NFW::i()->db->error());
                    NFWX::i()->jsonError(400, $this->last_msg);
                }
            }
        }

        $before = array_map(function ($x) {
            return $x['url'];
        }, $this->record['links']);
        $after = array_map(function ($x) {
            return $x['url'];
        }, $newLinks);
        foreach (array_diff($before, $after) as $url) {
            works_activity::adminLinkRemoved($this->record['id'], $url);
        }
        foreach (array_diff($after, $before) as $url) {
            works_activity::adminLinkAdded($this->record['id'], $url);
        }

        NFWX::i()->jsonSuccess();
    }

    function actionAdminMyStatus() {
        $this->error_report_type = 'active_form';
        if (!$this->load($_GET['record_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (!NFW::i()->db->query_build(array('DELETE' => 'works_managers_notes', 'WHERE' => 'work_id=' . $this->record['id'] . ' AND user_id=' . NFW::i()->user['id']))) {
            $this->error('Unable to delete old personal info', __FILE__, __LINE__, NFW::i()->db->error());
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (!isset($_POST['set']) || !$_POST['set']) {
            NFWX::i()->jsonSuccess(["message" => "Personal note cleared"]);
        }

        if (!NFW::i()->db->query_build(array(
            'INSERT' => 'comment, work_id, user_id',
            'INTO' => 'works_managers_notes',
            'VALUES' => '\'' . NFW::i()->db->escape($_POST['comment']) . '\', ' . $this->record['id'] . ',' . NFW::i()->user['id']
        ))) {
            $this->error('Unable to insert personal info', __FILE__, __LINE__, NFW::i()->db->error());
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        NFWX::i()->jsonSuccess(["message" => "Personal note set"]);
    }

    function actionAdminDelete() {
        if (!$this->load($_GET['record_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        // Remove attachments
        $CMedia = new media();
        if (isset($this->record['media_info'])) foreach ($this->record['media_info'] as $a) {
            $CMedia->reload($a['id']);
            $CMedia->delete();
        }

        works_activity::workDeleted($this->record['id']);

        $logMsg = 'Work `' . $this->record['title'] . '` (ID=' . $this->record['id'] . ') deleted';

        if (!$this->delete()) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        logs::write($logMsg);
        NFWX::i()->jsonSuccess();
    }
}
