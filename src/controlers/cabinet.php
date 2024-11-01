<?php
if (NFW::i()->user['is_guest']) {
    header('Location: ' . NFW::i()->absolute_path);
} elseif (NFW::i()->user['is_blocked']) {
    NFW::i()->stop('User\'s profile disabled by administration.', 'error-page');
}

$langMain = NFW::i()->getLang('main');

// Do action
if (isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'work_files':
            $CWorks = new works($_GET['work_id']);
            if (!$CWorks->record['id']) {
                $this->error($CWorks->last_msg, __FILE__, __LINE__);
                NFWX::i()->jsonError(400, $this->last_msg);
            }

            if ($CWorks->record['posted_by'] != NFW::i()->user['id']) {
                NFWX::i()->jsonError(400, NFW::i()->lang['Errors']['Bad_request']);
            }

            $files = [];
            foreach ($CWorks->record['media_info'] as $a) {
                $file = [
                    'url' => $a['url'],
                    'basename' => $a['basename'],
                    'postedBy' => date('d.m.Y H:i', $a['posted']) . ' by ' . $a['posted_username'],
                    'isScreenshot' => $a['is_screenshot'],
                    'isImage' => $a['is_image'],
                    'isAudio' => $a['is_audio'],
                    'isVoting' => $a['is_voting'],
                    'isRelease' => $a['is_release'],
                ];
                if ($a['type'] == 'image') {
                    list($width, $height) = getimagesize($a['fullpath']);
                    $file['icon'] = $a['tmb_prefix'] . '96';
                    $file['filesize'] = $a['filesize_str'] . ' ' . '[' . $width . 'x' . $height . ']';
                } else {
                    $file['icon'] = $a['icons']['64x64'];
                    $file['filesize'] = $a['filesize_str'];
                }

                $files[] = $file;
            }

            NFWX::i()->jsonSuccess(['files' => $files]);
            break;
        case 'upload_work':
            $CMedia = new media();
            if (!$CMedia->countSessionFiles('works')) {
                NFWX::i()->jsonError(400, $langMain['works upload no file error']);
            }

            $req = json_decode(file_get_contents('php://input'));

            ChromePhp::log($req);

            $CWorks = new works();
//            $CUsers->validateProfile($req);
//            if (count($CUsers->errors)) {
//                NFWX::i()->jsonError(400, $CUsers->errors, $CUsers->last_msg);
//            }
//
//            if (!$CUsers->actionRegister($req)) {
//                NFWX::i()->jsonError(400, $CUsers->last_msg);
//            }

            NFWX::i()->jsonSuccess(['message' => $langMain['works upload success message']]);
            break;
        default:
            NFWX::i()->jsonError(400, "Unknown action");
    }
}

// Determine page, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));
switch (count($pathParts) == 2 ? $pathParts[1] : false) {
    case 'works_list':
        $CWorks = new works();
        $records = $CWorks->getRecords(array(
            'filter' => array('posted_by' => NFW::i()->user['id'], 'allow_hidden' => true),
            'ORDER BY' => 'w.posted DESC',
            'load_attachments' => true,
            'load_attachments_icons' => false,
            'skip_pagination' => true
        ));
        $content = $CWorks->renderAction(['records' => $records], 'cabinet/list');
        break;
    case 'works_view':
        $CWorks = new works($_GET['record_id']);
        if (!$CWorks->record['id'] || $CWorks->record['posted_by'] != NFW::i()->user['id']) {
            NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'error-page');
        }

        $content = $CWorks->renderAction('cabinet/view');
        break;
    case 'works_add':
        // Collect events with reception opened
        $events = array();
        $CCompetitions = new competitions();
        foreach ($CCompetitions->getRecords(array('filter' => array('open_reception' => true))) as $c) {
            $events[] = $c['event_id'];
        }
        $events = array_unique($events);

        if (empty($events)) {
            NFW::i()->stop($langMain['events no open'], 'error-page');
        }

        $CWorks = new works();

        // Choose event
        if (count($events) > 1 && !isset($_GET['event_id'])) {
            $CEvents = new events();
            $content = $CWorks->renderAction(array(
                'events' => $CEvents->getRecords(array('load_media' => true, 'filter' => array('ids' => $events)))
            ), 'cabinet/add_choose_event');
        } else {

            $eventID = $_GET['event_id'] ?? reset($events);

            if (!in_array($eventID, $events)) {
                NFW::i()->stop($langMain['events not found'], 'error-page');
            }

            $CEvents = new events($eventID);
            if (!$CEvents->record['id']) {
                NFW::i()->stop($CEvents->last_msg, 'error-page');
            }

            if (!$CWorks->loadEditorOptions($CEvents->record['id'], array('open_reception' => true))) {
                NFW::i()->stop($CEvents->last_msg, 'error-page');
            }

            $content = $CWorks->renderAction(['event' => $CEvents->record], 'cabinet/add');
        }
        break;
    default:
        NFW::i()->stop(404);
        return; // Not necessary. Linter related
}

NFW::i()->assign('page', ['path' => 'cabinet', 'content' => $content]);
NFW::i()->display('main.tpl');
