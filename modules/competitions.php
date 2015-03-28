<?php
/***********************************************************************
  Copyright (C) 2009-2013 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

  Конкурсы.
  
 ************************************************************************/

class competitions extends active_record {
	var $attributes = array(
		'event_id' => array('desc'=>'Event', 'type'=>'select', 'options' => array()),
		'pos' => array('desc'=>'Position', 'type'=>'int', 'required'=>true),
		'title' => array('desc'=>'Title', 'type'=>'str', 'required'=>true, 'minlength'=>4, 'maxlength'=>255),
		'alias' => array('desc'=>'alias', 'type'=>'str', 'required'=>true, 'minlength'=>2, 'maxlength'=>32),
		'works_type' => array('desc'=>'Works type', 'type'=>'select', 'options' => array()),
		'announcement' => array('desc'=>'Announce', 'type'=>'textarea', 'maxlength'=>4096),
		'reception_from' => array('desc'=>'Works accepting start', 'type'=>'date', 'withTime' => true),
		'reception_to' => array('desc'=>'Works accepting end', 'type'=>'date', 'withTime' => true),
		'voting_from' => array('desc'=>'Voting start', 'type'=>'date', 'withTime' => true),
		'voting_to' => array('desc'=>'Voting end', 'type'=>'date', 'withTime' => true),
	);
	
	private function loadEditorOptions() {
		// Load settings
		$CSettings = new settings();
		$settings = $CSettings->getConfigs(array('works_type'));
		
		foreach ($settings['works_type'] as $t) {
			$this->attributes['works_type']['options'][] = array('id' => $t['alias'], 'desc' => $t['desc']);
		}
		
		// Load events
		$CEvents = new events();
		foreach ($CEvents->getRecords(array('filter' => array('managed' => true))) as $e) {
			$this->attributes['event_id']['options'][] = array('id' => $e['id'], 'desc' => $e['title']);
		}
	}
	
	private function formatRecord($record) {
		$lang_main = NFW::i()->getLang('main');
		
		$record['reception_status'] = array('desc' => '', 'text-class'  => '');
		$record['voting_status'] = array('available' => false, 'desc' => '', 'text-class'  => '');
		$record['release_status'] = array('available' => false);
		
		if (!$record['reception_from'] && !$record['reception_to']) {
			$record['reception_status']['desc'] = '-';
			$record['reception_status']['text-class']  = 'text-muted';
		}
		elseif ($record['reception_from'] > NFW::i()->actual_date) {
			$record['reception_status']['desc'] = '+'.NFW::i()->formatTimeDelta($record['reception_from']);
		}
		elseif ($record['reception_from'] < NFW::i()->actual_date && $record['reception_to'] > NFW::i()->actual_date) {
			$record['reception_status']['desc'] = 'NOW! +'.NFW::i()->formatTimeDelta($record['reception_to']);
			$record['reception_status']['text-class']  = 'text-danger';
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
			$record['voting_status']['desc'] = '+'.NFW::i()->formatTimeDelta($record['voting_from']);
		}
		elseif ($record['voting_from'] <= NFW::i()->actual_date && $record['voting_to'] >= NFW::i()->actual_date) {
			$record['voting_status']['desc'] = 'NOW! +'.NFW::i()->formatTimeDelta($record['voting_to']);
			$record['voting_status']['text-class']  = 'text-danger';
			$record['voting_status']['available']  = true;
		}
		else  {
			$record['voting_status']['desc'] = $lang_main['voting closed'];
			$record['voting_status']['text-class']  = 'text-muted';
		}
		
		if ((!$record['voting_from'] && !$record['voting_to']) || ($record['voting_to'] && $record['voting_to'] < NFW::i()->actual_date)){
			$record['release_status']['available'] = true;
		}
		
		return $record;
	}
		
