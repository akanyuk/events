<?php
/***********************************************************************
  Copyright (C) 2009-2013 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

  Конкурсы.
  
 ************************************************************************/

class competitions extends active_record {
	static $action_aliases = array(
		'update' => array(
			array('module' => 'competitions', 'action' => 'admin'),
			array('module' => 'competitions', 'action' => 'insert'),
			array('module' => 'competitions', 'action' => 'delete'),
		),
	);
	
	var $attributes = array(
		'event_id' => array('desc'=>'Event', 'type'=>'select', 'options' => array()),
		'position' => array('desc'=>'Position', 'type'=>'int', 'required'=>true),
		'title' => array('desc'=>'Title', 'type'=>'str', 'required'=>true, 'minlength'=>4, 'maxlength'=>255),
		'alias' => array('desc'=>'alias', 'type'=>'str', 'required'=>true, 'minlength'=>2, 'maxlength'=>32),
		'works_type' => array('desc'=>'Works type', 'type'=>'select', 'options' => array()),
		'announcement' => array('desc'=>'Announce', 'type'=>'textarea', 'maxlength'=>4096),
		'reception_from' => array('desc'=>'Works accepting start', 'type'=>'date', 'withTime' => true, 'startDate' => 1, 'endDate' => -365),
		'reception_to' => array('desc'=>'Works accepting end', 'type'=>'date', 'withTime' => true, 'startDate' => 1, 'endDate' => -365),
		'voting_from' => array('desc'=>'Voting start', 'type'=>'date', 'withTime' => true, 'startDate' => 1, 'endDate' => -365),
		'voting_to' => array('desc'=>'Voting end', 'type'=>'date', 'withTime' => true, 'startDate' => 1, 'endDate' => -365),
	);
	
	private function loadEditorOptions() {
		foreach (NFW::i()->works_type as $t) {
			$this->attributes['works_type']['options'][] = array('id' => $t['alias'], 'desc' => $t['desc']);
		}
	}
	
	private function formatRecord($record) {
		$lang_main = NFW::i()->getLang('main');
		
		$record['reception_status'] = array('informable' => false, 'desc' => '', 'text-class'  => '', 'label-class'  => 'label-default');
		$record['voting_status'] = array('informable' => false, 'available' => false, 'desc' => '', 'text-class'  => '', 'label-class'  => 'label-default');
		$record['release_status'] = array('available' => false);
		
		if (!$record['reception_from'] && !$record['reception_to']) {
			$record['reception_status']['desc'] = '-';
			$record['reception_status']['text-class']  = 'text-muted';
		}
		elseif ($record['reception_from'] > NFW::i()->actual_date) {
			$record['reception_status']['desc'] = '+'.NFWX::i()->formatTimeDelta($record['reception_from']);
			$record['reception_status']['informable'] = true;
		}
		elseif ($record['reception_from'] < NFW::i()->actual_date && $record['reception_to'] > NFW::i()->actual_date) {
			$record['reception_status']['desc'] = 'NOW! +'.NFWX::i()->formatTimeDelta($record['reception_to']);
			$record['reception_status']['text-class']  = 'text-danger';
			$record['reception_status']['label-class'] = 'label-danger';
			$record['reception_status']['informable'] = true;
		}
		else  {
			$record['reception_status']['desc'] = $lang_main['reception closed'];
			$record['reception_status']['text-class']  = 'text-muted';
		}

		if (!$record['voting_from'] && !$record['voting_to']) {
			$record['voting_status']['desc'] = '-';
			$record['voting_status']['text-class']  = 'text-muted';
		}
		elseif ($record['voting_from'] > NFW::i()->actual_date) {
			$record['voting_status']['desc'] = '+'.NFWX::i()->formatTimeDelta($record['voting_from']);
			$record['voting_status']['informable'] = true;
		}
		elseif ($record['voting_from'] <= NFW::i()->actual_date && $record['voting_to'] >= NFW::i()->actual_date) {
			$record['voting_status']['desc'] = 'NOW! +'.NFWX::i()->formatTimeDelta($record['voting_to']);
			$record['voting_status']['text-class']  = 'text-danger';
			$record['voting_status']['label-class'] = 'label-danger';
			$record['voting_status']['available']  = true;
			$record['voting_status']['informable'] = true;
		}
		else  {
			$record['voting_status']['desc'] = $lang_main['voting closed'];
			$record['voting_status']['text-class']  = 'text-muted';
		}
		
		if ((!$record['voting_from'] && !$record['voting_to']) || ($record['voting_to'] && $record['voting_to'] < NFWX::i()->actual_date)){
			$record['release_status']['available'] = true;
		}
		
		return $record;
	}
		
