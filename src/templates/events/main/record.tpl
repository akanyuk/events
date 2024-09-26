<?php
/**
 * @var array $event
 * @var array $competitions
 * @var array $competitionsGroups
 * @var string $content
 */

// Preparing competitions
$langMain = NFW::i()->getLang('main');
$isReceptionCan = false;
$isVotingCan = false;
foreach ($competitions as $key => $c) {
    if ($c['reception_status']['future'] || $c['reception_status']['now']) {
        $isReceptionCan = true;
    }

    if ($c['voting_status']['future'] || $c['voting_status']['now']) {
        $isVotingCan = true;
    }

    if ($c['release_status']['available'] && $c['release_works']) {
        $competitions[$key]['is_link'] = true;
        $counter = $c['release_works'];
    } elseif ($c['voting_status']['available'] && $c['voting_works']) {
        $competitions[$key]['is_link'] = true;
        $counter = $c['voting_works'];
    } else {
        $competitions[$key]['is_link'] = false;
        $counter = $c['release_works'];
    }

    if ($event['hide_works_count']) {
        $competitions[$key]['count_label'] = '<span class="badge text-bg-secondary" title="' . $langMain['competitions received works'] . '">?</span>';
    } elseif (!$counter) {
        $competitions[$key]['count_label'] = '<span class="badge text-bg-secondary" title="' . $langMain['competitions received works'] . '">' . $counter . '</span>';
    } elseif ($counter < 3) {
        $competitions[$key]['count_label'] = '<span class="badge text-bg-warning" title="' . $langMain['competitions received works'] . '">' . $counter . '</span>';
    } else {
        $competitions[$key]['count_label'] = '<span class="badge text-bg-success" title="' . $langMain['competitions received works'] . '">' . $counter . '</span>';
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
        $event['content_column'] = str_replace('%UPLOAD-BUTTON%', '<a href="' . NFW::i()->absolute_path . '/upload/' . $event['alias'] . '" class="btn btn-upload">' . $langMain['cabinet add work'] . '</a>', $event['content_column']);
    } else {
        $uploadButton = '<a href="' . NFW::i()->absolute_path . '/upload/' . $event['alias'] . '" class="btn btn-upload">' . $langMain['cabinet add work'] . '</a>';
    }
} else {
    $event['content_column'] = str_replace('%UPLOAD-BUTTON%', '', $event['content_column']);
}

$liveVotingButton = '';
if ($isVotingCan) {
    if (stristr($event['content_column'], '%LIVE-VOTING-BUTTON%')) {
        $event['content_column'] = str_replace('%LIVE-VOTING-BUTTON%', '<a href="' . NFW::i()->absolute_path . '/live_voting/' . $event['alias'] . '" class="btn btn-live-voting">Live voting</a>', $event['content_column']);
    } else {
        $liveVotingButton = '<a href="' . NFW::i()->absolute_path . '/live_voting/' . $event['alias'] . '" class="btn btn-live-voting">Live voting</a>';
    }
} else {
    $event['content_column'] = str_replace('%LIVE-VOTING-BUTTON%', '', $event['content_column']);
}

if (stristr($event['content_column'], '%COMPETITIONS-LIST-SHORT%')) {
    $event['content_column'] = str_replace('%COMPETITIONS-LIST-SHORT%', competitionsListShort($competitionsGroups, $competitions), $event['content_column']);
    $competitionsListShort = '';
} else {
    $competitionsListShort = competitionsListShort($competitionsGroups, $competitions);
}

if (stristr($content, '%TIMETABLE%')) {
    $content = str_replace('%TIMETABLE%', timetable($event['id']), $content);
    $timetable = '';
} else {
    $timetable = timetable($event['id']);
}

if (stristr($content, '%COMPETITIONS-LIST%')) {
    $content = str_replace('%COMPETITIONS-LIST%', competitionsList($competitionsGroups, $competitions), $content);
    $competitionsList = '';
} else {
    $competitionsList = competitionsList($competitionsGroups, $competitions);
}

// Left column begin

ob_start();
?>
    <div class="d-block d-md-none d-flex justify-content-start">
        <?php if ($event['is_preview_img']): ?>
            <div class="me-3">
                <img src="<?php echo $event['preview_img'] ?>" alt="<?php echo htmlspecialchars($event['title']) ?>"/>
            </div>
        <?php endif; ?>
        <div>
            <h2 class="fs-4"><?php echo htmlspecialchars($event['title']) ?></h2>
            <p class="text-muted"><?php echo $event['dates_desc'] ?></p>
        </div>
    </div>

    <div class="d-none d-md-block">
        <?php if ($event['preview_img_large']): ?>
            <img class="w-100 mb-3" src="<?php echo $event['preview_img_large'] ?>"
                 alt="<?php echo htmlspecialchars($event['title']) ?>"/>
        <?php endif; ?>
        <p class="text-muted"><?php echo $event['dates_desc'] ?></p>
    </div>

    <p><?php echo $event['announcement'] ?></p>
