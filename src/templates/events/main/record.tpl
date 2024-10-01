<?php
/**
 * @var array $event
 * @var array $competitions
 * @var array $competitionsGroups
 * @var string $worksBlock // for one compo event
 * @var string $votingBlock // for one compo event
 */

NFW::i()->registerFunction('competitions_list_short');

$langMain = NFW::i()->getLang('main');

// Preparing competitions
$isReceptionCan = false;
$isVotingCan = false;
foreach ($competitions as $key => $c) {
    if ($c['reception_status']['future'] || $c['reception_status']['now']) {
        $isReceptionCan = true;
    }

    if ($c['voting_status']['future'] || $c['voting_status']['now']) {
        $isVotingCan = true;
    }

    if ($isReceptionCan && $isVotingCan) {
        break;
    }
}

// Preparing groups of events
$eventsGroup = [];
if ($event['alias_group'] != "") {
    $CEvents = new events();
    $result = $CEvents->getRecords(['filter' => ['alias_group' => $event['alias_group']]]);
    foreach ($result as $record) {
        $eventsGroup[] = [
            'year' => date('Y', $record['date_to']),
            'alias' => $record['alias'],
            'title' => $record['title'],
            'is_current' => $record['id'] == $event['id'],
        ];
    }
}

$uploadButton = '';
if ($isReceptionCan) {
    if (stristr($event['content_column'], '%UPLOAD-BUTTON%')) {
        $event['content_column'] = str_replace('%UPLOAD-BUTTON%', '<a href="' . NFW::i()->absolute_path . '/upload/' . $event['alias'] . '" class="btn btn-primary d-block mb-1">' . $langMain['cabinet add work'] . '</a>', $event['content_column']);
    } else {
        $uploadButton = '<a href="' . NFW::i()->absolute_path . '/upload/' . $event['alias'] . '" class="btn btn-primary d-block mb-1">' . $langMain['cabinet add work'] . '</a>';
    }
} else {
    $event['content_column'] = str_replace('%UPLOAD-BUTTON%', '', $event['content_column']);
}

$liveVotingButton = '';
if ($isVotingCan) {
    if (stristr($event['content_column'], '%LIVE-VOTING-BUTTON%')) {
        $event['content_column'] = str_replace('%LIVE-VOTING-BUTTON%', '<a href="' . NFW::i()->absolute_path . '/live_voting/' . $event['alias'] . '" class="btn btn-primary d-block mb-1">Live voting</a>', $event['content_column']);
    } else {
        $liveVotingButton = '<a href="' . NFW::i()->absolute_path . '/live_voting/' . $event['alias'] . '" class="btn btn-primary d-block mb-1">Live voting</a>';
    }
} else {
    $event['content_column'] = str_replace('%LIVE-VOTING-BUTTON%', '', $event['content_column']);
}

if (stristr($event['content_column'], '%COMPETITIONS-LIST-SHORT%')) {
    $event['content_column'] = str_replace('%COMPETITIONS-LIST-SHORT%', competitions_list_short($competitionsGroups, $competitions, $event['hide_works_count']), $event['content_column']);
    $competitionsListShort = '';
} else {
    $competitionsListShort = competitions_list_short($competitionsGroups, $competitions, $event['hide_works_count']);
}

if (stristr($event['content'], '%TIMETABLE%')) {
    $event['content'] = str_replace('%TIMETABLE%', timetable($event['id']), $event['content']);
    $timetable = '';
} else {
    $timetable = timetable($event['id']);
}

if (stristr($event['content'], '%COMPETITIONS-LIST%')) {
    $event['content'] = str_replace('%COMPETITIONS-LIST%', competitionsList($competitionsGroups, $competitions, $event['hide_works_count']), $event['content']);
    $competitionsList = '';
} else {
    $competitionsList = competitionsList($competitionsGroups, $competitions, $event['hide_works_count']);
}

// Left column begin

