<?php
/***********************************************************************
  Copyright (C) 2009-2012 Andrew nyuk Marinov (aka.nyuk@gmail.com)
  $Id$  

   Модуль просмотра логов.
  
 ************************************************************************/

class view_logs extends logs {
	var $kinds = array();
	
	function __construct() {
		$this->lang = NFW::i()->getLang('logs');
		$this->kinds['Система'] = $this->lang['kinds'];
		
		// Load custom kinds from config
		// Define kinds for use in logs::write
		include (PROJECT_ROOT.'include/configs/logs_kinds.php');
		foreach($logs_kinds as $kind=>$a) {
			$this->lang['kinds'][$kind] = $this->kinds[$a['optgroup']][$kind] = $a['desc'];
		}
		
		return true;
	}
	
	/**
	 * Get array with logs
	 *
	 * @param array	  $options 		Options array:
	 * 								'filter'		// Filter array
	 * 								'kind'			// Logs with one kind or kind's array
	 * 								'posted_from'	// From timestamp
	 * 								'posted_to'		// To timestamp
	 * 								'poster'		// User ID or array with ID's
	 * 								'message'		// Logs message
	 * 								'kind'			// Logs kind
	 * 								'IP'			// Poster IP
	 * 								'free_filter'	// Неполное совпадение с фильтром прои поиске
	 * 								'IP'			// Poster IP
	 * 								'limit'			// SQL LIMIT
	 * 								'offset'		// SQL OFFSET
	 * 								'sort_reverse'	// Reverse sorting
	 *
	 * @return array(
	 * 			logs,				// Array with items
	 * 		   )
	 */
	private function fetch($options = array()) {
		$filter = (isset($options['filter'])) ? $options['filter'] : array();
	
		// Setup WHERE from filter
		$where = array();
		 
		if (isset($filter['posted_from']))
			$where[] = 'l.posted > '.intval($filter['posted_from']);
		 
		if (isset($filter['posted_to']))
			$where[] = 'l.posted < '.intval($filter['posted_to']);
	
		if (isset($filter['poster']) && $filter['poster']) {
			if (is_array($filter['poster']))
				$where[] = 'l.poster IN ('.join(',',$filter['poster']).')';
			else
				$where[] = 'l.poster = '.intval($filter['poster']);
		}
	
		if (isset($filter['message']))
			$where[] = 'l.message = \''.$filter['message'].'\'';
		 
		if (isset($filter['kind']) && $filter['kind']) {
			if (is_array($filter['kind']))
				$where[] = 'l.kind IN ('.join(',',$filter['kind']).')';
			else
				$where[] = 'l.kind= '.intval($filter['kind']);
		}
	
		if (isset($filter['ip']))
			$where[] = 'l.ip = \''.$filter['ip'].'\'';
	
		$where_str = (count($where)) ? ' WHERE '.join(' AND ', $where) : '';
	
		// Generate not strong "WHERE"
		if (isset($options['free_filter']) && is_array($options['free_filter'])) {
			$filter = $options['free_filter'];
			$foo = array();
			if (isset($options['free_filter']['ip'])) {
				$foo[] = 'l.ip LIKE \'%'.NFW::i()->db->escape($filter['ip']).'%\'';
			}
	
			if (!empty($foo)) {
				if ($where_str)
					$where_str .= ' AND ('.join(' OR ', $foo).')';
				else
					$where_str = ' WHERE '.join(' OR ', $foo);
			}
		}
	
		// Count filtered values
		$sql = 'SELECT COUNT(*) FROM '.NFW::i()->db->prefix.'logs AS l'.$where_str;
		if (!$result = NFW::i()->db->query($sql)) {
			self::error('Unable to count logs', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		list($num_filtered) = NFW::i()->db->fetch_row($result);
		if (!$num_filtered) {
			return array(array(), 0);
		}
	
		// ----------------
		// Fetching records
		// ----------------
	
		$sql_limit = (isset($options['limit']) && $options['limit']) ? ' LIMIT '.intval($options['limit']) : '';
		$sql_offset = (isset($options['offset']) && $options['offset']) ? ' OFFSET '.intval($options['offset']) : '';
	
		$sql_order_by = ' ORDER BY l.posted';
		if (isset($options['sort_reverse']) && $options['sort_reverse']) {
			$sql_order_by .= ' DESC';
		}
	
		$sql = 'SELECT l.* FROM '.NFW::i()->db->prefix.'logs AS l'.$where_str.$sql_order_by.$sql_limit.$sql_offset;
		if (!$result = NFW::i()->db->query($sql)) {
			self::error('Unable to fetch logs', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) return false;
	
		while ($l = NFW::i()->db->fetch_assoc($result)) {
			$l['browser'] = self::get_browser();
			$logs[] = $l;
		}
	
		return array($logs, $num_filtered);
	}
		
	private function getRecords($options = array()) {
		if (!$result = $this->fetch($options)) return false;
		list($logs, $num_filtered) = $result;
		
		$parent_attributes = (isset($options['additional_attributes'])) ? $options['additional_attributes'] : array(); 
		$skip_parent_attributes = (isset($options['skip_attributes'])) ? $options['skip_attributes'] : array();
		$has_additional_logs = false;
		
		foreach($logs as &$log) {
        	if (isset($this->lang['kinds'][$log['kind']])) {
	        	$log['message_full'] = ($log['message']) ? $this->lang['kinds'][$log['kind']].' ('.$log['message'].')' : $this->lang['kinds'][$log['kind']];
	        	$log['kind_desc'] = $this->lang['kinds'][$log['kind']];
        	}
        	else {
        		$log['message_full'] = $log['kind_desc'] = '';
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
	
    function actionAdmin() {
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
    	
		// Поскольку таблицы `users` нет, собираем пользователей из логов
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
    
    function actionExport() {
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