<?php
if (sizeof($eventsGroup) > 1): ?>
    <ul class="nav nav-pills mb-3">
        <?php foreach ($eventsGroup as $g): ?>
            <li class="nav-item nav-item-sm"><a class="nav-link <?php echo $g['is_current'] ? 'active"' : '' ?>"
                                                href="../<?php echo $g['alias'] ?>"
                                                title="<?php echo $g['title'] ?>"><?php echo $g['year'] ?></a>
            </li>
        <?php endforeach; ?>
    </ul>
<?php endif;
echo '<p>'.$event['content_column'].'</p>';
echo $uploadButton . ' ' . $liveVotingButton;
echo competitionsListShort($competitionsGroups, $competitions);
echo '<div class="mb-3"></div>';
NFWX::i()->mainLayoutLeftContent = ob_get_clean();

// Main content begin

echo '<h1 class="d-none d-md-block">' . htmlspecialchars($event['title']) . '</h1>';

echo $content . ' ' . $timetable . ' ' . $competitionsList;

function competitionsListShort($competitionsGroups, $competitions): string {
    ob_start();

    if (empty($competitionsGroups)) {
        foreach ($competitions as $c): ?>
            <div class="item">
                <div class="header">
                    <?php if ($c['is_link']): ?>
                        <a href="<?php echo NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] ?>"><?php echo htmlspecialchars($c['title']) ?></a>
                    <?php else: ?>
                        <a href="#<?php echo $c['alias'] ?>"><?php echo htmlspecialchars($c['title']) ?></a>
                    <?php endif; ?>
                </div>
                <div class="counter"><?php echo $c['count_label'] ?></div>
            </div>
        <?php endforeach;
        return '<div class="competitions-list-short">' . ob_get_clean() . '</div>';
    }

    foreach ($competitionsGroups as $group): ?>
        <div class="item">
            <div class="group-title">
                <a href="#<?php echo str_replace(" ", "_", htmlspecialchars($group['title'])) ?>"><?php echo htmlspecialchars($group['title']) ?></a>
            </div>
        </div>

        <?php foreach ($competitions as $c): if ($c['competitions_groups_id'] == $group['id']): ?>
            <div class="item item-subgroup">
                <div class="header">
                    <?php if ($c['is_link']): ?>
                        <a href="<?php echo NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] ?>"><?php echo htmlspecialchars($c['title']) ?></a>
                    <?php else: ?>
                        <a href="#<?php echo $c['alias'] ?>"><?php echo htmlspecialchars($c['title']) ?></a>
                    <?php endif; ?>
                </div>
                <div class="counter"><?php echo $c['count_label'] ?></div>
            </div>
        <?php endif; endforeach;
    endforeach;

    // Without group
    foreach ($competitions as $c): if ($c['competitions_groups_id'] == 0): ?>
        <div class="item">
            <div class="header">
                <?php if ($c['is_link']): ?>
                    <a href="<?php echo NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] ?>"><?php echo htmlspecialchars($c['title']) ?></a>
                <?php else: ?>
                    <a href="#<?php echo $c['alias'] ?>"><?php echo htmlspecialchars($c['title']) ?></a>
                <?php endif; ?>
            </div>
            <div class="counter"><?php echo $c['count_label'] ?></div>
        </div>
    <?php endif; endforeach;

    return '<div class="competitions-list-short">' . ob_get_clean() . '</div>';
}

function competitionsList($competitionsGroups, $competitions): string {
    if (empty($competitions)) {
        return "";
    }

    ob_start();
    if (empty($competitionsGroups)) {
        foreach ($competitions as $compo) {
            echo _compo($compo);
        }
        return '<div class="event-competitions">' . ob_get_clean() . '</div>';
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
                echo _compo($compo);
            }
        }
    }

    // Without group
    foreach ($competitions as $compo) {
        if ($compo['competitions_groups_id'] == 0) {
            echo _compo($compo);
        }
    }

    return '<div class="event-competitions">' . ob_get_clean() . '</div>';
}

function _compo($compo) {
    $langMain = NFW::i()->getLang('main');
    $receptionAvailable = $compo['reception_status']['now'] || $compo['reception_status']['future'];
    $votingAvailable = $compo['voting_status']['now'] || $compo['voting_status']['future'];

    ob_start();
    ?>
    <div id="<?php echo $compo['alias'] ?>" style="position: relative; top: -60px;"></div>
    <h3>
        <?php if ($compo['is_link']): ?>
            <a href="<?php echo NFW::i()->absolute_path . '/' . $compo['event_alias'] . '/' . $compo['alias'] ?>"><?php echo htmlspecialchars($compo['title']) ?></a>
        <?php else: ?>
            <?php echo htmlspecialchars($compo['title']) ?>
        <?php endif; ?>
        <small><?php echo $compo['count_label']?></small>
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

    <a class="d-block mb-3" href="<?php echo '#top' ?>">
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
