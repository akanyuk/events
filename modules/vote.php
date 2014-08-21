<?php
/***********************************************************************
  Copyright (C) 2009-2014 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

  Votekeys, votes, voting results.
  
 ************************************************************************/

class vote extends active_record {
	private function generateVotekey($event_id, $email = '') {
		while (true) {
			$votekey = '';
			for ($i = 0; $i < 8; ++$i) {
				$votekey .= chr(mt_rand(48, 57));
			}
	
			$result = NFW::i()->db->query_build(array('SELECT'	=> 'votekey', 'FROM' => 'votekeys', 'WHERE' => '`votekey`=\''.$votekey.'\' AND `event_id`='.$event_id));
			if (!NFW::i()->db->num_rows($result)) break;
		}
		
		$useragent = isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '';
		
		$query = array(
			'INSERT'	=> '`event_id`, `votekey`, `email`, `useragent`, `browser`, `poster_ip`, `posted`',
			'INTO'		=> 'votekeys',
			'VALUES'	=> $event_id.', \''.$votekey.'\', \''.NFW::i()->db->escape($email).'\', \''.NFW::i()->db->escape($useragent).'\', \''.NFW::i()->db->escape(logs::get_browser()).'\', \''.logs::get_remote_address().'\', '.time()
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
	
		if (isset($filter['event_id']) && $filter['event_id'] != '-1') $where[] = 'vk.event_id = '.intval($filter['event_id']);
	
		// not strong "WHERE"
		if (isset($options['free_filter'])) {
			$where[] = '(vk.votekey LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR vk.email LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR vk.poster_ip LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\')';
		}
	
		$where = empty($where) ? '' : join(' AND ', $where);
	
		// Count total records
		if (!$result = NFW::i()->db->query_build(array('SELECT' => 'COUNT(*)', 'FROM' => 'votekeys'))) {
			$this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($total_records) = NFW::i()->db->fetch_row($result);
	
		// Count filtered values
		if (!$result = NFW::i()->db->query_build(array('SELECT' => 'COUNT(*)', 'FROM' => 'votekeys AS vk', 'WHERE' => $where))) {
			$this->error('Unable to count filtered records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($num_filtered) = NFW::i()->db->fetch_row($result);
		if (!$num_filtered) {
			return array(array(), $total_records, 0);
		}
	
		if (!$result = NFW::i()->db->query_build(array(
			'SELECT'	=> 'vk.*, (SELECT COUNT(*) FROM '.NFW::i()->db->prefix.'votes WHERE votekey_id=vk.id) AS numvotes',
			'FROM'		=> 'votekeys AS vk',
			'WHERE' 	=> $where,
			'ORDER BY'	=> 'vk.posted DESC',
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

	private function getVotes($options = array()) {
		$filter = isset($options['filter']) ? $options['filter'] : array();
	
		// Generate 'WHERE' string
		$where = array();
	
		if (isset($filter['event_id']) && $filter['event_id'] != '-1') $where[] = 'v.event_id = '.intval($filter['event_id']);
	
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
			'SELECT'	=> 'v.*, vk.votekey, vk.email AS votekey_email, w.title AS work_title',
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
		
	// Load results for given works array
	private function getResults($event_id, $votekey_status = -1) {
		$query = array(
			'SELECT'	=> 'v.work_id, v.vote, w.competition_id, w.title, c.pos AS competition_pos, c.title AS competition_title',
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
		while ($r = NFW::i()->db->fetch_assoc($result)) {
			if (!isset($works[$r['competition_id']])) {
				$works[$r['competition_id']] = array(
					'title' => $r['competition_title'],
					'pos' => $r['competition_pos'],
					'works' => array()
				);
			}
	
			if (!isset($works[$r['competition_id']]['works'][$r['work_id']])) {
				$works[$r['competition_id']]['works'][$r['work_id']] = array(
					'id' => $r['work_id'],
					'title' => $r['title'],
					'total_scores' => 0,
					'num_votes' => 0,
					'average_vote' => 0,
					'place' => 0
				);
			}
	
			$works[$r['competition_id']]['works'][$r['work_id']]['total_scores'] += $r['vote'];
			$works[$r['competition_id']]['works'][$r['work_id']]['num_votes'] ++;;
		}
	
		$prev_average = 0;
		$prev_total = 0;
		foreach ($works as $cid=>$competition) {
			foreach ($works[$cid]['works'] as $key=>$work) {
				//$works[$cid]['works'][$key]['average_vote'] = bcdiv($works[$cid]['works'][$key]['total_scores'], $works[$cid]['works'][$key]['num_votes']);
				$works[$cid]['works'][$key]['average_vote'] = round($works[$cid]['works'][$key]['total_scores'] / $works[$cid]['works'][$key]['num_votes'], 2);
			}
				
			usort($works[$cid]['works'], 'sortByAverageTotal');
				
			$place = 1;
			foreach ($works[$cid]['works'] as $key=>$work) {
				if ($work['average_vote'] == $prev_average && $work['total_scores'] == $prev_total) $place--;
				$prev_average = $work['average_vote'];
				$prev_total = $work['total_scores'];
	
				$works[$cid]['works'][$key]['place'] = $place++;
			}
		}
	
		// Sort competitions
		usort($works, 'sortByPos');
	
		return $works;
	}
		
	function requestVotekey($data, $send = true) {
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
			$this->last_msg = $lang_main['votekey-request success note2'];
		}
		else {
			if (!$votekey = $this->generateVotekey($CEvents->record['id'], $email)) return false;
			$this->last_msg = $lang_main['votekey-request success note'];
		}

		if ($send) { email::sendFromTemplate($email, 'votekey_request', array('event' => $CEvents->record, 'votekey' => $votekey, 'language' => NFW::i()->user['language'])); $result = true; }
		else $result = array('event' => $CEvents->record, 'votekey' => $votekey, 'language' => NFW::i()->user['language']);

		return $result;
	}	
	
	function checkVotekey($votekey, $event_id) {
		if (!$votekey) return false;
		
		$result = NFW::i()->db->query_build(array(
			'SELECT'	=> 'id',
			'FROM' 		=> 'votekeys',
			'WHERE' 	=> '`votekey`=\''.NFW::i()->db->escape($votekey).'\' AND `event_id`='.$event_id));
		if (!NFW::i()->db->num_rows($result)) return false;
		
		list($votekey_id) = NFW::i()->db->fetch_row($result);
		return $votekey_id;		
	}
	
	function doVoting($data) {
		$lang_main = NFW::i()->getLang('main');
		
		$this->errors = array();
		
		$CCompetitions = new competitions(isset($data['competition_id']) ? $data['competition_id'] : false);
		if (!$CCompetitions->record['id']) {
			$this->errors['general'] = 'System error: wrong `event_id`';
			return false;
		}
		
		if (!$CCompetitions->record['voting_status']['available'] || !$CCompetitions->record['voting_works']) {
			$this->errors['general'] = 'Voting closed or no prods.';
		}
		
		$event_id = $CCompetitions->record['event_id'];
		
		$CWorks = new works();
		list($voting_works) = $CWorks->getRecords(array(
			'filter' => array('voting_only' => true, 'competition_id' => $CCompetitions->record['id'])
		));
		$available_works = array();
		foreach ($voting_works as $w) {
			$available_works[] = $w['id'];
		}

		$votes = array();
		$prune_old_voted_works = array();
		foreach ($data['votes'] as $work_id=>$vote) {
			$vote = intval($vote);
			if ($vote < 1 || $vote > 10) continue;
			if (!in_array($work_id, $available_works)) continue;
			
			$prune_old_voted_works[] = $work_id;
			$votes[] = array('work_id' => $work_id, 'vote' => $vote);
		}
		if (empty($votes)) {
			$this->errors['general'] = $lang_main['voting error empty votelist'];
		}
		
		// Check votekey
		$votekey = isset($data['votekey']) ? trim($data['votekey']) : false;
		if (!$votekey_id = $this->checkVotekey($votekey, $event_id)) {
			$this->errors['general'] = $lang_main['voting error wrong votekey'];
		}
		
		$username = NFW::i()->db->escape(isset($data['username']) ? $data['username'] : '');
		if (!$username) {
			$this->errors['username'] = $lang_main['voting error wrong username'];
		}
		
		if (!empty($this->errors)) return false;
		
		// Prune old votes with same votekey
		$query = array(
			'DELETE'	=> 'votes',
			'WHERE'		=> '`votekey_id`='.$votekey_id.' AND `work_id` IN ('.implode(',', $prune_old_voted_works).')',
		);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to delete old votes', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		
		// Start inserting
		$useragent = NFW::i()->db->escape(isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '');
		$browser = NFW::i()->db->escape(logs::get_browser());
		$poster_ip = logs::get_remote_address();
		$now = time();
		foreach ($votes as $v) {
			if (!NFW::i()->db->query_build(array(
				'INSERT'	=> '`event_id`, `work_id`, `votekey_id`, `vote`, `username`, `useragent`, `browser`, `poster_ip`, `posted`',
				'INTO'		=> 'votes',
				'VALUES'	=> $event_id.', '.$v['work_id'].', '.$votekey_id.', '.$v['vote'].', \''.$username.'\', \''.$useragent.'\', \''.$browser.'\', \''.$poster_ip.'\', '.$now
			))) {
				$this->error('Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
		}
		
		// Save votekey and username for future use
		NFW::i()->setCookie('votekey', $votekey, time() + 60*60*24*7);
		NFW::i()->setCookie('voting_username', $username, time() + 60*60*24*7);
		
		// Done
		$this->last_msg = $lang_main['voting success note'];
		return true;
	}
		
	function actionAdmin() {
		return $this->renderAction();
	}
	
	function actionManageVotekeys() {
		if (isset($_GET['part']) && $_GET['part'] == 'add-votekeys') {
			$count = intval($_POST['count']);
			while($count--) {
				$this->generateVotekey($_POST['event_id'], $_POST['email']);
			}
			
			NFW::i()->renderJSON(array('result' => 'success'));
		}
		elseif (isset($_GET['part']) && $_GET['part'] == 'list.js') {
			$this->error_report_type = 'plain';
		
			list($records, $iTotalRecords, $iTotalDisplayRecords) = $this->getVotekeys(array(
				'limit' => $_POST['iDisplayLength'],
				'offset' => $_POST['iDisplayStart'],
				'filter' => array(
					'event_id' => $_POST['event_id']
				),
				'free_filter' => isset($_POST['sSearch']) && trim($_POST['sSearch']) ? trim($_POST['sSearch']) : null,
			));
				
			NFW::i()->stop($this->renderAction(array(
				'records' => $records,
					'iTotalDisplayRecords' => $iTotalDisplayRecords,
					'iTotalRecords' => $iTotalRecords,
				), '_manage_votekeys_list.js'));
		}
		
		$CEvents = new events();
		NFW::i()->stop($this->renderAction(array(
			'events' => $CEvents->getRecords(array('filter' => array('managed' => true)))
		)));
	}
	
	function actionManageVotes() {
		if (isset($_GET['part']) && $_GET['part'] == 'add-vote') {
			$this->error_report_type = empty($_POST) ? 'alert' : 'active_form';
			
			$CEvents = new events($_GET['event_id']);
			if (!$CEvents->record['id']) {
				$this->error('Event not found', __FILE__, __LINE__);
				return false;
			}
			
			if (empty($_POST)) {
				$CWorks = new works();
				list($works) = $CWorks->getRecords(array('filter' => array('voting_only' => true, 'event_id' => $CEvents->record['id'])));
					
				NFW::i()->stop($this->renderAction(array(
				'event' => $CEvents->record,
				'works' => $works
				), '_manage_votes_form'));
			}
			
			$useragent = NFW::i()->db->escape(isset($_SERVER['HTTP_USER_AGENT']) ? $_SERVER['HTTP_USER_AGENT'] : '');
			$browser = NFW::i()->db->escape(logs::get_browser());
			$poster_ip = logs::get_remote_address();
			$now = time();
			$username = NFW::i()->db->escape($_POST['username']);
			
			foreach ($_POST['votes'] as $work_id=>$vote) {
				$vote = intval($vote);
				if ($vote < 1 || $vote > 10) continue;
				
				if (!NFW::i()->db->query_build(array(
					'INSERT'	=> '`event_id`, `work_id`, `vote`, `username`, `useragent`, `browser`, `poster_ip`, `posted`',
					'INTO'		=> 'votes',
					'VALUES'	=> $CEvents->record['id'].', '.$work_id.', '.$vote.', \''.$username.'\', \''.$useragent.'\', \''.$browser.'\', \''.$poster_ip.'\', '.$now
				))) {
					$this->error('Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
					return false;
				}
			}
							
			NFW::i()->renderJSON(array('result' => 'success'));
		}
		elseif (isset($_GET['part']) && $_GET['part'] == 'list.js') {
			$this->error_report_type = 'plain';

			$options = array(
				'limit' => $_POST['iDisplayLength'],
				'offset' => $_POST['iDisplayStart'],
				'filter' => array(
					'event_id' => $_POST['event_id']
				),
				'free_filter' => isset($_POST['sSearch']) && trim($_POST['sSearch']) ? trim($_POST['sSearch']) : null,
			);
						
			switch ($_POST['iSortCol_0']) {
				case 1:
					$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'w.title' : 'w.title DESC';
					break;
				case 2:
					$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'v.vote' : 'v.vote DESC';
					break;
				case 3:
					$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'v.username' : 'v.username DESC';
					break;
				case 4:
					$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'vk.votekey' : 'vk.votekey DESC';
					break;
				case 5:
					$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'vk.email' : 'vk.email DESC';
					break;
				case 6:
					$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'v.posted' : 'v.posted DESC';
					break;
				case 7:
					$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'v.browser' : 'v.browser DESC';
					break;
				case 8:
					$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'v.poster_ip' : 'v.poster_ip DESC';
					break;
			}
				
			list($records, $iTotalRecords, $iTotalDisplayRecords) = $this->getVotes($options);
			
		
			NFW::i()->stop($this->renderAction(array(
				'records' => $records,
				'iTotalDisplayRecords' => $iTotalDisplayRecords,
				'iTotalRecords' => $iTotalRecords,
			), '_manage_votes_list.js'));
		}
		
		$CEvents = new events();
		NFW::i()->stop($this->renderAction(array(
			'events' => $CEvents->getRecords(array('filter' => array('managed' => true)))
		)));		
	}
	
	function actionManageResults() {
		if (isset($_GET['part']) && $_GET['part'] == 'save-results') {
			$this->error_report_type = 'plain';
			
			foreach ($this->getResults($_POST['event_id'], $_POST['votekey']) as $r) foreach ($r['works'] as $w) {
				$query = array(
					'UPDATE'	=> 'works',
					'SET'		=> '`total_scores`='.$w['total_scores'].', `num_votes`='.$w['num_votes'].', `average_vote`='.$w['average_vote'].', `place`='.$w['place'],
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
				'records' => $this->getResults($_POST['event_id'], $_POST['votekey']),
			), '_manage_results_list.js'));
		}
		
		$CEvents = new events();
		NFW::i()->stop($this->renderAction(array(
			'events' => $CEvents->getRecords(array('filter' => array('managed' => true)))
		)));
	}	
}

function sortByPos($a, $b) {
	return $a['pos'] < $b['pos'] ? 1 : -1;
}

function sortByAverageTotal($a, $b) {
	if ($a['average_vote'] == $b['average_vote']) {
		return $a['total_scores'] < $b['total_scores'] ? 1 : -1;
	}
	
	return $a['average_vote'] < $b['average_vote'] ? 1 : -1;
}