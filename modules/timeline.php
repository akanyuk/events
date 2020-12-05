<?php
/***********************************************************************
  Copyright (C) 2009-2017 Andrey nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  
  
 ************************************************************************/
class timeline extends active_record {
	function __construct($record_id = false) {
		$result = parent::__construct($record_id);

		// Prune old records
		NFW::i()->db->query_build(array('DELETE' => $this->db_table, 'WHERE' => 'date_from < '.time()));
		
		return $result;
	}
		
	function getRecords($options = array()) {
		if (!$result = NFW::i()->db->query_build(array('SELECT' => '*', 'FROM' => $this->db_table, 'ORDER BY' => 'date_from'))) { 
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
		if (empty($_POST)) {
			return $this->renderAction(array(
				'records' => $this->getRecords()
			));
		}
		
		$this->error_report_type = 'active_form';
		
		// Prune all
		NFW::i()->db->query_build(array('DELETE' => $this->db_table));
		
		foreach ($_POST['content'] as $key=>$content) {
			if (!$content) continue;
			
			$query = array(
				'INSERT'	=> '`content`, `date_from`',
				'INTO'		=> $this->db_table,
				'VALUES'	=> '\''.NFW::i()->db->escape($content).'\', '.intval($_POST['date_from'][$key])
			);
			if (!NFW::i()->db->query_build($query)) {
				$this->error('Unable to insert new timeline', __FILE__, __LINE__, NFW::i()->db->error());
				return false;
			}
		}
		
		NFW::i()->renderJSON(array('result' => 'success'));
   }
}