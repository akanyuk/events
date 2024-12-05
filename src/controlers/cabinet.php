<?php

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
        case 'work_interaction':
            $CWorks = new works($_GET['work_id']);
            if (!$CWorks->record['id']) {
                $this->error($CWorks->last_msg, __FILE__, __LINE__);
                NFWX::i()->jsonError(400, $this->last_msg);
            }

            $CWorksInteraction = new works_interaction();
            $records = $CWorksInteraction->records($CWorks->record);
            if ($CWorksInteraction->error) {
                NFWX::i()->jsonError(400, $CWorksInteraction->last_msg);
            }

            NFWX::i()->jsonSuccess(['records' => $records]);
            break;
        case 'interaction_message':
            $req = json_decode(file_get_contents('php://input'));

            $CWorks = new works($req->workID);
            if (!$CWorks->record['id']) {
                NFWX::i()->jsonError(400, 'Bad request');
            }

            if (!$req->message) {
                $langMain = NFW::i()->getLang('main');
                NFWX::i()->jsonError(400, ['message' => $langMain['cabinet message required']]);
            }

            if (!works_interaction::addMessage($CWorks->record['id'], $req->message)) {
                $this->error('Unable to save message', __FILE__, __LINE__, NFW::i()->db->error);
                NFWX::i()->jsonError(500, ['debug' => NFW::i()->db->error], 'Save message failed');
            }

            NFWX::i()->jsonSuccess([
                'message' => $req->message,
                'is_message' => true,
                'posted' => time(),
                'poster_username' => NFW::i()->user['username']
            ]);
            break;
        case 'upload_work':
            $CMedia = new media();
            if (!$CMedia->countSessionFiles('works')) {
                NFWX::i()->jsonError(400, $langMain['works upload no file error']);
            }

            $req = json_decode(file_get_contents('php://input'));

            $CCompetitions = new competitions($req->competition_id);
            if (!$CCompetitions->record['id']) {
                NFWX::i()->jsonError(400, 'System error: competition not found');
            }

            $CEvents = new events($CCompetitions->record['event_id']);
            if (!$CEvents->record['id']) {
                NFWX::i()->jsonError(400, 'System error: event not found');
            }

            $CWorks = new works();
            if (!$CWorks->loadEditorOptions($CEvents->record['id'], array('open_reception' => true))) {
                NFWX::i()->jsonError(400, $CWorks->last_msg);
            }

            $r = [];
            foreach ($req as $k => $v) $r[$k] = $v;
            $CWorks->formatAttributes($r);

            $desc = array();
            if ($req->description_public) {
                $desc[] = 'Comment for visitors:' . "\n" . $req->description_public;
            }
            if ($req->description_refs) {
                $desc[] = 'Display additional: ' . $req->description_refs;
            }
            if ($req->description) {
                $desc[] = 'Comment for organizers:' . "\n" . $req->description;
            }
            $CWorks->record['description'] = implode("\n\n", $desc);

            $errors = $CWorks->validate();
            if (!empty($errors)) {
                NFWX::i()->jsonError(400, $errors, $CWorks->last_msg);
            }

            $CWorks->saveWork();
            if ($CWorks->error) {
                NFWX::i()->jsonError(400, $CWorks->last_msg);
            }

            NFWX::i()->hook("works_add_save_success", $CEvents->record['alias'], array('record' => $CWorks->record, 'req' => $req));

            // Adding media files
            $CMedia->closeSession('works', $CWorks->record['id']);
            NFWX::i()->jsonSuccess(['message' => $langMain['works upload success message']]);
            break;
        default:
            NFWX::i()->jsonError(400, "Unknown action");
    }
}

if (NFW::i()->user['is_guest']) {
    header('Location: ' . NFW::i()->absolute_path);
} elseif (NFW::i()->user['is_blocked']) {
    NFW::i()->stop('User\'s profile disabled by administration.', 'error-page');
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
            $events[] = $c['event_alias'];
        }
        $events = array_unique($events);

        if (empty($events)) {
            NFW::i()->stop($langMain['events no open'], 'error-page');
        }

        $CWorks = new works();

        // Choose event
        if (count($events) > 1 && !isset($_GET['event'])) {
            $CEvents = new events();
            $content = $CWorks->renderAction(array(
                'events' => $CEvents->getRecords(array('load_media' => true, 'filter' => array('aliases' => $events)))
            ), 'cabinet/add_choose_event');
        } else {
            $eventAlias = $_GET['event'] ?? reset($events);

            if (!in_array($eventAlias, $events)) {
                NFW::i()->stop(404);
            }

            $CEvents = new events();
            if (!$CEvents->loadByAlias($eventAlias)) {
                NFW::i()->stop(404);
            }

            $competition = [];
            if (isset($_GET['competition'])) {
                $CCompetitions = new competitions();
                if (!$CCompetitions->loadByAlias($_GET['competition'], $CEvents->record['id'])) {
                    NFW::i()->stop(404);
                }
                $competition = $CCompetitions->record;
            }

            if (!$CWorks->loadEditorOptions($CEvents->record['id'], array('open_reception' => true))) {
                NFW::i()->stop(404);
            }

            $content = $CWorks->renderAction([
                'event' => $CEvents->record,
                'competition' => $competition,
            ], 'cabinet/add');
        }
        break;
    default:
        NFW::i()->stop(404);
        return; // Not necessary. Linter related
}

NFW::i()->assign('page', ['path' => 'cabinet', 'content' => $content]);
NFW::i()->display('main.tpl');
