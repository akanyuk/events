<?php

/**
 * Class users_ext
 * @desc Расширенное управления пользователями: регистрация, авторизация, смена пароля, редактирование профиля
 */
class users_ext extends users {
	function __construct($record_id = false) {
		$this->db_table = 'users';
		return parent::__construct($record_id);
	}

	public function getCities() {
		$cities = array();
		
		if (!$result = NFW::i()->db->query_build(array('SELECT'	=> 'DISTINCT city', 'FROM' => $this->db_table, 'WHERE' => 'city<> "" AND registered<>0', 'ORDER BY' => 'city'))) {
			$this->error('Unable to fetch cities.', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		while($r = NFW::i()->db->fetch_assoc($result)) {
			$cities[] = $r['city']; 
		}		
		
		return $cities;
	}
	
    public function validate($role = 'update', $record = false) {
    	switch ($role) {
    		case 'register':
    			$errors = parent::validate();
    			
    			// Not required on registration
    			unset($errors['password']);
    			
    			if ($captcha_error = base_module::validate($_POST['captcha'], array('type' => 'captcha'))) {
    				$errors['captcha'] = $captcha_error;
    			}

    			return $errors;
    		case 'update':
    		case 'update_password':
    			return parent::validate($role);
    		case 'restore_password':
    			return active_record::validate($record, array(
    				'captcha' => array('type' => 'captcha'),
    				'request_email' => array('type' => 'email', 'desc' => 'E-mail', 'required'=>true),
    			));
    		case 'update_password_main':
    			$errors = parent::validate('update_password');
    
    			// check old password
    			if (!$this->authentificate($this->record['username'], $this->record['old_password'])) {
    				$errors['old_password'] = $this->lang['Errors']['Wrong old password'];
    			}
    
    			return $errors;
    	}
    }
        
    function actionUsersLogin() {
    	$this->error_report_type = empty($_POST) ? 'error-page' : 'active_form';
    	
    	if (!NFW::i()->user['is_guest']) {
    		$this->error($this->lang['Errors']['Already registered'], __FILE__, __LINE__);
    		return false;
    	}
    
   		return $this->renderAction();
    }
    
    function actionUsersRegister() {
    	$this->loadServicettributes();
    	
    	$this->error_report_type = empty($_POST) ? 'error-page' : 'active_form';
    	
    	if (!NFW::i()->user['is_guest']) {
    		$this->error($this->lang['Errors']['Already registered'], __FILE__, __LINE__);
    		return false;
    	}
    	 
    	if (empty($_POST)) {
    		return $this->renderAction();
    	}
    	
    	// Clean old unverified registrators - delete older than 72 hours
    	if (!$result = NFW::i()->db->query_build(array(
    		'DELETE'	=> $this->db_table,
    		'WHERE'		=> 'group_id='.NFW::i()->cfg['users_group_id_unverified'].' AND registered < '.(time() - 259200)
    	))) {
    		$this->error('Unable to delete old unverified registrators.', __FILE__, __LINE__, NFW::i()->db->error());
    		return false;
    	}
    
    	$this->formatAttributes($_POST);
    	$errors = $this->validate('register');

    	if (!empty($errors)) {
    		NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
    	}
    
    	$this->record['group_id'] = NFW::i()->cfg['users_group_id_unverified'];
    	$this->record['password'] = $this->random_key(32);
    	$this->record['is_blocked'] = 0;
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
    		'activation_url' => NFW::i()->absolute_path.'/users/?action=activate_account&key='.$activate_key,
    	));
    
    	NFW::i()->renderJSON(array('result' => 'success', 'message' => $this->lang['Registration message']));
    }
    
    function actionUsersActivateAccount() {
    	$this->error_report_type = empty($_POST) ? 'error-page' : 'active_form';
    	
    	if (!NFW::i()->user['is_guest']) {
    		$this->error($this->lang['Errors']['Already registered'], __FILE__, __LINE__);
    		return false;
    	}
    	 
    	// Find activation
    	if (!isset($_GET['key'])) {
    		$this->error($this->lang['Errors']['Wrong key'], __FILE__, __LINE__);
    		return false;
    	}
    	if (!$result = NFW::i()->db->query_build(array('SELECT'	=> '*', 'FROM' => $this->db_table, 'WHERE' => 'activate_key=\''.NFW::i()->db->escape($_GET['key']).'\''))) {
    		$this->error('Unable to fetch activation.', __FILE__, __LINE__, NFW::i()->db->error());
    		return false;
    	}
    	if (!NFW::i()->db->num_rows($result)) {
    		$this->error($this->lang['Errors']['Wrong key'], __FILE__, __LINE__);
    		return false;
    	}
    	$account = NFW::i()->db->fetch_assoc($result);
    	 
    	if (empty($_POST)) {
    		return $this->renderAction(array(
    			'account' => $account
    		));
    	}
    	
    	$this->record['password'] = isset($_POST['password']) ? $_POST['password'] : '';
    	$this->record['password2'] = isset($_POST['password2']) ? $_POST['password2'] : '';
    	$errors = $this->validate('update_password');
    	if (!empty($errors)) {
    		NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
    	}
    	 
    	$salt = self::random_key(12, true);
    	$query = array(
   			'UPDATE'	=> $this->db_table,
   			'SET'		=> 'group_id='.NFW::i()->cfg['users_group_id'].', password=\''.self::hash($this->record['password'], $salt).'\', salt=\''.$salt.'\', activate_key=NULL',
   			'WHERE'		=> 'id='.$account['id']
    	);
    	if (!NFW::i()->db->query_build($query)) {
    		$this->error('Unable to activate user',__FILE__, __LINE__,  NFW::i()->db->error());
    		return false;
    	}

    	
    	// Auto authentificate
    	if ($user = $this->authentificate($account['username'], $this->record['password'])) {
    		$this->cookie_update($user);
    	}
    	
    	NFW::i()->renderJSON(array('result' => 'success'));
    }
    
