<?php
/**
 * @desc Комментарии к работам
 */

class works_comments extends active_record {
    var $attributes = array(
        'work_id' => array('type' => 'int', 'desc' => 'Work ID', 'required' => true),
        'message' => array('type' => 'textarea', 'desc' => 'Message', 'desc_ru' => 'Текст', 'required' => true, 'maxlength' => 2048),
    );

    protected function load($id) {
        $query = array(
            'SELECT' => 'wc.*, c.event_id',
            'FROM' => $this->db_table . ' AS wc',
            'JOINS' => array(
                array(
                    'INNER JOIN' => 'works AS w',
                    'ON' => 'wc.work_id=w.id'
                ),
                array(
                    'INNER JOIN' => 'competitions AS c',
                    'ON' => 'w.competition_id=c.id'
                ),
            ),
            'WHERE' => 'wc.id=' . intval($id),
        );

        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to load works comment', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        if (!NFW::i()->db->num_rows($result)) {
            $this->error('Record not found.', __FILE__, __LINE__);
            return false;
        }
        $this->db_record = $this->record = NFW::i()->db->fetch_assoc($result);

        return $this->record;
    }

    public function loadCounters(&$works): bool {
        $works_ids = $counters = array();
        foreach ($works as $work) {
            $works_ids[] = $work['id'];
        }

        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'work_id, COUNT(id) AS comments_count',
            'FROM' => $this->db_table,
            'GROUP BY' => 'work_id',
            'WHERE' => 'work_id IN(' . implode(',', $works_ids) . ')',
        ))) {
            $this->error('Unable to count works comments', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $counters[$record['work_id']] = $record['comments_count'];
        }

        foreach ($works as &$work) {
            $work['comments_count'] = $counters[$work['id']] ?? 0;
        }
        unset($work);

        return true;
    }

    public function getRecords($options = array()) {
        $filter = $options['filter'] ?? array();

        // Setup WHERE from filter
        $where = array('e.is_hidden=0');

        if (isset($filter['work_id'])) {
            $where[] = 'wc.work_id=' . intval($filter['work_id']);
        }

        $where = empty($where) ? null : implode(' AND ', $where);

        $query = array(
            'FROM' => $this->db_table . ' AS wc',
            'JOINS' => array(
                array(
                    'INNER JOIN' => 'works AS w',
                    'ON' => 'wc.work_id=w.id'
                ),
                array(
                    'INNER JOIN' => 'competitions AS c',
                    'ON' => 'w.competition_id=c.id'
                ),
                array(
                    'INNER JOIN' => 'events AS e',
                    'ON' => 'c.event_id=e.id'
                ),
            ),
            'WHERE' => $where,
            'ORDER BY' => $options['ORDER BY'] ?? 'wc.id',
        );

        // ----------------
        // Counting records
        // ----------------

        if (isset($options['records_on_page']) && $options['records_on_page']) {
            $query['SELECT'] = 'COUNT(*)';

            if (!$result = NFW::i()->db->query_build($query)) {
                $this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
            list($num_records) = NFW::i()->db->fetch_row($result);

            $this->num_pages = ceil($num_records / $options['records_on_page']);
            $page = isset($options['page']) ? intval($options['page']) : 1;
            $this->cur_page = ($page <= 1 || $page > $this->num_pages) ? 1 : $page;

            $query['LIMIT'] = $options['records_on_page'] * ($this->cur_page - 1) . ',' . $options['records_on_page'];
        }

        // ----------------
        // Fetching records
        // ----------------

        $query['SELECT'] = 'wc.*, w.title AS work_title, w.author AS work_author, c.works_type, c.alias AS competition_alias, e.title AS event_title, e.alias AS event_alias, c.event_id';

        $records = array();

        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (!NFW::i()->db->num_rows($result)) return $records;

        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $records[] = $record;
        }

        return $records;
    }

    function workComments(int $workID) {
        $this->error_report_type = 'active_form';

        $CWorks = new works($workID);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            return false;
        }

        NFW::i()->registerFunction('friendly_date');
        $langMain = NFW::i()->getLang('main');
        $comments = array();
        foreach ($this->getRecords(array('filter' => array('work_id' => $CWorks->record['id']))) as $comment) {
            $comments[] = array(
                'id' => $comment['id'],
                'posted_str' => friendly_date($comment['posted'], $langMain) . ' ' . date('H:i', $comment['posted']) . ' by ' . htmlspecialchars($comment['posted_username']),
                'message' => nl2br(htmlspecialchars($comment['message'])),
            );
        }

        return $comments;
    }

    function addComment(int $workID, string $message): bool {
        $CWorks = new works($workID);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            return false;
        }

        $this->formatAttributes([
            'work_id' => $workID,
            'message' => $message,
        ]);
        $this->errors = $this->validate();
        if (!empty($this->errors)) {
            return false;
        }

        return $this->save();
    }

    function displayLatestComments() {
        $comments = $this->getRecords(array('records_on_page' => 10, 'ORDER BY' => 'wc.id DESC'));
        if (count($comments) == 0) {
            return false;
        }

        // grouping comments by work ID
        $gComments = [];
        $worksID = [];
        foreach ($comments as $comment) {
            $workID = $comment['work_id'];
            $worksID[] = $workID;

            if (empty($gComments[$workID]['comments'])) {
                $gComments[$workID]['work_id'] = $workID;
                $gComments[$workID]['work_url'] = NFW::i()->absolute_path . '/' . $comment['event_alias'] . '/' . $comment['competition_alias'] . '/' . $comment['work_id'] . '#comments';
                $gComments[$workID]['title'] = $comment['event_title'] . ' / ' . $comment['work_title'] . ' by ' . $comment['work_author'];
            }
            $gComments[$workID]['items'][] = [
                'posted' => $comment['posted'],
                'posted_username' => $comment['posted_username'],
                'message' => $comment['message'],
            ];
        }

        // Loading works screenshots

        $CWorks = new works();
        $works = $CWorks->getRecords([
            'filter' => [
                'work_id' => array_unique($worksID)
            ],
            'skip_pagination' => true,
            'load_attachments' => true,
        ]);

        $screenshots = [];
        foreach ($works as $work) {
            if ($work['screenshot']) {
                $screenshots[$work['id']] = $work['screenshot'];
            }
        }

        return $this->renderAction(array(
            'gComments' => $gComments,
            'screenshots' => $screenshots,
        ), '_display_latest_comments');
    }
}