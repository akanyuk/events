<?php
/**
 * @desc Managing works
 */

class works extends active_record {
    static $action_aliases = array(
        'update' => array(
            array('module' => 'works', 'action' => 'admin'),
            array('module' => 'works', 'action' => 'get_pos'),
            array('module' => 'works', 'action' => 'set_pos'),
            array('module' => 'works', 'action' => 'insert'),
            array('module' => 'works', 'action' => 'update_work'),
            array('module' => 'works', 'action' => 'update_status'),
            array('module' => 'works', 'action' => 'update_links'),
            array('module' => 'works', 'action' => 'my_status'),
            array('module' => 'works', 'action' => 'delete'),
            array('module' => 'works_media', 'action' => 'update_properties'),
            array('module' => 'works_media', 'action' => 'rename_file'),
            array('module' => 'works_media', 'action' => 'preview_zx'),
            array('module' => 'works_media', 'action' => 'convert_zx'),
            array('module' => 'works_media', 'action' => 'file_id_diz'),
            array('module' => 'works_media', 'action' => 'make_release'),
            array('module' => 'works_media', 'action' => 'remove_release'),
        ),
    );

    var $attributes = array(
        'competition_id' => array('type' => 'select', 'desc' => 'Competition', 'required' => true, 'options' => array()),
        'position' => array('type' => 'int', 'desc' => 'Position'),
        'title' => array('type' => 'str', 'desc' => 'Title', 'required' => true, 'maxlength' => 200),
        'author' => array('type' => 'str', 'desc' => 'Author', 'required' => true, 'maxlength' => 200),
        'description' => array('type' => 'textarea', 'desc' => 'Description', 'maxlength' => 2048),
        'platform' => array('type' => 'str', 'desc' => 'Platform', 'required' => true, 'options' => array()),
        'format' => array('type' => 'str', 'desc' => 'Format', 'maxlength' => 128),
        'external_html' => array('type' => 'textarea', 'desc' => 'External HTML (i.e. Youtube)', 'maxlength' => 2048),

        'status' => array('type' => 'select', 'desc' => 'Status', 'options' => array(
            ['id' => 0, 'voting' => false, 'release' => false, 'css-class' => 'warning', 'icon' => 'fa fa-question'],         // Unchecked
            ['id' => 1, 'voting' => true, 'release' => true, 'css-class' => 'success', 'icon' => 'fa fa-check-circle'],       // Checked
            ['id' => 2, 'voting' => false, 'release' => false, 'css-class' => 'danger', 'icon' => 'fa fa-ban'],               // Disqualified
            ['id' => 3, 'voting' => false, 'release' => false, 'css-class' => 'warning', 'icon' => 'fa fa-question'],         // Feedback needed
            ['id' => 4, 'voting' => false, 'release' => true, 'css-class' => 'danger', 'icon' => 'fa fa-exclamation-circle'], // Out of competition
            ['id' => 5, 'voting' => false, 'release' => true, 'css-class' => 'info', 'icon' => 'fa fa-hourglass-half'],       // Wait preselect
        )),
        'status_reason' => array('type' => 'textarea', 'maxlength' => 512),

        'author_note' => array('type' => 'textarea', 'desc' => 'Author note', 'maxlength' => 512),
    );

    // TODO: remove this
    public $current_event = false;

    function __construct($record_id = false) {
        $lang_main = NFW::i()->getLang('main');

        foreach ($this->attributes['status']['options'] as &$o) {
            $o['desc'] = $lang_main['works status desc'][$o['id']];
            $o['desc_full'] = $lang_main['works status desc full'][$o['id']];
        }

        return parent::__construct($record_id);
    }

    private function loadEditorOptions($event_id, $options = array()): bool {
        $CEvents = new events($event_id);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        $this->current_event = $CEvents->record;

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
            'event_id' => $CEvents->record['id'],
            'open_reception' => $options['open_reception'] ?? false
        );
        $Competitions = new competitions();
        foreach ($Competitions->getRecords(array('filter' => $filters)) as $c) {
            $this->attributes['competition_id']['options'][] = array('id' => $c['id'], 'desc' => $c['title']);
        }

