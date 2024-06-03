<?php
/** @var works $Module */

$lang_main = NFW::i()->getLang('main');

NFW::i()->breadcrumb = array(
    array('url' => 'cabinet/works?action=list', 'desc' => $lang_main['cabinet prods']),
    array('desc' => $Module->record['title'])
);

NFW::i()->registerResource('jquery.activeForm');

$CCompetitions = new competitions($Module->record['competition_id']);

NFW::i()->assign('page_title', $Module->record['title'] . ' / ' . $lang_main['cabinet prods']);

$placeTitle = array();
if ($Module->record['average_vote']) {
    $placeTitle[] = $lang_main['works average_vote'] . ':&nbsp;<strong>' . $Module->record['average_vote'] . '</strong>';
}
if ($Module->record['iqm_vote']) {
    $placeTitle[] = 'IQM :&nbsp;<strong>' . $Module->record['iqm_vote'] . '</strong>';
}
if ($Module->record['num_votes']) {
    $placeTitle[] = $lang_main['works num_votes'] . ':&nbsp;<strong>' . $Module->record['num_votes'] . '</strong>';
}
if ($Module->record['total_scores']) {
    $placeTitle[] = $lang_main['works total_scores'] . ':&nbsp;<strong>' . $Module->record['total_scores'] . '</strong>';
}

// Is the prod visible in public
if ($CCompetitions->record['voting_status']['available'] && $Module->record['status_info']['voting']) {
    $isPublished = true;
} else if ($CCompetitions->record['release_status']['available'] && $Module->record['status_info']['release']) {
    $isPublished = true;
} else {
    $isPublished = false;
}

// Success dialog
NFW::i()->registerFunction('ui_dialog');
$successDialog = new ui_dialog();
$successDialog->render();
?>
    <script type="text/javascript">
        $(document).ready(function () {
            $('form[id="works-add-files"]').activeForm({
                action: "<?php echo NFW::i()->base_path . 'cabinet/works?action=add_media&record_id=' . $Module->record['id']?>",
                error: function(response) {
                    if (response['responseJSON']['errors']['general'] !== undefined) {
                        alert(response['responseJSON']['errors']['general']);
                    }
                    return false;
                },
                success: function (response) {
                    $('div[id="on-complete-removable-aria"]').remove();

                    $(document).trigger('show-<?php echo $successDialog->getID()?>', [response.message]);
                    $(document).on('hide-<?php echo $successDialog->getID()?>', function () {
                        window.location.reload();
                    });
                }
            });
        });
    </script>
    <style>
        TABLE.work-files-list > tbody > tr > TD {
            vertical-align: middle;
        }

        TABLE.work-files-list TD.filestatus .fa {
            font-size: 200%;
        }

        .file-status-xs .fa {
            font-size: 120%;
        }

        TABLE.work-files-list .smalldesc {
            font-size: 90%;
        }

        @media (max-width: 768px) {
            TABLE.work-files-list .smalldesc {
                white-space: nowrap;
                overflow: hidden;
                font-size: 80%;
                margin: 0;
            }
        }
    </style>

<?php ob_start(); ?>
<?php if ($Module->record['place']): ?>
    <div style="font-size: 600%; text-align: center; padding-bottom: 10px;">
        <span class="label label-place" title="Place"><?php echo $Module->record['place'] ?></span>
    </div>
    <div style="text-align: center; font-size: 80%;"><?php echo implode('<br />', $placeTitle) ?></div>
    <hr/>
