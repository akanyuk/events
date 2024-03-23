<?php
$lang_main = NFW::i()->getLang('main');

NFW::i()->assign('page_title', $lang_main['cabinet prods']);

NFW::i()->breadcrumb = array(
    array('desc' => $lang_main['cabinet prods']),
);

if (empty($records)) {
    ?>
    <div class="jumbotron">
        <h1>Hey, <?php echo htmlspecialchars(NFW::i()->user['realname']) ?>!</h1>
        <p><?php echo $lang_main['works empty'] ?></p>
        <p><a href="?action=add" class="btn btn-primary btn-lg"
              role="button"><?php echo $lang_main['cabinet add work'] ?></a></p>
    </div>
    <?php
    return;
}

?>
<table class="table table-condensed">
    <?php foreach ($records as $r): ?>
        <?php
        switch ($r['place']) {
            case 0:
                $ePrefix = '';
                break;
            case 1:
                $ePrefix = '<span class="label label-place">'.$r['place'] . 'st</span>&nbsp;at ';
                break;
            case 2:
                $ePrefix = '<span class="label label-place">'.$r['place'] . 'nd</span>&nbsp;at ';
                break;
            case 3:
                $ePrefix = '<span class="label label-place">'.$r['place'] . 'rd</span>&nbsp;at ';
                break;
            default:
                $ePrefix = '<span class="label label-place">'.$r['place'] . 'th</span>&nbsp;at ';
                break;
        }
        ?>
        <tr class="<?php echo $r['status_info']['css-class'] == "success" ? "" : $r['status_info']['css-class'] ?>"
            title="<?php echo $r['status_info']['desc'] ?>">
            <td>
                <a href="<?php echo NFW::i()->base_path . 'cabinet/works?action=view&record_id=' . $r['id'] ?>">
                    <img src="<?php echo $r['screenshot'] ? $r['screenshot']['tmb_prefix'] . '64' : NFW::i()->assets('main/news-no-image.png') ?>"
                         alt=""/>
                </a>
            </td>
            <td style="width:100%;">
                <a href="<?php echo NFW::i()->base_path . 'cabinet/works?action=view&record_id=' . $r['id'] ?>">
                    <?php echo htmlspecialchars($r['title']) . ' by&nbsp;' . htmlspecialchars($r['author']) ?>
                </a>

                <div>
                    <?php echo $ePrefix . htmlspecialchars($r['event_title']) . ', ' . htmlspecialchars($r['competition_title']) ?>
                </div>

                <?php if ($r['status_reason']): ?>
                    <div class="text-warning small"><span class="fa fa-exclamation-triangle"></span> <?php echo $r['status_reason'] ?></div>
                <?php endif ?>
            </td>
            <td style="text-align: center;">
                <div class="label label-platform"><?php echo htmlspecialchars($r['platform']) ?></div>
                <?php if ($r['format']): ?>
                    <div class="label label-format"><?php echo htmlspecialchars($r['format']) ?></div>
                <?php endif; ?>
            </td>
        </tr>
    <?php endforeach; ?>
</table>