	protected function load($id, $options = array()) {
		$query = array(
			'SELECT' => 'c.*, e.title AS event_title',
			'FROM' => $this->db_table.' AS c',
			'JOINS'		=> array(
				array(
					'INNER JOIN'=> 'events AS e',
					'ON'		=> 'c.event_id=e.id'
				),
			),
			'WHERE' => $id ? 'c.id='.intval($id) : 'c.alias="'.NFW::i()->db->escape($options['alias']).'" AND c.event_id='.$options['event_id'] 
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

		$this->record = $this->formatRecord($this->record);
	
		// Get approved works
		$CWorks = new works();
		$this->record = array_merge($this->record, $CWorks->loadCounters($this->record['id'])); 
		return $this->record;
	}

	public function loadByAlias($alias, $event_id) {
		return $this->load(false, array('alias' => urldecode($alias), 'event_id' => $event_id));
	}
	
	public function getRecords($options = array()) {
		$filter = isset($options['filter']) ? $options['filter'] : array();
		
		// Setup WHERE from filter
		$where = array();
		
		if (isset($filter['event_id'])) {
			$where[] = 'c.event_id='.intval($filter['event_id']);
		}
		
		if (isset($filter['open_reception']) && $filter['open_reception']) {
			$where[] = 'e.is_hidden=0 AND c.reception_from<'.NFWX::i()->actual_date.' AND c.reception_to>'.NFWX::i()->actual_date;
		}

		if (isset($filter['open_voting']) && $filter['open_voting']) {
			$where[] = 'e.is_hidden=0 AND c.voting_from<='.NFWX::i()->actual_date.' AND c.voting_to>='.NFWX::i()->actual_date;
		}
		
		$where = count($where) ? join(' AND ', $where) : null;
		
		$query = array(
			'SELECT'	=> 'c.id, c.event_id, e.title AS event_title, c.title, e.alias AS event_alias, c.alias, c.works_type, c.position, c.announcement, c.reception_from, c.reception_to, c.voting_from, c.voting_to',
			'FROM'		=> $this->db_table.' AS c',
			'JOINS'		=> array(
				array(
					'INNER JOIN'=> 'events AS e',
					'ON'		=> 'c.event_id=e.id'
				),
			),
			'WHERE'		=> $where,
			'ORDER BY'	=> 'e.date_from, c.position'
		);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			return array();
		}
	
		$records = array();
		while($record = NFW::i()->db->fetch_assoc($result)) {
			$records[] = $this->formatRecord($record);			
		}
	
		$CWorks = new works();
		$CWorks->loadCounters($records);
		
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
		
		if (!isset($_GET['part']) || $_GET['part'] != 'list') {
			$this->loadEditorOptions();
    		return $this->renderAction(array('event' => $CEvents->record));
		}

		$this->error_report_type = 'plain';
		$records = $this->getRecords(array('filter' => array('event_id' => $CEvents->record['id'])));
		if ($records === false) {
			$this->error('Не удалось получить список записей.', __FILE__, __LINE__);
			return false;
		}
		
        NFW::i()->stop($this->renderAction(array(
        	'event' => $CEvents->record,
			'records' => $records
        ), '_admin_list'));        
	}

