<?php
if (!NFW::i()->user['is_guest'] && (!isset($_GET['action']) || $_GET['action'] != 'update_profile')) header('Location: '.NFW::i()->absolute_path);
if (NFW::i()->user['is_guest'] && isset($_GET['action']) && $_GET['action'] == 'update_profile') header('Location: '.NFW::i()->absolute_path);

NFW::i()->setUI('bootstrap');

$lang_main = NFW::i()->getLang('main');

$CPages = new pages();
if (!$page = $CPages->loadPage()) {
	NFW::i()->stop(404);
}
elseif (!$page['is_active']) {
	NFW::i()->stop('inactive');
}

$CUsers = new users_register();

switch(isset($_GET['action']) ? $_GET['action'] : null) {
	case 'update_profile':
		if (NFW::i()->user['is_guest']) header('Location: '.NFW::i()->absolute_path);
		
		if (empty($_POST)) {
			// Activation form
			$CPages->path_prefix = 'main';
			$page['content'] = $CPages->renderAction(array(
				'lang_main' => $lang_main
			), 'update_profile');
				
			$page['title'] = $lang_main['cabinet']['edit profile'];
				
			NFW::i()->assign('page', $page);
			NFW::i()->display('main.tpl');
		}
		
		$errors = $CUsers->update_profile($_POST);
		if (!empty($errors)) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}
		else {
			NFW::i()->renderJSON(array('result' => 'success', 'is_updated' => true));
		}
		break;
	case 'restore_password':
		if (!NFW::i()->user['is_guest']) header('Location: '.NFW::i()->absolute_path);
		
		if (empty($_POST)) {
			$CPages->path_prefix = 'main';
			$page['content'] = $CPages->renderAction(array(
				'lang_main' => $lang_main
			), 'restore_password');
				
			$page['title'] = $lang_main['register']['restore password'];
			
			NFW::i()->assign('page', $page);
			NFW::i()->display('main.tpl');
		}
		
		$errors = $CUsers->restore_password($_POST);
		if (!empty($errors)) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}
		else {
			NFW::i()->renderJSON(array(
				'result' => 'success',
				'message' => $lang_main['register']['restore message'],
			));
		}
		
		break;
	case 'activate':
		if (!NFW::i()->user['is_guest']) header('Location: '.NFW::i()->absolute_path);
		
		if (!$user = $CUsers->find_activation(isset($_GET['activate_key']) ? $_GET['activate_key'] : null)) {
			NFW::i()->stop($lang_main['register']['wrong key'], 'error-page');
		}
		
		if (empty($_POST)) {
			// Activation form
			$CPages->path_prefix = 'main';
			$page['content'] = $CPages->renderAction(array(
				'user' => $user,
				'lang_main' => $lang_main
			), 'activate');
			
			$page['title'] = $lang_main['register']['activation'];
			
			NFW::i()->assign('page', $page);
			NFW::i()->display('main.tpl');
		}
		
		$errors = $CUsers->activate($user, $_POST);
		if (!empty($errors) || $CUsers->error) {
			if ($CUsers->error) {
				$errors['general'] = $CUsers->last_msg;
			}
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}
		
		if ($account = $CUsers->authentificate($user['username'], $_POST['password'])) {
			$CUsers->cookie_update($account);
		}
		
		NFW::i()->renderJSON(array('result' => 'success'));
		break;
	case 'send':
		$errors = $CUsers->register($_POST);
		if (!empty($errors)) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}
		else {
			NFW::i()->renderJSON(array(
				'result' => 'success',
				'message' => $lang_main['register']['complete desc'],
			));
		}
		break;
	default:
		if (!NFW::i()->user['is_guest']) header('Location: '.NFW::i()->absolute_path);
		
		// Registration form
		$CPages->path_prefix = 'main';
		$page['content'] .= $CPages->renderAction(array(
			'attributes' => $CUsers->attributes,
			'lang_main'=>$lang_main
		), 'register');
		
		NFW::i()->assign('page', $page);
		NFW::i()->display('main.tpl');
}




