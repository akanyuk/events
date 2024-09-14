<?php
/**
 * @var object $Module
 * @var array $owner
 *
 * @var string $session_id
 * @var integer $owner_id
 * @var string $owner_class
 * @var integer $MAX_FILE_SIZE
 * @var integer $MAX_SESSION_SIZE
 * @var integer $image_max_x
 * @var integer $image_max_y
 */

const TITLE_SCREENSHOT = "Screenshot for social media links";
const TITLE_IMAGE = "Image on work page (can be multiple)";
const TITLE_AUDIO = "Files for audio playing (mp3 or ogg)";
const TITLE_VOTING = "Download link during voting";
const TITLE_RELEASE = "Download link after voting";

NFW::i()->registerResource('jquery.file-upload');
$lang_media = NFW::i()->getLang('media');

NFW::i()->registerFunction("limit_text");

// Calculate session size
$session_size = 0;
foreach ($owner['media_info'] as $record) {
    $session_size += $record['filesize'];
}

$js = NFW::i()->fetch(NFW::i()->findTemplatePath('media/_admin_works_media.js.tpl'));
echo '<script>' . $js . '</script>';

$css = NFW::i()->fetch(NFW::i()->findTemplatePath('media/_admin_works_media.css.tpl'));
echo '<style>' . $css . '</style>';
?>
<div class="modal fade" id="worksMediaZXSCRModal">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Preview with FLASH and hidden pixels</h4>
            </div>

            <div class="modal-body">
                <div class="form-group text-center" style="padding: 40px 0;">
                    <img id="preview" alt="" src=""/>
                </div>

                <label>Border color</label>
                <div class="form-group" id="border-buttons">
                    <button type="button" class="btn btn-black" data-value="0"></button>
                    <button type="button" class="btn btn-blue" data-value="1"></button>
                    <button type="button" class="btn btn-red" data-value="2"></button>
                    <button type="button" class="btn btn-magenta" data-value="3"></button>
                    <button type="button" class="btn btn-green" data-value="4"></button>
                    <button type="button" class="btn btn-cyan" data-value="5"></button>
                    <button type="button" class="btn btn-yellow" data-value="6"></button>
                    <button type="button" class="btn btn-white" data-value="7"></button>
                </div>
            </div>

            <div class="modal-footer">
                <button type="button" id="make" class="btn btn-primary"
                        title="Scale: 1x; Palette: <?php echo NFW::i()->cfg['zxgfx']['palette'] ?>; Output: png; Border: none"
                        data-target="preview">Make preview
                </button>
                <button type="button" class="btn btn-primary" id="make"
                        title="Scale: <?php echo NFW::i()->cfg['zxgfx']['output_scale'] ?>x; Palette: <?php echo NFW::i()->cfg['zxgfx']['palette'] ?>; Output: gif; Border: <?php echo NFW::i()->cfg['zxgfx']['border'] ?>"
                        data-target="image">Make image
                </button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="worksMediaRenameModal">
    <div class="modal-dialog">
        <form id="works-rename-file"
              method="post"
              action="<?php echo NFW::i()->base_path . 'admin/works_media?action=rename_file' ?>">
            <input name="file_id" type="hidden"/>
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">Rename file</h4>
                </div>

                <div class="modal-body">
                    <div data-active-container="basename">
                        <input type="text" name="basename" maxlength="64" class="form-control"/>
                        <span class="help-block"></span>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Rename</button>
                </div>
            </div>
        </form>
    </div>
</div>