	// Update positions
	function actionAdminSetPos() {
		$this->error_report_type = 'plain';
	
		foreach ($_POST['position'] as $r) {
			if (!$this->load($r['record_id'])) continue;
	
			if (!NFW::i()->checkPermissions('check_manage_event', $this->record['event_id'])) continue;
	
			if (!NFW::i()->db->query_build(array('UPDATE' => $this->db_table, 'SET'	=> 'position='.intval($r['position']), 'WHERE' => 'id='.$this->record['id']))) {
				$this->error('Unable to update positions', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
		}
		NFW::i()->stop('success');
	}
	
	// Update dates
	function actionAdminSetDates() {
		$this->error_report_type = 'active_form';
	
		$update = array();
		if ($_POST['reception_from']) $update[] = 'reception_from='.intval($_POST['reception_from']);
		if ($_POST['reception_to']) $update[] = 'reception_to='.intval($_POST['reception_to']);
		if ($_POST['voting_from']) $update[] = 'voting_from='.intval($_POST['voting_from']);
		if ($_POST['voting_to']) $update[] = 'voting_to='.intval($_POST['voting_to']);
	
		if (empty($update) || !isset($_POST['competition'])) {
			NFW::i()->renderJSON(array('result' => 'success'));
		}
	
		$is_updated = false;
		$update = implode(' , ', $update);
		foreach ($_POST['competition'] as $id) {
			if (!$this->load($id)) continue;
	
			if (!NFW::i()->checkPermissions('check_manage_event', $this->record['event_id'])) continue;
	
			if (!NFW::i()->db->query_build(array(
					'UPDATE' => $this->db_table,
					'SET'	=> $update,
					'WHERE' => 'id='.$this->record['id']
			))) {
				$this->error('Unable to update dates', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
	
			$is_updated = true;
		}
			
		NFW::i()->renderJSON(array('result' => 'success', 'is_updated' => $is_updated));
	}
	
	function actionAdminInsert() {
		$this->loadEditorOptions();
		
    	$this->error_report_type = 'active_form';
    	$this->formatAttributes($_POST);
    	
    	$CEvents = new events($_GET['event_id']);
    	if (!$CEvents->record['id']) {
    		$this->error($CEvents->last_msg, __FILE__, __LINE__);
    		return false;
    	}
    	
	   	$this->record['event_id'] = $CEvents->record['id'];
	   	
	   	// Autogenerate next position
	   	if (!$result = NFW::i()->db->query_build(array('SELECT' => ' `position` +1', 'FROM' => $this->db_table, 'WHERE' => 'event_id='.intval($this->record['event_id']), 'ORDER BY' => 'position DESC', 'LIMIT' => '1'))) {
	   		$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
	   		return false;
	   	}
	   	if (!NFW::i()->db->num_rows($result)) {
	   		$this->record['position'] = 1;
	   	}
	   	else {
	   		list($this->record['position']) = NFW::i()->db->fetch_row($result);
	   	}

	   		
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
		$this->error_report_type = (empty($_POST)) ? 'default' : 'active_form';
		
    	if (!$this->load($_GET['record_id'])) return false;
		
    	$this->loadEditorOptions();
    	
	    if (empty($_POST)) {
	        return $this->renderAction();
	    }

	   	// Save
	   	$this->formatAttributes($_POST);
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
	
	function actionAdminDelete() {
		$this->error_report_type = 'plain';
		if (!$this->load($_GET['record_id'])) return false;

		$CWorks = new works();
		$works =  $CWorks->getRecords(array('filter' => array('competition_id' => $this->record['id'], 'allow_hidden' => true), 'skip_pagination' => true));
		if (!empty($works)) {
			$this->error('Can not delete not empty competition.'."\n".'Remove works first.', __FILE__, __LINE__);
			return false;
		}
		
		$event_id = $this->record['event_id'];
		
		if (!$this->delete()) return false;
		
		
		// Re-sort competitions
		$cur_pos = 1;
		foreach ($this->getRecords(array('filter' => array('event_id' => $event_id))) as $competition) {
			if (!NFW::i()->db->query_build(array('UPDATE' => $this->db_table, 'SET'	=> 'position='.$cur_pos++, 'WHERE' => 'id='.$competition['id']))) {
				$this->error('Unable to update positions', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
		}
		
		NFW::i()->stop('success');
	}
}