ob_start();
?>
    <div class="d-none d-md-block">
        <?php if ($event['preview_img_large']): ?>
            <img class="w-100 mb-3" src="<?php echo $event['preview_img_large'] ?>"
                 alt="<?php echo htmlspecialchars($event['title']) ?>"/>
        <?php endif; ?>
        <p class="text-muted"><?php echo $event['dates_desc'] ?></p>
        <?php
        echo '<p>' . $event['announcement'] . '</p>';
        echo eventsGroup($eventsGroup);
        echo '<p>' . $event['content_column'] . '</p>';
        echo $uploadButton . ' ' . $liveVotingButton;
        echo $competitionsListShort;
        ?>
    </div>
<?php
NFWX::i()->mainLayoutRightContent = ob_get_clean();

// Main content begin
?>
    <div class="d-block d-md-none mb-3">
        <div class="d-flex justify-content-start">
            <?php if ($event['is_preview_img']): ?>
                <div class="me-3">
                    <img src="<?php echo $event['preview_img'] ?>"
                         alt="<?php echo htmlspecialchars($event['title']) ?>"/>
                </div>
            <?php endif; ?>
            <div>
                <h2 class="fs-4"><?php echo htmlspecialchars($event['title']) ?></h2>
                <p class="text-muted"><?php echo $event['dates_desc'] ?></p>
            </div>
        </div>
        <?php
        echo '<p>' . $event['announcement'] . '</p>';
        echo eventsGroup($eventsGroup);
        echo '<p>' . $event['content_column'] . '</p>';
        echo $uploadButton . ' ' . $liveVotingButton;
        echo $competitionsListShort;
        ?>
    </div>

    <h1 class="d-none d-md-block"><?php echo htmlspecialchars($event['title']) ?></h1>
<?php
echo $event['content'] . ' ' . $timetable . ' ' . $competitionsList . $votingBlock . $worksBlock;

function eventsGroup(array $eventsGroup): string {
    if (sizeof($eventsGroup) < 2) {
        return "";
    }

    ob_start();
    ?>
    <ul class="nav nav-pills mb-3">
        <?php foreach ($eventsGroup as $g): ?>
            <li class="nav-item nav-item-sm"><a class="nav-link <?php echo $g['is_current'] ? 'active disabled' : '' ?>"
                                                href="<?php echo NFW::i()->absolute_path.'/'.$g['alias'] ?>"
                                                title="<?php echo htmlspecialchars($g['title']) ?>"><?php echo $g['year'] ?></a>
            </li>
        <?php endforeach; ?>
    </ul>
    <?php
    return ob_get_clean();
}

function competitionsList($competitionsGroups, $competitions, bool $hideWorksCount): string {
    if (count($competitions) < 2) {
        return "";
    }

    ob_start();
    if (empty($competitionsGroups)) {
        foreach ($competitions as $compo) {
            echo _compo($compo, $hideWorksCount);
        }
        return ob_get_clean();
    }

    foreach ($competitionsGroups as $group) {
        ?>
        <div id="<?php echo str_replace(" ", "_", htmlspecialchars($group['title'])) ?>"
             style="position: relative; top: -60px;"></div>
        <h2><?php echo htmlspecialchars($group['title']) ?></h2>
        <p><?php echo $group['announcement'] ?></p>
        <?php
        foreach ($competitions as $compo) {
            if ($compo['competitions_groups_id'] == $group['id']) {
                echo _compo($compo, $hideWorksCount);
            }
        }
    }

    // Without group
    foreach ($competitions as $compo) {
        if ($compo['competitions_groups_id'] == 0) {
            echo _compo($compo, $hideWorksCount);
        }
    }

    return ob_get_clean();
}

