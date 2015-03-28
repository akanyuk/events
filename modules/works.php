<?php
/***********************************************************************
  Copyright (C) 2012 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$
  
  Управление авторскими работами.
  
 ************************************************************************/

class works extends active_record {
	var $attributes = array(
		'competition_id' => array('type' => 'select', 'desc' => 'Competition', 'required' => true, 'options' => array()),
		'status' => array('type' => 'select', 'desc' => 'Status', 'options' => array(
			0 => array('id' => 0, 'voting' => false, 'release' => false, 'label-class' => 'label-default', 'icon' => 'glyphicon-question-sign'),	// Unchecked
			1 => array('id' => 1, 'voting' =>  true, 'release' =>  true, 'label-class' => 'label-success', 'icon' => 'glyphicon-ok'),				// Checked
			2 => array('id' => 2, 'voting' => false, 'release' => false, 'label-class' => 'label-danger', 'icon' => 'glyphicon-ban-circle'),		// Disqualified
			3 => array('id' => 3, 'voting' => false, 'release' => false, 'label-class' => 'label-warning', 'icon' => 'glyphicon-question-sign'),	// Feedback needed
			4 => array('id' => 4, 'voting' => false, 'release' =>  true, 'label-class' => 'label-danger', 'icon' => 'glyphicon-exclamation-sign'),	// Out of competition
			5 => array('id' => 5, 'voting' => false, 'release' =>  true, 'label-class' => 'label-info', 'icon' => 'glyphicon-hourglass'),			// Wait preselect		
		)),
		'pos' => array('type' => 'int', 'desc' => 'Position'),
		'title' => array('type' => 'str', 'desc' => 'Title', 'required' => true, 'maxlength' => 200),
		'author' => array('type' => 'str', 'desc' => 'Author', 'required' => true, 'maxlength' => 200),
		'description' => array('type' => 'textarea', 'desc' => 'Description', 'maxlength' => 2048),
		'platform' => array('type' => 'str', 'desc' => 'Platform', 'required' => true, 'options' => array()),
		'format' => array('type' => 'str', 'desc' => 'Format', 'maxlength' => 128),
		'external_html' => array('type' => 'textarea', 'desc' => 'External HTML (i.e. Youtube)', 'maxlength' => 2048),
	);
	
	var $breadcrumb = array();

