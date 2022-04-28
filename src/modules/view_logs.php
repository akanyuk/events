<?php
/***********************************************************************
  Copyright (C) 2009-2016 Andrey nyuk Marinow (aka.nyuk@gmail.com)
  $Id$  

   Модуль просмотра логов.
  
 ************************************************************************/

class view_logs extends logs {
	static $action_aliases = array(
		'admin' => array(
			array('module' => 'view_logs', 'action' => 'export'),
		)
	);
		
	var $kinds = array();
	
	function __construct() {
		$this->lang = NFW::i()->getLang('logs');
		$this->kinds['Система'] = $this->lang['kinds'];
		
		// Define kinds for use in logs::write
		if (file_exists(PROJECT_ROOT.'include/configs/logs_kinds.php')) {
			include (PROJECT_ROOT.'include/configs/logs_kinds.php');
			foreach($logs_kinds as $kind=>$a) {
				$this->lang['kinds'][$kind] = $this->kinds[$a['optgroup']][$kind] = $a['desc'];
			}
		}
				
		return true;
	}
	
	private function getRecords($options = array()) {
		if (!$result = self::fetch($options)) return false;
		list($logs, $num_filtered) = $result;
		
		$parent_attributes = (isset($options['additional_attributes'])) ? $options['additional_attributes'] : array(); 
		$skip_parent_attributes = (isset($options['skip_attributes'])) ? $options['skip_attributes'] : array();
		$has_additional_logs = false;
		
		foreach($logs as &$log) {
        	if (isset($this->lang['kinds'][$log['kind']])) {
	        	$log['message_full'] = $log['message'] ? $this->lang['kinds'][$log['kind']].' ('.$log['message'].')' : $this->lang['kinds'][$log['kind']];
	        	$log['kind_desc'] = $this->lang['kinds'][$log['kind']];
        	}
        	else {
        		$log['message_full'] = $log['message'];
        		$log['kind_desc'] = '';
        	}
        	
        	if (!empty($parent_attributes)) {
	        	$additional = NFW::i()->unserializeArray($log['additional']);
	        	$ad = array();
	        	foreach ($additional as $varname=>$a) {
	        		if (in_array($varname, $skip_parent_attributes)) continue;
	        		
	        		$a['old'] = (isset($a['old'])) ? $a['old'] : null;
	        		$a['new'] = (isset($a['new'])) ? $a['new'] : null;
	        		
	        		if (isset($parent_attributes[$varname])) {
		        		if ($parent_attributes[$varname]['type'] == 'bool') {
		        			$a['old'] = ($a['old']) ? 'Да' : 'Нет';
		        			$a['new'] = ($a['new']) ? 'Да' : 'Нет';
		        		}
		        		elseif ($parent_attributes[$varname]['type'] == 'date') {
		        			$a['old'] = ($a['old']) ? date('d.m.Y', $a['old']) : '-';
		        			$a['new'] = ($a['new']) ? date('d.m.Y', $a['new']) : '-';
		        		}
		        		elseif ($parent_attributes[$varname]['type'] == 'select') {
		        			foreach($parent_attributes[$varname]['options'] as $o) {
		        				if (!is_array($o) || !isset($o['id']) || !isset($o['desc'])) continue;
		        				
		        				if ($o['id'] == $a['old']) $a['old'] = $o['desc'];
		        				if ($o['id'] == $a['new']) $a['new'] = $o['desc'];
		        			}
		        		}
	        		}
	        	
	        		$a['desc'] = (isset($parent_attributes[$varname]['desc'])) ? $parent_attributes[$varname]['desc'] : $varname;
	        	
	        		$ad[] = $a;
	        		$has_additional_logs = true;
	        	}
	        	$log['additional'] = $ad;
        	}
		}
		
		return array($logs, $num_filtered, $has_additional_logs);
	}
	
    function actionAdminAdmin() {
    	if (isset($_GET['part']) && $_GET['part'] == 'list.js') {
    		$this->error_report_type = 'silent';
    		
    		// Counting elements
    		if (!$result = NFW::i()->db->query('SELECT COUNT(*) FROM '.NFW::i()->db->prefix.'logs')) {
    			$this->error('Unable to count logs records', __FILE__, __LINE__, NFW::i()->db->error());
    			return false;
    		}
    		list($iTotalRecords) = NFW::i()->db->fetch_row($result);
    		
    		$options['filter']['posted_from'] = intval($_POST['posted_from']);
    		$options['filter']['posted_to'] = intval($_POST['posted_to']) + 86399;
    		$options['filter']['poster'] = $_POST['poster'];
    		$options['filter']['kind'] = $_POST['kind'];
    		$options['limit'] = $_POST['iDisplayLength'];
    		$options['offset'] = $_POST['iDisplayStart'];
    		$options['sort_reverse'] = (isset($_POST['sSortDir_0']) && $_POST['sSortDir_0'] == 'desc') ? 1 : 0;
    		
    		list($logs, $iTotalDisplayRecords) = $this->getRecords($options);
    		
    		
    		NFW::i()->stop($this->renderAction(array(
    			'logs' => $logs,
    			'iTotalRecords' => $iTotalRecords,
    			'iTotalDisplayRecords' => $iTotalDisplayRecords
    		), '_admin_list.js'));    		
    	}
    	
		// Собираем пользователей из логов
    	$users = array();
    	$query = array(
    		'SELECT'	=> 'poster AS id, poster_username',
    		'FROM'		=> 'logs',
    		'WHERE'		=> 'poster <>0 AND poster_username IS NOT NULL AND poster_username <> ""',
    		'GROUP BY' 	=> 'poster',
    		'ORDER BY'	=> 'poster_username'
    	);
    	if (!$result = NFW::i()->db->query_build($query)) {
    		$this->error('Unable to fetch users', __FILE__, __LINE__, NFW::i()->db->error());
    		return false;
    	}
    	while ($user = NFW::i()->db->fetch_assoc($result)) {
    		$users[] = $user;
    	}
    	 
    	return $this->renderAction(array(
    		'users' => $users,
    	));
    }
    
    function actionAdminExport() {
    	$this->error_report_type = 'alert';
    	
    	list($logs) = $this->getRecords(
    		array('filter' => array(
	    		'posted_from' => intval($_POST['posted_from']),
	    		'posted_to' => intval($_POST['posted_to']) + 86399,
    			'poster' => $_POST['poster'],
	    		'kind' => $_POST['kind'],
    		),
    		'sort_reverse' => 1
    	));

    	
		$result = $this->renderAction(array(
	    	'posted_from' => intval($_POST['posted_from']),
	    	'posted_to' => intval($_POST['posted_to']),
			'logs' => $logs,
    	), 'export.doc');	

		header('Content-type: application/force-download');		
		header('Content-Length: '.strlen($result));
		header('Content-Disposition: attachment; filename="logs-export.doc"');
		header('Content-Transfer-Encoding: binary');
		header('Connection: close');
    	NFW::i()->stop($result);
    }    
}