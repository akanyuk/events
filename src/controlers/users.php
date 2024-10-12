<?php

$CUsers = new users_ext();

// Do action
if (isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'restore_password':
            $req = json_decode(file_get_contents('php://input'));

            $CUsers->validateEmailAndCaptcha($req->email, $req->captcha);
            if (count($CUsers->errors)) {
                NFWX::i()->jsonError(400, $CUsers->errors);
            }

            if (!$CUsers->actionRestorePassword($req->email)) {
                NFWX::i()->jsonError(400, $CUsers->last_msg);
            }

            NFWX::i()->jsonSuccess(['message' => $CUsers->lang['Restore password message']]);
            break;
        default:
            NFWX::i()->jsonError(400, "Unknown action");
    }
}

// Determine page, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));

if (count($pathParts) > 2) {
    NFW::i()->stop(404);
}

$page = count($pathParts) == 2 ? $pathParts[1] : false;
if ($page === false) {
    NFW::i()->stop(404);
}

switch ($page) {
    case 'restore_password':
        $content = $CUsers->renderAction('restore_password');
        break;
    default:
        $content = $CUsers->renderAction('update_profile');
}

NFW::i()->assign('page', ['path' => $page, 'content' => $content]);
NFW::i()->display('main.tpl');
