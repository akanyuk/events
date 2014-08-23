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
	
		// Try to load language from GET or COOKIE
		if (isset($_GET['lang']) && in_array($_GET['lang'], array('Russian', 'English'))) {
			$this->user['language'] = $stored_language = $_GET['lang'];
			$this->setCookie('lang', $stored_language, time() + 60*60*24*30);
			$_SERVER['REQUEST_URI'] = preg_replace('/(&?lang='.$_GET['lang'].')/', '', $_SERVER['REQUEST_URI']);
			$_SERVER['REQUEST_URI'] = preg_replace('/(\?$)/', '', $_SERVER['REQUEST_URI']);
			unset($_GET['lang']);
		}
		elseif (isset($_COOKIE['lang']) && in_array($_COOKIE['lang'], array('Russian', 'English'))) {
			$this->user['language'] = $stored_language =  $_COOKIE['lang'];
		}
		else {
			$stored_language = false;
			$this->user['language'] = $this->default_user['language'];
		}
		$this->assign('lang_main', $this->getLang('main'));
		$this->lang = $this->getLang('nfw_main');
		
		parent::__construct($init_cfg);
		
		// Reload language if cookies language != user language
		if ($this->user['is_guest'] && $stored_language && $this->user['language'] != $stored_language) {
			$this->user['language'] = $stored_language;
			$this->lang = $this->getLang('nfw_main', true);
			$this->assign('lang_main', $this->getLang('main', true));
		}
		
		// This user is manager of next events...
		$this->user['manager_of_events'] = array();
		$query = NFW::i()->checkPermissions('events', 'update_managers') ? array('SELECT' => 'id AS event_id', 'FROM' => 'events') : array('SELECT' => 'event_id', 'FROM' => 'events_managers', 'WHERE' => 'user_id='.$this->user['id']);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->stop('Unable to fetch managed events');
		}
		while ($a = NFW::i()->db->fetch_assoc($result)) {
			$this->user['manager_of_events'][] = $a['event_id'];
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
		
	// Authenificate user if possible via activeForm
	function login($action = '') {
		$classname = (isset(NFW::i()->cfg['module_map']['users'])) ? NFW::i()->cfg['module_map']['users'] : 'users';
		$CUsers = new $classname ();
	
		// Logout action
		if ($action == 'logout' || isset($_GET['action']) && $_GET['action'] == 'logout') {
			$CUsers->cookie_logout();
	
			// Делаем редирект, чтобы куки прижились
			// Send no-cache headers
			header('Expires: Thu, 21 Jul 1977 07:30:00 GMT');	// When yours truly first set eyes on this world! :)
			header('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT');
			header('Cache-Control: post-check=0, pre-check=0', false);
			header('Pragma: no-cache');		// For HTTP/1.0 compability
			header('Content-type: text/html; charset=utf-8');
			NFW::i()->stop('<html><head><meta http-equiv="refresh" content="0;URL='.$this->absolute_path.'" /></head><body></body></html>');
		}
			
		// Login form action
		if ($action == 'form' || isset($_GET['action']) && $_GET['action'] == 'login') {
			$this->display('login.tpl');
		}
			
		// Authentificate send
		if (isset($_POST['login']) && isset($_POST['username']) && isset($_POST['password'])) {
			$form_username = trim($_POST['username']);
			$form_password = trim($_POST['password']);
			unset($_POST['login'], $_POST['username'], $_POST['password']);
	
			if (!$account = $CUsers->authentificate($form_username, $form_password)) {
				if (isset($_COOKIE['lang']) && in_array($_COOKIE['lang'], array('Russian', 'English')) && $_COOKIE['lang'] != $this->user['language']) {
					$this->user['language'] = $_COOKIE['lang'];
					// Reload lang file
					$this->lang = $this->getLang('nfw_main', true);
				}
	
				$this->renderJSON(array('result' => 'error', 'message' => $this->lang['Errors']['Wrong_auth']));
			}
	
			$this->user = $account;
			$this->user['is_guest'] = false;
	
			$CUsers->cookie_update($this->user);
			logs::write(logs::KIND_LOGIN);
			
			$this->renderJSON(array('result' => 'succes'));
		}
	
		// Cookie login
		if ($account = $CUsers->cookie_login()) {
			$this->user = $account;
			$this->user['is_guest'] = false;
		}
	
		return;
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
	 
	function sendNotify($event, $data = array()) {
		if (!isset(NFW::i()->cfg['notify_emails']) || !is_array(NFW::i()->cfg['notify_emails'])) return;
		 
		foreach (NFW::i()->cfg['notify_emails'] as $email) {
			email::sendFromTemplate($email, $event, array('data' => $data));
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