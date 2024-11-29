<?php
/**
 * @var object $Module
 * @var competitions $CCompetitions
 * @var array $personalNote
 * @var array $linkTitles
 */

$isPublic = true;
if (!$CCompetitions->record['voting_status']['available'] && !$CCompetitions->record['release_status']['available']) {
    $isPublic = false;
}
if ($CCompetitions->record['voting_status']['available'] && !$Module->record['status_info']['voting']) {
    $isPublic = false;
}
if ($CCompetitions->record['release_status']['available'] && !$Module->record['status_info']['release']) {
    $isPublic = false;
}
$publicHref = NFW::i()->absolute_path . '/' . $Module->record['event_alias'] . '/' . $Module->record['competition_alias'] . '/' . $Module->record['id'];

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.jgrowl');
NFW::i()->registerResource('bootstrap3.typeahead');
NFW::i()->registerResource('jquery.ui.interactions');

NFW::i()->assign('page_title', $Module->record['title'] . ' / edit');

NFW::i()->breadcrumb = array(
    array('url' => 'admin/events?action=update&record_id=' . $Module->record['event_id'], 'desc' => $Module->record['event_title']),
    array('url' => 'admin/works?event_id=' . $Module->record['event_id'] . '&filter_competition=' . $Module->record['competition_id'], 'desc' => $Module->record['competition_title']),
    array('desc' => $Module->record['title']),
);

ob_start();
NFW::i()->breadcrumb_status = '<div>Posted: ' . date('d.m.Y H:i', $Module->record['posted']) . ' (' . $Module->record['posted_username'] . ')</div>';
if ($Module->record['edited']) {
    NFW::i()->breadcrumb_status .= '<div>Updated: ' . date('d.m.Y H:i', $Module->record['edited']) . ' (' . $Module->record['edited_username'] . ')</div>';
}
?>
<style>
    .author-note {
        white-space: pre;
        font-family: monospace;
        overflow: auto;
    }

    .modal-backdrop.in {
        opacity: .9;
    }

    #works-preview-dialog .modal-dialog {
        height: 100%;
        margin: 0 auto;
    }

    #works-preview-dialog .modal-content {
        border-radius: 0;
    }

    #works-preview-dialog iframe.preview {
        width: 100%;
        border: none;
    }
</style>

