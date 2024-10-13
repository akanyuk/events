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

    // TODO: разобрать по разным валидациям
    private function validateRecord($role = 'update', $record = false): bool {
        switch ($role) {
            case 'register':
                $this->errors = parent::validate();

                // Not required on registration
                unset($this->errors['password']);

                if ($captchaErr = base_module::validate($_POST['captcha'], array('type' => 'captcha'))) {
                    $this->errors['captcha'] = $captchaErr;
                }

                return !count($this->errors);
            case 'update':
            case 'update_password':
                $this->errors = parent::validate($role);
                return !count($this->errors);
            case 'update_password_main':
                $this->errors = parent::validate('update_password');

                // check old password
                if (!$this->authentificate($this->record['username'], $this->record['old_password'])) {
                    $this->errors['old_password'] = $this->lang['Errors']['Wrong old password'];
                }

                return !count($this->errors);
            default:
                return true;
        }
    }

    public function loadAdditionalAttributes() {
        $this->loadServicettributes();
    }

    public function findActivation(string $key): ?array {
        if ($key === "") {
            $this->error($this->lang['Errors']['Wrong key'], __FILE__, __LINE__);
            return null;
        }

        if (!$result = NFW::i()->db->query_build(array('SELECT' => '*', 'FROM' => $this->db_table, 'WHERE' => 'activate_key=\'' . NFW::i()->db->escape($key) . '\''))) {
            $this->error('Unable to fetch activation.', __FILE__, __LINE__, NFW::i()->db->error());
            return null;
        }
        if (!NFW::i()->db->num_rows($result)) {
            $this->error($this->lang['Errors']['Wrong key'], __FILE__, __LINE__);
            return null;
        }

        return NFW::i()->db->fetch_assoc($result);
    }

    public function validateEmailAndCaptcha(string $email, $captcha): bool {
        $this->errors = active_record::validate(
            ['email' => $email, 'captcha' => $captcha],
            [
                'email' => ['type' => 'email', 'desc' => 'E-mail', 'required' => true],
                'captcha' => ['type' => 'captcha'],
            ],
        );

        return !count($this->errors);
    }

    public function validatePasswords(string $password, $password2): bool {
        if (strlen($password) < 4) {
            $this->errors['password'] = $this->lang['Errors']['Password too short'];
            return false;
        }

        if ($password != $password2) {
            $this->errors['password'] = $this->lang['Errors']['Passwords mismatch'];
            $this->errors['password2'] = $this->lang['Errors']['Passwords mismatch'];
            return false;
        }

        return true;
    }

    public function validateRegistration(object $req, string $captcha): bool {
        $r = []; foreach ($req as $k=>$v) $r[$k] = $v;
        $record = $this->formatAttributes($r, $this->attributes, true);
        $record['id'] = 0;

        $this->errors = active_record::validate($record, $this->attributes);

        // Not required on registration
        unset($this->errors['password']);

        if ($err = base_module::validate($captcha, array('type' => 'captcha'))) {
            $this->errors['captcha'] = $err;
        }

        return !count($this->errors);
    }

    public function actionRestorePassword($email): bool {
        // Fetch user matching $email
        if (!$result = NFW::i()->db->query_build(array('SELECT' => '*', 'FROM' => $this->db_table, 'WHERE' => 'email=\'' . NFW::i()->db->escape($email) . '\''))) {
            $this->error('Unable to search user account', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (!NFW::i()->db->num_rows($result)) {
            return true; // the e-mail address was not found, but for security reasons, the user will not find out about it
        }

        $account = NFW::i()->db->fetch_assoc($result);

        // Generate a new password activation key
        $activate_key = users::random_key(8, true);
        if (!NFW::i()->db->query_build(array('UPDATE' => 'users', 'SET' => 'activate_key=\'' . $activate_key . '\'', 'WHERE' => 'id=' . $account['id']))) {
            $this->error('Restore password system error', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        // Send e-mail
        if ($this->is_valid_email($account['email'])) {
            email::sendFromTemplate($account['email'], 'restore_password', [
                'activation_url' => NFW::i()->absolute_path . '/users/activate_account?key=' . $activate_key,
            ]);
        }

        return true;
    }

    function actionActivateAccount(array $account, string $password): bool {
        $salt = self::random_key(12, true);
        $query = array(
            'UPDATE' => $this->db_table,
            'SET' => 'group_id=' . NFW::i()->cfg['users_group_id'] . ', password=\'' . self::hash($password, $salt) . '\', salt=\'' . $salt . '\', activate_key=NULL',
            'WHERE' => 'id=' . $account['id']
        );
        if (!NFW::i()->db->query_build($query)) {
            $this->error('Unable to activate user', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        // Auto authenticate
        if ($user = $this->authentificate($account['username'], $password)) {
            $this->cookie_update($user);
        }

        return true;
    }

    function actionRegister(object $req):bool {
        // Cleaning old unverified registration attempts - delete older than 72 hours
        NFW::i()->db->query_build([
            'DELETE' => $this->db_table,
            'WHERE' => 'group_id=' . NFW::i()->cfg['users_group_id_unverified'] . ' AND registered < ' . (time() - 259200)
        ]);

        $r = []; foreach ($req as $k=>$v) $r[$k] = $v;
        $this->formatAttributes($r, $this->attributes);

        $this->record['group_id'] = NFW::i()->cfg['users_group_id_unverified'];
        $this->record['password'] = $this->random_key(32);
        $this->record['is_blocked'] = 0;
        $this->save();

        // Create e-mail activation
        $activate_key = users::random_key(8, true);
        $query = array(
            'UPDATE' => 'users',
            'SET' => 'activate_key=\'' . $activate_key . '\'',
            'WHERE' => 'id=' . $this->record['id']
        );
        if (!NFW::i()->db->query_build($query)) {
            $this->error('Unable to update user', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        email::sendFromTemplate($this->record['email'], 'register_activate', array(
            'username' => $this->record['username'],
            'activation_url' => NFW::i()->absolute_path . '/users/activate_account?key=' . $activate_key,
        ));

        return true;
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
        $errors = $this->validateRecord();

        if (!empty($errors)) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
        }

        $is_updated = $this->save();

        NFW::i()->renderJSON(array('result' => 'success', 'message' => $this->lang['Update profile message'], 'is_updated' => $is_updated));
    }

    function actionUsersUpdatePassword() {
        if (empty($_POST)) return false;

        $this->error_report_type = 'active_form';
        if (!$this->load(NFW::i()->user['id'])) return false;

        $this->record['password'] = $_POST['password'];
        $this->record['password2'] = $_POST['password2'];
        $this->record['old_password'] = $_POST['old_password'];

        $errors = $this->validateRecord('update_password_main');
        if (!empty($errors)) {
            NFW::i()->renderJSON(array('result' => 'error', 'errors' => $errors));
        }

        if (!NFW::i()->db->query_build(array('UPDATE' => $this->db_table, 'SET' => 'password=\'' . users::hash($this->record['password'], NFW::i()->user['salt']) . '\'', 'WHERE' => 'id=' . $this->record['id']))) {
            $this->error('Unable to update record\'s address', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        // Auto authenticate on change password
        if ($account = $this->authentificate($this->record['username'], $this->record['password'])) {
            $this->cookie_update($account);
        }

        NFW::i()->renderJSON(array('result' => 'success', 'is_updated' => true, 'message' => $this->lang['Update password message']));
    }
}