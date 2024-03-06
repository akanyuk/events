<?php
$pathParts = explode('/', parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

// Try to do some action
if (isset($_GET['action'])) {
    // Determine module and action
    $module = count($pathParts) > 0 ? $pathParts[1] : '';
    $action = $_GET['action'];

    $classname = NFW::i()->getClass($module, true);
    if (!class_exists($classname)) {
        NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'plain');
    }

    $CModule = new $classname ();
    // Check module_name->action permissions
    if (!NFW::i()->checkPermissions($module, $action, $CModule)) {
        NFW::i()->stop(NFW::i()->lang['Errors']['Bad_request'], 'plain');
    }

    NFW::i()->assign('Module', $CModule);
    $content = $CModule->action($action);
    if ($CModule->error) {
        NFW::i()->stop($CModule->last_msg, $CModule->error_report_type);
    }

    // Экшен должен останавливаться сам.
    // На всякий случай принудительная остановка
    NFW::i()->stop();
}

// -------------
//  Normal page
// -------------

NFW::i()->registerFunction('tmb');

$CPages = new pages();
$CEvents = new events();
$CCompetitions = new competitions();

$lang_main = NFW::i()->getLang('main');

$eventAlias = count($pathParts) > 1 ? $pathParts[1] : '';
$competitionAlias = count($pathParts) > 2 ? $pathParts[2] : '';
$workID = count($pathParts) > 3 ? $pathParts[3] : '';

if (!$eventAlias || !$CEvents->loadByAlias($eventAlias)) {
    // Normal page
    if (!$page = $CPages->loadPage()) {
        NFW::i()->stop(404);
    } elseif (!$page['is_active']) {
        NFW::i()->stop('inactive');
    }

    NFW::i()->assign('page', $page);
    NFW::i()->display('main.tpl');
}

// Page with event, competition or work

if (!$page = $CPages->loadPage('events')) {
    NFW::i()->stop(404);
} elseif (!$page['is_active']) {
    NFW::i()->stop('inactive');
}

// Loading votekey from request, cookie or registered user data
$votekey = "";
$CVote = new vote();
if (isset($_GET['key']) && $CVote->checkVotekey($_GET['key'], $CEvents->record['id'])) {
    $votekey = $_GET['key'];
    NFW::i()->setCookie('votekey', $_GET['key']);
} else if (isset($_COOKIE['votekey'])) {
    if ($CVote->checkVotekey($_COOKIE['votekey'], $CEvents->record["id"])) {
        $votekey = $_COOKIE['votekey'];
    } else {
        NFW::i()->setCookie('votekey', null, 0);
    }
} else if (!NFW::i()->user['is_guest']) {
    $result = $CVote->getVotekey($CEvents->record["id"], NFW::i()->user['email']);
    if ($result) {
        $votekey = $result;
        NFW::i()->setCookie('votekey', $votekey);
    }
}

if (!$competitionAlias || ($CEvents->record['one_compo_event'] && !$workID)) {
    // Event page
    $page['title'] = $CEvents->record['title'];

    NFW::i()->breadcrumb = array(
        array('url' => 'events', 'desc' => $lang_main['events']),
        array('desc' => $CEvents->record['title'])
    );

    NFWX::i()->main_og['title'] = $CEvents->record['title'];
    NFWX::i()->main_og['description'] = $CEvents->record['announcement_og'] ?: strip_tags($CEvents->record['announcement']);
    if ($CEvents->record['preview_img_large']) {
        NFWX::i()->main_og['image'] = tmb($CEvents->record['preview_large'], 500, 500, array('complementary' => true));
    }

    $competitions = $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id'])));

    // Special render - event with only one compo
    if ($CEvents->record['one_compo_event'] && !empty($competitions)) {
        $c = reset($competitions);
        $CCompetitions->reload($c['id']);

        $content = $CEvents->record['content'] . renderCompetitionPage($CCompetitions, $CEvents, $votekey);
        setBreadcrumbDesc(null, $CCompetitions->record, 'competition');

        $competitions = array();    // prevent default competitions list
    } else {
        $content = $CEvents->record['content'];
        setBreadcrumbDesc($CEvents->record, null, 'event');
    }

    $page['content'] = $CEvents->renderAction(array(
        'event' => $CEvents->record,
        'competitions' => $competitions,
        'content' => $content,
    ), 'record');

    NFW::i()->assign('page', $page);
    NFW::i()->display('main.tpl');
}

if (!$CCompetitions->loadByAlias($competitionAlias, $CEvents->record['id'])) {
    NFW::i()->stop(404);
}