<form id="<?php echo $session_id ?>"
      action="<?php echo NFW::i()->base_path . 'media.php?action=upload&session_id=' . $session_id ?>" method="POST"
      enctype="multipart/form-data">
    <input type="hidden" name="owner_id" value="<?php echo $owner_id ?>"/>
    <input type="hidden" name="owner_class" value="<?php echo $owner_class ?>"/>
    <input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $MAX_FILE_SIZE ?>"/>

    <div id="record-template" style="display: none;">
        <div id="record" class="record" data-id="%id%" data-basename="%basename%">
            <div id="comment" style="display: none;">%comment%</div>
            <div class="cell cell-i">
                <a role="<?php echo $session_id ?>-file-properties" href="%url%" data-type="%type%"
                   data-basename="%basename%" data-posted="%posted%" data-filesize="%filesize%">
                    <img <?php echo '%iconsrc%' ?> alt=""/>
                </a>
            </div>
            <div class="cell cell-f">
                <a role="<?php echo $session_id ?>-file-properties" href="%url%" data-type="%type%"
                   data-basename="%basename%" data-posted="%posted%" data-filesize="%filesize%">
                    <strong id="basename">%basename%</strong>
                </a>
                <div class="info">
                    <div>Uploaded: %posted_str% by %posted_username%</div>
                    <div>Filesize: %filesize%</div>
                </div>
            </div>
            <div class="cell cell-settings">
                <div class="pull-right" style="margin-left: 5px;">
                    <div class="dropdown">
                        <button class="btn btn-default dropdown-toggle"
                                type="button" id="<?php echo $session_id ?>-dropdown"
                                data-toggle="dropdown"
                                aria-haspopup="true"
                                aria-expanded="true"><span class="caret"></span></button>
                        <ul class="dropdown-menu dropdown-menu-right"
                            aria-labelledby="<?php echo $session_id ?>-dropdown">
                            <li><a href="#" id="works-media-rename">Rename</a></li>
                            <li><a href="#" id="works-media-zx-spectrum-scr">ZX Spectrum screen</a></li>
                            <li><a href="#" id="works-media-delete"><span
                                            class="text-danger">Delete</span></a></li>
                        </ul>
                    </div>
                </div>
                <div class="btn-group" role="group">
                    <button role="<?php echo $session_id ?>-prop" id="screenshot" type="button" class="btn btn-default"
                            title="<?php echo TITLE_SCREENSHOT ?>"><span class="fa fa-camera"></span></button>
                    <button role="<?php echo $session_id ?>-prop" id="image" type="button" class="btn btn-default"
                            title="<?php echo TITLE_IMAGE ?>"><span class="fa fa-image"></span></button>
                    <button role="<?php echo $session_id ?>-prop" id="audio" type="button" class="btn btn-default"
                            title="<?php echo TITLE_AUDIO ?>"><span class="fa fa-headphones"></span></button>
                    <button role="<?php echo $session_id ?>-prop" id="voting" type="button" class="btn btn-default"
                            title="<?php echo TITLE_VOTING ?>"><span class="fa fa-poll"></span></button>
                    <button role="<?php echo $session_id ?>-prop" id="release" type="button" class="btn btn-default"
                            title="<?php echo TITLE_RELEASE ?>"><span class="fa fa-file-archive"></span></button>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-md-12">
            <div class="row">
                <div id="media-list" class="settings">
                    <?php
                    foreach ($owner['media_info'] as $record) {
                        if ($record['type'] == 'image') {
                            list($width, $height) = getimagesize($record['fullpath']);
                            $record['image_size'] = '[' . $width . 'x' . $height . ']';
                            $record['icon'] = $record['tmb_prefix'] . '64';
                        } else {
                            $record['image_size'] = '';
                            $record['icon'] = $record['icons']['64x64'];
                        }
                        ?>
                        <div id="record" class="record"
                             data-id="<?php echo $record['id'] ?>"
                             data-basename="<?php echo $record['basename'] ?>">
                            <div id="comment"
                                 style="display: none;"><?php echo htmlspecialchars($record['comment']) ?></div>

                            <div class="cell cell-i">
                                <a role="<?php echo $session_id ?>-file-properties" href="<?php echo $record['url'] ?>"
                                   data-type="<?php echo $record['type'] ?>"
                                   data-basename="<?php echo $record['basename'] ?>"
                                   data-posted="<?php echo $record['posted'] ?>"
                                   data-filesize="<?php echo $record['filesize_str'] ?>">
                                    <img src="<?php echo $record['icon'] ?>" alt=""/>
                                </a>
                            </div>
                            <div class="cell cell-f">
                                <a role="<?php echo $session_id ?>-file-properties" href="<?php echo $record['url'] ?>"
                                   title="<?php echo htmlspecialchars($record['basename']) ?>"
                                   data-type="<?php echo $record['type'] ?>"
                                   data-basename="<?php echo $record['basename'] ?>"
                                   data-posted="<?php echo $record['posted'] ?>"
                                   data-filesize="<?php echo $record['filesize_str'] ?>">
                                    <strong id="basename"><?php echo limit_text($record['basename'], 64) ?></strong>
                                </a>
                                <div class="info">
                                    <div>Uploaded: <?php echo date('d.m.Y H:i', $record['posted']) ?>
                                        by <?php echo $record['posted_username'] ?></div>
                                    <div>
                                        Filesize: <?php echo $record['filesize_str'] ?> <?php echo $record['image_size'] ?></div>
                                </div>
                            </div>
                            <div class="cell cell-settings">
                                <div class="pull-right" style="margin-left: 5px;">
                                    <div class="dropdown">
                                        <button class="btn btn-default dropdown-toggle"
                                                type="button" id="<?php echo $session_id ?>-dropdown"
                                                data-toggle="dropdown"
                                                aria-haspopup="true"
                                                aria-expanded="true"><span class="caret"></span></button>
                                        <ul class="dropdown-menu dropdown-menu-right"
                                            aria-labelledby="<?php echo $session_id ?>-dropdown">
                                            <li><a href="#" id="works-media-rename">Rename</a></li>
                                            <li><a href="#" id="works-media-zx-spectrum-scr">ZX Spectrum screen</a></li>
                                            <li><a href="#" id="works-media-delete"><span
                                                            class="text-danger">Delete</span></a></li>
                                        </ul>
                                    </div>
                                </div>
                                <div class="btn-group" role="group">
                                    <button role="<?php echo $session_id ?>-prop" id="screenshot" type="button"
                                            class="btn btn-default<?php echo $record['is_screenshot'] ? ' btn-info active' : '' ?>"
                                            title="<?php echo TITLE_SCREENSHOT ?>"><span class="fa fa-camera"></span>
                                    </button>
                                    <button role="<?php echo $session_id ?>-prop" id="image" type="button"
                                            class="btn btn-default<?php echo $record['is_image'] ? ' btn-info active' : '' ?>"
                                            title="<?php echo TITLE_IMAGE ?>"><span class="fa fa-image"></span></button>
                                    <button role="<?php echo $session_id ?>-prop" id="audio" type="button"
                                            class="btn btn-default<?php echo $record['is_audio'] ? ' btn-info active' : '' ?>"
                                            title="<?php echo TITLE_AUDIO ?>"><span class="fa fa-headphones"></span>
                                    </button>
                                    <button role="<?php echo $session_id ?>-prop" id="voting" type="button"
                                            class="btn btn-default<?php echo $record['is_voting'] ? ' btn-info active' : '' ?>"
                                            title="<?php echo TITLE_VOTING ?>"><span class="fa fa-poll"></span></button>
                                    <button role="<?php echo $session_id ?>-prop" id="release" type="button"
                                            class="btn btn-default<?php echo $record['is_release'] ? ' btn-info active' : '' ?>"
                                            title="<?php echo TITLE_RELEASE ?>"><span class="fa fa-file-archive"></span>
                                    </button>
                                </div>
                                <div class="clearfix"></div>
                            </div>
                        </div>
                        <?php
                    }
                    ?>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <div class="hidden-xs col-md-6">
            <div id="dropzone" class="well dropzone"><?php echo $lang_media['Messages']['Dropzone'] ?></div>
        </div>
        <div class="col-md-4">
            <div class="alert alert-warning alert-cond" role="alert">
                <p><?php echo $lang_media['MaxFileSize'] ?>:
                    <strong><?php echo number_format($MAX_FILE_SIZE / 1048576, 2, '.', ' ') . $lang_media['mb'] ?></strong>
                </p>
                <p><?php echo $lang_media['MaxSessionSize'] ?>:
                    <strong><?php echo number_format($MAX_SESSION_SIZE / 1048576, 2, '.', ' ') . $lang_media['mb'] ?></strong>
                </p>
                <p><?php echo $lang_media['CurrentSessionSize'] ?>: <strong><span
                                id="session-size"><?php echo number_format($session_size / 1048576, 2, '.', ' ') ?></span><?php echo $lang_media['mb'] ?>
                    </strong></p>
                <?php if ($image_max_x && $image_max_y): ?>
                    <p><?php echo $lang_media['MaxImageSize'] ?>:
                        <strong><?php echo $image_max_x . 'x' . $image_max_y ?>px</strong></p>
                <?php endif; ?>
            </div>
        </div>
        <div class="col-md-2">
            <label for="<?php echo $session_id ?>-upload-button">
                <span class="btn btn-success btn-full-xs"><span class="fa fa-folder-open"
                                                                aria-hidden="true"></span> <?php echo $lang_media['Upload files'] ?></span>
                <input type="file" name="local_file" id="<?php echo $session_id ?>-upload-button" style="display:none"
                       multiple/>
            </label>

            <button id="file_id.diz" class="btn btn-primary btn-full-xs"><span class="fa fa-file-text"></span> Generate
                `file_id.diz`
            </button>
        </div>
    </div>

    <div id="uploading-status" class="uploading-status" style="display: none;"></div>
</form>

<form id="make-release" class="form-inline" style="padding-top: 20px;">
    <fieldset style="overflow: hidden">
        <legend>Permanent link:</legend>
        <span id="permanent-link"><?php echo $owner['release_link'] ? '<a href="' . $owner['release_link']['url'] . '">' . $owner['release_link']['url'] . '</a>' : '<em>none</em>' ?></span>

        <div class="form-group">
            <button id="media-remove-release"
                    class="btn btn-sm btn-danger btn-full-xs" <?php echo $owner['release_link'] ? '' : 'style="display: none;"' ?>
                    title="Delete file"><span class="hidden-xs"><span class="fa fa-times"></span></span><span
                        class="hidden-sm hidden-md hidden-lg"> Delete file</span></button>
        </div>

        <div class="clearfix" style="padding-top: 10px;"></div>

        <div class="form-group">
            <div class="input-group">
                <input type="text" class="form-control" name="release_basename" placeholder="filename"
                       value="<?php echo NFWX::i()->safeFilename($owner['title']) ?>">
                <div class="input-group-addon">.zip</div>
            </div>
        </div>
        <button class="btn btn-primary btn-full-xs"><span class="fa fa-save"></span> Generate new permanent archive
        </button>
    </fieldset>
</form>