<div class="row">
    <div class="col-md-6" style="padding-bottom: 20px;">

        <div data-active-container="status" class="form-group">
            <form id="update-status"
                  action="<?php echo $Module->formatURL('update_status') . '&record_id=' . $Module->record['id'] ?>">
                <input name="status" type="hidden" value="<?php echo $Module->record['status'] ?>"/>
                <fieldset>
                    <legend>Work status</legend>

                    <?php if ($isPublic): ?>
                        <dl>
                            <dt>Published with a link:</dt>
                            <dd><a href="<?php echo $publicHref ?>"><?php echo $publicHref ?></a></dd>
                        </dl>
                    <?php else: ?>
                        <dl>
                            <dt>Not been published yet. Link:</dt>
                            <dd><?php echo $publicHref ?></dd>
                        </dl>
                    <?php endif; ?>

                    <div class="form-group">
                        <div class="col-md-12">
                            <div id="status-buttons" class="btn-group" role="group">
                                <?php foreach ($Module->attributes['status']['options'] as $s) { ?>
                                    <button data-role="status-change-buttons"
                                            data-status-id="<?php echo $s['id'] ?>"
                                            data-css-class="<?php echo $s['css-class'] ?>" type="button"
                                            class="<?php echo 'btn btn-default ' . ($Module->record['status'] == $s['id'] ? 'active btn-info' : '') ?>"
                                            title="<?php echo $s['desc'] ?>"
                                            data-description="<?php echo $s['desc_full'] . '<br />Voting: <strong>' . ($s['voting'] ? 'On' : 'Off') . '</strong>. Release: <strong>' . ($s['release'] ? 'On' : 'Off') . '</strong>' ?>">
                                        <span class="<?php echo $s['icon'] ?>"></span></button>
                                <?php } ?>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-md-12">
                            <div id="status-description" class="alert alert-info"></div>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-md-12">
                            <label>Status reason (displayed to the author)</label>
                            <textarea class="form-control"
                                      name="status_reason"><?php echo $Module->record['status_reason'] ?></textarea>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-md-12">
                            <button type="submit" class="btn btn-primary">Update status</button>
                        </div>
                    </div>
                </fieldset>
            </form>
        </div>

        <form id="works-update"
              action="<?php echo $Module->formatURL('update_work') . '&record_id=' . $Module->record['id'] ?>">

            <div class="col-md-12">
                <?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes' => $Module->attributes['title'], 'vertical' => true)) ?>
            </div>
            <div class="col-md-12">
                <?php echo active_field(array('name' => 'author', 'value' => $Module->record['author'], 'attributes' => $Module->attributes['author'], 'vertical' => true)) ?>
            </div>
            <div class="col-md-12">
                <?php echo active_field(array('name' => 'competition_id', 'value' => $Module->record['competition_id'], 'attributes' => $Module->attributes['competition_id'], 'vertical' => true)) ?>
            </div>
            <div class="col-md-12">
                <?php echo active_field(array('name' => 'platform', 'value' => $Module->record['platform'], 'attributes' => $Module->attributes['platform'], 'inputCols' => '6', 'vertical' => true)) ?>
            </div>
            <div class="col-md-12">
                <?php echo active_field(array('name' => 'format', 'value' => $Module->record['format'], 'attributes' => $Module->attributes['format'], 'inputCols' => '6', 'vertical' => true)) ?>
            </div>
            <div class="col-md-12">
                <?php echo active_field(array('name' => 'author_note', 'value' => $Module->record['author_note'], 'attributes' => $Module->attributes['author_note'], 'height' => "60px;", 'vertical' => true)) ?>
            </div>
            <div class="col-md-12">
                <?php echo active_field(array('name' => 'external_html', 'value' => $Module->record['external_html'], 'attributes' => $Module->attributes['external_html'], 'height' => "100px;", 'vertical' => true)) ?>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <button type="submit" class="btn btn-primary">Save settings</button>
                    <button id="works-preview" class="btn btn-default">Preview</button>
                </div>
            </div>
        </form>
    </div>

    <div class="col-md-6">
        <?php if ($Module->record['description']): ?>
            <div class="hidden-xs">
                <div class="panel panel-default">
                    <div class="panel-heading">
                        <h4 class="panel-title">Author's comment</h4>
                    </div>
                    <div class="panel-body author-note"><?php echo htmlspecialchars($Module->record['description']) ?></div>
                </div>
            </div>

            <div class="hidden-sm hidden-md hidden-lg">
                <div class="panel-group" id="accordion" role="tablist" aria-multiselectable="true">
                    <div class="panel panel-default">
                        <div class="panel-heading" role="tab" id="headingOne">
                            <h4 class="panel-title">
                                <a role="button" data-toggle="collapse" data-parent="#accordion" href="#collapseOne"
                                   aria-expanded="true" aria-controls="collapseOne">
                                    Author's comment
                                </a>
                            </h4>
                        </div>
                        <div id="collapseOne" class="panel-collapse collapse" role="tabpanel"
                             aria-labelledby="headingOne">
                            <div class="panel-body author-note"><?php echo htmlspecialchars($Module->record['description']) ?></div>
                        </div>
                    </div>
                </div>
            </div>
        <?php endif; ?>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h4 class="panel-title">Personal note (only for you)</h4>
            </div>
            <div class="panel-body">
                <form id="works-my-status"
                      action="<?php echo $Module->formatURL('my_status') . '&record_id=' . $Module->record['id'] ?>">
                    <div class="form-group">
                        <div class="col-md-12">
                                    <textarea class="form-control"
                                              name="comment"><?php echo $personalNote['comment'] ?></textarea>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-12">
                            <label class="checkbox-inline">
                                <input type="hidden" name="is_checked" value="0"/>
                                <input type="checkbox" name="is_checked"
                                       value="1" <?php echo $personalNote['is_checked'] ? ' checked="checked"' : '' ?>/>
                                Checked
                            </label>

                            <label class="checkbox-inline">
                                <input type="hidden" name="is_marked" value="0"/>
                                <input type="checkbox" name="is_marked"
                                       value="1" <?php echo $personalNote['is_marked'] ? ' checked="checked"' : '' ?>/>
                                Marked
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-12">
                            <button type="submit" class="btn btn-primary">Set your note</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <form id="works-update-links"
              action="<?php echo $Module->formatURL('update_links') . '&record_id=' . $Module->record['id'] ?>">
            <fieldset>
                <div style="display: flex; justify-content: space-between;">
                    <legend>Links</legend>
                    <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapseLinksHelp"
                            aria-expanded="false" aria-controls="collapseExample"><span
                                class="fa fa-question-circle"></span>
                    </button>
                </div>

                <div class="collapse" id="collapseLinksHelp">
                    <div class="well">
                        <p>YouTube links will be automatically converted to an iframe</p>

                        <p>VK Video links will be automatically converted to an iframe only with manually hash added.
                            Example: <code>&hash=5df22c4cff63dc92</code></p>

                        <p>You can also use embedded VK Video instead of a direct link to the video</p>
                    </div>
                </div>

                <div id="work-links" class="settings" style="padding-bottom: 10px;">
                    <?php foreach ($Module->record['links'] as $v) { ?>
                        <div id="record" class="record" data-rel="update">
                            <div class="cell"><span class="icon fa fa-sort" title="Sort"></span></div>
                            <div class="cell" style="width: 100%;">
                                <div class="input-group" style="margin-bottom: 3px;">
                                    <input type="text" class="form-control" data-type="links-url"
                                           autocomplete="off"
                                           name="links[url][]" value="<?php echo htmlspecialchars($v['url']) ?>"
                                           placeholder="Url"/>
                                    <span class="input-group-btn">
										<button data-action="toggle-title" class="btn btn-default" tabindex="-1"
                                                title="Show custom tittle"><span
                                                    class="glyphicon glyphicon-chevron-down"></span></button>
										<button data-action="remove-link" class="btn btn-default" tabindex="-1"
                                                title="Remove link"><span
                                                    class="glyphicon glyphicon-remove"></span></button>
									</span>
                                </div>
                                <div class="input-group"
                                     style="width: 100%; display: <?php echo $v['title'] ? 'block' : 'none' ?>;">
                                    <input type="text" class="form-control" data-type="links-title"
                                           autocomplete="off"
                                           name="links[title][]" value="<?php echo $v['title'] ?>"
                                           placeholder="Custom title (not required)"/>
                                </div>
                            </div>
                        </div>
                    <?php } ?>
                </div>

                <div style="display: flex; justify-content: space-between;">
                    <div>
                        <button id="save-links" type="submit" class="btn btn-primary">Save links</button>
                    </div>
                    <button id="add-link" class="btn btn-default"><span class="fa fa-plus"></span></button>
                </div>
            </fieldset>
        </form>

    </div>
