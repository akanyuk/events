<?php
/**
 * @var bool $showWorksCount
 * @var array $competition
 */
$lang_main = NFW::i()->getLang('main');

if ($competition['voting_works'] >= 3) {
    $worksLabelClass = 'label-success';
} elseif ($competition['voting_works'] > 0) {
    $worksLabelClass = 'label-warning';
} else {
    $worksLabelClass = 'label-default';
}

?>
<p><?php echo nl2br($competition['announcement']) ?></p>

<table class="table table-compo-status">
    <tbody>
    <?php if ($competition['reception_from']): ?>
        <tr>
            <td class="title"><?php echo $lang_main['competitions reception'] ?></td>
            <td>
                <span class="label <?php echo $competition['reception_status']['label-class'] ?>"><strong><?php echo $competition['reception_status']['desc'] ?></strong></span>
            </td>
            <td class="dates"><?php echo date('d.m.Y H:i', $competition['reception_from']) . ' - ' . date('d.m.Y H:i', $competition['reception_to']) ?></td>
        </tr>
    <?php endif; ?>
    <?php if ($competition['voting_from']): ?>
        <tr>
            <td class="title"><?php echo $lang_main['competitions voting'] ?></td>
            <td>
                <span class="label <?php echo $competition['voting_status']['label-class'] ?>"><strong><?php echo $competition['voting_status']['desc'] ?></strong></span>
            </td>
            <td class="dates"><?php echo date('d.m.Y H:i', $competition['voting_from']) . ' - ' . date('d.m.Y H:i', $competition['voting_to']) ?></td>
        </tr>
    <?php endif; ?>
    <?php if ($showWorksCount): ?>
        <tr>
            <td class="title"><?php echo $lang_main['competitions approved works'] ?></td>
            <td>
                <span class="label <?php echo $worksLabelClass ?>"><strong><?php echo $competition['voting_works'] ?></strong></span>
            </td>
            <td>&nbsp;</td>
        </tr>
    <?php endif; ?>
    </tbody>
</table>

<div class="compo-status-mobile">
    <?php if ($competition['reception_from']): ?>
        <div class="pull-left">
            <div class="title"><?php echo $lang_main['competitions reception'] ?></div>
        </div>
        <div class="pull-right">
            <span class="label <?php echo $competition['reception_status']['label-class'] ?>"><strong><?php echo $competition['reception_status']['desc'] ?></strong></span>
        </div>
        <div class="clearfix"></div>

        <div class="dates">
            <?php echo date('d.m.Y H:i', $competition['reception_from']) . ' - ' . date('d.m.Y H:i', $competition['reception_to']) ?>
        </div>
    <?php endif; ?>
    <?php if ($competition['voting_from']): ?>
        <div class="pull-left">
            <div class="title"><?php echo $lang_main['competitions voting'] ?></div>
        </div>
        <div class="pull-right">
            <span class="label <?php echo $competition['voting_status']['label-class'] ?>"><strong><?php echo $competition['voting_status']['desc'] ?></strong></span>
        </div>
        <div class="clearfix"></div>
        <div class="dates">
            <?php echo date('d.m.Y H:i', $competition['voting_from']) . ' - ' . date('d.m.Y H:i', $competition['voting_to']) ?>
        </div>
    <?php endif; ?>
    <?php if ($showWorksCount): ?>
        <div class="pull-left">
            <div class="title"><?php echo $lang_main['competitions approved works'] ?></div>
        </div>
        <div class="pull-right">
            <span class="label <?php echo $worksLabelClass ?>"><strong><?php echo $competition['voting_works'] ?></strong></span>
        </div>
        <div class="clearfix"></div>
    <?php endif; ?>
</div>