	protected function load($id, $options = array()) {
		$query = array(
			'SELECT' => '*',
			'FROM' => $this->db_table,
			'WHERE' => $id ? 'id='.intval($id) : 'alias="'.NFW::i()->db->escape($options['alias']).'" AND event_id='.$options['event_id'] 
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
			$where[] = 'c.reception_from<'.NFW::i()->actual_date.' AND c.reception_to>'.NFW::i()->actual_date;
		}

		if (isset($filter['open_voting']) && $filter['open_voting']) {
			$where[] = 'c.voting_from<='.NFW::i()->actual_date.' AND c.voting_to>='.NFW::i()->actual_date;
		}
		
		$where = count($where) ? join(' AND ', $where) : null;
		
		$query = array(
			'SELECT'	=> 'c.id, c.event_id, e.title AS event_title, c.title, e.alias AS event_alias, c.alias, c.works_type, c.pos, c.announcement, c.reception_from, c.reception_to, c.voting_from, c.voting_to',
			'FROM'		=> $this->db_table.' AS c',
			'JOINS'		=> array(
				array(
					'INNER JOIN'=> 'events AS e',
					'ON'		=> 'c.event_id=e.id'
				),
			),
			'WHERE'		=> $where,
			'ORDER BY'	=> 'e.date_from, c.pos'
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
	
	function actionAdmin() {
		if (!isset($_GET['part']) || $_GET['part'] != 'list.js') {
			$this->loadEditorOptions();
    		return $this->renderAction();
		}

		$this->error_report_type = 'plain';
		$records = $this->getRecords();
		if ($records === false) {
			$this->error('Не удалось получить список записей.', __FILE__, __LINE__);
			return false;
		}
		
        NFW::i()->stop($this->renderAction(array(
			'records' => $records
        ), '_admin_list.js'));        
	}

	function actionInsert() {
    	$this->loadEditorOptions();
    	
    	if (empty($_POST)) {
	        return $this->renderAction();
    	}
	   	    	
	   	// Saving
    	$this->error_report_type = 'active_form';
	   	$this->formatAttributes($_POST);
	   
	   	// Autogenerate next position
	   	if (!$result = NFW::i()->db->query_build(array('SELECT' => ' `pos` +1', 'FROM' => $this->db_table, 'WHERE' => 'event_id='.intval($this->record['event_id']), 'ORDER BY' => 'pos DESC', 'LIMIT' => '1'))) {
	   		$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
	   		return false;
	   	}
	   	if (!NFW::i()->db->num_rows($result)) {
	   		$this->record['pos'] = 1;
	   	}
	   	else {
	   		list($this->record['pos']) = NFW::i()->db->fetch_row($result);
	   	}

	   		
		$errors = $this->validate();
		if (!empty($errors)) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}
	   	
	   	$this->save();
    	if ($this->error) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $this->last_msg)));
		}

    	// Add service information
		$query = array(
			'UPDATE'	=> $this->db_table,
			'SET'		=> '`posted_by`='.NFW::i()->user['id'].', `posted_username`=\''.NFW::i()->db->escape(NFW::i()->user['username']).'\', `poster_ip`=\''.logs::get_remote_address().'\', `posted`='.time(),
			'WHERE'		=> '`id`='.$this->record['id']
		);
		if (!NFW::i()->db->query_build($query)) {
			$this->error('Unable to update record', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
				
		NFW::i()->renderJSON(array('result' => 'success', 'record_id' => $this->record['id']));
    }

	function actionUpdate() {
		if (isset($_GET['part']) && $_GET['part'] == 'update_pos' && isset($_POST['pos']) && !empty($_POST['pos'])) {
			$this->error_report_type = 'plain';
				
			foreach ($_POST['pos'] as $id=>$value) {
				if (!$this->load($id)) continue;

				if (!in_array($this->record['event_id'], NFW::i()->user['manager_of_events'])) continue;

				if (!NFW::i()->db->query_build(array('UPDATE' => $this->db_table, 'SET'	=> 'pos='.intval($value), 'WHERE' => 'id='.$this->record['id']))) {
					$this->error('Unable to update positions', __FILE__, __LINE__, NFW::i()->db->error());
					return false;
				}
			}
			NFW::i()->stop('success');
		}
		
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
		
		// Add service information
		if ($is_updated) {
			$query = array(
				'UPDATE'	=> $this->db_table,
				'SET'		=> '`edited_by`='.NFW::i()->user['id'].', `edited_username`=\''.NFW::i()->db->escape(NFW::i()->user['username']).'\', `edited_ip`=\''.logs::get_remote_address().'\', `edited`='.time(),
				'WHERE'		=> '`id`='.$this->record['id']
			);
			if (!NFW::i()->db->query_build($query)) {
				$this->error('Unable to update record', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
		}
				
		NFW::i()->renderJSON(array('result' => 'success', 'is_updated' => $is_updated));
	}
}