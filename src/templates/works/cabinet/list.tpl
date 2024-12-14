<?php
/**
 * @var array $records
 * @var array $unread
 */

$langMain = NFW::i()->getLang('main');
NFW::i()->assign('page_title', $langMain['cabinet prods']);

if (empty($records)) {
    ?>
    <div class="p-5 mb-4 bg-body-tertiary rounded-3">
        <div class="container-fluid py-5">
            <h1 class="display-5 fw-bold">Hey, <?php echo htmlspecialchars(NFW::i()->user['realname']) ?>!</h1>
            <p class="col-md-8 fs-4"><?php echo $langMain['works empty'] ?></p>
            <a href="<?php echo NFW::i()->base_path?>cabinet/works_add" class="btn btn-primary btn-lg"
               type="button"><?php echo $langMain['cabinet add work'] ?></a>
        </div>
    </div>
    <?php
    return;
}

NFW::i()->registerFunction('cache_media');

$top = '#top';

$years = [];
$currentYear = 0;
if (count($records) >= 10) {
    foreach ($records as $record) {
        if (!in_array(date('Y', $record['event_from']), $years)) {
            $years[] = date('Y', $record['event_from']);
        }
    }
}
$isYears = count($years) > 1;

echo NFW::i()->fetch(NFW::i()->findTemplatePath('_common_status_icons.tpl'));
?>
<div class="d-grid mx-auto col-lg-8">
    <h2 class="index-head mb-5"><?php echo $langMain['cabinet prods'] ?></h2>

    <?php if ($isYears): ?>
        <div class="mb-3">
            <?php foreach ($years as $y): $dis = $y == date('Y', $records[0]['event_from']) ? 'disabled' : '' ?>
                <a class="mb-1 btn btn-secondary <?php echo $dis ?>" href="#<?php echo $y ?>"><?php echo $y ?></a>
            <?php endforeach; ?>
        </div>
    <?php endif; ?>

    <?php foreach ($records as $work):
        if ($isYears) {
            $y = date('Y', $work['event_from']);
            if ($y != $currentYear) {
                if ($currentYear) {
                    echo '<a class="d-block mb-3 text-secondary-emphasis" href="' . $top . '">
    <svg width="2em" height="2em">
        <use href="#icon-caret-up"></use>
    </svg>
    </a>';
                }
                $currentYear = $y;
                echo '<section id="' . $y . '"></section><h2 class="index-head">' . $y . '</h2>';
            }
        }

        $alert = '';
        if ($work['status_info']['css-class'] !== "success" || $work['status_reason']) {
            $alertTitle = $work['status_info']['desc'];
            $alertText = $work['status_reason'] ?: $work['status_info']['desc_full'];
            $alert = '
<div class="alert alert-' . $work['status_info']['css-class'] . ' d-flex align-items-center mt-2" role="alert">
    <svg class="flex-shrink-0 me-2" width="1em" height="1em" data-bs-toggle="tooltip" data-bs-title="' . $work['status_info']['desc'] . '">
        <use xlink:href="#' . $work['status_info']['svg-icon'] . '"/>
    </svg>
    <div>' . $alertText . '</div>
</div>';
        }

        $url = NFW::i()->base_path . 'cabinet/works_view?record_id=' . $work['id'];

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

        $spanUnread = '';
        if (isset($unread[$work['id']]) && $unread[$work['id']] > 0) {
            $spanUnread = '<span class="ms-2 badge rounded-pill bg-warning">'.$unread[$work['id']].'</span>';
        }

        ?>
        <div class="table-row mb-3">
            <div class="align-top text-left pt-2" style="display: table-cell; width: 80px;"><a
                    href="<?php echo $url ?>"><img class="media-object" alt=""
                                                   src="<?php echo $work['screenshot'] ? $work['screenshot']['tmb_prefix'] . '64' : NFW::i()->assets('main/news-no-image.png') ?>"/></a>
            </div>
            <div class="align-middle text-left" style="display: table-cell;"><h4><a
                        href="<?php echo $url ?>"><?php echo htmlspecialchars($work['title']).$spanUnread ?></a>
                </h4>
                <div class="d-none d-sm-block me-1 text-muted text-muted">
                    <?php echo $ePrefix . $work['event_title'] . ' / ' . $work['competition_title'] ?>
                </div>
            </div>
            <div class="d-block d-sm-none my-1 text-muted">
                <?php echo $ePrefix . $work['event_title'] . ' / ' . $work['competition_title'] ?>
            </div>
            <?php echo $alert ?>
        </div>
    <?php endforeach; ?>
    <?php if ($isYears): ?>
        <a class="d-block mb-3 text-secondary-emphasis" href="<?php echo $top ?>">
            <svg width="2em" height="2em">
                <use href="#icon-caret-up"></use>
            </svg>
        </a>
    <?php endif; ?>
</div>

