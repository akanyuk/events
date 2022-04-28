<?php
/***********************************************************************
  Copyright (C) 2017 Andrey nyuk Marinov (aka.nyuk@gmail.com)
  $Id$
  
  Комментарии к работам
  
 ************************************************************************/

class works_comments extends active_record {
	
	var $attributes = array(
		'work_id' => array('type' => 'int', 'desc' => 'Work ID', 'required' => true),
		'message' => array('type' => 'textarea', 'desc' => 'Текст', 'required' => true, 'maxlength' => 2048),
	);
	
	protected function load($id) {
		$query = array(
			'SELECT'	=> 'wc.*, c.event_id',
			'FROM'		=> $this->db_table.' AS wc',
			'JOINS'		=> array(
				array(
					'INNER JOIN'=> 'works AS w',
					'ON'		=> 'wc.work_id=w.id'
				),
				array(
					'INNER JOIN'=> 'competitions AS c',
					'ON'		=> 'w.competition_id=c.id'
				),
			),
			'WHERE'		=> 'wc.id='.intval($id),
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
	
	public function loadCounters(&$works) {
		$works_ids = $counters = array();
		foreach ($works as $work) {
			$works_ids[] = $work['id'];
		}
	
		if (!$result = NFW::i()->db->query_build(array(
			'SELECT'	=> 'work_id, COUNT(id) AS comments_count',
			'FROM'		=> $this->db_table,
			'GROUP BY'	=> 'work_id',
			'WHERE'		=> 'work_id IN('.implode(',', $works_ids).')',
		))) {
			$this->error('Unable to count works comments', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		while ($record = NFW::i()->db->fetch_assoc($result)) {
			$counters[$record['work_id']] = $record['comments_count'];
		}
	
		foreach ($works as &$work) {
			$work['comments_count'] = isset($counters[$work['id']]) ? $counters[$work['id']] : 0;
		}
		unset($work);
	}

	public function getRecords($options = array()) {
		$filter = isset($options['filter']) ? $options['filter'] : array();
	
		// Setup WHERE from filter
		$where = array('e.is_hidden=0');
	
		if (isset($filter['work_id'])) {
			$where[] = 'wc.work_id='.intval($filter['work_id']);
		}
	
		$where = empty($where) ? null : implode(' AND ', $where);
	
		$query = array(
			'FROM'		=> $this->db_table.' AS wc',
			'JOINS'		=> array(
				array(
					'INNER JOIN'=> 'works AS w',
					'ON'		=> 'wc.work_id=w.id'
				),
				array(
					'INNER JOIN'=> 'competitions AS c',
					'ON'		=> 'w.competition_id=c.id'
				),
				array(
					'INNER JOIN'=> 'events AS e',
					'ON'		=> 'c.event_id=e.id'
				),
			),
			'WHERE'		=> $where,
			'ORDER BY'	=> isset($options['ORDER BY']) ? $options['ORDER BY'] : 'wc.id',
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
	
			$query['LIMIT'] = $options['records_on_page'] * ($this->cur_page - 1).','.$options['records_on_page'];
		}
	
		// ----------------
		// Fetching records
		// ----------------
	
		$query['SELECT'] = 'wc.*, w.title AS work_title, c.works_type, c.alias AS competition_alias, e.title AS event_title, e.alias AS event_alias, c.event_id';
		
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
	
	function displayLatestComments() {
		return $this->renderAction(array(
			'comments' => $this->getRecords(array('records_on_page' => 5, 'ORDER BY' => 'wc.id DESC'))
		), '_display_latest_comments');
	}
	
	function displayWorkComments($work_id) {
		return $this->renderAction(array(
			'Module' => $this,
			'work_id' => $work_id,
			'comments' => $this->getRecords(array('filter' => array('work_id' => $work_id))) 
		), '_display_work_comments');
	}

	function actionMainCommentsList() {
		$this->error_report_type = 'active_form';
		
		$CWorks = new works($_GET['work_id']);
		if (!$CWorks->record['id']) {
			$this->error($CWorks->last_msg, __FILE__, __LINE__);
			return false;
		}
		
		NFW::i()->registerFunction('friendly_date');
		$lang_main = NFW::i()->getLang('main');
		$comments = array();
		foreach ($this->getRecords(array('filter' => array('work_id' => $CWorks->record['id']))) as $comment) {
			$comments[] = array(
				'id' => $comment['id'],
				'posted_str' => friendly_date($comment['posted'], $lang_main).' '.date('H:i', $comment['posted']).' by '.htmlspecialchars($comment['posted_username']), 
				'message' => nl2br(htmlspecialchars($comment['message'])),
			);
		}
		
		NFW::i()->renderJSON(array('result' => 'success', 'comments' => $comments));
	}
	
    function actionMainAddComment() {
    	$this->error_report_type = 'active_form';

    	$CWorks = new works($_POST['work_id']);
    	if (!$CWorks->record['id']) {
    		$this->error($CWorks->last_msg, __FILE__, __LINE__);
    		return false;
    	}
    	 
    	$this->formatAttributes($_POST);
    	$errors = $this->validate();

		if (!empty($errors)) {
   			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}

		$this->save();
		if ($this->error) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $this->last_msg)));
		}

    	NFW::i()->renderJSON(array('result' => 'success'));
    }

    function actionMainDelete() {
    	$this->error_report_type = 'plain';
    	if (!$this->load($_POST['record_id'])) return false;
    	 
    	$this->delete();
    	NFW::i()->stop('success');
    }
}