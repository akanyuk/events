<?php
/**
 * @var object $Module
 * @var competitions $CCompetitions
 * @var array $personalNote
 * @var array $linkTitles
 */

$langMain = NFW::i()->getLang('main');

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

echo '<div style="display: none;">' . NFW::i()->fetch(NFW::i()->findTemplatePath('_common_status_icons.tpl')) . '</div>';
?>
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
                    <dl>
                        <dt>Current owner:</dt>
                        <dd>
                            <a href="/admin/users?filter=<?php echo urlencode($Module->record['posted_username']) ?>"><?php echo htmlspecialchars($Module->record['posted_username']) ?></a>
                            (<?php echo htmlspecialchars($Module->record['poster_email']) ?>)
                        </dd>
                    </dl>

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
                                        <svg width="1em" height="1em">
                                            <use xlink:href="#<?php echo $s['svg-icon'] ?>"/>
                                        </svg>
                                    </button>
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
                            <button type="submit" class="btn btn-primary btn-full-xs">Update status</button>
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

        <br/>

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

    <div class="col-md-6">
        <form id="works-my-status"
              action="<?php echo $Module->formatURL('my_status') . '&record_id=' . $Module->record['id'] ?>">
            <div <?php echo $personalNote['comment'] ? 'class="has-warning"' : '' ?> style="padding-bottom: 10px;">
                <label class="control-label" for="comment">Personal note (only for you)</label>
                <textarea class="form-control"
                          name="comment"><?php echo $personalNote['comment'] ?></textarea>
            </div>
            <button id="set-personal-note" class="btn btn-primary">Set</button>
            <button id="clear-personal-note" class="btn btn-primary">Clear</button>
        </form>

        <h3>Activity</h3>
        <button id="show-all-activity" class="btn btn-default btn-sm btn-full-xs"
                style="margin-top: 1em; margin-bottom: 1em; display:none;">Show early activity
        </button>
        <div class="activity" id="work-activity"></div>

        <form id="send-message" style="margin-top: 1em;"
              action="<?php echo NFW::i()->base_path ?>admin/works_activity?action=message&work_id=<?php echo $Module->record['id'] ?>">
            <div class="form-group">
                <div class="col-md-12">
                    <textarea required="required" class="form-control" name="message"
                              placeholder="Send a message to the author"></textarea>
                </div>
            </div>

            <div class="form-group">
                <div class="col-md-12">
                    <button type="submit" class="btn btn-primary btn-full-xs">Send message</button>
                </div>
            </div>
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
            'after_upload' => 'admin_work_media_added',
            'after_delete' => 'admin_work_media_deleted',
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
        <button class="btn btn-danger btn-full-xs" data-role="works-delete">Delete work permanently</button>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        const wuF = $('form[id="works-update"]');
        wuF.activeForm({
            success: function () {
                $.jGrowl('Work profile updated');
                loadActivity();
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

        previewModal.on('hide.bs.modal', function () {
            previewModal.find('iframe').attr("srcdoc", ""); // For stopping audio
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
                loadActivity();
            }
        });

        // Personal note form
        const formMyStatus = $('form[id="works-my-status"]');
        const textareaMyStatus = formMyStatus.find('textarea')
        formMyStatus.activeForm({
            success: function (response) {
                $.jGrowl(response['message']);
            }
        });
        $('button[id="clear-personal-note"]').click(function () {
            textareaMyStatus.val("");
            textareaMyStatus.parent().removeClass("has-warning");
        });
        $('button[id="set-personal-note"]').click(function () {
            if (textareaMyStatus.val() === "") {
                $.jGrowl("Please fill note text", {theme: 'error'});
                return false;
            }
            textareaMyStatus.parent().addClass("has-warning");
        });


        // Links
        updateSaveLinksButtonVisibility();

        $('#work-links').sortable({items: 'div[id="record"]', axis: 'y', handle: '.icon'});

        $(document).on('click', '[data-action="toggle-title"]', function () {
            $(this).closest('div[id="record"]').find('input[data-type="links-title"]').closest('div').toggle();
            return false;
        });

        $(document).on('click', '[data-action="remove-link"]', function () {
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
                loadActivity();
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
        const btn = $('button[id="save-links"]');
        <?php if (!empty($Module->record['links'])):?>
        btn.show();
        <?php else: ?>
        if ($('#work-links').find('div[id="record"]').length) {
            btn.show();
        } else {
            btn.hide();
        }
        <?php endif; ?>
    }

    // Activity

    const divWorkActivity = $('div[id="work-activity"]');
    const buttonShowAllActivity = $('button[id="show-all-activity"]');
    const showLastActivityCnt = 25; // Showing last N activity

    $('form[id="send-message"]').activeForm({
        success: function (resp) {
            $('form[id="send-message"]').find('textarea').val("");
            const item = activityItem(resp);
            divWorkActivity.append(item);
        }
    });

    buttonShowAllActivity.click(function () {
        divWorkActivity.find('.item').show();
        buttonShowAllActivity.hide();

        $([document.documentElement, document.body]).animate({
            scrollTop: divWorkActivity.offset().top - 100
        }, 500);
    });

    loadActivity(); // At startup

    function loadActivity() {
        buttonShowAllActivity.hide();

        $.ajax(
            '<?php echo NFW::i()->base_path . 'admin/works_activity?action=list&work_id=' . $Module->record['id']?>',
            {
                method: "get",
                success: function (response) {
                    divWorkActivity.empty();
                    let isButtonShowAllActivity = false;
                    let isUnreadDelimiterShown = false;
                    const numRecords = response['records'].length;
                    response['records'].forEach(function (r, index) {
                        if (index === 0 && r['is_new']) {
                            isUnreadDelimiterShown = true; // All activities new
                        }

                        if (!isUnreadDelimiterShown && r['is_new']) {
                            let delimMsg = document.createElement('div');
                            delimMsg.innerText = "New activity";
                            delimMsg.className = "message";

                            let delim = document.createElement('div');
                            delim.classList.add("item", "unread-delimiter");
                            delim.appendChild(delimMsg);

                            divWorkActivity.append(delim);

                            isUnreadDelimiterShown = true;
                        }

                        let item = activityItem(r);
                        if (numRecords - index > showLastActivityCnt && !r['is_new']) {
                            item["style"].display = 'none';
                            isButtonShowAllActivity = true;
                        }
                        divWorkActivity.append(item);
                    });

                    if (numRecords > showLastActivityCnt && isButtonShowAllActivity) {
                        buttonShowAllActivity.show();
                    }

                    UpdateHeaderUnread(response['unread']);
                },
                error: function () {
                    alert("Load work activity unexpected error");
                }
            }
        );
    }

    function activityItem(r) {
        const isOutgoing = r['posted_by'] !== <?php echo $Module->record['posted_by']?>;

        let author = document.createElement('div');
        author.className = "author";
        author.innerText = formatDateTime(r['posted'], true, true) + ' by ' + r['poster_username'];

        let message = document.createElement('div');
        message.className = "message";
        message.innerText = r['message'];

        let item = document.createElement('div');
        item.className = "item";
        if (!r['is_message']) {
            item.classList.add("action");
        } else if (isOutgoing) {
            item.classList.add("outgoing");
        } else {
            item.classList.add("incoming");
        }

        item.appendChild(author);
        item.appendChild(message);

        return item;
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
