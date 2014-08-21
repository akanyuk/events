<?php
/***********************************************************************
  Copyright (C) 2009-2013 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

 ************************************************************************/
class pages extends active_record {
	var $path = '';
	var $attributes = array(
		'title' => array('desc'=>'Заголовок страницы', 'type'=>'str', 'required'=>true, 'minlength'=>4, 'maxlength'=>255),
		'content' => array('desc'=>'Содержимое страницы', 'type'=>'str', 'maxlength'=>1048576),
		'path' => array('desc'=>'Относительный путь', 'type'=>'str', 'required'=>true, 'maxlength'=>255),
		'elements' => array('desc'=>'Элементы', 'type'=>'custom'),
		'is_active' => array('desc'=>'Страница активна', 'type'=>'bool')
	);
	
	function loadPage($path = false) {
		if ($path === false) {
			$path = preg_replace('/(^\/)|(\/$)|(\?.*)|(\/\?.*)/', '', $_SERVER['REQUEST_URI']);
		}

		$this->path = $path ? $path : '/';	// Index page
		return $this->load($this->path, true);
	}
		
	protected function load($id, $load_by_path = false) {
		$query = array(
			'SELECT'	=> '*',
			'FROM'		=> $this->db_table,
		);
		
		if ($load_by_path) {
			$query['WHERE']	= 'path=\''.NFW::i()->db->escape($id).'\' OR path=\''.NFW::i()->db->escape(urldecode($id)).'\'';
		}
		else {
			$query['WHERE']	= 'id='.intval($id);
		}
		
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to fetch record', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			$this->error('Record not found.', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		$this->db_record = $this->record = NFW::i()->db->fetch_assoc($result);
	
		$CMedia = new media();
		$this->record['attachments'] = $CMedia->getFiles(get_class($this), $this->record['id']); 
		
		// Load elements
		$this->record['elements'] = NFW::i()->unserializeArray($this->record['elements']);
		if (!empty($this->record['elements'])) {
			$CElements = new elements();
			foreach ($CElements->getRecords() as $e) {
				if (in_array($e['id'], $this->record['elements'])) {
					$this->record[$e['alias']] =  $e['content'];
				}
			}
		}
		
		return $this->record;
	}
		
	function getRecords() {
		$query = array(
			'SELECT'	=> 'id, title, path, is_active, posted, posted_by, posted_username',
			'FROM'		=> $this->db_table,
			'ORDER BY'	=> 'is_active DESC, id DESC'
		);
		
		if (!$result = NFW::i()->db->query_build($query)) { 
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

	    return $records;
	}
		
	function validate() {
		$errors = parent::validate();
		
		// Validate 'path' unique
		$query = array(
			'SELECT' 	=> '*',
			'FROM'		=> $this->db_table,
			'WHERE'		=>  'path=\''.NFW::i()->db->escape($this->record['path']).'\''
		);
		if ($this->record['id']) {
			$query['WHERE'] .= ' AND id<>'.$this->record['id'];
		}
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to validate path', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		 
		if (NFW::i()->db->num_rows($result)) {
			$errors['path'] = 'Дублирование поля «'.$this->attributes['path']['desc'].'» недопустимо.';
		}
		 
		return $errors;
	}
		
	function actionAdmin() {
		if (!isset($_GET['part']) || $_GET['part'] != 'list.js') {
			return $this->renderAction();
		}

		$this->error_report_type = 'plain';
		
		$records = $this->getRecords();
		if ($records === false) {
			$this->error('Не удалось получить список страниц.', __FILE__, __LINE__);
			return false;
		}
			
		NFW::i()->stop($this->renderAction(array(
			'records' => $records
		), '_admin_list.js'));        
	}

    function actionInsert() {
    	$CMedia = new media();
    	
    	if (empty($_POST)) {
	        return $this->renderAction(array(
	        	'media_form' => $CMedia->openSession(array('owner_class' => get_class($this), 'safe_filenames' => true, 'force_rename' => true))
	        ));        
    	}
	   	    	
	   	// Saving
    	$this->error_report_type = 'active_form';
	   	$this->formatAttributes($_POST);
		$errors = $this->validate();
		if (!empty($errors)) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}
	   	
		$this->record['elements'] = array();
		$CElements = new elements();
		foreach ($CElements->getRecords() as $e) {
			if ($e['default']) {
				$this->record['elements'][] = $e['id'];
			}
		}
		$this->record['elements'] = NFW::i()->serializeArray($this->record['elements']);
		
	   	$this->save();
    	if ($this->error) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => $this->last_msg)));
		}

		// Add media
		$CMedia->closeSession(get_class($this), $this->record['id']);
		
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
		$this->error_report_type = (empty($_POST)) ? 'default' : 'active_form';
		
    	if (!$this->load($_GET['record_id'])) return false;
		
    	$CElements = new elements();
    	
	    if (empty($_POST)) {
	    	$CMedia = new media();
	        return $this->renderAction(array(
	        	'elements' => $CElements->getRecords(),
	        	'media_form' => $CMedia->openSession(array('owner_class' => get_class($this), 'owner_id' => $this->record['id'], 'safe_filenames' => true, 'force_rename' => true))
	        ));
    	}

	   	// Save
	   	$this->formatAttributes($_POST);
	   	$this->record['elements'] = NFW::i()->serializeArray(isset($_POST['elements']) ? $_POST['elements'] : $this->record['elements']);
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
    	NFW::i()->stop();
    }
}