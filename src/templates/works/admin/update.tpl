<?php
/**
 * @var object $Module
 * @var array $personalNote
 * @var array $linkTitles
 */

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
?>
<div class="text-muted" style="display: inline-block; font-size: 11px; line-height: 12px;">
    Posted: <?php echo date('d.m.Y H:i', $Module->record['posted']) . ' (' . $Module->record['posted_username'] . ')' ?>
    <?php echo $Module->record['edited'] ? '<br />Updated: ' . date('d.m.Y H:i', $Module->record['edited']) . ' (' . $Module->record['edited_username'] . ')' : '' ?>
</div>
<?php
NFW::i()->breadcrumb_status = ob_get_clean();
?>
<style>
    .author-note {
        white-space: pre;
        font-family: monospace;
        overflow: auto;
    }
</style>

<div class="row">
    <div class="col-md-6" style="padding-bottom: 20px;">
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
                    <button type="submit" class="btn btn-primary">Save work settings</button>
                    <button id="works-preview" class="btn btn-default">Preview</button>
                </div>
            </div>
        </form>

        <br/>
        <form id="works-update-links"
              action="<?php echo $Module->formatURL('update_links') . '&record_id=' . $Module->record['id'] ?>">
            <fieldset>
                <legend>Links</legend>

                <div id="work-links" class="settings" style="padding-bottom: 10px;">
                    <?php foreach ($Module->record['links'] as $v) { ?>
                        <div id="record" class="record" data-rel="update">
                            <div class="cell"><span class="icon fa fa-sort" title="Sort"></span></div>
                            <div class="cell" style="width: 100%;">
                                <div class="input-group" style="margin-bottom: 3px;">
                                    <input type="text" class="form-control" data-type="links-url"
                                           autocomplete="off"
                                           name="links[url][]" value="<?php echo $v['url'] ?>"
                                           placeholder="Url"/>
                                    <span class="input-group-btn">
										<button data-action="toggle-title" class="btn btn-default" tabindex="-1"
                                                title="Show custom tittle"><span
                                                    class="glyphicon glyphicon-chevron-down"></span></button>
										<button data-action="auto-youtube" class="btn btn-default" tabindex="-1"
                                                title="Create YouTube HTML"><span
                                                    class="fab fa-youtube"></span></button>
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

                <div class="form-group">
                    <div class="col-md-12">
                        <div class="pull-right">
                            <button id="add-link" class="btn btn-default"><span class="fa fa-plus"></span>
                            </button>
                        </div>
                        <button type="submit" class="btn btn-primary">Save links</button>
                        <div class="clear-fix"></div>
                    </div>
                </div>
            </fieldset>
        </form>
    </div>

    <div class="col-md-6">
        <div class="panel panel-default">
            <div class="panel-heading">
                <h4 class="panel-title">Work status</h4>
            </div>
            <div class="panel-body">
                <div data-active-container="status" class="form-group">
                    <form id="update-status"
                          action="<?php echo $Module->formatURL('update_status') . '&record_id=' . $Module->record['id'] ?>">
                        <input name="status" type="hidden" value="<?php echo $Module->record['status'] ?>"/>

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
                    </form>
                </div>
            </div>
        </div>

        <?php if ($Module->record['description']): ?>
            <div class="panel panel-default">
                <div class="panel-heading">
                    <h4 class="panel-title">Author's comment</h4>
                </div>
                <div class="panel-body author-note"><?php echo htmlspecialchars($Module->record['description']) ?></div>
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
    </div>
</div>

<hr/>
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

        $(document).on('click', 'button[id="works-preview"]', function (e) {
            e.preventDefault();
            $.ajax(
                '<?php echo $Module->formatURL('preview') . '&record_id=' . $Module->record['id']?>',
                {
                    method: "post",
                    data: wuF.serialize(),
                    dataType: "json",
                    success: function (response) {
                        previewModal.find('[id="content"]').html(response.content);
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

        // LINKS

        $('#work-links').sortable({items: '#record', axis: 'y', handle: '.icon'});

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

        // Generate YouTube embed html
        $(document).on('click', '[data-action="auto-youtube"]', function () {
            const url = $(this).closest('#record').find('input[data-type="links-url"]').val();
            const videoID = url.match(/(?:https?:\/{2})?(?:w{3}\.)?youtu(?:be)?\.(?:com|be)(?:\/watch\?v=|\/)([^\s&]+)/);

            if (videoID != null) {
                let tpl = '<?php echo NFWX::i()->project_settings['works_youtube_tpl']?>';
                tpl = tpl.replace('%id%', videoID[1]);

                const existVal = wuF.find('[name="external_html"]').val();
                wuF.find('[name="external_html"]').val(existVal ? existVal + "\n\n" + tpl : tpl);
            } else {
                $.jGrowl('The youtube url is not valid', {theme: 'error'});
            }

            return false;
        });

        $('form[id="works-update-links"]').activeForm({
            success: function () {
                $.jGrowl('Work links updated');
            }
        });

        $('[data-role="works-delete"]').click(function () {
            if (!confirm("Remove work?\nCAN NOT BE UNDONE!")) return false;

            $.post('<?php echo $Module->formatURL('delete') . '&record_id=' . $Module->record['id']?>', function (response) {
                response === 'success' ? window.location.href = '<?php echo $Module->formatURL() . '?event_id=' . $Module->record['event_id']?>' : alert(response);
            });
            return false;
        });
    });
</script>

<div id="works-preview-dialog" class="modal fade">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Preview</h4>
            </div>
            <div id="content" class="modal-body"></div>
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
					<button data-action="auto-youtube" class="btn btn-default" tabindex="-1"
                            title="Create YouTube HTML"><span class="fab fa-youtube"></span></button>
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
