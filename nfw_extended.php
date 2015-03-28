<?php
define('NFW_CLASSNAME', 'NFW_EXTENDED');

class NFW_EXTENDED extends NFW {
	var $actual_date = false;
	
	function __construct($init_cfg = null) {
		// Глобально точность операций
		bcscale (2);
		
		// Actual date (i.e. for debugging)
		$this->actual_date = time();
		if (isset($_COOKIE['DBG_ACTUAL_DATE']) && $result = strtotime($_COOKIE['DBG_ACTUAL_DATE'])) {
			$this->actual_date = $result;
		}
		
		// Define kinds for use in logs::write
		require (PROJECT_ROOT.'include/configs/logs_kinds.php');
		foreach($logs_kinds as $kind=>$a) {
			if (isset($a['define'])) {
				define($a['define'], $kind);
			}
		}
	
		parent::__construct($init_cfg);
		
		// This user is manager of following events...
		$this->user['manager_of_events'] = array();
		if (!$this->user['is_guest']) {
			$query = NFW::i()->checkPermissions('events', 'update_managers') ? array('SELECT' => 'id AS event_id', 'FROM' => 'events') : array('SELECT' => 'event_id', 'FROM' => 'events_managers', 'WHERE' => 'user_id='.$this->user['id']);
			if (!$result = NFW::i()->db->query_build($query)) {
				$this->stop('Unable to fetch managed events');
			}
			while ($a = NFW::i()->db->fetch_assoc($result)) {
				$this->user['manager_of_events'][] = $a['event_id'];
			}
		}
	}
		
	function checkPermissions($module = 1, $action = '', $additional = false) {
		if (parent::checkPermissions($module, $action, $additional)) return true;

		// --- special permissions for event's managers ---
		if (!empty(NFW::i()->user['manager_of_events'])) {
			$always_manage = array(
				'events' => array('admin'),
				'competitions' => array('admin'),
				'works' => array('admin'),
				'vote' => array('admin'),
				'timeline' => array('admin'),
				'profile' => array('admin'),
				'admin' => array(''),
			);
			if (isset($always_manage[$module]) && in_array($action, $always_manage[$module])) return true;
			 
			if ($module == 'events') {
				if ($action == 'update' && isset($_GET['record_id']) && in_array($_GET['record_id'], NFW::i()->user['manager_of_events'])) return true;
				if (($action == 'media_upload' || $action == 'media_modify') && in_array($additional, NFW::i()->user['manager_of_events'])) return true;
				return false;
			}
			
			if ($module == 'competitions') {
				if (empty($_POST)) return true;
				
				// Check in module
				if ($action == 'update' && isset($_GET['part']) && $_GET['part'] == 'update_pos') return true;
				
				if ($action == 'insert') {
					return in_array($_POST['event_id'], NFW::i()->user['manager_of_events']) ? true : false;
				}
				 
				if ($action == 'update') {
					if (isset($_POST['event_id']) && !in_array($_POST['event_id'], NFW::i()->user['manager_of_events'])) return false;
					
					$Compo = new competitions($_GET['record_id']);
					return in_array($Compo->record['event_id'], NFW::i()->user['manager_of_events']) ? true : false;
				}
				
				return false;
			}
			
			if ($module == 'works') {
				if (empty($_POST)) return true;
				
				// Check in module
				if ($action == 'update' && isset($_GET['part']) && $_GET['part'] == 'update_pos') return true;
				
				if ($action == 'insert') {
					$Compo = new competitions($_POST['competition_id']);
					return $Compo->record['id'] && in_array($Compo->record['event_id'], NFW::i()->user['manager_of_events']) ? true : false;
				}
				
				if ($action == 'update' || $action == 'media_manage') {
					$CWorks = new works($_GET['record_id']);
					return $CWorks->record['id'] && in_array($CWorks->record['event_id'], NFW::i()->user['manager_of_events']) ? true : false;
				}
				
				if ($action == 'media_get' || $action == 'media_upload' || $action == 'media_modify') {
					$CWorks = new works($additional);
					return $CWorks->record['id'] && in_array($CWorks->record['event_id'], NFW::i()->user['manager_of_events']) ? true : false;
				}
				
				return false;
			}
			
			if ($module == 'vote') {
				if (empty($_POST)) return true;
				
				if (isset($_GET['part']) && $_GET['part'] == 'list.js' && in_array($action, array('manage_votekeys', 'manage_votes', 'manage_results'))) return true;

				if ($action == 'manage_votekeys' && isset($_GET['part']) && $_GET['part'] == 'add-votekeys') {
					return in_array($_POST['event_id'], NFW::i()->user['manager_of_events']) ? true : false;
				}
				
				if ($action == 'manage_votes' && isset($_GET['part']) && $_GET['part'] == 'add-vote') {
					return in_array($_GET['event_id'], NFW::i()->user['manager_of_events']) ? true : false;
				}
				
				// Check in module
				if ($action == 'manage_results' && isset($_GET['part']) && $_GET['part'] == 'save-results') return true;
				
				return false;
			}
		}
		
		
		// --- special permissions for works authors  ---
		
		// Any operations with `works` session files for authors
		if ($module == 'works' && in_array($action, array('media_get', 'media_upload', 'media_modify')) && $additional == 0) return true;

		// Fetching works
		if ($module == 'works' && $action == 'media_get') {
			$CWorks = new works($additional);
			if (!$CWorks->record['id']) return false;

			// Always return work to author
			if ($CWorks->record['posted_by'] == NFW::i()->user['id']) return true;
		}
		
		return false;
	}
		
