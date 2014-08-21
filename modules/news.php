<?php
/***********************************************************************
  Copyright (C) 2009-2012 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

 Новости.
  
 ************************************************************************/
class news extends active_record {
	var $attributes = array(
		'title' => array('desc'=>'Заголовок', 'type'=>'str', 'required'=>true, 'minlength'=>4, 'maxlength'=>255),
		'announcement' => array('desc'=>'Анонс', 'type'=>'textarea', 'maxlength'=>4096),
		'content' => array('desc'=>'Содержимое', 'type'=>'textarea', 'maxlength'=>1048576),
	);
	
	protected function load($id) {
		if (!parent::load($id)) return false;
	
		$CMedia = new media();
		$this->record['attachments'] = $CMedia->getFiles(get_class($this), $this->record['id']);
		
		return $this->record;
	}
		
	function getRecords($options = array()) {
		$where = array();
		if (isset($options['posted_from']) && $options['posted_from']) {
			$where[] = 'posted>='.intval($options['posted_from']);
		}
		if (isset($options['posted_to']) && $options['posted_to']) {
			$where[] = 'posted<='.intval($options['posted_to']);
		}
		$where = empty($where) ? null : implode (' AND ', $where);
		
		$query = array(
			'SELECT'	=> '*',
			'FROM'		=> $this->db_table,
			'WHERE' => $where,
			'ORDER BY'	=> 'posted DESC'
		);
		
		if (isset($options['records_on_page']) && $options['records_on_page']) {
			if (!$result = NFW::i()->db->query_build(array(
				'SELECT'	=> 'COUNT(*)',
				'FROM'		=> $this->db_table,
				'WHERE' => $where,
			))) { 
				$this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
			list($num_records) = NFW::i()->db->fetch_row($result);
		
			$this->num_pages = ceil($num_records / $options['records_on_page']);
			$page = isset($options['page']) ? intval($options['page']) : 1; 
			$this->cur_page = ($page <= 1 || $page > $this->num_pages) ? 1 : $page;
			
			$query['LIMIT'] = $options['records_on_page'] * ($this->cur_page - 1).','.$options['records_on_page'];
		}
				
		if (!$result = NFW::i()->db->query_build($query)) { 
			$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			return array();
		}

		$CMedia = new media();
		$records = array();
	    while($cur_record = NFW::i()->db->fetch_assoc($result)) {
	    	if (isset($options['load_attachments']) && $options['load_attachments']) {  
	    		$cur_record['attachments'] = $CMedia->getFiles(get_class($this), $cur_record['id']);
	    	}
	    	
	    	$records[] = $cur_record;
	    }

	    return $records;
	}
		
	function actionAdmin() {
		$this->error_report_type = 'plain';
		
		if (isset($_GET['part']) && $_GET['part'] == 'list.js') {
			$records = $this->getRecords();
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
		
	    if (empty($_POST)) {
	    	$CMedia = new media();
	        return $this->renderAction(array(
	        	'media_form' => $CMedia->openSession(array('owner_class' => get_class($this), 'owner_id' => $this->record['id'], 'safe_filenames' => true, 'force_rename' => true))
	        ));
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