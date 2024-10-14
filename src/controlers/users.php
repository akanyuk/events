<?php

$CUsers = new users_ext();

// Do action
if (isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'restore_password':
            $req = json_decode(file_get_contents('php://input'));

            $CUsers->validateEmail($req->email);
            if (count($CUsers->errors)) {
                NFWX::i()->jsonError(400, $CUsers->errors);
            }

            if (!$CUsers->actionRestorePassword($req->email)) {
                NFWX::i()->jsonError(400, $CUsers->last_msg);
            }

            NFWX::i()->jsonSuccess(['message' => $CUsers->lang['Restore password message']]);
            break;
        case 'activate_account':
            $req = json_decode(file_get_contents('php://input'));

            $account = $CUsers->findActivation($req->key);
            if ($CUsers->error) {
                NFWX::i()->jsonError(400, $CUsers->last_msg);
            }

            $CUsers->validatePasswords($req->password, $req->password2);
            if (count($CUsers->errors)) {
                NFWX::i()->jsonError(400, $CUsers->errors);
            }

            if (!$CUsers->actionActivateAccount($account, $req->password)) {
                NFWX::i()->jsonError(400, $CUsers->last_msg);
            }

            NFWX::i()->jsonSuccess();
            break;
        case 'register':
            $req = json_decode(file_get_contents('php://input'));

            $CUsers->loadAdditionalAttributes();
            $CUsers->validateProfile($req);
            if (count($CUsers->errors)) {
                NFWX::i()->jsonError(400, $CUsers->errors, $CUsers->last_msg);
            }

            if (!$CUsers->actionRegister($req)) {
                NFWX::i()->jsonError(400, $CUsers->last_msg);
            }

            NFWX::i()->jsonSuccess(['message' => $CUsers->lang['Registration message']]);
            break;
        case 'update_profile':
            $req = json_decode(file_get_contents('php://input'));

            $CUsers->validateProfile($req);
            if (count($CUsers->errors)) {
                NFWX::i()->jsonError(400, $CUsers->errors, $CUsers->last_msg);
            }

            if (!$CUsers->actionUpdateProfile($req)) {
                NFWX::i()->jsonError(400, $CUsers->last_msg);
            }

            NFWX::i()->jsonSuccess(['message' => $CUsers->lang['Update profile message']]);
            break;
        case 'update_password':
            $req = json_decode(file_get_contents('php://input'));

            $errors = [];

            if (!$CUsers->authentificate(NFW::i()->user['username'], $req->old_password)) {
                $errors['old_password'] = $CUsers->lang['Errors']['Wrong old password'];
            }

            $CUsers->validatePasswords($req->password, $req->password2);
            if (count($CUsers->errors)) {
                $errors = array_merge($errors, $CUsers->errors);
            }

            if (count($errors)) {
                NFWX::i()->jsonError(400, $errors);
            }

            if (!$CUsers->actionUpdatePassword($req->password)) {
                NFWX::i()->jsonError(400, $CUsers->last_msg);
            }

            NFWX::i()->jsonSuccess(['message' => $CUsers->lang['Update password message']]);
            break;
        default:
            NFWX::i()->jsonError(400, "Unknown action");
    }
}

// Determine page, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));
switch (count($pathParts) == 2 ? $pathParts[1] : false) {
    case 'restore_password':
        $content = $CUsers->renderAction('restore_password');
        break;
    case 'activate_account':
        if (!NFW::i()->user['is_guest']) {
            NFW::i()->stop($CUsers->lang['Errors']['Already registered'], 'error-page');
        }

        if (!isset($_GET['key']) || $_GET['key'] === "") {
            NFW::i()->stop(404);
        }
        $key = $_GET['key'];

        $account = $CUsers->findActivation($key);
        if ($CUsers->error) {
            NFW::i()->stop($CUsers->last_msg, 'error-page');
        }

        $content = $CUsers->renderAction([
            'account' => $account,
            'key' => $key,
        ], 'activate_account');
        break;
    case 'register':
        if (!NFW::i()->user['is_guest']) {
            NFW::i()->stop($CUsers->lang['Errors']['Already registered'], 'error-page');
        }

        $defaultCountry = '';
        $defaultCity = '';
        if (file_exists(VAR_ROOT . '/SxGeoCity.dat')) {
            require_once(NFW_ROOT . 'helpers/SxGeo/SxGeo.php');
            $SxGeo = new SxGeo(VAR_ROOT . '/SxGeoCity.dat');
            if ($geo = $SxGeo->getCityFull($_SERVER['REMOTE_ADDR'])) {
                $defaultCountry = $geo['country']['iso'];
                $defaultCity = NFW::i()->user['language'] == 'Russian' ? $geo['city']['name_ru'] : $geo['city']['name_en'];
            }
        }

        $CUsers->loadAdditionalAttributes();

        $content = $CUsers->renderAction([
            'CUsers' => $CUsers,
            'defaultCountry' => $defaultCountry,
            'defaultCity' => $defaultCity,
        ], 'register');
        break;
    case 'update_profile':
        if (NFW::i()->user['is_guest']) {
            NFW::i()->stop($CUsers->lang['Errors']['Not registered'], 'error-page');
            return false;
        }

        $content = $CUsers->renderAction([
            'CUsers' => $CUsers,
        ],'update_profile');
        break;
    default:
        NFW::i()->stop(404);
        return; // Not necessary. Linter related
}

NFW::i()->assign('page', ['path' => 'users', 'content' => $content]);
NFW::i()->display('main.tpl');