	function __construct($record_id = false) {
		$lang_main = NFW::i()->getLang('main');
	
		foreach ($this->attributes['status']['options'] as &$o) {
			$o['desc'] = $lang_main['works status desc'][$o['id']];
			$o['desc_full'] = $lang_main['works status desc full'][$o['id']];
		}

		// Collect available platforms
		if (!$result = NFW::i()->db->query_build(array('SELECT'	=> 'DISTINCT platform', 'FROM' => 'works', 'ORDER BY' > 'platform'))) {
			$this->error('Unable to fetch platforms', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		while ($record = NFW::i()->db->fetch_assoc($result)) {
			$this->attributes['platform']['options'][] = $record['platform'];
		}
		
		
		return parent::__construct($record_id);
	}
	
    private function formatRecord($record) {
    	$lang_main = NFW::i()->getLang('main');
    	
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
    	
    	if (file_exists(PROJECT_ROOT.'files/'.$record['event_alias'].'/'.$record['competition_alias'].'/'.iconv("UTF-8", NFW::i()->cfg['media']['fs_encoding'], $record['title']).'.zip')) {
    		$record['permanent_file'] = pathinfo('files/'.$record['event_alias'].'/'.$record['competition_alias'].'/'.$record['title'].'.zip');    		
    		$record['permanent_file']['url'] = NFW::i()->absolute_path.'/files/'.$record['event_alias'].'/'.$record['competition_alias'].'/'.$record['title'].'.zip';
    	}
    	else {
    		$record['permanent_file'] = false;
    	}
    	
    	return $record;
	}

	protected function load($id, $options = array()) {
		$query = array(
			'SELECT'	=> 'w.*, c.title AS competition_title, c.pos AS competition_pos, c.alias AS competition_alias, c.works_type, c.voting_from, c.voting_to, e.id AS event_id, e.title AS event_title, e.date_from AS event_from, e.date_to AS event_to, e.alias AS event_alias, u.email AS poster_email, u.realname AS poster_realname, u.country AS poster_country, u.city AS poster_city',
			'FROM'		=> $this->db_table.' AS w',
			'JOINS'		=> array(
				array(
					'INNER JOIN'=> 'competitions AS c',
					'ON'		=> 'w.competition_id=c.id'
				),
				array(
					'INNER JOIN'=> 'events AS e',
					'ON'		=> 'c.event_id=e.id'
				),
				array(
					'LEFT JOIN'=> 'users AS u',
					'ON'		=> 'w.posted_by=u.id'
				),
			),
			'WHERE'		=> 'w.id='.intval($id),
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
		$this->record['attachments'] = $CMedia->getFiles(get_class($this), $this->record['id']);
	
		$this->record = $this->formatRecord($this->record);
		return $this->record;
	}
	
	protected function save() {
		if ($this->record['id']) {
			$is_updated = parent::save();
			if ($this->error) return false;
			
			if ($is_updated) {
				// Add service information
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
			
			return $is_updated;
		}
		else {
			parent::save();
			if ($this->error) return false;
				
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
			
			return true;
		}	
	}
		
	public function loadCounters(&$competitions) {
		$ids = $compo_by_id = array();
		if (is_array($competitions)) {
			foreach ($competitions as &$c) {
				$ids[] = $c['id'];
				$compo_by_id[$c['id']] = array('voting_works' => 0, 'release_works' => 0);
			}
			unset($c);
		}
		else {
			$ids[] = $competitions;
			$compo_by_id[$competitions] = array('voting_works' => 0, 'release_works' => 0);
		}

		if (!$result = NFW::i()->db->query_build(array(
			'SELECT'	=> 'competition_id, status',
			'FROM'		=> $this->db_table,
			'WHERE'		=> 'competition_id IN('.implode(',', $ids).')',
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
		}
		else {
			return $compo_by_id[$competitions];
		}
	}
	
	public function getRecords($options = array()) {
		// Count total records
		$query = array('SELECT' => 'COUNT(*)', 'FROM' => $this->db_table);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($total_records) = NFW::i()->db->fetch_row($result);
	
		$filter = isset($options['filter']) ? $options['filter'] : array();
	
		// Setup WHERE from filter
		$where = array();
	
		if (isset($filter['posted_by'])) {
			$where[] = 'w.posted_by='.intval($filter['posted_by']);
		}
	
		if (isset($filter['event_id'])) {
			$where[] = 'c.event_id='.intval($filter['event_id']);
		}

		if (isset($filter['competition_id'])) {
			$where[] = 'c.id='.intval($filter['competition_id']);
		}

		if (!(isset($filter['allow_hidden']) && $filter['allow_hidden'])) {
			$where[] = 'e.is_hidden=0';
		}
		
		if (isset($filter['voting_only']) && $filter['voting_only']) {
			$vs = array();
			foreach ($this->attributes['status']['options'] as $s) {
				if ($s['voting']) {
					$vs[] = $s['id'];
				}
			}
			$where[] = 'w.status IN ('.implode(',', $vs).')';
		}
		
		if (isset($filter['release_only']) && $filter['release_only']) {
			$vs = array();
			foreach ($this->attributes['status']['options'] as $s) {
				if ($s['release']) {
					$vs[] = $s['id'];
				}
			}
			$where[] = 'w.status IN ('.implode(',', $vs).')';
		}
		
		// not strong "WHERE"
	
		if (isset($options['free_filter'])) {
			$where[] = '(w.title LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR c.title LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\')';
		}
	
		$where = count($where) ? join(' AND ', $where) : null;
		
		$joins = array(
			array(
				'INNER JOIN'=> 'competitions AS c',
				'ON'		=> 'w.competition_id=c.id'
			),
			array(
				'INNER JOIN'=> 'events AS e',
				'ON'		=> 'c.event_id=e.id'
			),
		);
		
		// Count filtered values
		$query = array(
			'SELECT'	=> 'COUNT(*)',
			'FROM'		=> $this->db_table.' AS w',
			'JOINS'		=> $joins,
			'WHERE'		=> $where,
		);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to count filtered records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($num_filtered) = NFW::i()->db->fetch_row($result);
		if (!$num_filtered) {
			return array(array(), $total_records, 0);
		}
	
		// ----------------
		// Fetching records
		// ----------------
		$query = array(
			'SELECT'	=> 'w.*, c.title AS competition_title, c.pos AS competition_pos, c.alias AS competition_alias, c.works_type, c.voting_from, c.voting_to, e.id AS event_id, e.title AS event_title, e.date_from AS event_from, e.date_to AS event_to, e.alias AS event_alias',
			'FROM'		=> $this->db_table.' AS w',
			'JOINS'		=> $joins,
			'WHERE'		=> $where,
			'ORDER BY'	=> isset($options['ORDER BY']) ? $options['ORDER BY'] : 'e.date_from, c.pos, w.pos',
			'LIMIT' 	=> isset($options['limit']) && $options['limit'] ? intval($options['limit']) : null,
			'OFFSET' 	=> isset($options['offset']) && $options['offset'] ? intval($options['offset']) : null,
		);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) return false;
		$records = $ids = array();
		while ($record = NFW::i()->db->fetch_assoc($result)) {
			$ids[] = $record['id'];
			$record['attachments'] = array();
				
			$records[] = $record;
		}

		// Load attachments
		$CMedia = new media();
		foreach ($CMedia->getFiles(get_class($this), $ids) as $a) {
			foreach ($records as $key=>$record) {
				if ($record['id'] != $a['owner_id']) continue;
					
				array_push($records[$key]['attachments'], $a);
				break;
			}
		}
		
		foreach ($records as $key=>$record) {
			$records[$key] = $this->formatRecord($record);
		}
		
		return array($records, $total_records, $num_filtered);
	}
	
	function validate() {
		$errors = parent::validate($this->record, $this->attributes);
		if (!$this->searchArrayAssoc($this->attributes['competition_id']['options'], $this->record['competition_id'])) {
			$errors['competition_id'] = 'System error: wrong cometition ID'; 
		}
		
		return $errors;
	}
	
	
   	// Просмотр автором работ из ЛК    
    function cabinetList() {
    	list($records) = $this->getRecords(array(
    		'filter' => array('posted_by' => NFW::i()->user['id']),
    		'ORDER BY' => 'e.date_from DESC, c.pos, w.pos'
    	));
    	 
		return $this->renderAction(array('records' => $records));
    }
    
    function cabinetView() {
    	if (!$this->load($_GET['record_id'])) return false;
    	if ($this->record['posted_by'] != NFW::i()->user['id']) {
    		$this->error(NFW::i()->lang['Errors']['Bad_request'], __FILE__, __LINE__);
    		return false;
    	}

    	$lang_main = NFW::i()->getLang('main');
    	$this->breadcrumb = array(
    		array('url' => 'cabinet/works?action=list', 'desc' => $lang_main['cabinet prods']),
    		array('desc' => $this->record['title'])
    	);
    	 
    	return $this->renderAction();
    }

    function cabinetAdd() {
    	$Competitions = new competitions();
    	foreach ($Competitions->getRecords(array('filter' => array('open_reception' => true))) as $c) {
    		$this->attributes['competition_id']['options'][] = array('id' => $c['id'], 'desc' => $c['title'].' / '.$c['event_title']);
    	}

    	if (empty($this->attributes['competition_id']['options'])) {
    		$lang_main = NFW::i()->getLang('main');
    		$this->error($lang_main['events no open'], __FILE__, __LINE__);
    		return false;
    	}
    	 
    	$CMedia = new media();
    	if (empty($_POST)) {
    		
    		$lang_main = NFW::i()->getLang('main');
    		$this->breadcrumb = array(
    			array('url' => 'cabinet/works?action=list', 'desc' => $lang_main['cabinet prods']),
    			array('desc' => $lang_main['cabinet add work'])
    		);
    		
    		return $this->renderAction(array(
    			'attributes' => $this->attributes,
    			'media_form' => $CMedia->openSession(array(
    				'owner_class' => get_class($this), 
    				'secure_storage' => true,    				
    				'path_prefix' => 'works',
    				'template' => 'add_work',
    			)),
    		));
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
		
		// Add media
		$CMedia->closeSession(get_class($this), $this->record['id']);
		
		$CCompetitions = new competitions($this->record['competition_id']); 
		NFW::i()->sendNotify('works_add', $CCompetitions->record['event_id'], array('work' => $this->record));
		
		$lang_main = NFW::i()->getLang('main');
    	NFW::i()->renderJSON(array('result' => 'success', 'message' => $lang_main['works upload success message']));
    }

    function actionAdmin() {
    	if (!isset($_GET['part']) || $_GET['part'] != 'list.js') {
    		$CEvents = new events();
    		return $this->renderAction(array(
    			'events' => $CEvents->getRecords(array('filter' => array('managed' => true))) 
    		));
    	}
    	
    	$this->error_report_type = 'silent';
    			
    	$options = array(
    		'limit' => $_POST['iDisplayLength'],
    		'offset' => $_POST['iDisplayStart'],
    		'filter' => array(
    			'event_id' => $_POST['event_id'] == '-1' ? null : $_POST['event_id'],
    			'competition_id' => $_POST['competition_id'] && $_POST['competition_id'] != '-1' ? $_POST['competition_id'] : null,
    			'allow_hidden' => true
    		),
    		'free_filter' => isset($_POST['sSearch']) && $_POST['sSearch'] ? $_POST['sSearch'] : null
    	);
/*
    	switch ($_POST['iSortCol_0']) {
    		case 1:
    			$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'w.pos' : 'w.pos DESC';
    			break;
    		case 2:
    			$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'w.title' : 'w.title DESC';
    			break;
    		case 2:
    			$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'w.posted_username' : 'w.posted_username DESC';
    			break;
    		case 2:
    			$options['ORDER BY'] = $_POST['sSortDir_0'] == 'asc' ? 'w.posted_username' : 'w.posted_username DESC';
    			break;
    	}
*/
    	list($records, $iTotalRecords, $iTotalDisplayRecords) = $this->getRecords($options);

    	// Competitions
    	$Competitions = new competitions();
    	$available_competitions = $Competitions->getRecords(array('filter' => array('event_id' => $_POST['event_id'] == '-1' ? null : $_POST['event_id'])));
    	
    	NFW::i()->stop($this->renderAction(array(
    		'records' => $records,
    		'iTotalRecords' => $iTotalRecords,
    		'iTotalDisplayRecords' => $iTotalDisplayRecords,
    		'available_competitions' => $available_competitions
    	), '_admin_list.js'));
    }
        
	function actionInsert() {
		$this->error_report_type = empty($_POST) ? 'alert' : 'active_form';

		// Author not required in admin
		$this->attributes['author']['required'] = false;
		
		$CEvents = new events(isset($_GET['event_id']) ? $_GET['event_id'] : null);
		if (!$CEvents->record['id']) {
			$this->error('Unable to search event', __FILE__, __LINE__);
			return false;
		}
		
		// Load competitions
		$Competitions = new competitions();
		foreach ($Competitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))) as $c) {
			$this->attributes['competition_id']['options'][] = array('id' => $c['id'], 'desc' => $c['title']);
		}
		
		if (empty($_POST)) {
			NFW::i()->stop($this->renderAction(array(
				'event' => $CEvents->record
			)));
		}
	
		// Saving
		$this->formatAttributes($_POST);
		$errors = $this->validate();
		if (!empty($errors)) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}
		 
		// Determine `position`
		if (!$result = NFW::i()->db->query_build(array('SELECT' => 'MAX(`pos`)', 'FROM' => $this->db_table, 'WHERE' => 'competition_id='.intval($this->record['competition_id'])))) {
			$this->error('Unable to determine `position`', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($pos) = NFW::i()->db->fetch_row($result);
		$this->record['pos'] = intval($pos) + 1;
			
		$this->save();
		if ($this->error) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $this->last_msg)));
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
			    	
		// Main
		
		$this->error_report_type = empty($_POST) ? 'default' : 'active_form';

		if (!$this->load($_GET['record_id'])) return false;

		// Author not required in admin
		$this->attributes['author']['required'] = false;
		
		// Load competitions
		$Competitions = new competitions();
		foreach ($Competitions->getRecords(array('filter' => array('event_id' => $this->record['event_id']))) as $c) {
			$this->attributes['competition_id']['options'][] = array('id' => $c['id'], 'desc' => $c['title']);
		}
		
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
		 
		if (isset($_POST['send_notify']) && $_POST['send_notify']) {
			$CUsers = new users($this->record['posted_by']);
			if ($this->is_valid_email($CUsers->record['email'])) {
				email::sendFromTemplate($CUsers->record['email'], 'works_update', array('work' => $this->record, 'language' => $CUsers->record['language']));
			}
		}
		
		NFW::i()->renderJSON(array('result' => 'success', 'is_updated' => $is_updated));
	}
	
	function actionMediaManage() {
		$this->error_report_type = empty($_POST) ? 'plain' : 'active_form';
		
		if (!$this->load($_GET['record_id'])) return false;
		
		if (empty($_POST)) {
			foreach ($this->record['media_info'] as $a) {
				if ($a['type'] == 'image') {
					list($width, $height) = getimagesize($a['fullpath']);
					$a['image_size'] = '['.$width.'x'.$height.']'; 
					$a['icon'] = $a['tmb_prefix'].'64';
				}
				else {
					$a['image_size'] = '';
					$a['icon'] = $a['icons']['64x64'];
				}
				
				$result[] = array(
					'id' => $a['id'], 
					'basename' => $a['basename'], 
					'url' => $a['url'],
					'type' => $a['type'],
					'icon' => $a['icon'],
					'image_size' => $a['image_size'],
					'filesize_str' => $a['filesize_str'],
					'posted_str' => date('d.m.Y H:i:s', $a['posted']),
					'posted_username' => $a['posted_username'],
					'is_screenshot' => $a['is_screenshot'], 
					'is_voting' => $a['is_voting'],
					'is_image' => $a['is_image'],
					'is_audio' => $a['is_audio'],
					'is_release' => $a['is_release']
				);
			}			
			NFW::i()->renderJSON(array('iTotalRecords' => count($result), 'aaData' => $result));
		}
				
		if (isset($_POST['media_release']) && $_POST['media_release']) {
			if (!$_POST['attach_file_id'] && empty($this->record['release_files'])) {
				$this->error('Nothing to add into archive!<br />Please select `release` files first.', __FILE__, __LINE__);
				return false;
			}
				
			$pack_dir = PROJECT_ROOT.'files/'.$this->record['event_alias'].'/'.$this->record['competition_alias'];
			if (!file_exists($pack_dir)) {
				if (!mkdir($pack_dir)) {
					$this->error('Unable to make competition directory', __FILE__, __LINE__);
					return false;
				}
				chmod($pack_dir, 0777);
			}
		
			$pack_filename = iconv("UTF-8", NFW::i()->cfg['media']['fs_encoding'], $this->record['title']).'.zip';
				
			$zip = new ZipArchive();
			if ($zip->open($pack_dir.'/'.$pack_filename, ZIPARCHIVE::OVERWRITE | ZIPARCHIVE::CREATE) !== TRUE) {
				$this->error('Unable to create zip-archive', __FILE__, __LINE__);
				return false;
			}
		
			$already_added = array();
				
			foreach ($this->record['release_files'] as $a) {
				if ($a['mime_type'] == 'application/zip') {
					// Repack zip-archive
					$ezip = zip_open($a['fullpath']);
					while ($zip_entry = zip_read($ezip)) {
						if (zip_entry_open($ezip, $zip_entry, "r")) {
							$already_added[] = strtolower(zip_entry_name($zip_entry));
							$zip->addFromString(iconv("UTF-8", 'cp866', zip_entry_name($zip_entry)), zip_entry_read($zip_entry, zip_entry_filesize($zip_entry)));
							zip_entry_close($zip_entry);
						}
					}
				}
				else {
					$basename = strtolower($a['basename']);
					$basename = in_array($basename, $already_added) ? $a['id'].'_'.$basename : $basename;
					$already_added[] = $basename;
					$zip->addFile($a['fullpath'], iconv("UTF-8", 'cp866', $basename));
				}
			}
		
			$archive_description = 'Full name of prod: '.$this->record['title']."\n".'Author: '.$this->record['author']."\n".'Event: '.$this->record['event_title'].' ('.date('d.m.Y', $this->record['event_from']).' - '.date('d.m.Y', $this->record['event_to']).')'."\n".'Compo: '.$this->record['competition_title']."\n".'Platform: '.$this->record['platform'].($this->record['format'] ? ' / '.$this->record['format'] : '')."\n".'Link: '.NFW::i()->absolute_path.'/files/'.$this->record['event_alias'].'/'.$this->record['competition_alias'].'/'.$pack_filename;
				
			if ($_POST['attach_file_id'] && !in_array('file_id.diz', $already_added)) {
				$zip->addFromString('file_id.diz', $archive_description);
			}
		
			$zip->setArchiveComment(iconv("UTF-8", 'cp1251', htmlspecialchars($archive_description)));
			$zip->close();
			chmod($pack_dir.'/'.$pack_filename, 0666);
			NFW::i()->renderJSON(array('result' => 'success', 'url' => NFW::i()->absolute_path.'/files/'.$this->record['event_alias'].'/'.$this->record['competition_alias'].'/'.$this->record['title'].'.zip'));
		}
				
		// Main save
		$query = array('UPDATE' => $this->db_table, 'SET' => 'media_info=\''.NFW::i()->serializeArray(isset($_POST['media_info']) ? $_POST['media_info'] : null).'\'', 'WHERE' => 'id='.$this->record['id']);
		if (!NFW::i()->db->query_build($query)) {
			$this->error('Unable to update media_info', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		NFW::i()->renderJSON(array('result' => 'success', 'message' => 'Media settings updated.'));
	}
		
    function actionDelete() {
    	$this->error_report_type = 'plain';
    	if (!$this->load($_POST['record_id'])) return false;
    	
    	// Remove attachments
    	$CMedia = new media();
    	foreach ($this->record['attachments'] as $a) {
    		$CMedia->reload($a['id']);
    		$CMedia->delete();    		
    	}
    	 
   		$this->delete();
		NFW::i()->stop('success');
	}
}