if ($workID) {
    // Work page
    $CWorks = new works($workID);
    if (!$CWorks->record['id'] || $CWorks->record['competition_id'] != $CCompetitions->record['id']) {
        NFW::i()->stop(404);
    }

    NFW::i()->breadcrumb = array(
        array('url' => 'events', 'desc' => $lang_main['events']),
        array('url' => $CEvents->record['alias'], 'desc' => $CEvents->record['title']),
        array('url' => $CEvents->record['alias'] . '/' . $CCompetitions->record['alias'], 'desc' => $CCompetitions->record['title'])
    );

    NFWX::i()->main_og['title'] = $CWorks->record['display_title'];
    NFWX::i()->main_og['description'] = $CEvents->record['title'] . ' / ' . $CCompetitions->record['title'];
    if ($CWorks->record['screenshot']) {
        NFW::i()->registerFunction('cache_media');
        NFWX::i()->main_og['image'] = cache_media($CWorks->record['screenshot'], 640);
    }

    $page['title'] = $CWorks->record['display_title'];

    if ($CCompetitions->record['release_status']['available'] && $CCompetitions->record['release_works']) {
        NFW::i()->registerFunction('display_work_media');
        $page['content'] = display_work_media($CWorks->record, array('rel' => 'release', 'single' => true));
    } elseif ($CCompetitions->record['voting_status']['available'] && $CCompetitions->record['voting_works']) {
        $page['content'] = $CCompetitions->renderAction(array(
            'event' => $CEvents->record,
            'competition' => $CCompetitions->record,
            'works' => [$CWorks->record],
        ), '_voting');
    } else {
        NFW::i()->stop(404);
    }

    $CWorksComments = new works_comments();
    $page['content'] .= $CWorksComments->displayWorkComments($CWorks->record['id']);

    NFW::i()->assign('page', $page);
    NFW::i()->display('main.tpl');
} else {
    // Competition page
    NFW::i()->breadcrumb = array(
        array('url' => 'events', 'desc' => $lang_main['events']),
        array('url' => $CEvents->record['alias'], 'desc' => $CEvents->record['title']),
        array('desc' => $CCompetitions->record['title'])
    );
    setBreadcrumbDesc(null, $CCompetitions->record, 'competition');

    NFWX::i()->main_og['title'] = $CCompetitions->record['title'];
    NFWX::i()->main_og['description'] = $CEvents->record['title'];
    if ($CEvents->record['preview_img_large']) {
        NFWX::i()->main_og['image'] = tmb($CEvents->record['preview_large'], 500, 500, array('complementary' => true));
    }

    $page['title'] = $CCompetitions->record['title'];
    $page['content'] = $CCompetitions->renderAction(array(
        'content' => renderCompetitionPage($CCompetitions, $CEvents, $votekey),
        'event' => $CEvents->record,
        'competitions' => $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))),
    ), 'record');

    NFW::i()->assign('page', $page);
    NFW::i()->display('main.tpl');
}

function setBreadcrumbDesc($event, $competition, $by) {
    NFW::i()->breadcrumb_status = '';

    $lang_main = NFW::i()->getLang('main');

    switch ($by) {
        case 'event':
            NFW::i()->breadcrumb_status = $event['status_label'] . '&nbsp;&nbsp;&nbsp;<span class="text-muted">' . $event['dates_desc'] . '</span>';
            break;
        case 'competition':
            if ($competition['voting_status']['available'] && $competition['voting_works']) {
                NFW::i()->breadcrumb_status = '<span class="label label-danger">' . $lang_main['voting to'] . ': ' . date('d.m.Y H:i', $competition['voting_to']) . '</span>';
                break;
            }
    }
}

function renderCompetitionPage($CCompetitions, $CEvents, string $votekey): string {
    $compo = $CCompetitions->record;
    $event = $CEvents->record;

    if ($compo['release_status']['available'] && $compo['release_works']) {
        return $CCompetitions->renderAction(array(
            'competition' => $compo,
            'event' => $event), '_release');
    } elseif ($compo['voting_status']['available'] && $compo['voting_works']) {
        // Get voting works
        $CWorks = new works();
        list($voting_works) = $CWorks->getRecords(array(
            'load_attachments' => true,
            'load_attachments_icons' => false,
            'filter' => array('voting_only' => true, 'competition_id' => $compo['id']),
            'ORDER BY' => 'w.position'
        ));

        return $CCompetitions->renderAction(array(
            'event' => $event,
            'competition' => $compo,
            'works' => $voting_works,
            'votekey' => $votekey,
        ), '_voting');
    } elseif ($event['one_compo_event']) {
        return $CCompetitions->renderAction(array(
            'showWorksCount' => !$event['hide_works_count'],
            'competition' => $compo,
        ), '_one_compo_event');
    } else {
        return nl2br($compo['announcement']);
    }
}
