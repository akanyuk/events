<?php
/***********************************************************************
  Copyright (C) 2009-2013 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

 Элементы сайта (промо-блоки, контакты, реквизиты...)
  
 ************************************************************************/
class elements extends active_record {
	var $attributes = array(
		'title' => array('desc'=>'Заголовок', 'type'=>'str', 'required'=>true, 'minlength'=>4, 'maxlength'=>255),
		'alias' => array('desc'=>'alias', 'type'=>'str', 'required'=>true, 'minlength'=>3, 'maxlength'=>64),
		'content' => array('desc'=>'Содержимое', 'type'=>'textarea', 'maxlength'=>1048576),
		'editable' => array('desc'=>'Редактируемо', 'type'=>'bool', 'default'=>true),
		'visual_editor' => array('desc'=>'Визуальный редактор', 'type'=>'bool', 'default'=>true),
		'with_attachments' => array('desc'=>'Использует вложения', 'type'=>'bool'),
	);
	
	function __construct($record_id = false, $load_by_alias = false) {
		if (!$load_by_alias) return parent::__construct($record_id);
		
		// load record by alias
		$this->db_table = get_class($this);
		if (!$result = NFW::i()->db->query_build(array('SELECT' => '*', 'FROM' => $this->db_table, 'WHERE' => 'alias=\''.NFW::i()->db->escape($record_id).'\''))) {
			$this->error('Unable to fetch record', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			$this->error('Record not found.', __FILE__, __LINE__);
			return false;
		}
		$this->db_record = $this->record = NFW::i()->db->fetch_assoc($result);
	}
		
	protected function load($id) {
		if (!parent::load($id)) return false;
	
		$CMedia = new media();
		$this->record['attachments'] = $CMedia->getFiles(get_class($this), $this->record['id']);
		
		return $this->record;
	}
		
	function getRecords($editable_only = false) {
		$query = array(
			'SELECT'	=> '*',
			'FROM'		=> $this->db_table,
			'ORDER BY'	=> 'title'
		);
		if ($editable_only) {
			$query['WHERE'] = 'editable=1';
		}
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
			
	function actionAdmin() {
		$this->error_report_type = 'plain';
		
		if (isset($_GET['part']) && $_GET['part'] == 'list.js') {
			$records = $this->getRecords(true);
			if ($records === false) {
				$this->error('Не удалось получить список записей.', __FILE__, __LINE__);
				return false;
			}
			
	        NFW::i()->stop($this->renderAction(array(
				'records' => $records
	        ), '_admin_list.js'));        
		}
		
        return $this->renderAction();        
	}

    function actionInsert() {
    	if (empty($_POST)) {
	        return $this->renderAction();        
    	}
	   	    	
	   	// Saving
    	$this->error_report_type = 'active_form';
	   	$this->formatAttributes($_POST);
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
		$this->error_report_type = (empty($_POST)) ? 'alert' : 'active_form';
		
    	if (!$this->load($_GET['record_id'])) return false;
		
	    if (empty($_POST)) {
	    	$CMedia = new media();
	    	NFW::i()->stop($this->renderAction(array(
	    		'media_form' => $CMedia->openSession(array('owner_class' => get_class($this), 'owner_id' => $this->record['id'], 'safe_filenames' => true, 'force_rename' => true))
	    	)));
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