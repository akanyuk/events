<?php
/**
 * @desc Votes, voting results.
 */

class vote extends active_record {
    static $action_aliases = array(
        'admin' => array(
            array('module' => 'vote', 'action' => 'votekeys'),
            array('module' => 'vote', 'action' => 'votes'),
            array('module' => 'vote', 'action' => 'add_vote'),
            array('module' => 'vote', 'action' => 'results'),
            array('module' => 'live_voting', 'action' => 'admin'),
            array('module' => 'live_voting', 'action' => 'read_state'),
            array('module' => 'live_voting', 'action' => 'update_state'),
        ),
    );

    // Load results for given works array
    public function getResults($event_id, $calcBy) {
        $query = array(
            'SELECT' => 'v.work_id, v.vote, w.competition_id, w.title, w.author, c.position AS competition_pos, c.title AS competition_title',
            'FROM' => 'votes AS v',
            'JOINS' => array(
                array(
                    'LEFT JOIN' => 'works AS w',
                    'ON' => 'v.work_id=w.id'
                ),
                array(
                    'LEFT JOIN' => 'competitions AS c',
                    'ON' => 'w.competition_id=c.id'
                ),
            ),
            'WHERE' => 'v.event_id=' . $event_id,
            'ORDER BY' => 'v.work_id'
        );

        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to fetch votes', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        $works = array();
        $allVotes = array();
        while ($r = NFW::i()->db->fetch_assoc($result)) {
            if (!isset($works[$r['competition_id']])) {
                $works[$r['competition_id']] = array(
                    'title' => $r['competition_title'],
                    'position' => $r['competition_pos'],
                    'works' => array()
                );
            }

            if (!isset($works[$r['competition_id']]['works'][$r['work_id']])) {
                $works[$r['competition_id']]['works'][$r['work_id']] = array(
                    'id' => $r['work_id'],
                    'title' => $r['title'],
                    'author' => $r['author'],
                    'num_votes' => 0,
                    'total_scores' => 0,
                    'average_vote' => 0,
                    'iqm_vote' => 0,
                    'place' => 0
                );
            }

            if (!isset($allVotes[$r['work_id']])) {
                $allVotes[$r['work_id']] = array();
            }
            $allVotes[$r['work_id']][] = intval($r['vote']);

            $works[$r['competition_id']]['works'][$r['work_id']]['total_scores'] += $r['vote'];
            $works[$r['competition_id']]['works'][$r['work_id']]['num_votes']++;
        }

        $prevNumVotes = 0;
        $prev_total = 0;
        $prev_average = 0;
        $prev_iqm = 0;
        foreach ($works as $cid => $competition) {
            // Calculate average and iqm
            foreach ($competition['works'] as $key => $work) {
                $works[$cid]['works'][$key]['average_vote'] = round($works[$cid]['works'][$key]['total_scores'] / $works[$cid]['works'][$key]['num_votes'], 2);
                $works[$cid]['works'][$key]['iqm_vote'] = calculateIQM($allVotes[$work['id']]);
            }

            switch ($calcBy) {
                case "iqm":
                    usort($works[$cid]['works'], 'calcByIQM');
                    break;
                case "sum":
                    usort($works[$cid]['works'], 'calcBySum');
                    break;
                default:
                    usort($works[$cid]['works'], 'calcByAvg');
            }

            $place = 1;
            foreach ($works[$cid]['works'] as $key => $work) {
                switch ($calcBy) {
                    case 'avg':
                        if ($work['average_vote'] == $prev_average && $work['total_scores'] == $prev_total && $place > 1) {
                            $place--;
                        }
                        break;
                    case 'iqm':
                        if ($work['iqm_vote'] == $prev_iqm && $work['total_scores'] == $prev_total && $place > 1) {
                            $place--;
                        }
                        break;
                    default:
                        if ($work['total_scores'] == $prev_total && $work['num_votes'] == $prevNumVotes && $place > 1) {
                            $place--;
                        }
                }

                $prev_total = $work['total_scores'];
                $prevNumVotes = $work['num_votes'];
                $prev_average = $work['average_vote'];
                $prev_iqm = $work['iqm_vote'];
                $works[$cid]['works'][$key]['place'] = $place++;
            }
        }

        // Sort competitions
        usort($works, 'sortByPos');

        return $works;
    }

