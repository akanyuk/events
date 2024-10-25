<?php
/** @var works $Module */

$langMain = NFW::i()->getLang('main');

NFW::i()->assign('page_title', $Module->record['title'] . ' / ' . $langMain['cabinet prods']);
NFW::i()->breadcrumb = array(
    array('url' => 'cabinet/works?action=list', 'desc' => $langMain['cabinet prods']),
    array('desc' => $Module->record['title'] . ' by ' . $Module->record['author'])
);

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
    <div class="mb-3 badge text-bg-danger">Preview!</div>
<?php echo display_work_media($Module->record, array('rel' => 'preview')); ?>

<?php ob_start(); ?>
    <div class="alert alert-<?php echo $Module->record['status_info']['css-class'] ?> d-flex align-items-center"
         role="alert">
        <svg class="flex-shrink-0 me-2" width="1em" height="1em" data-bs-toggle="tooltip"
             data-bs-title="<?php echo $Module->record['status_info']['desc'] ?>">
            <use xlink:href="#<?php echo $Module->record['status_info']['svg-icon'] ?>"/>
        </svg>
        <div><?php echo $Module->record['status_reason'] ?: $Module->record['status_info']['desc_full'] ?></div>
    </div>

<?php if ($isPublished): $permalink = NFW::i()->absolute_path . '/' . $Module->record['event_alias'] . '/' . $Module->record['competition_alias'] . '/' . $Module->record['id']; ?>
    <div class="d-grid d-sm-block mb-3">
        <a class="btn btn-primary" href="<?php echo $permalink ?>"><?php echo $langMain['works permanent link'] ?></a>
    </div>
<?php endif; ?>

    <dl>
        <dt><?php echo $langMain['event'] ?></dt>
        <dd><?php echo $Module->record['event_title'] ?></dd>
        <dt><?php echo $langMain['competition'] ?></dt>
        <dd><?php echo $Module->record['competition_title'] ?></dd>

        <dt><?php echo NFW::i()->lang['Posted'] ?>:</dt>
        <dd><?php echo date('d.m.Y H:i:s', $Module->record['posted']) . ' (' . $Module->record['posted_username'] . ')' ?></dd>
        <?php if ($Module->record['edited']): ?>
            <dt><?php echo NFW::i()->lang['Updated'] ?>:</dt>
            <dd><?php echo date('d.m.Y H:i:s', $Module->record['edited']) . ' (' . $Module->record['edited_username'] . ')' ?></dd>
        <?php endif; ?>
    </dl>
<?php
NFWX::i()->mainLayoutRightContent = ob_get_clean();

ob_start();
?>
    <h3><?php echo $langMain['works files'] ?></h3>
    <table class="table table-condensed table-striped work-files-list">
        <tbody>
        <?php
        foreach ($Module->record['media_info'] as $a) {
            if ($a['type'] == 'image') {
                list($width, $height) = getimagesize($a['fullpath']);
                $a['image_size'] = '[' . $width . 'x' . $height . ']';
                $a['icon'] = $a['tmb_prefix'] . '64';
            } else {
                $a['image_size'] = false;
                $a['icon'] = $a['icons']['64x64'];
            }
            ?>
            <tr>
                <td><a href="<?php echo $a['url'] ?>"><img src="<?php echo $a['icon'] ?>" alt=""/></a></td>
                <td class="full">
                    <div style="white-space: nowrap;">
                        <strong><a href="<?php echo $a['url'] ?>"><?php echo htmlspecialchars($a['basename']) ?></a></strong>
                        <span class="file-status-xs hidden-sm hidden-md hidden-lg">
                            <?php if ($a['is_screenshot']): ?>
                                <span class="fa fa-camera text-success"
                                      title="<?php echo $langMain['filestatus screenshot'] ?>"></span>
                            <?php endif; ?>
                            <?php if ($a['is_image']): ?>
                                <span class="fa fa-image text-success"
                                      title="<?php echo $langMain['filestatus image'] ?>"></span>
                            <?php endif; ?>
                            <?php if ($a['is_audio']): ?>
                                <span class="fa fa-headphones text-success"
                                      title="<?php echo $langMain['filestatus audio'] ?>"></span>
                            <?php endif; ?>
                            <?php if ($a['is_voting']): ?>
                                <span class="fa fa-poll text-success"
                                      title="<?php echo $langMain['filestatus voting'] ?>"></span>
                            <?php endif; ?>
                            <?php if ($a['is_release']): ?>
                                <span class="fa fa-file-archive text-success"
                                      title="<?php echo $langMain['filestatus release'] ?>"></span>
                            <?php endif; ?>
                        </span>
                    </div>

                    <p class="text-muted smalldesc">
                        <?php echo $langMain['works uploaded'] . ': ' . date('d.m.Y H:i', $a['posted']) . ' by ' . $a['posted_username'] ?>
                        <br/>
                        <?php echo $langMain['works filesize'] . ': ' . $a['filesize_str'] . ' ' . $a['image_size'] ?>
                    </p>
                </td>
                <td class="nowrap filestatus">
                    <div class="hidden-xs">
                            <span class="fa fa-camera <?php echo $a['is_screenshot'] ? 'text-success' : 'text-muted' ?>"
                                  title="<?php echo $langMain['filestatus screenshot'] ?>"></span>
                        <span class="fa fa-image <?php echo $a['is_image'] ? 'text-success' : 'text-muted' ?>"
                              title="<?php echo $langMain['filestatus image'] ?>"></span>
                        <span class="fa fa-headphones <?php echo $a['is_audio'] ? 'text-success' : 'text-muted' ?>"
                              title="<?php echo $langMain['filestatus audio'] ?>"></span>
                        <span class="fa fa-poll <?php echo $a['is_voting'] ? 'text-success' : 'text-muted' ?>"
                              title="<?php echo $langMain['filestatus voting'] ?>"></span>
                        <span class="fa fa-file-archive <?php echo $a['is_release'] ? 'text-success' : 'text-muted' ?>"
                              title="<?php echo $langMain['filestatus release'] ?>"></span>
                    </div>
                </td>
                <td></td>
            </tr>
        <?php } ?>
        </tbody>
    </table>

    <div id="on-complete-removable-aria" style="padding-top: 10px;">
        <?php
        $CMedia = new media();
        echo $CMedia->openSession(array(
            'owner_class' => get_class($Module),
            'secure_storage' => true,
            'template' => '_cabinet_add_work_media',
        ));
        ?>
        <form id="works-add-files" class="active-form">
            <input type="hidden" name="formSent" value="1"/>
            <div class="form-group">
                <button id="add-work-files"
                        class="btn btn-primary"><?php echo $langMain['works add files submit'] ?></button>
            </div>
        </form>
    </div>
<?php
ob_end_clean();