class users_register extends users {
	const UNVERIFIED_GROUP = 4;
	const USERS_GROUP_ID = 3;
	
	var $attributes = array(
		'username' => array('desc' => 'Username', 'type' => 'str', 'required' => true, 'unique' => true, 'minlength' => 2, 'maxlength' => 32),
		'email' => array('desc' => 'E-mail', 'type' => 'email', 'required' => true, 'unique' => true),
		'realname' => array('desc' => 'Realname', 'type' => 'str', 'minlength' => 2, 'maxlength' => 40),
		'language'	=> array('desc' => 'Language', 'type' => 'select', 'options' => array(
			'Russian', 'English'
		)),
		'city' => array('desc' => 'City', 'type' => 'str', 'minlength' => 2, 'maxlength' => 85),
		'captcha' => array('desc' => 'Captcha', 'type' => 'captcha')
	);

	function __construct($record_id = false) {
		$result = parent::__construct($record_id);
			
		$this->db_table = 'users';
		
		// Multilanguage support
		$lang_main = NFW::i()->getLang('main');
		foreach ($this->attributes as $key=>&$a) {
			if (isset($lang_main['register'][$key])) {
				$a['desc'] = $lang_main['register'][$key];
			}
		}
			
		return $result;
	}
	
	function register($fields) {
		// Clean old unverified registrators - delete older than 72 hours
		$query = array(
			'DELETE'	=> 'users',
			'WHERE'		=> 'group_id='.self::UNVERIFIED_GROUP.' AND registered < '.(time() - 259200)
		);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to delete old unverified registrators.', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
	
		$this->formatAttributes($fields);
		$this->record['password'] = users::random_key(8, true);
		$this->record['group_id'] = self::UNVERIFIED_GROUP;
		$errors = $this->validate('update');
	
		if (!empty($errors)) return $errors;
	
		$this->save();
		 
		// Create e-mail activation
		$activate_key = users::random_key(8, true);
		$query = array(
			'UPDATE'	=> 'users',
			'SET'		=> 'activate_key=\''.$activate_key.'\'',
			'WHERE'		=> 'id='.$this->record['id']
		);
		if (!NFW::i()->db->query_build($query)) {
			$this->error('Unable to update user', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
			
		email::sendFromTemplate($this->record['email'], 'register_activate', array(
			'username' => $this->record['username'],
			'activation_url' => NFW::i()->absolute_path.'/register.html?action=activate&activate_key='.$activate_key,
		));
	
		return array();
	}
	
	public function find_activation($activate_key) {
		$query = array(
			'SELECT'	=> '*',
			'FROM'		=> 'users',
			'WHERE'		=> 'activate_key=\''.NFW::i()->db->escape($activate_key).'\''
		);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to fetch activation.', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		if (!NFW::i()->db->num_rows($result)) {
			return false;
		}
	
		$record = NFW::i()->db->fetch_assoc($result);
		 
		return $record;
	}
	 
	function activate($user, $fields) {
		$this->record['password'] = $fields['password'];
		$this->record['password2'] = $fields['password2'];
		$errors = $this->validate('update_password');
		if (!empty($errors)) return $errors;
	
		$query = array(
			'UPDATE'	=> 'users',
			'SET'		=> 'group_id='.self::USERS_GROUP_ID.', password=\''.users::hash($this->record['password'], $user['salt']).'\', activate_key=NULL',
			'WHERE'		=> 'id='.$user['id']
		);
		if (!NFW::i()->db->query_build($query)) {
			$this->error('Unable to activate user',__FILE__, __LINE__,  NFW::i()->db->error());
			return false;
		}
		 
		return array();
	}	
	
	function restore_password($fields) {
		$Module = new pages();
		$Module->attributes = array(
			'captcha' => array('type' => 'captcha'),
			'request_email' => array('type' => 'email', 'desc' => 'E-mail', 'required'=>true),
		);
		$Module->formatAttributes($_POST);
		$errors = $Module->validate();
		if (!empty($errors)) return $errors;
		
		// Fetch user matching $email
		$query = array(
			'SELECT'	=> '*',
			'FROM'		=> 'users',
			'WHERE'		=> 'email=\''.NFW::i()->db->escape($fields['request_email']).'\''
		);
		if (!$result = NFW::i()->db->query_build($query)) {
			$this->error('Unable to search user\'s account',__FILE__, __LINE__,  NFW::i()->db->error());
			return false;
		}
		if (NFW::i()->db->num_rows($result)) {
			$account = NFW::i()->db->fetch_assoc($result);
		
			// Generate a new password activation key
			$activate_key = users::random_key(8, true);
			if (!NFW::i()->db->query_build(array('UPDATE' => 'users', 'SET' => 'activate_key=\''.$activate_key.'\'', 'WHERE' => 'id='.$account['id']))) {
				$this->error('Restore password system error',__FILE__, __LINE__,  NFW::i()->db->error());
				return false;
			}
		
			// Send e-mail
			if ($Module->is_valid_email($account['email'])) {
				email::sendFromTemplate($account['email'], 'restore_password', array('activation_url' => NFW::i()->absolute_path.'/register.html?action=activate&activate_key='.$activate_key));
			}
		}		
	}
	
	function update_profile($fields) {
		$update = array();
		$this->reload(NFW::i()->user['id']);
		unset($this->attributes['captcha']);
		
		if ($fields['realname'] != NFW::i()->user['realname']) {
			$this->record['realname'] = $fields['realname'];
			$update[] = 'realname=\''.NFW::i()->db->escape($this->record['realname']).'\'';
		}
		
		if ($fields['language'] != NFW::i()->user['language']) {
			$this->record['language'] = $fields['language'];
			$update[] = 'language=\''.NFW::i()->db->escape($this->record['language']).'\'';
		}

		if ($fields['country'] != NFW::i()->user['country']) {
			$this->record['country'] = $fields['country'];
			$update[] = 'country=\''.NFW::i()->db->escape($this->record['country']).'\'';
		}

		if ($fields['city'] != NFW::i()->user['city']) {
			$this->record['city'] = $fields['city'];
			$update[] = 'city=\''.NFW::i()->db->escape($this->record['city']).'\'';
		}

		$errors = $this->validate('update');
		
		if ($fields['new_password'] || $fields['password2'] || $fields['old_password']) {
			$password = $fields['new_password'];
			$password2 = $fields['password2'];
			$old_password = $fields['old_password'];
		
			if ($password != $password2) {
				$errors['new_password'] = $errors['password2'] = 'Пароли не совпадают.';
			}
		
			if (strlen($password) < 4) {
				$errors['new_password'] = 'Длина пароля должна быть не менее 4-х символов.';
			}
		
			if (strlen($password2) < 4) {
				$errors['password2'] = 'Длина пароля должна быть не менее 4-х символов.';
			}
		
			if (!users::authentificate(NFW::i()->user['username'], $old_password)) {
				$errors['old_password'] = 'Старый пароль указан некорректно.';
			}
		
			if (empty($errors)) {
				$update[] = 'password=\''.users::hash($password, NFW::i()->user['salt']).'\'';
			}
		}
		
		if (!empty($errors)) {
			NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
		}
		
		if (empty($update)) {
			NFW::i()->renderJSON(array('result' => 'success', 'is_updated' => false));
		}
		
		
		if (!NFW::i()->db->query_build(array('UPDATE'	=> 'users', 'SET' => implode(', ', $update), 'WHERE' => 'id='.NFW::i()->user['id']))) {
			$this->error('Unable to update users profile',__FILE__, __LINE__,  NFW::i()->db->error());
			return false;
		}
		
		
		// Auto authentificate on change password
		if (isset($password) && $account = users::authentificate(NFW::i()->user['username'], $password)) {
			$account['is_guest'] = false;
			users::cookie_update($account);
		}		
	}
}