<?php
/**
 * @var array $event
 * @var array $competitions
 * @var array $competitionsGroups
 * @var string $content
 */

// Preparing competitions
$langMain = NFW::i()->getLang('main');
foreach ($competitions as $key => $c) {
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
        $competitions[$key]['count_label'] = '<span class="label label-default" title="' . $langMain['competitions received works'] . '">?</span>';
        $competitions[$key]['count_in_title'] = '';
    } elseif (!$counter) {
        $competitions[$key]['count_label'] = '<span class="label label-default" title="' . $langMain['competitions received works'] . '">' . $counter . '</span>';
        $competitions[$key]['count_in_title'] = ' (' . $counter . ')';
    } elseif ($counter < 3) {
        $competitions[$key]['count_label'] = '<span class="label label-warning" title="' . $langMain['competitions received works'] . '">' . $counter . '</span>';
        $competitions[$key]['count_in_title'] = ' (' . $counter . ')';
    } else {
        $competitions[$key]['count_label'] = '<span class="label label-success" title="' . $langMain['competitions received works'] . '">' . $counter . '</span>';
        $competitions[$key]['count_in_title'] = ' (' . $counter . ')';
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

if (sizeof($eventsGroup) > 1): ?>
    <nav aria-label="...">
        <ul class="pagination pagination-sm">
            <?php foreach ($eventsGroup as $g): ?>
                <li <?php echo $g['is_current'] ? 'class="active"' : '' ?>><a href="../<?php echo $g['alias'] ?>"
                                                                              title="<?php echo $g['title'] ?>"><?php echo $g['year'] ?></a>
                </li>
            <?php endforeach; ?>
        </ul>
    </nav>
<?php endif;

if (stristr($content, '%COMPETITIONS-LIST-SHORT%')) {
    $content = str_replace('%COMPETITIONS-LIST-SHORT%', competitionsListShort($competitionsGroups, $competitions), $content);
}

if (stristr($content, '%COMPETITIONS-LIST%')) {
    $content = str_replace('%COMPETITIONS-LIST%', competitionsList($competitionsGroups, $competitions), $content);
    echo $content;
} else {
    echo $content . competitionsList($competitionsGroups, $competitions);
}


function competitionsListShort($competitionsGroups, $competitions) {
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
        return ob_get_clean();
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

    return ob_get_clean();
}

function competitionsList($competitionsGroups, $competitions): string {
    if (empty($competitions)) {
        return "";
    }

    ob_start();
    if (empty($competitionsGroups)) {
        foreach ($competitions as $compo) {
            echo competitionsListCompo($compo);
        }
        return '<div class="event-competitions">' . ob_get_clean() . '</div>';
    }

    foreach ($competitionsGroups as $group) {
?>
        <div id="<?php echo str_replace(" ", "_", htmlspecialchars($group['title'])) ?>" style="position: relative; top: -60px;"></div>
        <h2><?php echo htmlspecialchars($group['title']) ?></h2>
        <?php echo $group['announcement'] ?>
<?php
        foreach ($competitions as $compo) {
            if ($compo['competitions_groups_id'] == $group['id']) {
                echo competitionsListCompo($compo);
            }
        }
    }

    // Without group
    foreach ($competitions as $compo) {
        if ($compo['competitions_groups_id'] == 0) {
            echo competitionsListCompo($compo);
        }
    }

    return '<div class="event-competitions">'.ob_get_clean().'</div>';
}

function competitionsListCompo($compo) {
    $langMain = NFW::i()->getLang('main');

    ob_start();
    ?>
    <div id="<?php echo $compo['alias'] ?>" style="position: relative; top: -60px;"></div>
    <h3>
        <?php if ($compo['is_link']): ?>
            <a href="<?php echo NFW::i()->absolute_path . '/' . $compo['event_alias'] . '/' . $compo['alias'] ?>"><?php echo htmlspecialchars($compo['title']) . $compo['count_in_title'] ?></a>
        <?php else: ?>
            <?php echo htmlspecialchars($compo['title']) . $compo['count_in_title'] ?>
        <?php endif; ?>
    </h3>

    <p><?php echo nl2br($compo['announcement']) ?></p>

    <div class="panel panel-default">
        <div class="panel-body">
            <p><?php echo $langMain['competitions reception'] ?>:
                <?php if ($compo['reception_from']): ?>
                    <span class="hidden-xs">
                                <strong><?php echo date('d.m.Y H:i', $compo['reception_from']) . ' - ' . date('d.m.Y H:i', $compo['reception_to']) ?></strong>
                            </span>
                <?php endif; ?>
                <span class="label <?php echo $compo['reception_status']['label-class'] ?>"><?php echo $compo['reception_status']['desc'] ?></span>
                <?php if ($compo['reception_from']): ?>
                    <span class="visible-xs">
                                <small class="text-muted" style="display: block; padding-top: 5px;">
                                    <?php echo date('d.m.Y H:i', $compo['reception_from']) . ' - ' . date('d.m.Y H:i', $compo['reception_to']) ?>
                                </small>
                            </span>
                <?php endif; ?>
            </p>
            <p><?php echo $langMain['competitions voting'] ?>:
                <?php if ($compo['voting_from']): ?>
                    <span class="hidden-xs">
                                <strong><?php echo date('d.m.Y H:i', $compo['voting_from']) . ' - ' . date('d.m.Y H:i', $compo['voting_to']) ?></strong>
                            </span>
                <?php endif; ?>
                <span class="label <?php echo $compo['voting_status']['label-class'] ?>"><?php echo $compo['voting_status']['desc'] ?></span>
                <?php if ($compo['voting_from']): ?>
                    <span class="visible-xs">
                            <small class="text-muted" style="display: block; padding-top: 5px;">
                                <?php echo date('d.m.Y H:i', $compo['voting_from']) . ' - ' . date('d.m.Y H:i', $compo['voting_to']) ?>
                            </small>
                        </span>
                <?php endif; ?>
            </p>
        </div>
    </div>

    <div style="font-size: 200%;"><a href="#top"><span class="fa fa-caret-up"></span></a></div>
    <?php
    return ob_get_clean();
}