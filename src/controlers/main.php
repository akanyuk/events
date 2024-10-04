<?php
$pathParts = explode('/', parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

// Try to do some action
// TODO: deprecated. Must be moved into internal_api controller
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
$votekey = new votekey($CEvents->record['id']);
NFW::i()->assign('votekey', $votekey); // Empty votekey by default

if (!NFW::i()->user['is_guest']) {
    $votekey = votekey::findOrCreateVotekey($CEvents->record['id'], NFW::i()->user['email']);
    if (!$votekey->error) {
        $votekey->cookieStore();
        NFW::i()->assign('votekey', $votekey);
    }
} else if (isset($_GET['key'])) {
    $votekey = votekey::getVotekey($_GET['key'], $CEvents->record['id']);
    if (!$votekey->error) {
        $votekey->cookieStore();
        NFW::i()->assign('votekey', $votekey);
    }
} else {
    $votekey = votekey::cookieRestore($CEvents->record['id']);
    if (!$votekey->error) {
        NFW::i()->assign('votekey', $votekey);
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

    $worksBlock = '';
    $votingBlock = '';

    // Special render - event with only one compo
    if (count($competitions) == 1) {
        $c = reset($competitions);
        $CCompetitions->reload($c['id']);

        list($worksBlock, $votingBlock) = renderWorksBlock($CEvents->record, $CCompetitions->record);
    }

    $page['content'] = $CEvents->renderAction(array(
        'event' => $CEvents->record,
        'competitions' => $competitions,
        'competitionsGroups' => $competitionsGroups,
        'worksBlock' => $worksBlock,
        'votingBlock' => $votingBlock,
    ), 'record');

    NFW::i()->assign('page', $page);
    NFW::i()->display('main.tpl');
}

if (!$CCompetitions->loadByAlias($competitionAlias, $CEvents->record['id'])) {
    NFW::i()->stop(404);
}

if (!$workID) {
    // Competition page
    $competitions = $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id'])));
    if (count($competitions) == 1) {
        header('Location: ' . NFW::i()->absolute_path . '/' . $CEvents->record['alias']);
    }

    NFW::i()->breadcrumb = array(
        array('url' => $CEvents->record['alias'], 'desc' => $CEvents->record['title']),
        array('desc' => $CCompetitions->record['title'])
    );
    if ($CCompetitions->record['voting_status']['available'] && $CCompetitions->record['voting_works']) {
        NFW::i()->breadcrumb_status = '<span class="badge text-bg-danger">' . $lang_main['voting to'] . ': ' . date('d.m.Y H:i', $CCompetitions->record['voting_to']) . '</span>';
    }

    NFWX::i()->main_og['title'] = $CCompetitions->record['title'];
    NFWX::i()->main_og['description'] = $CEvents->record['title'];
    if ($CEvents->record['preview_img_large']) {
        NFWX::i()->main_og['image'] = tmb($CEvents->record['preview_large'], 500, 500, array('complementary' => true));
    }

    list($worksBlock, $votingBlock) = renderWorksBlock($CEvents->record, $CCompetitions->record);

    $CCompetitionsGroups = new competitions_groups();

    $page['title'] = $CCompetitions->record['title'];
    $page['content'] = NFW::i()->fetch(NFW::i()->findTemplatePath('competitions/main/record.tpl'), [
        'announcement' => $CCompetitions->record['announcement'],
        'competitions' => $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))),
        'competitionsGroups' => $CCompetitionsGroups->getRecords($CEvents->record['id']),
        'competitionID' => $CCompetitions->record['id'],
        'hideWorksCount' => $CEvents->record['hide_works_count'],
        'worksBlock' => $worksBlock,
        'votingBlock' => $votingBlock,
        'workComments' => '',
    ]);

    NFW::i()->assign('page', $page);
    NFW::i()->display('main.tpl');
}

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

list($worksBlock, $votingBlock) = renderWorksBlock($CEvents->record, $CCompetitions->record, $workID);

$CCompetitionsGroups = new competitions_groups();
$CWorksComments = new works_comments();

$page['content'] = NFW::i()->fetch(NFW::i()->findTemplatePath('competitions/main/record.tpl'), [
    'announcement' => $CCompetitions->record['announcement'],
    'competitions' => $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))),
    'competitionsGroups' => $CCompetitionsGroups->getRecords($CEvents->record['id']),
    'competitionID' => $CCompetitions->record['id'],
    'hideWorksCount' => $CEvents->record['hide_works_count'],
    'worksBlock' => $worksBlock,
    'votingBlock' => $votingBlock,
    'workComments' => $CWorksComments->displayWorkComments($CWorks->record['id']),
]);

NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');

function renderWorksBlock(array $event, array $compo, $workID = 0): array {
    NFW::i()->registerFunction('display_work_media');
    $CWorks = new works();
    $worksBlock = '';
    if ($compo['release_status']['available'] && $compo['release_works']) {
        $filter = [
            'release_only' => true,
            'competition_id' => $compo['id'],
            'work_id' => $workID ? [$workID] : null,
        ];
        $releaseWorks = $CWorks->getRecords(array(
            'load_attachments' => true,
            'load_attachments_icons' => false,
            'filter' => $filter,
            'ORDER BY' => 'sorting_place, w.average_vote DESC, w.total_scores DESC, w.position',
            'skip_pagination' => true,
        ));
        foreach ($releaseWorks as $work) {
            $worksBlock .= display_work_media($work, [
                'rel' => 'release',
                'single' => (bool)$workID,
                'voting_system' => $event['voting_system'],
            ]);
        }
        return [$worksBlock, ""];
    } elseif ($compo['voting_status']['available'] && $compo['voting_works']) {
        $langMain = NFW::i()->getLang('main');
        $votingOptions = $langMain['voting votes'];
        if (!empty($event['options'])) {
            $votingOptions = [];
            foreach ($event['options'] as $v) {
                $votingOptions[$v['value']] = $v['label_' . NFW::i()->user['language']] ? $v['label_' . NFW::i()->user['language']] : $v['value'];
            }
        }

        $filter = [
            'voting_only' => true,
            'competition_id' => $compo['id'],
            'work_id' => $workID ? [$workID] : null,
        ];
        $works = $CWorks->getRecords(array(
            'load_attachments' => true,
            'load_attachments_icons' => false,
            'filter' => $filter,
            'ORDER BY' => 'w.position',
            'skip_pagination' => true,
        ));
        $curPos = 1;
        foreach ($works as $work) {
            $work['position'] = $curPos++;
            $worksBlock .= display_work_media($work, [
                'rel' => 'voting',
                'single' => (bool)$workID,
                'vote_options' => $votingOptions,
                'voting_system' => $event['voting_system'],
            ]);
        }

        $votingBlock = NFW::i()->fetch(NFW::i()->findTemplatePath('competitions/main/_voting.tpl'), [
            'eventID' => $event['id'],
            'works' => $works,
        ]);

        return [$worksBlock, $votingBlock];
    }

    // Placeholder. Not reachable
    return [nl2br($compo['announcement']), ""];
}