    function actionUsersRestorePassword() {
    	$this->error_report_type = empty($_POST) ? 'error-page' : 'active_form';
    	
    	if (!NFW::i()->user['is_guest']) {
    		$this->error($this->lang['Errors']['Already registered'], __FILE__, __LINE__);
    		return false;
    	}
    	 
    	if (empty($_POST)) {
    		return $this->renderAction();
    	}
    	
    	$errors = $this->validate('restore_password', $_POST);
    	if (!empty($errors)) {
    		NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
    	}
    	
   		// Fetch user matching $email
   		if (!$result = NFW::i()->db->query_build(array( 'SELECT' => '*', 'FROM' => $this->db_table, 'WHERE' => 'email=\''.NFW::i()->db->escape($_POST['request_email']).'\''))) {
   			$this->error('Unable to search user\'s account',__FILE__, __LINE__,  NFW::i()->db->error());
   			return false;
   		}
   		if (!NFW::i()->db->num_rows($result)) {
   			NFW::i()->renderJSON(array('result' => 'success', 'message' => $this->lang['Restore password message']));
   		}
    	
   		$account = NFW::i()->db->fetch_assoc($result);
    	
   		// Generate a new password activation key
   		$activate_key = users::random_key(8, true);
   		if (!NFW::i()->db->query_build(array('UPDATE' => 'users', 'SET' => 'activate_key=\''.$activate_key.'\'', 'WHERE' => 'id='.$account['id']))) {
   			$this->error('Restore password system error',__FILE__, __LINE__,  NFW::i()->db->error());
   			return false;
   		}
    	
   		// Send e-mail
   		if ($this->is_valid_email($account['email'])) {
   			email::sendFromTemplate($account['email'], 'restore_password', array('activation_url' => NFW::i()->absolute_path.'/users/?action=activate_account&key='.$activate_key));
   		}
   		
   		NFW::i()->renderJSON(array('result' => 'success', 'message' => $this->lang['Restore password message']));
    }
    
    // Просмотр и редактирование своего профиля клиентом
    function actionUsersUpdateProfile() {
    	$this->error_report_type = empty($_POST) ? 'error-page' : 'active_form';
    	if (NFW::i()->user['is_guest']) {
    		$this->error($this->lang['Errors']['Not registered'], __FILE__, __LINE__);
    		return false;
    	}
    	
        if (!$this->load(NFW::i()->user['id'])) {
    		return false;
    	}

    	if (empty($_POST)) {
    		return $this->renderAction();
    	}
    	 
    	$this->error_report_type = 'active_form';
    	
    	$this->formatAttributes($_POST);
    	$errors = $this->validate();
    	 
    	if (!empty($errors)) {
    		NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
    	}
    	 
    	$is_updated = $this->save();
    	 
    	NFW::i()->renderJSON(array('result' => 'success', 'message' => $this->lang['Update profile message'], 'is_updated' => $is_updated));    	
    }
    
    function actionUsersUpdatePassword() {
    	if (empty($_POST)) return false;
    
    	$this->error_report_type = 'active_form';
    	if (!$this->load(NFW::i()->user['id']))  return false;
    
    	$this->record['password'] = $_POST['password'];
    	$this->record['password2'] = $_POST['password2'];
    	$this->record['old_password'] = $_POST['old_password'];
    
    	$errors = $this->validate('update_password_main');
    	if (!empty($errors)) {
    		NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
    	}
    
    	if (!NFW::i()->db->query_build(array('UPDATE' => $this->db_table, 'SET' => 'password=\''.users::hash($this->record['password'], NFW::i()->user['salt']).'\'', 'WHERE' => 'id='.$this->record['id']))) {
    		$this->error('Unable to update record\'s address', __FILE__, __LINE__, NFW::i()->db->error());
    		return false;
    	}
    
    	// Auto authentificate on change password
    	if ($account = $this->authentificate($this->record['username'], $this->record['password'])) {
    		$this->cookie_update($account);
    	}
    
    	NFW::i()->renderJSON(array('result' => 'success', 'is_updated' => true, 'message' => $this->lang['Update password message']));
    }
}