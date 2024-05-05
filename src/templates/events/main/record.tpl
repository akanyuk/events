<?php
/**
 * @var array $event
 * @var array $competitions
 * @var string $content
 */

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

if (!empty($competitions)) {
    $lang_main = NFW::i()->getLang('main');

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
            $competitions[$key]['count_label'] = '<span class="label label-default" title="' . $lang_main['competitions received works'] . '">?</span>';
            $competitions[$key]['count_in_title'] = '';
        } elseif (!$counter) {
            $competitions[$key]['count_label'] = '<span class="label label-default" title="' . $lang_main['competitions received works'] . '">' . $counter . '</span>';
            $competitions[$key]['count_in_title'] = ' (' . $counter . ')';
        } elseif ($counter < 3) {
            $competitions[$key]['count_label'] = '<span class="label label-warning" title="' . $lang_main['competitions received works'] . '">' . $counter . '</span>';
            $competitions[$key]['count_in_title'] = ' (' . $counter . ')';
        } else {
            $competitions[$key]['count_label'] = '<span class="label label-success" title="' . $lang_main['competitions received works'] . '">' . $counter . '</span>';
            $competitions[$key]['count_in_title'] = ' (' . $counter . ')';
        }
    }

    ob_start();
    ?>
    <div class="event-competitions">
        <?php foreach ($competitions as $c) { ?>
            <div id="<?php echo $c['alias'] ?>" style="position: relative; top: -60px;"></div>
            <h3>
                <?php if ($c['is_link']): ?>
                    <a href="<?php echo NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] ?>"><?php echo htmlspecialchars($c['title'])  . $c['count_in_title'] ?></a>
                <?php else: ?>
                    <?php echo htmlspecialchars($c['title']) . $c['count_in_title'] ?>
                <?php endif; ?>
            </h3>

            <p><?php echo nl2br($c['announcement']) ?></p>

            <div class="panel panel-default">
                <div class="panel-body">
                    <p><?php echo $lang_main['competitions reception'] ?>:
                        <?php if ($c['reception_from']): ?>
                            <span class="hidden-xs">
                                <strong><?php echo date('d.m.Y H:i', $c['reception_from']) . ' - ' . date('d.m.Y H:i', $c['reception_to']) ?></strong>
                            </span>
                        <?php endif; ?>
                        <span class="label <?php echo $c['reception_status']['label-class'] ?>"><?php echo $c['reception_status']['desc'] ?></span>
                        <?php if ($c['reception_from']): ?>
                            <span class="visible-xs">
                                <small class="text-muted" style="display: block; padding-top: 5px;">
                                    <?php echo date('d.m.Y H:i', $c['reception_from']) . ' - ' . date('d.m.Y H:i', $c['reception_to']) ?>
                                </small>
                            </span>
                        <?php endif; ?>
                    </p>
                    <p><?php echo $lang_main['competitions voting'] ?>:
                        <?php if ($c['voting_from']): ?>
                            <span class="hidden-xs">
                                <strong><?php echo date('d.m.Y H:i', $c['voting_from']) . ' - ' . date('d.m.Y H:i', $c['voting_to']) ?></strong>
                            </span>
                        <?php endif; ?>
                        <span class="label <?php echo $c['voting_status']['label-class'] ?>"><?php echo $c['voting_status']['desc'] ?></span>
                        <?php if ($c['voting_from']): ?>
                            <span class="visible-xs">
                            <small class="text-muted" style="display: block; padding-top: 5px;">
                                <?php echo date('d.m.Y H:i', $c['voting_from']) . ' - ' . date('d.m.Y H:i', $c['voting_to']) ?>
                            </small>
                        </span>
                        <?php endif; ?>
                    </p>
                </div>
            </div>

            <p><a href="#top">▲</a></p>
        <?php } ?>
    </div>
    <?php
    $competitionsList = ob_get_clean();

    ob_start();
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
    $competitionsListShort = ob_get_clean();
} else {
    $competitionsList = '';
    $competitionsListShort = '';
}

if (stristr($content, '%COMPETITIONS-LIST-SHORT%')) {
    $content = str_replace('%COMPETITIONS-LIST-SHORT%', $competitionsListShort, $content);
}

if (sizeof($eventsGroup) > 1): ?>
    <nav aria-label="...">
        <ul class="pagination pagination-sm">
        <?php foreach ($eventsGroup as $g): ?>
            <li <?php echo $g['is_current'] ? 'class="active"' : ''?>><a href="../<?php echo $g['alias'] ?>" title="<?php echo $g['title'] ?>"><?php echo $g['year'] ?></a></li>
        <?php endforeach; ?>
        </ul>
    </nav>
<?php endif;

if (stristr($content, '%COMPETITIONS-LIST%')) {
    $content = str_replace('%COMPETITIONS-LIST%', $competitionsList, $content);
    echo $content;
} else {
    echo $content . $competitionsList;
}