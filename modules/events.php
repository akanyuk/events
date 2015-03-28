<?php
/***********************************************************************
  Copyright (C) 2009-2013 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$

  События: пати, стэндалон-компо...

 ************************************************************************/
class events extends active_record {
	var $attributes = array(
		'title' => array('desc'=>'Title', 'type'=>'str', 'required'=>true, 'minlength'=>4, 'maxlength'=>255),
		'alias' => array('desc'=>'alias', 'type'=>'str', 'required'=>true, 'minlength'=>2, 'maxlength'=>32),
		'announcement' => array('desc'=>'Announce', 'type'=>'textarea', 'maxlength'=>4096),
		'options' => array('desc'=>'Options', 'type'=>'custom'),
		'content' => array('desc'=>'Description', 'type'=>'str', 'maxlength'=>1048576),
		'date_from' => array('desc'=>'Date from', 'type'=>'date', 'required'=>true),
		'date_to' => array('desc'=>'Date to', 'type'=>'date', 'is_end' => true, 'required'=>true),
		'is_hidden' => array('desc'=>'Disabled', 'type'=>'bool'),
	);

	var $options_attributes = array(
		'label_Russian' => array('desc' => 'Label [RU]', 'type' => 'str', 'width' =>	'200px;', 'required' =>	0),
		'label_English' => array('desc' => 'Label [EN]', 'type' => 'str', 'width' =>	'200px;', 'required' =>	0),
		'value' => array('desc' => 'Value', 'type' => 'str', 'width' =>	'100px;', 'required' =>	1)
	);
		
	private function formatRecord($record) {
		$record['options'] = NFW::i()->unserializeArray($this->record['options']);
		
		$lang_main = NFW::i()->getLang('main');

		if ($record['date_from'] > NFW::i()->actual_date) {
			$record['status'] = array(
				'desc' => '+'.ceil(($record['date_from'] - NFW::i()->actual_date) / 86400).' '.$lang_main['days'],
				'label-class' => 'label-primary',
			);
		}
		elseif ($record['date_from'] < NFW::i()->actual_date && $record['date_to'] > NFW::i()->actual_date) {
			$record['status'] = array(
				'desc' => 'NOW!',
				'label-class' => 'label-danger',
			);
		}
		else  {
			$record['status'] = array(
				'desc' => $lang_main['event closed'],
				'label-class' => 'label-default',
			);
		}

		$record['is_one_day'] = date('d-m-Y', $record['date_from']) == date('d-m-Y', $record['date_to']) ? true : false;
		
		return $record;
	}

	public function load($id, $load_by_alias = false) {
		$query = array(
			'SELECT' => '*',
			'FROM' => $this->db_table,
			'WHERE' => $load_by_alias ? 'alias="'.NFW::i()->db->escape($id).'"' : 'id='.intval($id)
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

		$this->record['attachments'] = array();
		$this->record['announce'] = false;

		$CMedia = new media();
		foreach ($CMedia->getFiles(get_class($this), $this->record['id']) as $a) {
			if ($a['comment'] == 'announce') {
				$this->record['announce'] = $a['url'];
			}
			else {
				$this->record['attachments'][] = $a;
			}
		}

		$this->record = $this->formatRecord($this->record);
		return $this->record;
	}

	public function loadByAlias($alias) {
		$result = $this->load(urldecode($alias), true);
		
		if ($this->error || $this->record['is_hidden']) {
			$this->error('Record not found.', __FILE__, __LINE__);
			return false;
		}
		
		return $result;
	}

	function getRecords($options = array()) {


		$filter = isset($options['filter']) ? $options['filter'] : array();
		$filter_managed = isset($filter['managed']) && $filter['managed'] ? true : false;

		$where = array();

		if (!isset($filter['allow_hidden']) || !$filter['allow_hidden']) {
			$where[] = 'is_hidden=0';
		}

		$query = array(
			'SELECT'	=> 'id, is_hidden, title, alias, announcement, date_from, date_to, posted',
			'FROM'		=> $this->db_table,
			'WHERE'		=> implode(' AND ', $where),
			'ORDER BY'	=> 'date_from DESC'
		);

		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			return array();
		}

		$records = $ids = $attachments = array();
	    while($cur_record = NFW::i()->db->fetch_assoc($result)) {

	
	    	if ($filter_managed && !in_array($cur_record['id'], NFW::i()->user['manager_of_events'])) continue;

	    	$cur_record['attachments'] = array();
	    	$cur_record['announce'] = false;
	    	$records[] = $this->formatRecord($cur_record);

	    	$ids[] = $cur_record['id'];
	    	$attachments[$cur_record['id']] = array();
	    }

	    // load images
	    if (isset($options['load_media']) && $options['load_media']) {
	    	// Load records announces
	    	$CMedia = new media();
	    	foreach ($CMedia->getFiles(get_class($this), $ids) as $a) {
	    		$attachments[$a['owner_id']][] = $a;
	    	}

	    	foreach ($records as &$r) {
	    		if (!isset($attachments[$r['id']])) continue;

	    		foreach ($attachments[$r['id']] as $a) {
	    			if ($a['comment'] == 'announce') {
	    				$r['announce'] = $a['url'];
	    			}
	    			else {
	    				$r['attachments'][] = $a;
	    			}
	    		}

	    	}
	    	unset($r);
	    }

	    return $records;
	}

