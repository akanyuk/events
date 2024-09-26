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

// Any `event` page can store votekey from request
if (isset($_GET['key'])) {
    $votekey = votekey::getVotekey($_GET['key'], $CEvents->record['id']);
    if (!$votekey->error) {
        NFW::i()->setCookie('votekey', $_GET['key']);
    }
}

// Page with event, competition or work
$page = $CPages->record;
$page['path'] = "foo";  // Unnecessary. Preventing `index` page

if (!$competitionAlias && !$workID) {
    // Event page
    $page['title'] = $CEvents->record['title'];

    NFWX::i()->main_og['title'] = $CEvents->record['title'];
    NFWX::i()->main_og['description'] = $CEvents->record['announcement_og'] ?: strip_tags($CEvents->record['announcement']);
    if ($CEvents->record['preview_img_large']) {
        NFWX::i()->main_og['image'] = tmb($CEvents->record['preview_large'], 500, 500, array('complementary' => true));
    }

    $competitions = $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id'])));

    $CCompetitionsGroups = new competitions_groups();
    $competitionsGroups = $CCompetitionsGroups->getRecords($CEvents->record['id']);

    // Special render - event with only one compo
    if (count($competitions) == 1) {
        $c = reset($competitions);
        $CCompetitions->reload($c['id']);

        $content = $CEvents->record['content'] . renderCompetitionPage($CCompetitions, $CEvents, true);
        $competitions = array();    // prevent default competitions list
    } else {
        $content = $CEvents->record['content'];
    }

    $page['content'] = $CEvents->renderAction(array(
        'event' => $CEvents->record,
        'competitions' => $competitions,
        'competitionsGroups' => $competitionsGroups,
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

    if ($CCompetitions->record['voting_status']['available'] && !$CWorks->record['status_info']['voting']) {
        NFW::i()->stop(404);
    }

    if ($CCompetitions->record['release_status']['available'] && !$CWorks->record['status_info']['release']) {
        NFW::i()->stop(404);
    }

    NFW::i()->breadcrumb = array(
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
        $page['content'] = display_work_media($CWorks->record, [
            'rel' => 'release',
            'single' => true,
            'voting_system' => $CEvents->record['voting_system'],
        ]);
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
        array('url' => $CEvents->record['alias'], 'desc' => $CEvents->record['title']),
        array('desc' => $CCompetitions->record['title'])
    );
    if ($CCompetitions->record['voting_status']['available'] && $CCompetitions->record['voting_works']) {
        NFW::i()->breadcrumb_status = '<span class="label label-danger">' . $lang_main['voting to'] . ': ' . date('d.m.Y H:i', $CCompetitions->record['voting_to']) . '</span>';
    }

    NFWX::i()->main_og['title'] = $CCompetitions->record['title'];
    NFWX::i()->main_og['description'] = $CEvents->record['title'];
    if ($CEvents->record['preview_img_large']) {
        NFWX::i()->main_og['image'] = tmb($CEvents->record['preview_large'], 500, 500, array('complementary' => true));
    }

    $competitions = $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id'])));
    $oneCompoEvent = count($competitions) == 1;

    $page['title'] = $CCompetitions->record['title'];
    $page['content'] = $CCompetitions->renderAction(array(
        'content' => renderCompetitionPage($CCompetitions, $CEvents, $oneCompoEvent),
        'event' => $CEvents->record,
        'announcement' => $oneCompoEvent ? '' : $CCompetitions->record['announcement'],
        'competitions' => $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))),
    ), 'record');

    NFW::i()->assign('page', $page);
    NFW::i()->display('main.tpl');
}

function renderCompetitionPage($CCompetitions, $CEvents, bool $oneCompoEvent): string {
    $compo = $CCompetitions->record;
    $event = $CEvents->record;

    if ($compo['release_status']['available'] && $compo['release_works']) {
        return $CCompetitions->renderAction(array(
            'competition' => $compo,
            'oneCompoEvent' => $oneCompoEvent,
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
        ), '_voting');
    } elseif ($oneCompoEvent) {
        return $CCompetitions->renderAction(array(
            'showWorksCount' => !$event['hide_works_count'],
            'competition' => $compo,
        ), '_one_compo_event');
    } else {
        return nl2br($compo['announcement']);
    }
}
