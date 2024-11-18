<?php
/** @var works $Module */

$langMain = NFW::i()->getLang('main');
$langMedia = NFW::i()->getLang('media');

NFW::i()->assign('page_title', $Module->record['title'] . ' / ' . $langMain['cabinet prods']);
NFW::i()->breadcrumb = array(
    array('url' => 'cabinet/works_list', 'desc' => $langMain['cabinet prods']),
    array('desc' => $Module->record['title'] . ' by ' . $Module->record['author'])
);
NFW::i()->breadcrumb_status = $Module->record['event_title'] . '&nbsp;/ ' . $Module->record['competition_title'];

NFW::i()->registerFunction('display_work_media');

$CCompetitions = new competitions($Module->record['competition_id']);

// Is the prod visible in public
if ($CCompetitions->record['voting_status']['available'] && $Module->record['status_info']['voting']) {
    $isPublished = true;
} else if ($CCompetitions->record['release_status']['available'] && $Module->record['status_info']['release']) {
    $isPublished = true;
} else {
    $isPublished = false;
}

echo NFW::i()->fetch(NFW::i()->findTemplatePath('_common_status_icons.tpl'));
?>
    <div class="d-md-none">
        <?php echo startBlock($Module->record, $isPublished); ?>
    </div>

    <div class="badge text-bg-danger">PREVIEW!</div>
    <hr class="mt-0"/>
<?php echo display_work_media($Module->record, array('rel' => 'preview')); ?>
    <hr class="d-md-none mt-0"/>

<?php ob_start(); ?>
    <div class="d-none d-md-block">
        <?php echo startBlock($Module->record, $isPublished); ?>
    </div>

    <dl class="mb-5">
        <dt><?php echo NFW::i()->lang['Posted'] ?>:</dt>
        <dd><?php echo date('d.m.Y H:i:s', $Module->record['posted']) . ' (' . $Module->record['posted_username'] . ')' ?></dd>
        <?php if ($Module->record['edited']): ?>
            <dt><?php echo NFW::i()->lang['Updated'] ?>:</dt>
            <dd><?php echo date('d.m.Y H:i:s', $Module->record['edited']) . ' (' . $Module->record['edited_username'] . ')' ?></dd>
        <?php endif; ?>
    </dl>

    <h2 class="index-head mb-3"><?php echo $langMain['works files'] ?></h2>
<?php
$CMedia = new media();
echo $CMedia->openSession(array(
    'owner_id' => $Module->record['id'],
    'owner_class' => get_class($Module),
    'secure_storage' => true,
    'template' => '_cabinet_add_work_media',
    'after_upload' => 'cabinet_work_media_added',
));
NFWX::i()->mainLayoutRightContent = ob_get_clean();

function startBlock(array $record, bool $isPublished): string {
    $langMain = NFW::i()->getLang('main');
    ob_start();
    ?>
    <div class="alert alert-<?php echo $record['status_info']['css-class'] ?> d-flex align-items-center"
         role="alert">
        <svg class="flex-shrink-0 me-2" width="1em" height="1em" data-bs-toggle="tooltip"
             data-bs-title="<?php echo $record['status_info']['desc'] ?>">
            <use xlink:href="#<?php echo $record['status_info']['svg-icon'] ?>"/>
        </svg>
        <div><?php echo $record['status_reason'] ?: $record['status_info']['desc_full'] ?></div>
    </div>

    <?php if ($isPublished):
        $permalink = NFW::i()->absolute_path . '/' . $record['event_alias'] . '/' . $record['competition_alias'] . '/' . $record['id'];
        ?>
        <div class="d-grid mb-3">
            <a class="btn btn-lg btn-primary"
               href="<?php echo $permalink ?>#title"><?php echo $langMain['works permanent link'] ?></a>
        </div>
    <?php endif;

    return ob_get_clean();
}