        return true;
    }

    private function formatRecord($record) {
        $record['display_title'] = $record['voting_to'] <= NFW::i()->actual_date ? $record['title'] . ' by ' . $record['author'] : $record['title'];
        $record['status_info'] = $this->attributes['status']['options'][$record['status']];

        // Convert `media_info`
        $record['screenshot'] = false;
        $record['voting_files'] = $record['release_files'] = $record['audio_files'] = $record['image_files'] = array();

        $media_info = NFW::i()->unserializeArray($record['media_info']);
        $record['media_info'] = array();
        foreach ($record['attachments'] as $a) {
            $a['is_screenshot'] = $a['is_voting'] = $a['is_image'] = $a['is_audio'] = $a['is_release'] = false;

            if (isset($media_info[$a['id']]['screenshot']) && $media_info[$a['id']]['screenshot']) {
                $record['screenshot'] = $a;
                $a['is_screenshot'] = true;
            }
            if (isset($media_info[$a['id']]['voting']) && $media_info[$a['id']]['voting']) {
                $record['voting_files'][] = $a;
                $a['is_voting'] = true;
            }
            if (isset($media_info[$a['id']]['image']) && $media_info[$a['id']]['image']) {
                $record['image_files'][] = $a;
                $a['is_image'] = true;
            }
            if (isset($media_info[$a['id']]['audio']) && $media_info[$a['id']]['audio']) {
                $record['audio_files'][] = $a;
                $a['is_audio'] = true;
            }
            if (isset($media_info[$a['id']]['release']) && $media_info[$a['id']]['release']) {
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
            'SELECT' => 'w.*, c.title AS competition_title, c.position AS competition_pos, c.alias AS competition_alias, c.works_type, c.voting_from, c.voting_to, e.id AS event_id, e.title AS event_title, e.date_from AS event_from, e.date_to AS event_to, e.alias AS event_alias, u.email AS poster_email, u.realname AS poster_realname, u.country AS poster_country, u.city AS poster_city',
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
            foreach ($competitions as &$c) {
                $ids[] = $c['id'];
                $compo_by_id[$c['id']] = array('voting_works' => 0, 'release_works' => 0);
            }
            unset($c);
        } else {
            $ids[] = $competitions;
            $compo_by_id[$competitions] = array('voting_works' => 0, 'release_works' => 0);
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

            $select[] = 'wmi.is_checked AS managers_notes_is_checked';
            $select[] = 'wmi.is_marked AS managers_notes_is_marked';
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
        };

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

    function actionMainSearch() {
        $search_string = isset($_GET['q']) ? trim($_GET['q']) : false;
        if (!$search_string) {
            NFW::i()->stop('[]');
        }

        $response = array();
        foreach ($this->getRecords(array('filter' => array('search_main' => $search_string), 'limit' => 12, 'skip_pagination' => true)) as $record) {
            $response[] = array(
                'id' => $record['id'],
                'title' => $record['display_title'],
                'link' => $record['main_link']
            );
        }

        NFW::i()->stop(json_encode($response));
    }

    // Просмотр автором работ из ЛК
    function actionCabinetList() {
        $records = $this->getRecords(array(
            'filter' => array('posted_by' => NFW::i()->user['id'], 'allow_hidden' => true),
            'ORDER BY' => 'e.date_from DESC, c.position, w.position',
            'load_attachments' => true,
            'load_attachments_icons' => false,
            'skip_pagination' => true
        ));

        return $this->renderAction(array('records' => $records));
    }

    function actionCabinetView() {
        $this->error_report_type = empty($_POST) ? 'error-page' : 'active_form';

        if (!$this->load($_GET['record_id'])) return false;
        if ($this->record['posted_by'] != NFW::i()->user['id']) {
            $this->error(NFW::i()->lang['Errors']['Bad_request'], __FILE__, __LINE__);
            return false;
        }

        if (empty($_POST)) {
            return $this->renderAction();
        }

        // Add files to work
        $CMedia = new media();
        $files_added = $CMedia->getSessionFiles(get_class($this));
        if (empty($files_added)) {
            $this->error('System error: no files. Please try again.', __FILE__, __LINE__);
            return false;
        }
        $CMedia->closeSession(get_class($this), $this->record['id']);

        // Reset `checked` status for all managers
        NFW::i()->db->query_build(array('UPDATE' => 'works_managers_notes', 'SET' => 'is_checked=0', 'WHERE' => 'work_id=' . $this->record['id']));

        NFWX::i()->sendNotify('works_add_files', $this->record['event_id'], array('work' => $this->record, 'media_added' => count($files_added), 'comment' => $_POST['comment']), $files_added);

        $lang_main = NFW::i()->getLang('main');
        NFW::i()->renderJSON(array('result' => 'success', 'message' => $lang_main['works added files success message']));
    }

    function actionCabinetAdd() {
        $lang_main = NFW::i()->getLang('main');

        // Collect events with reception opened
        $events = array();
        $CCompetitions = new competitions();
        foreach ($CCompetitions->getRecords(array('filter' => array('open_reception' => true))) as $c) {
            $events[] = $c['event_id'];
        }
        $events = array_unique($events);

        if (empty($events)) {
            $this->error($lang_main['events no open'], __FILE__, __LINE__);
            return false;
        }

        // Choose event
        if (count($events) > 1 && !isset($_GET['event_id'])) {
            $CEvents = new events();
            return $this->renderAction(array(
                'events' => $CEvents->getRecords(array('load_media' => true, 'filter' => array('ids' => $events)))
            ), 'add_choose_event');
        }

        $event_id = $_GET['event_id'] ?? reset($events);

        if (!in_array($event_id, $events)) {
            $this->error($lang_main['events not found'], __FILE__, __LINE__);
            return false;
        }

        if (!$this->loadEditorOptions($event_id, array('open_reception' => true))) {
            return false;
        }

        if (empty($_POST)) {
            return $this->renderAction();
        }

        $lang_main = NFW::i()->getLang('main');

        $this->formatAttributes($_POST);
        // Collect description from several fields
        $desc = array();
        if ($_POST['description_public']) {
            $desc[] = 'Comment for visitors:' . "\n" . $_POST['description_public'];
        }
        if ($_POST['description_refs']) {
            $desc[] = 'Display additional: ' . $_POST['description_refs'];
        }
        if ($_POST['description']) {
            $desc[] = 'Comment for organizers:' . "\n" . $_POST['description'];
        }
        $this->record['description'] = implode("\n\n", $desc);

        $errors = $this->validate();

        $CMedia = new media();
        if (!$CMedia->countSessionFiles(get_class($this))) {
            $errors['general'] = $lang_main['works upload no file error'];
        }

        if (!empty($errors)) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
        }

        $this->save();
        if ($this->error) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $this->last_msg)));
        }

        NFWX::i()->hook("works_add_save_success", $this->current_event['alias'], array('record' => $this->record, 'post' => $_POST));

        // Add media
        $CMedia->closeSession(get_class($this), $this->record['id']);
        $this->reload();    // Load $this->record['attachments']

        NFWX::i()->sendNotify('works_add', $this->current_event['id'], array('work' => $this->record), $this->record['media_info']);
        NFW::i()->renderJSON(array('result' => 'success', 'message' => $lang_main['works upload success message']));
    }

    function actionAdminAdmin() {
        if (!$this->loadEditorOptions($_GET['event_id'])) {
            return false;
        }

        $records = $this->getRecords(array(
            'filter' => array(
                'event_id' => $this->current_event['id'],
                'allow_hidden' => true,
            ),
            'ORDER BY' => 'c.position, w.posted',
            'load_attachments' => true,
            'skip_pagination' => true,
        ));

        return $this->renderAction([
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

        // Fetch personal info
        if (!$result = NFW::i()->db->query_build(array('SELECT' => 'is_checked, is_marked, comment', 'FROM' => 'works_managers_notes', 'WHERE' => 'work_id=' . $this->record['id'] . ' AND user_id=' . NFW::i()->user['id']))) {
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
            "personalNote" => $personalNote,
            "linkTitles" => $linkTitles,
        ]);
    }

    function actionAdminUpdateWork() {
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

        $errors = $this->validate();
        if (!empty($errors)) {
            NFWX::i()->jsonError(400, $errors);
        }

        $this->save();
        if ($this->error) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        NFWX::i()->jsonSuccess();
    }

    function actionAdminUpdateStatus() {
        if (!$this->load($_GET['record_id']) || !$this->loadEditorOptions($this->record['event_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

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

        NFWX::i()->jsonSuccess();
    }

    function actionAdminUpdateLinks() {
        if (!$this->load($_GET['record_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $new_links = array();
        if (isset($_POST['links'])) foreach ($_POST['links']['url'] as $pos => $url) {
            if (!$url) continue;

            $new_links[] = array('url' => $url, 'title' => $_POST['links']['title'][$pos]);
        }
        $is_links_updated = !(NFW::i()->serializeArray($this->record['links']) == NFW::i()->serializeArray($new_links));

        if ($is_links_updated) {
            // Prune all old links
            if (!NFW::i()->db->query_build(array('DELETE' => 'works_links', 'WHERE' => 'work_id=' . $this->record['id']))) {
                $this->error('Unable to delete old links', __FILE__, __LINE__, NFW::i()->db->error());
                NFWX::i()->jsonError(400, $this->last_msg);
            }

            foreach ($new_links as $key => $link) {
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

        NFWX::i()->jsonSuccess();
    }

    function actionAdminMyStatus() {
        $this->error_report_type = 'active_form';
        if (!$this->load($_GET['record_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        // Update work manager note
        if (!NFW::i()->db->query_build(array('DELETE' => 'works_managers_notes', 'WHERE' => 'work_id=' . $this->record['id'] . ' AND user_id=' . NFW::i()->user['id']))) {
            $this->error('Unable to delete old personal info', __FILE__, __LINE__, NFW::i()->db->error());
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (!NFW::i()->db->query_build(array(
            'INSERT' => 'work_id, user_id, comment, is_checked, is_marked',
            'INTO' => 'works_managers_notes',
            'VALUES' => $this->record['id'] . ',' . NFW::i()->user['id'] . ', \'' . NFW::i()->db->escape($_POST['comment']) . '\', ' . intval($_POST['is_checked']) . ', ' . intval($_POST['is_marked'])
        ))) {
            $this->error('Unable to insert personal info', __FILE__, __LINE__, NFW::i()->db->error());
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        NFWX::i()->jsonSuccess();
    }

    function actionAdminDelete() {
        if (!$this->load($_GET['record_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        // Remove attachments
        $CMedia = new media();
        if (isset($this->record['attachments'])) foreach ($this->record['attachments'] as $a) {
            $CMedia->reload($a['id']);
            $CMedia->delete();
        }

        $logMsg = 'Work `' . $this->record['title'] . '` (ID=' . $this->record['id'] . ') deleted';

        if (!$this->delete()) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        logs::write($logMsg);
        NFWX::i()->jsonSuccess();
    }
}
