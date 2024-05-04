<?php
/**
 * @var $worksComments string Pre rendered works comments HTML content
 */

// Index page
$lang_main = NFW::i()->getLang('main');

$CEvents = new events();
$upcoming = $current = $past = array();
$lastEvents = $CEvents->getRecords(array('limit' => 5, 'load_media' => true));
foreach ($lastEvents as $record) {
    switch ($record['status_type']) {
        case 'upcoming':
            array_unshift($upcoming, $record);
            break;
        case 'current':
            $current[] = $record;
            break;
        default:
            $past[] = $record;
            break;
    }
}
?>
    <style>
        .index-current-event .competition {
            padding-top: 10px;
        }

        .index-current-event .competition .title {
            font-size: 18px;
            font-weight: bold;
        }

        .index-current-event .competition .info {
            font-size: 13px;
            color: #888;
        }
    </style>
<?php
if (!empty($current)) {
    foreach ($current as $record) {
        displayIndexEvent($record, 'full');
    }
}

if (!empty($upcoming)) {
    $layout = empty($current) || count($upcoming) < 2 ? 'big' : 'small';
    foreach ($upcoming as $record) {
        displayIndexEvent($record, $layout);
    }
}

echo '<div class="well well-sm">';
echo '<input id="works-search" class="form-control" placeholder="' . $lang_main['search hint'] . '" />';
echo '</div>';

if ($worksComments) {
    echo '<div class="hidden-md hidden-sm hidden-lg">';
    echo '<h2 class="index-head">' . $lang_main['latest comments'] . '</h2>';
    echo $worksComments;
    echo '<div style="margin-top: 20px; margin-bottom: 40px;">';
    echo '<a class="btn btn-lg btn-events-main" href="' . NFW::i()->base_path . 'comments.html">' . $lang_main['all comments'] . '</a>';
    echo '</div>';
    echo '</div>';
}

if (!empty($past)) {
    echo '<h2 class="index-head">' . $lang_main['latest events'] . '</h2>';
    foreach ($past as $record) {
        displayIndexEvent($record);
    }
}

if (count($lastEvents) > 0) {
    ?>
    <div style="margin-bottom: 40px; text-align: center;">
        <a class="btn btn-lg btn-primary btn-events-main"
           href="<?php echo NFW::i()->absolute_path ?>/events"><?php echo $lang_main['all events'] ?></a>
    </div>
    <?php
}

function displayIndexEvent($record, $layout = 'small'): void {
    switch ($layout) {
        case 'small':
            ?>
            <div style="padding-bottom: 20px;">
                <div style="display: table-row;">
                    <div style="display: table-cell; width: 80px; vertical-align: middle; text-align: left;">
                        <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><img class="media-object"
                                                                                            src="<?php echo $record['preview_img'] ?>"
                                                                                            alt=""/></a>
                    </div>
                    <div style="display: table-cell; vertical-align: middle;">
                        <h4 style="margin-bottom: 0;"><a
                                    href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                        </h4>
                        <div class="text-muted"><?php echo $record['dates_desc'] ?></div>
                        <div><?php echo $record['status_label'] ?></div>
                    </div>
                </div>
                <?php if ($record['announcement']): ?>
                    <p style="padding-top: 0.5em;"><?php echo nl2br($record['announcement']) ?></p>
                <?php endif; ?>
            </div>
            <?php
            break;
        case 'big':
            ?>
            <div style="padding-bottom: 50px;">
                <div class="row">
                    <div class="col-sm-12 col-md-5">
                        <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>">
                            <img src="<?php echo $record['preview_img_large'] ?: NFW::i()->assets('main/current-event-large.png') ?>"
                                 style="width: 100%; margin-top: 20px;" alt=""/>
                        </a>
                    </div>
                    <div class="col-sm-12 col-md-7">
                        <h2>
                            <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                        </h2>
                        <div style="font-weight: bold;"><?php echo $record['dates_desc'] ?></div>
                        <div style="font-size: 200%"><?php echo $record['status_label'] ?></div>
                        <?php if ($record['announcement']): ?>
                            <div style="padding-top: 20px;"><?php echo nl2br($record['announcement']) ?></div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
            <?php
            break;
        case 'full':
            $lang_main = NFW::i()->getLang('main');

            $competitions = array();
            $CCompetitions = new competitions();
            foreach ($CCompetitions->getRecords(array('filter' => array('event_id' => $record['id']))) as $c) {
                if ($c['voting_status']['available'] && $c['voting_works']) {
                    $c['count_label'] = $c['voting_works'] < 3 ? '<span class="label label-warning">' . $c['voting_works'] . '</span>' : '<span class="label label-success">' . $c['voting_works'] . '</span>';
                    $competitions[] = $c;
                }
            }
            ?>
            <div class="index-current-event" style="padding-bottom: 20px;">
                <div class="row">
                    <div class="col-sm-12 col-md-5">
                        <img src="<?php echo $record['preview_img_large'] ?: NFW::i()->assets('main/current-event-large.png') ?>"
                             style="width: 100%; margin-top: 20px;" alt=""/>
                    </div>
                    <div class="col-sm-12 col-md-7">
                        <h2>
                            <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                        </h2>
                        <div style="font-weight: bold;"><?php echo $record['dates_desc'] ?></div>
                        <div style="font-size: 200%"><?php echo $record['status_label'] ?></div>
                        <?php if ($record['announcement']): ?>
                            <div style="padding-top: 20px;"><?php echo nl2br($record['announcement']) ?></div>
                        <?php endif; ?>
                    </div>
                </div>

                <?php if (!empty($competitions)): ?>
                    <div class="hidden-sm hidden-md hidden-lg">
                        <?php foreach ($competitions as $c) { ?>
                            <div class="competition">
                                <div class="title"><a
                                            href="<?php echo NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] ?>"><?php echo htmlspecialchars($c['title']) ?></a>
                                </div>
                                <div class="info">
                                    <div>
                                        <?php echo $lang_main['competitions voting'] ?>:
                                        <span class="<?php echo $c['voting_status']['text-class'] ?>"><strong><?php echo $c['voting_status']['desc'] ?></strong></span>
                                    </div>
                                </div>
                            </div>
                        <?php } ?>
                    </div>

                    <table class="table table-condensed hidden-xs">
                        <thead>
                        <tr>
                            <th><?php echo $lang_main['competition'] ?></th>
                            <th><?php echo $lang_main['competitions type'] ?></th>
                            <th class="r"><?php echo $lang_main['competitions voting'] ?></th>
                            <th class="r"><?php echo $lang_main['competitions approved works-short'] ?></th>
                        </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($competitions as $c) { ?>
                            <tr>
                                <td class="nw"><a
                                            href="<?php echo NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] ?>"><?php echo htmlspecialchars($c['title']) ?></a>
                                </td>
                                <td class="nw"><em><?php echo $c['works_type'] ?></em></td>
                                <td class="nw r <?php echo $c['voting_status']['text-class'] ?>"><?php echo $c['voting_status']['desc'] ?></td>
                                <td class="nw r"><?php echo $c['count_label'] ?></td>
                            </tr>
                        <?php } ?>
                    </table>
                <?php endif; ?>
            </div>
            <?php
            break;
    }
}
	