	function validate() {
		$errors = parent::validate();

		// Validate 'alias' unique
		$query = array(
			'SELECT' 	=> '*',
			'FROM'		=> $this->db_table,
			'WHERE'		=>  'alias=\''.NFW::i()->db->escape($this->record['alias']).'\''
		);
		if ($this->record['id']) {
			$query['WHERE'] .= ' AND id<>'.$this->record['id'];
		}
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to validate alias', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}

		if (NFW::i()->db->num_rows($result)) {
			$errors['alias'] = 'Дублирование поля «'.$this->attributes['alias']['desc'].'» недопустимо.';
		}

		return $errors;
	}

	function actionAdmin() {
		$this->error_report_type = 'plain';

		if (isset($_GET['part']) && $_GET['part'] == 'list.js') {
			$records = $this->getRecords(array('filter' => array('allow_hidden' => true)));
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
	        	'media_form' => $CMedia->openSession(array('owner_class' => get_class($this), 'safe_filenames' => true, 'force_rename' => true)),
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
	        return $this->renderAction();
	    }

	    if (isset($_POST['part']) && $_POST['part'] == 'votelist') {
	    	$this->path_prefix = 'docs';
	    	NFW::i()->stop($this->renderAction(array(
	    		'data' => $_POST
	    	), 'votelist'));
	    }
	    elseif (isset($_POST['part']) && $_POST['part'] == 'make') {
	    	$results_txt = $_POST['results_txt'];
	    	$results_filename = $_POST['results_filename'] ? htmlspecialchars($_POST['results_filename']) : 'results.txt';

	    	if (isset($_POST['save_results']) && $_POST['save_results']) {
		    	if (!$fp = fopen(PROJECT_ROOT.'files/'.$this->record['alias'].'/'.$results_filename, 'w')) {
		    		$this->error('Unable to open results file', __FILE__, __LINE__);
		    		return false;
		    	}
		    	fwrite($fp, $results_txt);
		    	fclose($fp);

		    	NFW::i()->renderJSON(array('result' => 'success', 'url' => NFW::i()->absolute_path.'/files/'.$this->record['alias'].'/'.$results_filename));
	    	}
	    	elseif (isset($_POST['save_pack']) && $_POST['save_pack']) {
	    		$pack_filename = $_POST['pack_filename'] ? htmlspecialchars($_POST['pack_filename']) : $this->record['alias'].'-pack.zip';

	    		$zip = new ZipArchive();
	    		$result = $zip->open(PROJECT_ROOT.'files/'.$this->record['alias'].'/'.$pack_filename, ZIPARCHIVE::OVERWRITE | ZIPARCHIVE::CREATE);

	    		if (isset($_POST['attach_results_txt']) && $_POST['attach_results_txt']) {
	    			$zip->addFromString(iconv("UTF-8", 'cp866', $results_filename), $results_txt);
	    		}

	    		// Add works
	    		$competitions = isset($_POST['competitions']) && is_array($_POST['competitions']) ? $_POST['competitions'] : array();
	    		$CWorks = new works();
	    		list($release_works) = $CWorks->getRecords(array('filter' => array('release_only' => true, 'event_id' => $this->record['id'])));
	    		foreach ($release_works as $w) {
	    			if (!in_array($w['competition_id'], $competitions)) continue;

	    			$already_added = array();	// Check filenames duplicate
	    			foreach ($w['release_files'] as $a) {
	    				if ($a['mime_type'] == 'application/zip') {
	    					// Repack zip-archive
	    					$ezip = zip_open($a['fullpath']);
	    					while ($zip_entry = zip_read($ezip)) {
	    						if (zip_entry_open($ezip, $zip_entry, "r")) {
	    							$zip->addFromString(iconv("UTF-8", 'cp866', $w['competition_alias'].'/'.$w['title'].'/'.zip_entry_name($zip_entry)), zip_entry_read($zip_entry, zip_entry_filesize($zip_entry)));
	    							zip_entry_close($zip_entry);
	    						}
	    					}
	    				}
	    				else {
		    				$basename = in_array($a['basename'], $already_added) ? $a['id'].'_'.$a['basename'] : $a['basename'];
		    				$already_added[] = $a['basename'];
		    		 		$zip->addFile($a['fullpath'], iconv("UTF-8", 'cp866', $w['competition_alias'].'/'.$w['title'].'/'.$basename));
	    				}
	    			}
	    		}

	    		// Attach media
	    		if (isset($_POST['attach_media']) && $_POST['attach_media'] && !empty($this->record['attachments'])) {
	    			$media_info = array();
	    			foreach ($this->record['attachments'] as $a) {
	    				$zip->addFile($a['fullpath'], iconv("UTF-8", 'cp866', $a['basename']));
	    				if ($a['comment']) {
	    					$media_info[] = $a['basename'].' - '.$a['comment'];
	    				}
	    			}
	    			
	    			if (!empty($media_info)) {
	    				$zip->addFromString(iconv("UTF-8", 'cp866', 'media-info.txt'), implode("\n", $media_info));
	    			}
	    		}
	    		
	    		$zip->setArchiveComment(htmlspecialchars($this->record['title'])."\n".date('d.m.Y', $this->record['date_from']).'-'.date('d.m.Y', $this->record['date_to'])."\n".NFW::i()->absolute_path);
	    		$zip->close();
	    		NFW::i()->renderJSON(array('result' => 'success', 'url' => NFW::i()->absolute_path.'/files/'.$this->record['alias'].'/'.$pack_filename));
	    	}
	    	elseif (isset($_POST['refresh_results'])) {
			NFW::i()->setCookie('layout_type', $_POST['layout_type']);
			NFW::i()->setCookie('layout_platform_show', json_encode($_POST['layout_platform_show']));
			NFW::i()->renderJSON(array('result' => 'success', 'reload' => 'reload'));
		}
	    	else {
	    		$this->error('Wrong request', __FILE__, __LINE__);
	    	}
	    }

	   	// Save
	   	$this->formatAttributes($_POST);


	   	// Format `options`
	   	if (isset($_POST['update_record_options']) && $_POST['update_record_options']) {
		   	$values = array();
		   	foreach($this->options_attributes as $varname=>$a) {
			   	foreach ($_POST['options'][$varname] as $index=>$cur_val) {
			   		$values[$index][$varname] = $this->formatAttribute($cur_val, $a);
			   	}
		   	}
		   	$this->record['options'] = NFW::i()->serializeArray($values);
		}
		else {
		   	$this->record['options'] = NFW::i()->serializeArray($this->record['options']);
		}

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

	function actionUpdateManagers() {
		$this->error_report_type = (empty($_POST)) ? 'default' : 'active_form';

		if (!$this->load($_GET['record_id'])) return false;

		if (empty($_POST)) {
			NFW::i()->stop($this->renderAction());
		}

		NFW::i()->db->query('DELETE FROM '.NFW::i()->db->prefix.'events_managers WHERE event_id='.$this->record['id']) or error('Unable to delete old event managers', __FILE__, __LINE__, NFW::i()->db->error());
		if (isset($_POST['managers']) && is_array($_POST['managers'])) foreach ($_POST['managers'] as $a) {
			NFW::i()->db->query('INSERT INTO '.NFW::i()->db->prefix.'events_managers (user_id, event_id) VALUES ('.intval($a).','.$this->record['id'].')') or error('Unable to insert event managers', __FILE__, __LINE__, NFW::i()->db->error());
		}

		NFW::i()->renderJSON(array('result' => 'success'));
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

    	// Remove managers
    	NFW::i()->db->query('DELETE FROM '.NFW::i()->db->prefix.'events_managers WHERE event_id='.$this->record['id']) or error('Unable to delete event managers', __FILE__, __LINE__, NFW::i()->db->error());

   		$this->delete();
    	NFW::i()->stop();
    }
}