    public function getWorksVotes(array $workID, votekey $votekey): array {
        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'vote, work_id',
            'FROM' => 'votes',
            'WHERE' => 'work_id IN (' . implode(',', $workID) . ') AND votekey_id=' . $votekey->id,
        ))) {
            $this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
            return [];
        }

        if (!NFW::i()->db->num_rows($result)) {
            return [];
        }
        $votes = [];
        while ($r = NFW::i()->db->fetch_assoc($result)) {
            $votes[$r['work_id']] = $r['vote'];
        }

        return $votes;
    }

    public function getVotes(int $eventID, string $searchQuery, int $limit, int $offset) {
        // Count total records
        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'COUNT(*)',
            'FROM' => 'votes',
            'WHERE' => 'event_id = ' . $eventID,
        ))) {
            $this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        list($totalRecords) = NFW::i()->db->fetch_row($result);
        if ($totalRecords == 0) {
            return [[], 0, 0];
        }

        $joins = array(
            array(
                'INNER JOIN' => 'works AS w',
                'ON' => 'v.work_id=w.id'
            ),
            array(
                'LEFT JOIN' => 'votekeys AS vk',
                'ON' => 'v.votekey_id=vk.id'
            )
        );

        $where = ['v.event_id = ' . $eventID];
        if ($searchQuery) {
            $where[] = '(w.title LIKE \'%' . NFW::i()->db->escape($searchQuery) . '%\' OR vk.votekey LIKE \'%' . NFW::i()->db->escape($searchQuery) . '%\' OR vk.email LIKE \'%' . NFW::i()->db->escape($searchQuery) . '%\' OR v.username LIKE \'%' . NFW::i()->db->escape($searchQuery) . '%\' OR v.poster_ip LIKE \'%' . NFW::i()->db->escape($searchQuery) . '%\')';
        }
        $where = join(' AND ', $where);

        // Count filtered values
        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'COUNT(*)',
            'FROM' => 'votes AS v',
            'JOINS' => $joins,
            'WHERE' => $where
        ))) {
            $this->error('Unable to count filtered records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        list($numFiltered) = NFW::i()->db->fetch_row($result);
        if (!$numFiltered) {
            return [[], $totalRecords, 0];
        }

        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'v.*, vk.votekey, vk.email AS votekey_email, w.title AS work_title, w.author AS work_author, w.place AS work_place',
            'FROM' => 'votes AS v',
            'JOINS' => $joins,
            'WHERE' => $where,
            'ORDER BY' => $options['ORDER BY'] ?? 'v.posted DESC',
            'LIMIT' => $offset . ',' . $limit,
        ))) {
            $this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (!NFW::i()->db->num_rows($result)) {
            return [];
        }
        $records = [];
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $records[] = $record;
        }

        return [$records, $totalRecords, $numFiltered];
    }

    public function addLiveVoteByRegisteredUser(int $workID, $vote): bool {
        if (NFW::i()->user['is_guest']) {
            $this->error('Authorization required', __FILE__, __LINE__);
            return false;
        }

        $CWorks = new works($workID);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            return false;
        }

        $CEvents = new events($CWorks->record['event_id']);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        if (!live_voting::IsAllowed($CEvents->record['id'], $CWorks->record['id'])) {
            $this->error("Live voting not allowed", __FILE__, __LINE__);
            return false;
        }

        $votekey = votekey::findOrCreateVotekey($CEvents->record['id'], NFW::i()->user['email']);
        if ($votekey->error) {
            $this->error('Find or create votekey failed: ' . $votekey->last_msg, __FILE__, __LINE__);
            return false;
        }

        // Prune old vote with same votekey
        if (!NFW::i()->db->query_build(array('DELETE' => 'votes', 'WHERE' => 'votekey_id=' . $votekey->id . ' AND work_id=' . $CWorks->record['id']))) {
            $this->error('Unable to delete old votes', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        // Start inserting
        if (in_array($vote, $CEvents->votingOptions())) {
            if (!NFW::i()->db->query_build(array(
                'INSERT' => '`event_id`, `work_id`, `votekey_id`, `vote`, `username`, `useragent`, `poster_ip`, `posted`',
                'INTO' => 'votes',
                'VALUES' => $CEvents->record['id'] . ', ' . $CWorks->record['id'] . ', ' . $votekey->id . ', ' . $vote . ', \'' . NFW::i()->user['realname'] . '\', \'' . NFW::i()->db->escape($_SERVER['HTTP_USER_AGENT'] ?? '') . '\', \'' . logs::get_remote_address() . '\', ' . time()
            ))) {
                $this->error('Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
        }

        if (!$votekey->used()) {
            $this->error('Unable to update votekey state', __FILE__, __LINE__, $votekey->last_msg);
            return false;
        }

        return true;
    }

    function actionMainAddVote(): bool {
        $this->error_report_type = 'active_form';

        // Check for system errors
        $CCompetitions = new competitions($_POST['competition_id'] ?? false);
        if (!$CCompetitions->record['id']) {
            $this->error('System error: wrong `event_id`', __FILE__, __LINE__);
            return false;
        }

        if (!$CCompetitions->record['voting_status']['available'] || !$CCompetitions->record['voting_works']) {
            $this->error('Voting closed or no prods.', __FILE__, __LINE__);
            return false;
        }

        $event_id = $CCompetitions->record['event_id'];
        $lang_main = NFW::i()->getLang('main');

        // Check votekey
        $votekey = votekey::getVotekey(isset($_POST['votekey']) ? trim($_POST['votekey']) : false, $event_id);
        if ($votekey->error) {
            $this->errors['votekey'] = $this->errors['general-message'] = $lang_main['voting error wrong votekey'];
        }

        $username = NFW::i()->db->escape($_POST['username'] ?? '');
        if (!$username) {
            $this->errors['username'] = $lang_main['voting error wrong username'];
        }

        if (!empty($this->errors)) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => $this->errors));
            return false;
        }

        $CWorks = new works();
        $single_work_id = isset($_POST['work_id']) && $_POST['work_id'] ? intval($_POST['work_id']) : false;
        $available_works = array();
        foreach ($CWorks->getRecords(array('filter' => array('voting_only' => true, 'competition_id' => $CCompetitions->record['id']), 'skip_pagination' => true)) as $w) {
            if ($w['id'] == $single_work_id || !$single_work_id) {
                $available_works[] = $w['id'];
            }
        }

        $votes = array();
        $commentsDuringVoting = array();
        foreach ($_POST['votes'] as $work_id => $vote) {
            if (!in_array($work_id, $available_works)) {
                continue;
            }

            if (isset($_POST['comment'][$work_id]) && strlen($_POST['comment'][$work_id]) < 2048) {
                $commentsDuringVoting[$work_id] = $_POST['comment'][$work_id];
            }

            $vote = intval($vote);
            if ($vote == 0) {
                continue;
            }

            $votes[] = array('work_id' => $work_id, 'vote' => $vote);
        }

        foreach ($commentsDuringVoting as $workID => $comment) {
            works_comments::upsertCommentByVotekey($votekey->id, $workID, $comment, $username);
        }

        // Prune old votes with same votekey
        if (!NFW::i()->db->query_build(array('DELETE' => 'votes', 'WHERE' => 'votekey_id=' . $votekey->id . ' AND work_id IN (' . implode(',', $available_works) . ')'))) {
            $this->error('Unable to delete old votes', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        // Start inserting
        $useragent = NFW::i()->db->escape($_SERVER['HTTP_USER_AGENT'] ?? '');
        $poster_ip = logs::get_remote_address();
        $now = time();
        foreach ($votes as $v) {
            if (!NFW::i()->db->query_build(array(
                'INSERT' => '`event_id`, `work_id`, `votekey_id`, `vote`, `username`, `useragent`, `poster_ip`, `posted`',
                'INTO' => 'votes',
                'VALUES' => $event_id . ', ' . $v['work_id'] . ', ' . $votekey->id . ', ' . $v['vote'] . ', \'' . $username . '\', \'' . $useragent . '\', \'' . $poster_ip . '\', ' . $now
            ))) {
                $this->error('Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
        }

        if (!$votekey->used()) {
            $this->error('Unable to update votekey state', __FILE__, __LINE__, $votekey->last_msg);
            return false;
        }

        // Done
        NFW::i()->renderJSON(array('result' => 'success', 'message' => $lang_main['voting success note']));
        return true; // Linter
    }

    function actionAdminAdmin() {
        $CEvents = new events($_GET['event_id'] ?? false);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        return $this->renderAction(array('event' => $CEvents->record));
    }

    function actionAdminVotekeys(): bool {
        $CEvents = new events($_GET['event_id'] ?? false);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        if (isset($_GET['part']) && $_GET['part'] == 'add-votekeys') {
            $count = intval($_POST['count']);
            while ($count--) {
                $votekey = votekey::generateVotekey($CEvents->record['id'], $_POST['email']);
                if ($votekey->error) {
                    $this->error($votekey->last_msg, __FILE__, __LINE__);
                    return false;
                }
            }
            NFW::i()->renderJSON(array('result' => 'success'));
        } elseif (isset($_GET['part']) && $_GET['part'] == 'list.js') {
            $this->error_report_type = 'plain';
            $CVotekey = new votekey();
            list($records, $iTotalRecords, $iTotalDisplayRecords) = $CVotekey->getVotekeys(
                $CEvents->record['id'],
                array(
                    'limit' => $_POST['iDisplayLength'],
                    'offset' => $_POST['iDisplayStart'],
                    'search' => isset($_POST['sSearch']) && trim($_POST['sSearch']) ? trim($_POST['sSearch']) : null,
                ));

            NFW::i()->stop($this->renderAction(array(
                'records' => $records,
                'iTotalDisplayRecords' => $iTotalDisplayRecords,
                'iTotalRecords' => $iTotalRecords,
            ), '_votekeys_list.js'));
        }

        NFW::i()->stop($this->renderAction(array('event' => $CEvents->record)));
        return true; // Linter
    }

    function actionAdminVotes(): bool {
        $CEvents = new events($_GET['event_id'] ?? false);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        if (isset($_GET['part']) && $_GET['part'] == 'list.js') {
            $this->error_report_type = 'plain';

            list($records, $iTotalRecords, $iTotalDisplayRecords) = $this->getVotes(
                $CEvents->record['id'],
                trim($_POST['sSearch']),
                intval($_POST['iDisplayLength']),
                intval($_POST['iDisplayStart']),
            );

            NFW::i()->stop($this->renderAction(array(
                'records' => $records,
                'iTotalDisplayRecords' => $iTotalDisplayRecords,
                'iTotalRecords' => $iTotalRecords,
            ), '_votes_list.js'));
        }

        NFW::i()->stop($this->renderAction(array('event' => $CEvents->record)));
        return true; // Linter
    }

    function actionAdminAddVote(): bool {
        $this->error_report_type = 'active_form';

        $CEvents = new events($_GET['event_id'] ?? false);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        $votekey = votekey::getVotekey(isset($_POST['votekey']) ? trim($_POST['votekey']) : false, $CEvents->record['id']);
        $useragent = NFW::i()->db->escape($_SERVER['HTTP_USER_AGENT'] ?? '');
        $poster_ip = logs::get_remote_address();
        $now = time();
        $username = NFW::i()->db->escape($_POST['username']);

        foreach ($_POST['votes'] as $workID => $vote) {
            $vote = intval($vote);

            $accepted = NFWX::i()->hook(
                "vote_accept_vote",
                $CEvents->record['alias'],
                array('vote' => $vote)
            );

            if ($accepted !== "accepted" && $vote == 0) {
                continue;
            }

            if ($votekey->id > 0) {
                // Prune old vote with same votekey
                if (!NFW::i()->db->query_build(array('DELETE' => 'votes', 'WHERE' => 'votekey_id=' . $votekey->id . ' AND work_id =' . $workID))) {
                    $this->error('Unable to delete old vote', __FILE__, __LINE__, NFW::i()->db->error());
                    return false;
                }
            }

            if (!NFW::i()->db->query_build(array(
                'INSERT' => '`event_id`, `work_id`, `vote`, `votekey_id`, `username`, `useragent`, `poster_ip`, `posted`',
                'INTO' => 'votes',
                'VALUES' => $CEvents->record['id'] . ', ' . $workID . ', ' . $vote . ',' . $votekey->id . ', \'' . $username . '\', \'' . $useragent . '\', \'' . $poster_ip . '\', ' . $now
            ))) {
                $this->error('Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
        }

        NFW::i()->renderJSON(array('result' => 'success'));
        return true; // Linter
    }

    function actionAdminResults(): bool {
        $CEvents = new events($_GET['event_id'] ?? false);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        $this->error_report_type = 'plain';

        if (isset($_GET['part']) && $_GET['part'] == 'save-results') {
            $calcBy = $CEvents->record['voting_system'];
            foreach ($this->getResults($CEvents->record['id'], $calcBy) as $r) {
                foreach ($r['works'] as $w) {
                    $query = array(
                        'UPDATE' => 'works',
                        'SET' => '`total_scores`=' . $w['total_scores'] . ', `num_votes`=' . $w['num_votes'] . ', `average_vote`=' . $w['average_vote'] . ', `iqm_vote`=' . $w['iqm_vote'] . ', `place`=' . $w['place'],
                        'WHERE' => '`id`=' . $w['id']
                    );
                    if (!NFW::i()->db->query_build($query)) {
                        $this->error('Unable to update work votes', __FILE__, __LINE__, NFW::i()->db->error());
                        return false;
                    }
                }
            }

            NFW::i()->stop('Results saved with "'.$calcBy.'" calculation');
        } elseif (isset($_GET['part']) && $_GET['part'] == 'list') {
            $calcBy = $_GET['calc_by'] ?? false;
            NFW::i()->stop($this->renderAction(array(
                'records' => $this->getResults($CEvents->record['id'], $calcBy),
                'calcBy' => $this->getResults($CEvents->record['id'], $calcBy),
            ), '_results_list'));
        }

        NFW::i()->stop($this->renderAction(array('event' => $CEvents->record)));
        return true; // Linter
    }
}

function sortByPos($a, $b): int {
    return $a['position'] > $b['position'] ? 1 : -1;
}

function calcByAvg($a, $b): int {
    if ($a['average_vote'] == $b['average_vote']) {
        return $a['total_scores'] < $b['total_scores'] ? 1 : -1;
    }

    return $a['average_vote'] < $b['average_vote'] ? 1 : -1;
}

function calcBySum($a, $b): int {
    if ($a['total_scores'] == $b['total_scores']) {
        return $a['num_votes'] < $b['num_votes'] ? 1 : -1;
    }

    return $a['total_scores'] < $b['total_scores'] ? 1 : -1;
}

function calcByIQM($a, $b): int {
    if ($a['iqm_vote'] == $b['iqm_vote']) {
        return $a['total_scores'] < $b['total_scores'] ? 1 : -1;
    }

    return $a['iqm_vote'] < $b['iqm_vote'] ? 1 : -1;
}

function calculateIQM($votes = array()) {
    $numVotes = count($votes);
    $start = ceil($numVotes / 4);
    $len = floor($numVotes / 2);
    $end = $numVotes - $start - $len;

    // Делаем обрезание справа и слева симметричным
    if ($end > $start) {
        $len++;
    } else if ($end < $start) {
        $start--;
        $len++;
    }

    sort($votes);
    $slicedVotes = array_slice($votes, $start, $len);
    if (count($slicedVotes) == 0) {
        return 0;
    }

    return round(array_sum($slicedVotes) / count($slicedVotes), 2);
}
