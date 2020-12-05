<?php
/***********************************************************************
  Copyright (C) 2009-2017 Andrey nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

 ************************************************************************/
class pages extends active_record {
	static $action_aliases = array(
		'admin' => array(
			array('module' => 'pages', 'action' => 'update'),
			array('module' => 'pages', 'action' => 'media_upload'),
			array('module' => 'pages', 'action' => 'media_modify'),
		),
		'advanced-admin' => array(
			array('module' => 'pages', 'action' => 'insert'),
			array('module' => 'pages', 'action' => 'delete'),
		)
	);
	
	var $attributes = array(
		'title' => array('desc'=>'Заголовок страницы', 'type'=>'str', 'required'=>true, 'minlength'=>4, 'maxlength'=>255),
		'content' => array('desc'=>'Содержимое страницы', 'type'=>'str', 'maxlength'=>1048576),
		'path' => array('desc'=>'Относительный путь', 'type'=>'str', 'unique'=>true, 'maxlength'=>255),
		'meta_keywords' => array('desc'=>'SEO: ключевые слова через&nbsp;запятую', 'type'=>'str', 'maxlength'=>255),
		'meta_description' => array('desc'=>'SEO: описание страницы', 'type'=>'str', 'maxlength'=>255),
		'is_active' => array('desc'=>'Страница активна', 'type'=>'bool')
	);
	
	function __construct($record_id = false) {
		return parent::__construct($record_id);
	}
	
	function loadPage($path = false) {
		$path = urldecode($path === false ? preg_replace('/(^\/)|(\/$)|(\?.*)|(\/\?.*)/', '', $_SERVER['REQUEST_URI']) : $path);
		
		if (!$this->load('\''.NFW::i()->db->escape($path).'\' OR LOWER(path)=\''.NFW::i()->db->escape($path.'?lang='.strtolower(NFW::i()->user['language'])).'\'', true)) return false;
		
		// Remove multilanguage addon
		$this->record['path'] = preg_replace('/\?lang=.*$/', '', $this->record['path']);

		$this->record['is_index_page'] = $this->record['path'] == '' ? true : false;
		
		return $this->record;
	}
		
	protected function load($id, $load_by_path = false) {
		$query = array('SELECT'	=> '*', 'FROM' => $this->db_table);
		if ($load_by_path) {
			$query['WHERE']	= 'path='.$id;
			$query['ORDER BY'] = 'LENGTH(path) DESC';
		}
		else {
			$query['WHERE']	= 'id='.intval($id);
		}
		
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to fetch record', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			$this->error('Record not found: '.$id, __FILE__, __LINE__);
			return false;
		}
		$this->db_record = $this->record = NFW::i()->db->fetch_assoc($result);
	
		$CMedia = new media();
		$this->record['attachments'] = $CMedia->getFiles(get_class($this), $this->record['id']); 
		
		return $this->record;
	}
		
	function getRecords($options = array()) {
		$order_by = isset($options['ORDER BY']) ? $options['ORDER BY'] : 'edited DESC';
		$query = array(
			'SELECT'	=> 'id, title, path, is_active, posted, posted_by, posted_username, edited, edited_by, edited_username',
			'FROM'		=> $this->db_table,
			'ORDER BY'	=> $order_by
		);
		if (isset($options['records_on_page']) && $options['records_on_page']) {
			if (!$result = NFW::i()->db->query_build(array(
				'SELECT'	=> 'COUNT(*)',
				'FROM'		=> $this->db_table,
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
		
		$records = array();
	    while($cur_record = NFW::i()->db->fetch_assoc($result)) {
	    	$records[] = $cur_record;
	    }

	    return $records;
	}
		
	function actionAdminAdmin() {
		if (isset($_GET['part']) && $_GET['part'] == 'list.js') {
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
		
		return $this->renderAction();				
	}

    function actionAdminInsert() {
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

		// Confirm media, added via CKEditor
		$CMedia = new media();
		$CMedia->closeSession(get_class($this), $this->record['id']);
		
		NFW::i()->renderJSON(array('result' => 'success', 'record_id' => $this->record['id']));
    }

	function actionAdminUpdate() {
		$this->error_report_type = empty($_POST) ? 'default' : 'active_form';
		
    	if (!$this->load($_GET['record_id'])) return false;
		
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