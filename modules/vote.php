<?php
/**
 * @desc Votekeys, votes, voting results.
 */
class vote extends active_record {
    const votekeyLength = 8;

	static $action_aliases = array(
		'admin' => array(
			array('module' => 'vote', 'action' => 'votekeys'),
			array('module' => 'vote', 'action' => 'votes'),
            array('module' => 'vote', 'action' => 'add_vote'),
			array('module' => 'vote', 'action' => 'results'),
		),
	);
	
	private function generateVotekey($event_id, $email = '') {
		while (true) {
			$votekey = '';
			for ($i = 0; $i < self::votekeyLength; ++$i) {
				$votekey .= chr(mt_rand(48, 57));
			}
	
			$result = NFW::i()->db->query_build(array('SELECT'	=> 'votekey', 'FROM' => 'votekeys', 'WHERE' => '`votekey`=\''.$votekey.'\' AND `event_id`='.$event_id));
			if (!NFW::i()->db->num_rows($result)) break;
		}
		
		$query = array(
			'INSERT'	=> '`event_id`, `votekey`, `email`, `useragent`, `poster_ip`, `posted`',
			'INTO'		=> 'votekeys',
			'VALUES'	=> $event_id.', \''.$votekey.'\', \''.NFW::i()->db->escape($email).'\', \''.NFW::i()->db->escape(isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '').'\', \''.logs::get_remote_address().'\', '.time()
		);
		if (!NFW::i()->db->query_build($query)) {
			$this->error('Unable to insert new votekey', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}

		return $votekey;
	}
	
	private function getVotekeys($options = array()) {
		$filter = isset($options['filter']) ? $options['filter'] : array();
	
		// Generate 'WHERE' string
		$where = array();
	
		if (isset($filter['event_id']) && $filter['event_id'] != '-1') $where[] = 'event_id = '.intval($filter['event_id']);
	
		// not strong "WHERE"
		if (isset($options['free_filter'])) {
			$where[] = '(votekey LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR email LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR poster_ip LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\')';
		}
	
		$where = empty($where) ? '' : join(' AND ', $where);
	
		// Count total records
		if (!$result = NFW::i()->db->query_build(array('SELECT' => 'COUNT(*)', 'FROM' => 'votekeys'))) {
			$this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($total_records) = NFW::i()->db->fetch_row($result);
	
		// Count filtered values
		if (!$result = NFW::i()->db->query_build(array('SELECT' => 'COUNT(*)', 'FROM' => 'votekeys', 'WHERE' => $where))) {
			$this->error('Unable to count filtered records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($num_filtered) = NFW::i()->db->fetch_row($result);
		if (!$num_filtered) {
			return array(array(), $total_records, 0);
		}
	
		if (!$result = NFW::i()->db->query_build(array(
			'SELECT'	=> '*',
			'FROM'		=> 'votekeys',
			'WHERE' 	=> $where,
			'ORDER BY'	=> 'posted DESC',
			'LIMIT' 	=> (isset($options['offset']) ? intval($options['offset']) : null).(isset($options['limit']) ? ','.intval($options['limit']) : null),
		))) {
			$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			return array();
		}
		$records = array();
		while($cur_record = NFW::i()->db->fetch_assoc($result)) {
			$records[] = $cur_record;
		}
	
		return array($records, $total_records, $num_filtered);
	}

	private function calculateIQM($votes = array()) {
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

	// Load results for given works array
	private function getResults($event_id, $options = array()) {
		$votekey_status = isset($options['votekey_status']) ? $options['votekey_status'] : -1;
		$place_order = isset($options['place_order']) ? $options['place_order'] : 'avg';
		
		$query = array(
			'SELECT'	=> 'v.work_id, v.vote, w.competition_id, w.title, w.author, c.position AS competition_pos, c.title AS competition_title',
			'FROM'		=> 'votes AS v',
			'JOINS' 	=> array(
				array(
					'LEFT JOIN'=> 'works AS w',
					'ON'		=> 'v.work_id=w.id'
				),
				array(
					'LEFT JOIN'=> 'competitions AS c',
					'ON'		=> 'w.competition_id=c.id'
				),
			),
			'WHERE'		=> 'v.event_id='.$event_id,
			'ORDER BY' => 'v.work_id'
		);
		if ($votekey_status == 0) {
			$query['WHERE'] .= ' AND v.votekey_id=0';
		}
		elseif ($votekey_status == 1) {
			$query['WHERE'] .= ' AND v.votekey_id<>0';
		}

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
			$works[$r['competition_id']]['works'][$r['work_id']]['num_votes'] ++;
		}

        $prev_numvotes = 0;
        $prev_total = 0;
        $prev_average = 0;
        $prev_iqm = 0;
		foreach ($works as $cid=>$competition) {
		    // Calculate average and iqm
			foreach ($works[$cid]['works'] as $key=>$work) {
				$works[$cid]['works'][$key]['average_vote'] = round($works[$cid]['works'][$key]['total_scores'] / $works[$cid]['works'][$key]['num_votes'], 2);
                $works[$cid]['works'][$key]['iqm_vote'] = $this->calculateIQM($allVotes[$work['id']]);
			}

			if ($place_order == 'avg') {
				usort($works[$cid]['works'], 'sortByAverageTotal');
			} else if ($place_order == 'iqm') {
                usort($works[$cid]['works'], 'sortByIQM');
            } else {
				usort($works[$cid]['works'], 'sortByScoresTotal');
			}
				
			$place = 1;
			foreach ($works[$cid]['works'] as $key=>$work) {
				if ($place_order == 'avg') {
					if ($work['average_vote'] == $prev_average && $work['total_scores'] == $prev_total) $place--;
                } else if ($place_order == 'iqm') {
                    if ($work['iqm_vote'] == $prev_iqm && $work['total_scores'] == $prev_total) $place--;
                } else {
					if ($work['total_scores'] == $prev_total && $work['num_votes'] == $prev_numvotes) $place--;
				}

                $prev_total = $work['total_scores'];
                $prev_numvotes = $work['num_votes'];
				$prev_average = $work['average_vote'];
                $prev_iqm = $work['iqm_vote'];
                $works[$cid]['works'][$key]['place'] = $place++;
			}
		}
	
		// Sort competitions
		usort($works, 'sortByPos');
	
		return $works;
	}

	public function getVotes($options = array()) {
		$filter = isset($options['filter']) ? $options['filter'] : array();
	
		// Generate 'WHERE' string
		$where = array();
	
		if (isset($filter['event_id']) && $filter['event_id'] != '-1') $where[] = 'v.event_id = '.intval($filter['event_id']);
		if (isset($filter['competition_id']) && $filter['competition_id'] != '-1') $where[] = 'w.competition_id = '.intval($filter['competition_id']);		
	
		// not strong "WHERE"
		if (isset($options['free_filter'])) {
			$where[] = '(w.title LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR vk.votekey LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR vk.email LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR v.username LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR v.poster_ip LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\')';
		}
	
		$where = empty($where) ? '' : join(' AND ', $where);
	
		// Count total records
		if (!$result = NFW::i()->db->query_build(array('SELECT' => 'COUNT(*)', 'FROM' => 'votes'))) {
			$this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($total_records) = NFW::i()->db->fetch_row($result);
	
		$joins = array(
			array(
				'INNER JOIN'=> 'works AS w',
				'ON'		=> 'v.work_id=w.id'
			),
			array(
				'LEFT JOIN'=> 'votekeys AS vk',
				'ON'		=> 'v.votekey_id=vk.id'
			)
		);
	
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
		list($num_filtered) = NFW::i()->db->fetch_row($result);
		if (!$num_filtered) {
			return array(array(), $total_records, 0);
		}
	
		if (!$result = NFW::i()->db->query_build(array(
			'SELECT'	=> 'v.*, vk.votekey, vk.email AS votekey_email, w.title AS work_title, w.author AS work_author, w.place AS work_place',
			'FROM'		=> 'votes AS v',
			'JOINS' 	=> $joins,
			'WHERE' 	=> $where,
			'ORDER BY'	=> isset($options['ORDER BY']) ? $options['ORDER BY'] : 'v.posted DESC',
			'LIMIT' 	=> (isset($options['offset']) ? intval($options['offset']) : null).(isset($options['limit']) ? ','.intval($options['limit']) : null),
		))) {
			$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			return array();
		}
		$records = array();
		while($cur_record = NFW::i()->db->fetch_assoc($result)) {
			$records[] = $cur_record;
		}
	
		return array($records, $total_records, $num_filtered);
	}
		
	function getVotekey($data) {
		$lang_main = NFW::i()->getLang('main');
		
		$CEvents = new events(isset($data['event_id']) ? $data['event_id'] : false);
		if (!$CEvents->record['id']) {
			$this->error('System error: wrong `event_id`');
			return false;
		}
		
		$CCompetitions = new competitions();
		$competitions = $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id'], 'open_voting' => true)));
		if (empty($competitions)) {
			$this->error('System error: Voting closed for this event');
			return false;
		}
		
		$email = isset($data['email']) ? trim($data['email']) : false;
		if (!$email || !$this->is_valid_email($email)) {
			$this->error($lang_main['votekey-request wrong email']);
			return false;
		}

		// Check if email already exist
		$query = array(
			'SELECT'	=> 'votekey',
			'FROM'		=> 'votekeys',
			'WHERE'		=> 'email=\''.NFW::i()->db->escape($email).'\' AND event_id='.$CEvents->record['id'],
		);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to search votekey', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		
		if (NFW::i()->db->num_rows($result)) {
			list($votekey) = NFW::i()->db->fetch_row($result);
			$message = $lang_main['votekey-request success note2'];
		}
		else {
			if (!$votekey = $this->generateVotekey($CEvents->record['id'], $email)) return false;
			$message = $lang_main['votekey-request success note'];
		}

		return array('votekey' => $votekey, 'email' => $email, 'event' => $CEvents->record, 'message' => $message);
	}	
	
	public function checkVotekey($votekey, $event_id) {
		if (!$votekey) return false;
		
		$result = NFW::i()->db->query_build(array(
			'SELECT'	=> 'id',
			'FROM' 		=> 'votekeys',
			'WHERE' 	=> '`votekey`=\''.NFW::i()->db->escape($votekey).'\' AND `event_id`='.$event_id));
		if (!NFW::i()->db->num_rows($result)) return false;
		
		list($votekey_id) = NFW::i()->db->fetch_row($result);
		return $votekey_id;		
	}
		
	function actionMainRequestVotekey() {
		if ($result = $this->getVotekey($_POST)) {
			email::sendFromTemplate($result['email'], 'votekey_request', array(
				'event' => $result['event'], 
				'votekey' => $result['votekey'], 
				'language' => NFW::i()->user['language']
			));
			
			NFW::i()->renderJSON(array('result' => 'success', 'message' => $result['message']));
		}
		else {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('email' => $this->last_msg)));
		}
	}
	
	function actionMainAddVote() {
		$this->error_report_type = 'active_form';
		
		// Check for system errors
		$CCompetitions = new competitions(isset($_POST['competition_id']) ? $_POST['competition_id'] : false);
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
		$this->errors = array();
		
		$CWorks = new works();
		$single_work_id = isset($_POST['work_id']) && $_POST['work_id'] ? intval($_POST['work_id']) : false;
		$available_works = array();
		foreach ($CWorks->getRecords(array('filter' => array('voting_only' => true, 'competition_id' => $CCompetitions->record['id']), 'skip_pagination' => true)) as $w) {
			if ($w['id'] == $single_work_id || !$single_work_id) {  
				$available_works[] = $w['id'];
			}
		}
	
		$votes = array();
		foreach ($_POST['votes'] as $work_id=>$vote) {
			$vote = intval($vote);
			if ($vote == 0) continue;
			if (!in_array($work_id, $available_works)) continue;
				
			$votes[] = array('work_id' => $work_id, 'vote' => $vote);
		}
		if (empty($votes)) {
			$this->errors['general-message'] = $lang_main['voting error empty votelist'];
		}
	
		// Check votekey
		$votekey = isset($_POST['votekey']) ? trim($_POST['votekey']) : false;
		if (!$votekey_id = $this->checkVotekey($votekey, $event_id)) {
			$this->errors['votekey'] = $this->errors['general-message'] = $lang_main['voting error wrong votekey'];
		}
	
		$username = NFW::i()->db->escape(isset($_POST['username']) ? $_POST['username'] : '');
		if (!$username) {
			$this->errors['username'] = $lang_main['voting error wrong username'];
		}
	
		if (!empty($this->errors)) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $this->errors));
			return false;
		}
	
		// Prune old votes with same votekey
		if (!$result = NFW::i()->db->query_build(array('DELETE' => 'votes', 'WHERE' => 'votekey_id='.$votekey_id.' AND work_id IN ('.implode(',', $available_works).')'))) {
			$this->error('Unable to delete old votes', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
	
		// Start inserting
		$useragent = NFW::i()->db->escape(isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '');
		$poster_ip = logs::get_remote_address();
		$now = time();
		foreach ($votes as $v) {
			if (!NFW::i()->db->query_build(array(
				'INSERT'	=> '`event_id`, `work_id`, `votekey_id`, `vote`, `username`, `useragent`, `poster_ip`, `posted`',
				'INTO'		=> 'votes',
				'VALUES'	=> $event_id.', '.$v['work_id'].', '.$votekey_id.', '.$v['vote'].', \''.$username.'\', \''.$useragent.'\', \''.$poster_ip.'\', '.$now
			))) {
				$this->error('Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
		}
	
		// Update votekey
		if (!NFW::i()->db->query_build(array('UPDATE' => 'votekeys', 'SET' => 'is_used=1', 'WHERE' => 'id='.$votekey_id))) {
			$this->error('Unable to update votekey state', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
	
		// Save votekey and for future use
		NFW::i()->setCookie('votekey', $votekey, time() + 60*60*24*7);
	
		// Done
		NFW::i()->renderJSON(array('result' => 'success', 'message' => $lang_main['voting success note']));
	}	
	
	function actionAdminAdmin() {
		$CEvents = new events(isset($_GET['event_id']) ? $_GET['event_id'] : false);
		if (!$CEvents->record['id']) {
			$this->error($CEvents->last_msg, __FILE__, __LINE__);
			return false;
		}
		
		return $this->renderAction(array('event' => $CEvents->record));
	}
	
	function actionAdminVotekeys() {
		$CEvents = new events(isset($_GET['event_id']) ? $_GET['event_id'] : false);
		if (!$CEvents->record['id']) {
			$this->error($CEvents->last_msg, __FILE__, __LINE__);
			return false;
		}
		
		if (isset($_GET['part']) && $_GET['part'] == 'add-votekeys') {
			$count = intval($_POST['count']);
			while($count--) {
				$this->generateVotekey($CEvents->record['id'], $_POST['email']);
			}
			
			NFW::i()->renderJSON(array('result' => 'success'));
		}
		elseif (isset($_GET['part']) && $_GET['part'] == 'list.js') {
			$this->error_report_type = 'plain';
		
			list($records, $iTotalRecords, $iTotalDisplayRecords) = $this->getVotekeys(array(
				'limit' => $_POST['iDisplayLength'],
				'offset' => $_POST['iDisplayStart'],
				'filter' => array('event_id' => $CEvents->record['id']),
				'free_filter' => isset($_POST['sSearch']) && trim($_POST['sSearch']) ? trim($_POST['sSearch']) : null,
			));
				
			NFW::i()->stop($this->renderAction(array(
				'records' => $records,
					'iTotalDisplayRecords' => $iTotalDisplayRecords,
					'iTotalRecords' => $iTotalRecords,
				), '_votekeys_list.js'));
		}
		
		NFW::i()->stop($this->renderAction(array('event' => $CEvents->record)));
	}
	
	function actionAdminVotes() {
		$CEvents = new events(isset($_GET['event_id']) ? $_GET['event_id'] : false);
		if (!$CEvents->record['id']) {
			$this->error($CEvents->last_msg, __FILE__, __LINE__);
			return false;
		}
		
		if (isset($_GET['part']) && $_GET['part'] == 'list.js') {
			$this->error_report_type = 'plain';

			list($records, $iTotalRecords, $iTotalDisplayRecords) = $this->getVotes(array(
				'limit' => $_POST['iDisplayLength'],
				'offset' => $_POST['iDisplayStart'],
				'filter' => array('event_id' => $CEvents->record['id']),
				'free_filter' => isset($_POST['sSearch']) && trim($_POST['sSearch']) ? trim($_POST['sSearch']) : null,
			));
		
			NFW::i()->stop($this->renderAction(array(
				'records' => $records,
				'iTotalDisplayRecords' => $iTotalDisplayRecords,
				'iTotalRecords' => $iTotalRecords,
			), '_votes_list.js'));
		}
		
		NFW::i()->stop($this->renderAction(array('event' => $CEvents->record)));		
	}

    function actionAdminAddVote() {
        $this->error_report_type = 'active_form';

        $CEvents = new events(isset($_GET['event_id']) ? $_GET['event_id'] : false);
        if (!$CEvents->record['id']) {
            $this->error($CEvents->last_msg, __FILE__, __LINE__);
            return false;
        }

        // Check votekey
        $votekey_id = 0;
        $votekey = isset($_POST['votekey']) ? trim($_POST['votekey']) : false;
        if ($votekey && !$votekey_id = $this->checkVotekey($votekey, $CEvents->record['id'])) {
            $this->error('Votekey not found');
            return false;
        }

        $useragent = NFW::i()->db->escape(isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '');
        $poster_ip = logs::get_remote_address();
        $now = time();
        $username = NFW::i()->db->escape($_POST['username']);

        foreach ($_POST['votes'] as $work_id=>$vote) {
            $vote = intval($vote);
            if ($vote == 0) continue;

            if ($votekey_id > 0) {
                // Prune old vote with same votekey
                if (!$result = NFW::i()->db->query_build(array('DELETE' => 'votes', 'WHERE' => 'votekey_id='.$votekey_id.' AND work_id ='.$work_id))) {
                    $this->error('Unable to delete old vote', __FILE__, __LINE__, NFW::i()->db->error());
                    return false;
                }
            }

            if (!NFW::i()->db->query_build(array(
                'INSERT'	=> '`event_id`, `work_id`, `vote`, `votekey_id`, `username`, `useragent`, `poster_ip`, `posted`',
                'INTO'		=> 'votes',
                'VALUES'	=> $CEvents->record['id'].', '.$work_id.', '.$vote.','.$votekey_id.', \''.$username.'\', \''.$useragent.'\', \''.$poster_ip.'\', '.$now
            ))) {
                $this->error('Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
                return false;
            }
        }

        NFW::i()->renderJSON(array('result' => 'success'));
    }

	function actionAdminResults() {
		$CEvents = new events(isset($_GET['event_id']) ? $_GET['event_id'] : false);
		if (!$CEvents->record['id']) {
			$this->error($CEvents->last_msg, __FILE__, __LINE__);
			return false;
		}
		
		$results_options = array(
			'votekey_status' => isset($_POST['votekey']) ? $_POST['votekey'] : false,
			'place_order' => isset($_POST['order']) ? $_POST['order'] : false 						
		);
		
		if (isset($_GET['part']) && $_GET['part'] == 'save-results') {
			$this->error_report_type = 'plain';
			
			foreach ($this->getResults($CEvents->record['id'], $results_options) as $r) foreach ($r['works'] as $w) {
				$query = array(
					'UPDATE'	=> 'works',
					'SET'		=> '`total_scores`='.$w['total_scores'].', `num_votes`='.$w['num_votes'].', `average_vote`='.$w['average_vote'].', `iqm_vote`='.$w['iqm_vote'].', `place`='.$w['place'],
					'WHERE'		=> '`id`='.$w['id']
				);
				if (!$result = NFW::i()->db->query_build($query)) {
					$this->error('Unable to update work votes', __FILE__, __LINE__, NFW::i()->db->error());
					return false;
				}
			}
			
			NFW::i()->stop('Success');
		}
		elseif (isset($_GET['part']) && $_GET['part'] == 'list.js') {
			$this->error_report_type = 'plain';
		
			NFW::i()->stop($this->renderAction(array(
				'records' => $this->getResults($CEvents->record['id'], $results_options),
			), '_results_list.js'));
		}
		
		NFW::i()->stop($this->renderAction(array('event' => $CEvents->record)));
	}	
}

function sortByPos($a, $b) {
	return $a['position'] < $b['position'] ? 1 : -1;
}

function sortByAverageTotal($a, $b) {
	if ($a['average_vote'] == $b['average_vote']) {
		return $a['total_scores'] < $b['total_scores'] ? 1 : -1;
	}
	
	return $a['average_vote'] < $b['average_vote'] ? 1 : -1;
}

function sortByScoresTotal($a, $b) {
	if ($a['total_scores'] == $b['total_scores']) {
		return $a['num_votes'] < $b['num_votes'] ? 1 : -1;
	}

	return $a['total_scores'] < $b['total_scores'] ? 1 : -1;
}

function sortByIQM($a, $b) {
    if ($a['iqm_vote'] == $b['iqm_vote']) {
        return $a['total_scores'] < $b['total_scores'] ? 1 : -1;
    }

    return $a['iqm_vote'] < $b['iqm_vote'] ? 1 : -1;
}