<?php endif; ?>
    <dl class="dl-horizontal">
        <dt><?php echo $lang_main['works title'] ?>:</dt>
        <dd><?php echo htmlspecialchars($Module->record['title'] . ($Module->record['author'] ? ' by ' . $Module->record['author'] : '')) ?></dd>
        <dt><?php echo $lang_main['works platform'] ?>:</dt>
        <dd><?php echo htmlspecialchars($Module->record['platform'] . ($Module->record['format'] ? ' / ' . $Module->record['format'] : '')) ?></dd>
        <dt><?php echo $lang_main['event'] ?>:</dt>
        <dd><?php echo $Module->record['event_title'] ?></dd>
        <dt><?php echo $lang_main['competition'] ?>:</dt>
        <dd><?php echo $Module->record['competition_title'] ?> <em>(<?php echo $Module->record['works_type'] ?>)</em>
        </dd>

        <?php if (!$Module->record['place']): ?>
            <dt><?php echo $lang_main['works voting'] ?>:</dt>
            <dd class="<?php echo $CCompetitions->record['voting_status']['text-class'] ?>"><?php echo $CCompetitions->record['voting_status']['desc'] ?></dd>
        <?php endif; ?>

        <dd>&nbsp;</dd>
        <dt><?php echo $lang_main['works status'] ?></dt>
        <dd>
            <span class="label label-<?php echo $Module->record['status_info']['css-class'] ?>"><?php echo $Module->record['status_info']['desc'] ?></span>
        </dd>
        <dd><?php echo $Module->record['status_info']['desc_full'] ?></dd>
        <dt><?php echo $lang_main['works voting'] ?></dt>
        <dd>
            <?php echo $Module->record['status_info']['voting'] ? '<span class="label label-success">On</span>' : '<span class="label label-default">Off</span>' ?>
        </dd>
        <dt><?php echo $lang_main['works release'] ?></dt>
        <dd>
            <?php echo $Module->record['status_info']['release'] ? '<span class="label label-success">On</span>' : '<span class="label label-default">Off</span>' ?>
        </dd>
        <?php if ($Module->record['status_reason']): ?>
            <dt><?php echo $lang_main['works reason'] ?></dt>
            <dd><span class="text-warning"><?php echo nl2br($Module->record['status_reason']) ?></span></dd>
        <?php endif ?>

        <?php if ($isPublished): $permalink = NFW::i()->absolute_path . '/' . $Module->record['event_alias'] . '/' . $Module->record['competition_alias'] . '/' . $Module->record['id']; ?>
            <dd>&nbsp;</dd>
            <dt><?php echo $lang_main['works permanent link'] ?>:</dt>
            <dd><a href="<?php echo $permalink ?>"><?php echo $permalink ?></a></dd>
        <?php endif; ?>

        <dd>&nbsp;</dd>
        <dt><?php echo NFW::i()->lang['Posted'] ?>:</dt>
        <dd><?php echo date('d.m.Y H:i:s', $Module->record['posted']) . ' (' . $Module->record['posted_username'] . ')' ?></dd>
        <?php if ($Module->record['edited']): ?>
            <dt><?php echo NFW::i()->lang['Updated'] ?>:</dt>
            <dd><?php echo date('d.m.Y H:i:s', $Module->record['edited']) . ' (' . $Module->record['edited_username'] . ')' ?></dd>
        <?php endif; ?>
    </dl>

    <h3><?php echo $lang_main['works files'] ?></h3>
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
                                <span class="fa fa-camera text-success" title="<?php echo $lang_main['filestatus screenshot']?>"></span>
                            <?php endif;?>
                            <?php if ($a['is_slide']): ?>
                                <span class="fa fa-film text-success" title="<?php echo $lang_main['filestatus slide']?>"></span>
                            <?php endif;?>
                            <?php if ($a['is_image']): ?>
                                <span class="fa fa-image text-success" title="<?php echo $lang_main['filestatus image']?>"></span>
                            <?php endif;?>
                            <?php if ($a['is_audio']): ?>
                                <span class="fa fa-headphones text-success" title="<?php echo $lang_main['filestatus audio']?>"></span>
                            <?php endif;?>
                            <?php if ($a['is_voting']): ?>
                                <span class="fa fa-poll text-success" title="<?php echo $lang_main['filestatus voting']?>"></span>
                            <?php endif;?>
                            <?php if ($a['is_release']): ?>
                                <span class="fa fa-file-archive text-success" title="<?php echo $lang_main['filestatus release']?>"></span>
                            <?php endif;?>
                        </span>
                    </div>

                    <p class="text-muted smalldesc">
                        <?php echo $lang_main['works uploaded'] . ': ' . date('d.m.Y H:i', $a['posted']) . ' by ' . $a['posted_username'] ?>
                        <br/>
                        <?php echo $lang_main['works filesize'] . ': ' . $a['filesize_str'] . ' ' . $a['image_size'] ?>
                    </p>
                </td>
                <td class="nowrap filestatus">
                    <div class="hidden-xs">
                        <span class="fa fa-camera <?php echo $a['is_screenshot'] ? 'text-success' : 'text-muted'?>" title="<?php echo $lang_main['filestatus screenshot']?>"></span>
                        <span class="fa fa-film <?php echo $a['is_slide'] ? 'text-success' : 'text-muted'?>" title="<?php echo $lang_main['filestatus slide']?>"></span>
                        <span class="fa fa-image <?php echo $a['is_image'] ? 'text-success' : 'text-muted'?>" title="<?php echo $lang_main['filestatus image']?>"></span>
                        <span class="fa fa-headphones <?php echo $a['is_audio'] ? 'text-success' : 'text-muted'?>" title="<?php echo $lang_main['filestatus audio']?>"></span>
                        <span class="fa fa-poll <?php echo $a['is_voting'] ? 'text-success' : 'text-muted'?>" title="<?php echo $lang_main['filestatus voting']?>"></span>
                        <span class="fa fa-file-archive <?php echo $a['is_release'] ? 'text-success' : 'text-muted'?>" title="<?php echo $lang_main['filestatus release']?>"></span>
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
            <input type="hidden" name="formSent" value="1" />
            <div class="form-group">
                <button id="add-work-files"
                        class="btn btn-primary"><?php echo $lang_main['works add files submit'] ?></button>
            </div>
        </form>
    </div>
<?php
$information_pane = ob_get_clean();


if ($CCompetitions->record['release_status']['available'] || $CCompetitions->record['voting_status']['available']) {
    // Preview not need
    echo $information_pane;
} else {
    NFW::i()->registerFunction('display_work_media');
    ?>
    <ul class="nav nav-tabs" role="tablist">
        <li role="presentation" class="active"><a href="#main" aria-controls="main" role="tab"
                                                  data-toggle="tab"><?php echo $lang_main['works tab main'] ?></a></li>
        <li role="presentation"><a href="#preview" aria-controls="files" role="tab"
                                   data-toggle="tab"><?php echo $lang_main['works tab preview'] ?></a></li>
    </ul>
    <div class="tab-content">
        <div role="tabpanel" class="tab-pane in active" style="padding-top: 20px;"
             id="main"><?php echo $information_pane ?></div>
        <div role="tabpanel" class="tab-pane" id="preview">
            <br/>
            <?php echo display_work_media($Module->record, array('rel' => 'preview')) ?>
        </div>
    </div>
    <?php
}	