function _compo(array $compo, bool $hideWorksCount) {
    $langMain = NFW::i()->getLang('main');
    $receptionAvailable = $compo['reception_status']['now'] || $compo['reception_status']['future'];
    $votingAvailable = $compo['voting_status']['now'] || $compo['voting_status']['future'];

    ob_start();
    ?>
    <div id="<?php echo $compo['alias'] ?>" style="position: relative; top: -60px;"></div>
    <h3>
        <?php if ($compo['is_link']): ?>
            <a href="<?php echo NFW::i()->absolute_path . '/' . $compo['event_alias'] . '/' . $compo['alias'] ?>"><?php echo htmlspecialchars($compo['title']) . ($hideWorksCount ? '' : ' (' . $compo['counter'] . ')') ?></a>
        <?php else: ?>
            <?php echo htmlspecialchars($compo['title']) . ($hideWorksCount ? '' : ' (' . $compo['counter'] . ')') ?>
        <?php endif; ?>
    </h3>

    <p><?php echo $compo['announcement'] ?></p>

    <?php if (!$compo['reception_status']['newer'] || !$compo['voting_status']['newer']): ?>
        <ul>
            <?php if (!$compo['reception_status']['newer']): ?>
                <li>
                    <?php echo $langMain['competitions reception'] ?>
                    <?php if ($compo['reception_from']): ?>
                        <span
                            style="white-space: nowrap; <?php echo $compo['reception_status']['past'] ? 'color: #777;' : 'font-weight: bold;' ?>"><?php echo date('d.m H:i', $compo['reception_from']) . ' - ' . date('d.m H:i', $compo['reception_to']) ?></span>
                    <?php endif; ?>
                    <?php if ($receptionAvailable): ?>
                        <span
                            class="badge <?php echo $compo['reception_status']['label-class'] ?>"><?php echo $compo['reception_status']['desc'] ?></span>
                    <?php endif; ?>
                </li>
            <?php endif; ?>
            <?php if (!$compo['voting_status']['newer']): ?>
                <li>
                    <?php echo $langMain['competitions voting'] ?>
                    <?php if ($compo['voting_from']): ?>
                        <span
                            style="white-space: nowrap; <?php echo $compo['voting_status']['past'] ? 'color: #777;' : 'font-weight: bold;' ?>"><?php echo date('d.m H:i', $compo['voting_from']) . ' - ' . date('d.m H:i', $compo['voting_to']) ?></span>
                    <?php endif; ?>
                    <?php if ($votingAvailable): ?>
                        <span
                            class="badge <?php echo $compo['voting_status']['label-class'] ?>"><?php echo $compo['voting_status']['desc'] ?></span>
                    <?php endif; ?>
                </li>
            <?php endif; ?>
        </ul>
    <?php endif; ?>

    <a class="d-block mb-3 text-info" href="<?php echo '#top' ?>">
        <svg width="2em" height="2em">
            <use href="#icon-caret-up"></use>
        </svg>
    </a>
    <?php
    return ob_get_clean();
}

function timetable(int $eventID) {
    $rows = _timetableRows($eventID);
    if (empty($rows)) {
        return "";
    }

    ob_start();
    ?>
    <table class="table table-condensed table-timetable">
        <tbody>
        <?php
        foreach ($rows as $r) {
            if (isset($r['date'])) {
                echo '<tr><td colspan="3"><h3>' . $r['date'] . '</h3></td></tr>';
                continue;
            }
            ?>
            <tr class="<?php echo $r['type'] ?>">
                <?php echo $r['time'] ? '<td class="td-dt" rowspan="' . $r['rowspan'] . '">' . $r['time'] . '</td>' : '' ?>
                <td class="td-place"><?php echo $r['place'] ? '<span class="badge text-bg-secondary text-bg-' . $r['place'] . '">' . $r['place'] . '</span>' : '' ?></td>
                <td><?php echo $r['description'] ?></td>
            </tr>
            <?
        }
        ?>
        </tbody>
    </table>
    <?php
    return ob_get_clean();
}

function _timetableRows(int $eventID): array {
    $CTimeline = new timeline();

    $result = [];
    $curDate = '';
    foreach ($CTimeline->getRecords($eventID) as $record) {
        if (!$record['is_public']) {
            continue;
        }

        $d = date('d.m.Y', $record['begin']);
        if ($curDate != $d) {
            $result[] = [
                'date' => $d,
            ];
            $curDate = $d;
        }

        $result[] = [
            'time' => date('H:i', $record['begin']),
            'type' => $record['type'],
            'place' => $record['place'],
            'description' => $record['description'],
            'rowspan' => 1,
        ];
    }

    $prevT = "-";
    $rowspanKey = 0;
    foreach ($result as $k => $r) {
        if (!isset($r['time'])) {
            continue;
        }

        $curT = $r['time'];
        if ($r['time'] == $prevT) {
            $result[$k]['time'] = '';
            $result[$rowspanKey]['rowspan']++;
        } else {
            $rowspanKey = $k;
        }

        $prevT = $curT;
    }

    return $result;
}
