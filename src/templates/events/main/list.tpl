<?php
/**
 * @var array $events
 */

$top = '#top';

$years = [];
foreach ($events as $record) {
    if (!in_array(date('Y', $record['date_from']), $years)) {
        $years[] = date('Y', $record['date_from']);
    }
}
$currentYear = 0;
?>
<div class="d-grid mx-auto col-lg-8">
    <div class="mb-3">
        <?php foreach ($years as $y): $dis = $y == date('Y', $events[0]['date_from']) ? 'disabled' : '' ?>
            <a class="btn btn-info <?php echo $dis ?>" href="#<?php echo $y ?>"><?php echo $y ?></a>
        <?php endforeach; ?>
    </div>

    <?php foreach ($events as $record):
        $y = date('Y', $record['date_from']);
        if ($y != $currentYear) {
            if ($currentYear) {
                echo '<a class="d-block mb-3 text-info" href="' . $top . '">
    <svg width="2em" height="2em">
        <use href="#icon-caret-up"></use>
    </svg>
    </a>';
            }
            $currentYear = $y;
            echo '<div id="' . $y . '" style="position: relative; top: -30px;">&nbsp;</div>';
            echo '<h2 id="' . $y . '" class="index-head">' . $y . '</h2>';
        }

        ?>
        <div class="table-row">
            <div class="align-top text-left" style="display: table-cell; width: 80px;"><a
                        href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><img class="media-object"
                                                                                         src="<?php echo $record['preview_img'] ?>"
                                                                                         alt=""/></a>
            </div>
            <div class="align-middle text-left" style="display: table-cell;"><h4><a
                            href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                </h4>
                <div class="text-muted"><?php echo $record['dates_desc'] ?></div>
            </div>
        </div>
        <div class="mb-5"><?php echo nl2br($record['announcement']) ?></div>
    <?php endforeach;
    echo '<a class="d-block mb-3 text-info" href="' . $top . '">
    <svg width="2em" height="2em">
        <use href="#icon-caret-up"></use>
    </svg>
    </a>';
    ?>
</div>