	function renderNews($options = array()) {
		if (isset($options['id'])) {
			$CNews = new news($options['id']);
			if (!$CNews->record['id']) return false;
			
			$CNews->path_prefix = 'main';
			
			return array(
				$CNews->record['title'],
				$CNews->renderAction(array('record' => $CNews->record), $options['template'], 'news'),
				$CNews->record['posted']
			);
		}
		else {
			$fetch_options = array(
				'load_attachments' => isset($options['load_attachments']) ? $options['load_attachments'] : false,
				'posted_from' => isset($options['posted_from']) ? $options['posted_from'] : false,
				'posted_to' => isset($options['posted_to']) ? $options['posted_to'] : false,
				'records_on_page' => isset($options['records_on_page']) ? $options['records_on_page'] : 10,
				'page' => isset($_GET['p']) ? intval($_GET['p']) : 1
			);
			
			$CNews = new news();
			if (!$news = $CNews->getRecords($fetch_options)) return false;
	
			// Generate paging links
			$paging_links = $CNews->num_pages > 1 ? NFW::i()->paginate($CNews->num_pages, $CNews->cur_page, NFW::i()->absolute_path.'/news.html', ' ') : '';
				
			// Render page content
			$CNews->path_prefix = 'main';
			return $CNews->renderAction(array(
				'news' => $news, 
				'paging_links' => $paging_links,
			), $options['template']);
		}
	}
	
	function paginate($num_pages, $cur_page, $link_to, $separator = ", ") {
	    $pages = array();
	    $link_to_all = false;
	
	    $first_letter = (strstr($link_to, '?')) ? '&' : '?';
	    
	    if ($cur_page == -1) {
	        $cur_page = 1;
	        $link_to_all = true;
	    }
	
	    if ($num_pages <= 1)
	        $pages = array('<li class="active"><span>1</span></li>');
	    else {
	        if ($cur_page > 3) {
	            $pages[] = '<li><a href="'.$link_to.$first_letter.'p=1">1</a></li>';
	
	            if ($cur_page != 4)
	                $pages[] = '<li class="disabled"><span>...</span></li>';
	        }
	
	        // Don't ask me how the following works. It just does, OK? :-)
	        for ($current = $cur_page - 2, $stop = $cur_page + 3; $current < $stop; ++$current) {
	            if ($current < 1 || $current > $num_pages)
	                continue;
	            else if ($current != $cur_page || $link_to_all)
	                $pages[] = '<li><a href="'.$link_to.$first_letter.'p='.$current.'">'.$current.'</a></li>';
	            else
	                $pages[] = '<li class="active"><span>'.$current.'</span></li>';
	        }
	
	        if ($cur_page <= ($num_pages-3)) {
	            if ($cur_page != ($num_pages-3))
	                $pages[] = '<li class="disabled"><span>...</span></li>';
	
	            $pages[] = '<li><a href="'.$link_to.$first_letter.'p='.$num_pages.'">'.$num_pages.'</a></li>';
	        }
	    }
	
	    return '<ul class="pagination">'.implode($separator, $pages).'</ul>';
	}	
    
	function formatTimeDelta($time) {
		$lang_main = NFW::i()->getLang('main');
		
		$left = $time - NFW::i()->actual_date;
		if (intval($left/86400)) {
			return intval($left/86400).' '.$lang_main['days'];
		}
		elseif (intval($left/3600)) {
			return intval($left/3600).' '.$lang_main['hours'];
		}
		else {
			return intval($left/60).' '.$lang_main['minutes'];
		}
	}
	 
	function sendNotify($event, $event_id, $data = array()) {
		foreach (NFW::i()->cfg['notify_emails'] as $email) {
			email::sendFromTemplate($email, $event, array('data' => $data));
		}
		
		$query = array(
			'SELECT' => 'u.email', 
			'FROM' => 'events_managers AS e',
			'JOINS' => array(
				array(
					'INNER JOIN'=> 'users AS u',
					'ON'		=> 'e.user_id=u.id'
				),					
			), 
			'WHERE' => 'e.event_id='.$event_id
		);
		if (!$result = NFW::i()->db->query_build($query)) return false;
		while ($u = NFW::i()->db->fetch_assoc($result)) {
			email::sendFromTemplate($u['email'], $event, array('data' => $data));
		}
	}
	
	function serializeArray($array) {
		return base64_encode(serialize($array));
	}
	
	function unserializeArray($string) {
		$result = unserialize(base64_decode($string));
		if (!$result) $result = array();
		 
		return $result;
	}
	
    function stop($message = '', $output = null) {
    	if ($message === 404) {
    		$CElements = new elements('main-menu', true);
    		NFW::i()->setUI('bootstrap');
			header("HTTP/1.0 404 Not Found");
			NFW::i()->assign('page', array('main-menu' => $CElements->record['content'], 'path' => '', 'title' => 'Запрашиваемя страница не найдена', 'content' => '<div class="alert alert-danger">Запрашиваемя страница не найдена.</div>'));
			NFW::i()->display('main.tpl');
		}
		elseif ($message === 'inactive') {
			$CElements = new elements('main-menu', true);
			NFW::i()->setUI('bootstrap');
			NFW::i()->assign('page', array('main-menu' => $CElements->record['content'], 'path' => '', 'title' => 'Страница временно недоступна', 'content' => '<div class="alert alert-danger">Страница временно недоступна.</div>'));
			NFW::i()->display('main.tpl');
		}
    	else if($output === 'error-page') {
    		$CElements = new elements('main-menu', true);
    		NFW::i()->setUI('bootstrap');
    		NFW::i()->assign('page', array('main-menu' => $CElements->record['content'], 'path' => '', 'title' => 'Ошибка', 'content' => '<div class="alert alert-danger">'.$message.'</div>'));
    		NFW::i()->display('main.tpl');
    	}
    	 
    	parent::stop($message, $output);
    }
}