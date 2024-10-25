<?php
/**
 * @var array $records
 */

$langMain = NFW::i()->getLang('main');
NFW::i()->assign('page_title', $langMain['cabinet prods']);

if (empty($records)) {
    ?>
    <div class="p-5 mb-4 bg-body-tertiary rounded-3">
        <div class="container-fluid py-5">
            <h1 class="display-5 fw-bold">Hey, <?php echo htmlspecialchars(NFW::i()->user['realname']) ?>!</h1>
            <p class="col-md-8 fs-4"><?php echo $langMain['works empty'] ?></p>
            <a href="?action=add" class="btn btn-primary btn-lg"
               type="button"><?php echo $langMain['cabinet add work'] ?></a>
        </div>
    </div>
    <?php
    return;
}

$noImage = NFW::i()->assets('main/current-event-large.png');
NFW::i()->registerFunction('cache_media');

$top = '#top';

$years = [];
foreach ($records as $record) {
    if (!in_array(date('Y', $record['event_from']), $years)) {
        $years[] = date('Y', $record['event_from']);
    }
}
$currentYear = 0;

echo NFW::i()->fetch(NFW::i()->findTemplatePath('_common_status_icons.tpl'));
?>
<div class="d-grid mx-auto col-sm-10 col-md-8">
    <?php if (count($years) > 1):?>
        <div class="mb-3">
            <?php foreach ($years as $y): $dis = $y == date('Y', $records[0]['event_from']) ? 'disabled' : '' ?>
                <a class="mb-1 btn btn-info <?php echo $dis ?>" href="#<?php echo $y ?>"><?php echo $y ?></a>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>

    <?php foreach ($records as $work):
        $y = date('Y', $work['event_from']);
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

        $alert = '';
        if ($work['status_info']['css-class'] !== "success" || $work['status_reason']) {
            $alertTitle = $work['status_info']['desc'];
            $alertText = $work['status_reason'] ?: $work['status_info']['desc_full'];
            $alert = '
<div class="alert alert-' . $work['status_info']['css-class'] . ' d-flex align-items-center" role="alert">
    <svg class="flex-shrink-0 me-2" width="1em" height="1em" data-bs-toggle="tooltip" data-bs-title="' . $work['status_info']['desc'] . '">
        <use xlink:href="#'.$work['status_info']['svg-icon'].'"/>
    </svg>
    <div>' . $alertText . '</div>
</div>';
        }

        $url = NFW::i()->base_path . 'cabinet/works?action=view&record_id=' . $work['id'];
        $title = $work['title'] . ' by ' . $work['author'];

        $platformFormat = '<div class="badge badge-platform me-1 mb-2" title="' . $langMain['works platform'] . '">' . htmlspecialchars($work['platform']) . '</div>';
        if ($work['format']) {
            $platformFormat .= '<div class="badge badge-format" title="' . $langMain['works format'] . '">' . htmlspecialchars($work['format']) . '</div>';
        }

        switch ($work['place']) {
            case 0:
                $ePrefix = '';
                break;
            case 1:
                $ePrefix = '<strong>' . $work['place'] . 'st</strong>&nbsp;at ';
                break;
            case 2:
                $ePrefix = '<strong>' . $work['place'] . 'nd</strong>&nbsp;at ';
                break;
            case 3:
                $ePrefix = '<strong>' . $work['place'] . 'rd</strong>&nbsp;at ';
                break;
            default:
                $ePrefix = '<strong>' . $work['place'] . 'th</strong>&nbsp;at ';
                break;
        }

        ?>
        <div class="card card-comment mb-3">
            <a href="<?php echo $url ?>"><img
                    src="<?php echo $work['screenshot'] ? cache_media($work['screenshot']) : $noImage ?>"
                    class="card-img-top mt-0 mt-md-2 pe-md-3 <?php echo $work['screenshot'] ? '' : 'no-screenshot' ?>"
                    alt=""></a>
            <div class="card-body px-0 pt-md-0">
                <p class="lead"><a
                        href="<?php echo $url ?>"><?php echo htmlspecialchars($title) ?></a>
                </p>
                <?php echo $platformFormat ?>
                <p><?php echo $ePrefix . $work['event_title'] ?> /
                    <?php echo $work['competition_title'] ?></p>

                <?php echo $alert ?>
            </div>
        </div>
        <?php

        next($records);
        if (key($records) !== null && !$records[key($records)]['screenshot']) {
            echo '<hr class="comment-delimiter"/>';
        }
    endforeach;
    ?>
</div>

