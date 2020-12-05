<?php
/***********************************************************************
  Copyright (C) 2009-2017 Andrey nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

 Новости.
  
 ************************************************************************/
class news extends active_record {
    var $num_pages = 0;
    var $cur_page = 0;

	static $action_aliases = array(
		'admin' => array(
			array('module' => 'news', 'action' => 'insert'),
			array('module' => 'news', 'action' => 'update'),
			array('module' => 'news', 'action' => 'delete'),
			array('module' => 'news', 'action' => 'media_upload'),
			array('module' => 'news', 'action' => 'media_modify'),
		),
	);
		
	var $attributes = array(
		'title' => array('desc'=>'Заголовок', 'type'=>'str', 'required'=>true, 'minlength'=>4, 'maxlength'=>255),
		'announcement' => array('desc'=>'Анонс', 'type'=>'textarea', 'maxlength'=>4096),
		'content' => array('desc'=>'Содержимое', 'type'=>'textarea', 'maxlength'=>1048576),
		'meta_keywords' => array('desc'=>'SEO: ключевые слова через&nbsp;запятую', 'type'=>'str', 'maxlength'=>255),
	);
	
	protected function load($id) {
		if (!parent::load($id)) return false;
	
		$CMedia = new media();
		$this->record['media'] = $CMedia->getFiles(get_class($this), $this->record['id']);
		
		return $this->record;
	}
		
	function getRecords($options = array()) {
		$skip_pagination = isset($options['skip_pagination']) && $options['skip_pagination'] ? true : false;
        $total_records = 0;
        $num_filtered = 0;

		if (!$skip_pagination) {
			// Count total records
			if (!$result = NFW::i()->db->query_build(array('SELECT' => 'COUNT(*)', 'FROM' => $this->db_table))) {
				$this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
			list($total_records) = NFW::i()->db->fetch_row($result);
		}
		
		$where = array();
		if (isset($options['posted_from']) && $options['posted_from']) {
			$where[] = 'posted>='.intval($options['posted_from']);
		}
		
		if (isset($options['posted_to']) && $options['posted_to']) {
			$where[] = 'posted<='.intval($options['posted_to']);
		}
		
		if (isset($options['free_filter']) && $options['free_filter']) {
			$where[] = '(title LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\' OR posted_username LIKE \'%'.NFW::i()->db->escape($options['free_filter']).'%\')';
		}
		
		$where = empty($where) ? null : implode (' AND ', $where);
		
		// Count filtered values
		if (!$skip_pagination || (isset($options['records_on_page']) && $options['records_on_page'])) {
			if (!$result = NFW::i()->db->query_build(array(
				'SELECT' => 'COUNT(*)',
				'FROM' => $this->db_table,
				'WHERE' => $where
			))) {
				$this->error('Unable to count filtered records', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
			list($num_filtered) = NFW::i()->db->fetch_row($result);
			if (!$num_filtered) {
				return $skip_pagination ? array() : array(array(), $total_records, 0);
			}
		}
		
		$query = array(
			'SELECT'	=> '*',
			'FROM'		=> $this->db_table,
			'WHERE' 	=> $where,
			'ORDER BY'	=> isset($options['ORDER BY']) ? $options['ORDER BY'] : 'posted DESC'
		);
		
		// Setup pagination
		
		if (isset($options['records_on_page']) && $options['records_on_page']) {
			$this->num_pages = ceil($num_filtered / $options['records_on_page']);
			$page = isset($options['page']) ? intval($options['page']) : 1; 
			$this->cur_page = ($page <= 1 || $page > $this->num_pages) ? 1 : $page;
			
			$query['LIMIT'] = $options['records_on_page'] * ($this->cur_page - 1).','.$options['records_on_page'];
		}
				
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			return $skip_pagination ? array() : array(array(), $total_records, 0);
		}

		$records = $ids = $media = array();
		
		while ($record = NFW::i()->db->fetch_assoc($result)) {
			$records[] = $record;
			$ids[] = $record['id'];
			$media[$record['id']] = array();
		}
		
	    // load records media
	    if (isset($options['load_media']) && $options['load_media']) {
	    	$CMedia = new media();
	    	foreach ($CMedia->getFiles(get_class($this), $ids) as $a) {
	    		$media[$a['owner_id']][] = $a;
	    	}
	    
	    	foreach ($records as $key=>$record) {
    			$records[$key]['media'] = $media[$record['id']];
	    	}
	    }
	    
	    return $skip_pagination ? $records : array($records, $total_records, $num_filtered);
	}
		
	function actionAdminAdmin() {
		if (!isset($_GET['part']) || $_GET['part'] != 'list.js') {
			return $this->renderAction();
		}
		
		$this->error_report_type = 'silent';
		
		$options = array(
			'free_filter' => isset($_POST['sSearch']) && trim($_POST['sSearch']) ? trim($_POST['sSearch']) : null,
			'limit' => $_POST['iDisplayLength'],
			'offset' => $_POST['iDisplayStart'],
		);
		
		$reverse = isset($_POST['sSortDir_0']) && $_POST['sSortDir_0'] == 'desc' ? true : false;
		switch ($_POST['iSortCol_0']) {
			case '1':
				$options['ORDER BY'] = $reverse ? 'title DESC' : 'title';
				break;
			case '3':
				$options['ORDER BY'] = $reverse ? 'posted_username DESC' : 'posted_username';
				break;
			default:
				$options['ORDER BY'] = $reverse ? 'posted DESC' : 'posted';
				break;
		}

		list($records, $iTotalRecords, $iTotalDisplayRecords) = $this->getRecords($options);
		NFW::i()->stop($this->renderAction(array(
			'records' => $records,
			'iTotalRecords' => $iTotalRecords,
			'iTotalDisplayRecords' => $iTotalDisplayRecords
		), '_admin_list.js'));
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
    	
    	// Remove media
    	$CMedia = new media();
    	foreach ($this->record['media'] as $a) {
    		$CMedia->reload($a['id']);
    		$CMedia->delete();    		
    	}
    	 
   		$this->delete();
    	NFW::i()->stop('success');
    }
}