</div>

<h3>Files</h3>
<div id="media-form-container">
    <?php
    $CMedia = new media();
    echo $CMedia->openSession(
        array(
            'owner_class' => get_class($Module),
            'owner_id' => $Module->record['id'],
            'secure_storage' => true,
            'MAX_SESSION_SIZE' => 1024 * 1024 * 256,
            'template' => '_admin_works_media',
        ),
        array('owner' => $Module->record)
    );
    ?>
</div>

<br/>
<br/>
<div class="panel panel-danger">
    <div class="panel-heading">
        <h4 class="panel-title">Danger Zone</h4>
    </div>
    <div class="panel-body">
        <button class="btn btn-danger" data-role="works-delete">Delete work permanently</button>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        const wuF = $('form[id="works-update"]');
        wuF.activeForm({
            success: function () {
                $.jGrowl('Work profile updated');
            }
        });

        // Platform typeahead
        let aPlatforms = [];
        <?php foreach ($Module->attributes['platform']['options'] as $p) echo 'aPlatforms.push(' . json_encode($p) . ');' . "\n"; ?>
        $('input[name="platform"]').typeahead({source: aPlatforms, minLength: 0}).attr('autocomplete', 'off');

        // Work status
        $('[data-role="status-change-buttons"]').click(function () {
            $('[data-role="status-change-buttons"]').removeClass('active btn-info');
            $(this).addClass('active btn-info');

            $('input[name="status"]').val($(this).data('status-id'));

            const obj = $('#status-description');
            obj.html($(this).data('description'));
            obj.removeClass('alert-default alert-success alert-info alert-warning alert-danger');
            obj.addClass('alert-' + $(this).data('css-class'));
        });
        $('[data-role="status-change-buttons"][class~="active"]').trigger('click');

        // Preview
        const previewModal = $('div[id="works-preview-dialog"]');
        previewModal.modal({'show': false});

        previewModal.on('shown.bs.modal', function () {
            previewModal.find('iframe').css("height", previewModal.height() - 40);
        });

        $(document).on('click', 'button[id="works-preview"]', function (e) {
            e.preventDefault();
            $.ajax(
                '<?php echo $Module->formatURL('preview') . '&record_id=' . $Module->record['id']?>',
                {
                    method: "post",
                    data: wuF.serialize(),
                    dataType: "json",
                    success: function (response) {
                        previewModal.find('iframe').attr("srcdoc", response.content);
                        previewModal.modal('show');
                    },
                    error: function (response) {
                        if (response['responseJSON']['errors']['general'] === undefined) {
                            return
                        }
                        alert(response['responseJSON']['errors']['general']);
                    }
                }
            );
        });

        $('form[id="update-status"]').activeForm({
            success: function () {
                $.jGrowl('Status updated');
            }
        });

        // Personal note form
        $('form[id="works-my-status"]').activeForm({
            success: function () {
                $.jGrowl('Personal note saved');
            }
        });

        // Links
        updateSaveLinksButtonVisibility();

        $('#work-links').sortable({items: 'div[id="record"]', axis: 'y', handle: '.icon'});

        $(document).on('click', '[data-action="toggle-title"]', function () {
            $(this).closest('div[id="record"]').find('input[data-type="links-title"]').closest('div').toggle();
            return false;
        });

        $(document).on('click', '[data-action="remove-link"]', function (event) {
            if ($(this).closest('div[id="record"]').attr('data-rel') === 'update') {
                if (!confirm('Remove link?')) {
                    event.preventDefault();
                    return false;
                }
            }

            $(this).closest('div[id="record"]').remove();
            updateSaveLinksButtonVisibility();
            return false;
        });

        $('button[id="add-link"]').click(function () {
            const tpl = $('div[id="links-record-template"]').html();
            $('div[id="work-links"]').append(tpl);
            $('input[data-type="links-title"]:last').typeahead({
                source: aTitles,
                minLength: 1,
                items: 20,
                showHintOnFocus: true
            }).focus();
            $('input[data-type="links-url"]:last').focus();

            updateSaveLinksButtonVisibility();
            return false;
        });

        // Autocomplete link title
        let aTitles = [];
        <?php foreach ($linkTitles as $t) echo 'aTitles.push(\'' . htmlspecialchars($t) . '\');' . "\n"; ?>
        $('input[data-type="links-title"]').typeahead({
            source: aTitles,
            minLength: 1,
            items: 20,
            showHintOnFocus: true
        });

        $('form[id="works-update-links"]').activeForm({
            success: function () {
                $.jGrowl('Work links updated');
            }
        });

        $('[data-role="works-delete"]').click(function () {
            if (!confirm("Remove work?\nCAN NOT BE UNDONE!")) {
                return false;
            }

            $.ajax('<?php echo $Module->formatURL('delete') . '&record_id=' . $Module->record['id']?>',
                {
                    method: "POST",
                    dataType: "json",
                    error: function (response) {
                        if (response['responseJSON']['errors']['general'] === undefined) {
                            return
                        }

                        $.jGrowl(response['responseJSON']['errors']['general'], {theme: 'error'});
                    },
                    success: function () {
                        window.location.href = '<?php echo $Module->formatURL() . '?event_id=' . $Module->record['event_id']?>'
                    }
                },
            );

            return false;
        });
    });

    function updateSaveLinksButtonVisibility() {
        if ($('#work-links').find('div[id="record"]').length) {
            $('button[id="save-links"]').show();
        } else {
            $('button[id="save-links"]').hide();
        }
    }
</script>

<div id="works-preview-dialog" class="modal fade">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-body">
                <iframe class="preview"></iframe>
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            </div>
        </div>
    </div>
</div>

<div id="links-record-template" style="display: none;">
    <div id="record" class="record" data-rel="insert">
        <div class="cell"><span class="icon fa fa-sort" title="Sort"></span></div>
        <div class="cell" style="width: 100%;">
            <div class="input-group" style="margin-bottom: 3px;">
                <input type="text" class="form-control" data-type="links-url" autocomplete="off" name="links[url][]"
                       placeholder="Url"/>
                <span class="input-group-btn">
					<button data-action="toggle-title" class="btn btn-default" tabindex="-1" title="Show custom tittle"><span
                                class="fa fa-chevron-down"></span></button>
					<button data-action="remove-link" class="btn btn-default" tabindex="-1" title="Remove link"><span
                                class="fa fa-times"></span></button>
				</span>
            </div>
            <div class="input-group" style="width: 100%; display: none;">
                <input type="text" class="form-control" data-type="links-title" autocomplete="off" name="links[title][]"
                       placeholder="Custom title (not required)"/>
            </div>
        </div>
    </div>
</div>
