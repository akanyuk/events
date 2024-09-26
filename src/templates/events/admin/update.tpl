<?php
/**
 * @var $Module events
 */

// Custom rendering: votelist, results.txt, etc...
$customRender = isset($_REQUEST['force-render']) ? 'update.' . $_REQUEST['force-render'] : false;
if ($customRender && file_exists(SRC_ROOT . '/templates/events/admin/' . $customRender . '.tpl')) {
    NFW::i()->stop($Module->renderAction(array('request' => $_REQUEST), $customRender));
}

NFW::i()->assign('page_title', $Module->record['title'] . ' / edit');

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.jgrowl');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerResource('jquery.ui.interactions');

active_field('set_defaults', array('labelCols' => '2', 'inputCols' => '10'));

// Preload competitions array
$CCompetitions = new competitions();
$competitions = $CCompetitions->getRecords(array('filter' => array('event_id' => $Module->record['id'])));


// Generate breadcrumbs

NFW::i()->breadcrumb = array(
    array('url' => 'admin/events', 'desc' => 'Events'),
    array('desc' => $Module->record['title'])
);

NFW::i()->breadcrumb_status = '<div>Posted: ' . date('d.m.Y H:i', $Module->record['posted']) . ' (' . $Module->record['posted_username'] . ')</div>';
if ($Module->record['edited']) {
    NFW::i()->breadcrumb_status .= '<div>Updated: ' . date('d.m.Y H:i', $Module->record['edited']) . ' (' . $Module->record['edited_username'] . ')</div>';
}

// Logotype form

$CMedia = new media();

$preview_form = $CMedia->openSession(array(
    'owner_class' => 'events_preview',
    'owner_id' => $Module->record['id'],
    'single_upload' => true,
    'images_only' => true,
    'template' => '_admin_events_preview_form',
    'preview_default' => NFW::i()->assets('main/news-no-image.png'),
    'image_max_x' => 64, 'image_max_y' => 64,
    'preview' => $Module->record['preview'] ?: array('id' => false, 'url' => false),
));

$preview_large_form = $CMedia->openSession(array(
    'owner_class' => 'events_preview_large',
    'owner_id' => $Module->record['id'],
    'single_upload' => true,
    'images_only' => true,
    'template' => '_admin_events_preview_form',
    'preview_default' => NFW::i()->assets('main/news-no-image.png'),
    'preview' => $Module->record['preview_large'] ?: array('id' => false, 'url' => false),
));

// Success dialog
NFW::i()->registerFunction('ui_dialog');
$successDialog = new ui_dialog();
$successDialog->render();
?>
<script type="text/javascript">
    $(document).ready(function () {
        // Main action
        $('form[data-action="events-update"]').each(function () {
            $(this).activeForm({
                action: '<?php echo $Module->formatURL('update') . '&record_id=' . $Module->record['id']?>',
                success: function (response) {
                    if (response['is_updated']) {
                        $.jGrowl('Event profile updated.');
                    }
                }
            });
        });

        // Visual edit
        const switchEditor = $('a[id="switch-editor"]');
        const result = JSON.parse(localStorage.getItem('eventVisualEditor'));
        const visualEditor = result != null && result;
        if (visualEditor) {
            $('textarea[name="content"]').CKEDIT({
                'media': 'events',
                'media_owner': '<?php echo $Module->record['id']?>'
            });

            switchEditor.text("Switch to source editor");
        } else {
            switchEditor.text("Switch to visual editor");
        }

        switchEditor.click(function (e) {
            e.preventDefault();
            localStorage.setItem('eventVisualEditor', JSON.stringify(!visualEditor));
            window.location.reload();
        });

        // Voting variants
        const sF = $('form[id="voting-settings-update"]');
        sF.activeForm({
            success: function (response) {
                if (response['is_updated']) {
                    $.jGrowl('Voting settings updated.');
                }
            }
        });

        // Sortable `values`
        sF.find('div[id="values-area"]').sortable({items: 'div[id="record"]', axis: 'y', handle: '.icon'});

        $(document).off('click', '*[data-action="remove-values-record"]').on('click', '*[data-action="remove-values-record"]', function (event) {
            if ($(this).closest('div[id="record"]').data('role') === 'update') {
                if (!confirm('Remove value')) {
                    event.preventDefault();
                    return false;
                }
            }

            $(this).closest('div[id="record"]').remove();
        });

        sF.find('button[id="add-values-record"]').click(function () {
            const tpl = $('div[id="voting-settings-record-template"]').html();
            sF.find('div[id="values-area"]').append(tpl);
            return false;
        });

        // Votelist
        $('a[data-action="toggle-votelist-col"]').attr('title', 'Toggle all').click(function () {
            const tbody = $(this).closest('table').find('tbody');
            const index = $(this).closest('th').index();

            // Determine new state
            let newState = false;
            tbody.find('tr').each(function () {
                if ($(this).find('td').eq(index).find('input[type="checkbox"]:not(:checked)').length) {
                    newState = true;
                }
            });

            // Set new state
            tbody.find('tr').each(function () {
                $(this).find('td').eq(index).find('input[type="checkbox"]').prop('checked', newState);
            });

            return false;
        });


        $('form[id="make"]').activeForm({
            success: function (response) {
                $(document).trigger('show-<?php echo $successDialog->getID()?>', ['<a href="' + response.url + '">' + response.url + '</a>']);
            }
        });
    });
</script>

<style>
    FORM#make TEXTAREA {
        font-family: Consolas, Lucida Console, Courier New, monospace;
        font-size: 13px;
        color: #444;
        height: 450px;
    }
</style>
<div class="row">
    <div id="events-update-record=container" class="col-md-9">

        <ul class="nav nav-tabs" role="tablist">
            <li role="presentation" class="active"><a href="#settings" aria-controls="settings" role="tab"
                                                      data-toggle="tab">Settings</a></li>
            <li role="presentation"><a href="#description" aria-controls="description" role="tab" data-toggle="tab">Description</a>
            </li>
            <li role="presentation"><a href="#voting_settings" aria-controls="voting_settings" role="tab"
                                       data-toggle="tab">Voting settings</a></li>
            <li role="presentation"><a href="#votelist" aria-controls="votelist" role="tab"
                                       data-toggle="tab">Votelist</a></li>
            <li role="presentation"><a href="#builders" aria-controls="builders" role="tab"
                                       data-toggle="tab">Builders</a></li>
            <?php if (NFW::i()->checkPermissions('events', 'manage')): ?>
                <li role="presentation"><a href="#manage" aria-controls="manage" role="tab" data-toggle="tab">Manage</a>
                </li>
            <?php endif; ?>
        </ul>

        <div class="tab-content">
            <?php if (NFW::i()->checkPermissions('events', 'manage')): ?>
                <div role="tabpanel" class="tab-pane" style="padding-top: 20px;"
                     id="manage"><?php echo $Module->renderAction('_manage') ?></div>
            <?php endif; ?>

            <div role="tabpanel" class="tab-pane in active" style="padding-top: 20px;" id="settings">
                <form data-action="events-update">
                    <?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes' => $Module->attributes['title'], 'inputCols' => '8')) ?>
                    <?php echo active_field(array('name' => 'date_from', 'value' => $Module->record['date_from'], 'attributes' => $Module->attributes['date_from'], 'endDate' => -365)) ?>
                    <?php echo active_field(array('name' => 'date_to', 'value' => $Module->record['date_to'], 'attributes' => $Module->attributes['date_to'], 'endDate' => -365)) ?>
                    <?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes' => $Module->attributes['announcement'], 'height' => '100px;')) ?>
                    <?php echo active_field(array('name' => 'announcement_og', 'value' => $Module->record['announcement_og'], 'attributes' => $Module->attributes['announcement_og'])) ?>
                    <?php echo active_field(array('name' => 'hide_works_count', 'value' => $Module->record['hide_works_count'], 'attributes' => $Module->attributes['hide_works_count'])) ?>

                    <div class="form-group">
                        <div class="col-md-10 col-md-offset-2">
                            <button type="submit" class="btn btn-primary"><span
                                    class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes'] ?></button>
                        </div>
                    </div>
                </form>
                <hr/>
                <?php echo $CMedia->openSession(array('owner_class' => get_class($Module), 'owner_id' => $Module->record['id'])); ?>
            </div>

            <div role="tabpanel" class="tab-pane" style="padding-top: 10px;" id="description">
                <form data-action="events-update">
                    <textarea name="content" class="form-control"
                              style="height: 500px;"><?php echo htmlspecialchars($Module->record['content']) ?></textarea>

                    <div style="display: flex; justify-content: space-between; margin-top: 10px; margin-bottom: 20px;">
                        <a id="switch-editor" href="#">Switch to source editor</a>
                    </div>

                    <h4>Available meta tags:</h4>
                    <pre>
%COMPETITIONS-LIST%
%TIMETABLE%
</pre>

                    <h3>Description in column</h3>
                    <textarea name="content_column" class="form-control"
                              style="height: 200px;"><?php echo htmlspecialchars($Module->record['content_column']) ?></textarea>

                    <h4>Available meta tags:</h4>
                    <pre>
%UPLOAD-BUTTON%
%LIVE-VOTING-BUTTON%
%COMPETITIONS-LIST-SHORT%
</pre>

                    <button type="submit" class="btn btn-primary"><span
                            class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes'] ?></button>
                </form>
            </div>

            <div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="voting_settings">
                <div id="voting-settings-record-template" style="display: none;">
                    <div id="record" class="record">
                        <div class="cell"><span class="icon glyphicon glyphicon-sort" title="Sort"></span></div>
                        <?php foreach ($Module->options_attributes as $key => $a) { ?>
                            <div class="cell"><input type="text" class="form-control"
                                                     name="options[<?php echo $key ?>][]"
                                                     style="<?php echo $a['style'] ?>"
                                                     placeholder="<?php echo $a['desc'] ?>" <?php echo isset($a['required']) && $a['required'] ? 'required' : '' ?> />
                            </div>
                        <?php } ?>
                        <div class="cell">
                            <button data-action="remove-values-record" class="btn btn-danger btn-xs"
                                    title="<?php echo NFW::i()->lang['Remove'] ?>"><span
                                    class="glyphicon glyphicon-remove"></span></button>
                        </div>
                    </div>
                </div>

                <form id="voting-settings-update">
                    <input type="hidden" name="update_record_options" value="1"/>

                    <div class="input-group" style="margin: 0 15px;">
                        <?php echo active_field([
                            'name' => 'voting_system',
                            'value' => $Module->record['voting_system'],
                            'attributes' => $Module->attributes['voting_system'],
                            'vertical' => true,
                        ]) ?>
                    </div>

                    <h2>Voting variants</h2>

                    <div class="alert alert-info">Do not specify options if you want to keep the default values (0-10)
                    </div>

                    <div id="values-area" class="settings">
                        <?php foreach ($Module->record['options'] as $v) { ?>
                            <div id="record" class="record" data-role="update">
                                <div class="cell"><span class="icon glyphicon glyphicon-sort" title="Sort"></span></div>
                                <?php foreach ($Module->options_attributes as $key => $a) { ?>
                                    <div class="cell"><input type="text" class="form-control"
                                                             name="options[<?php echo $key ?>][]"
                                                             value="<?php echo $v[$key] ?>"
                                                             style="<?php echo $a['style'] ?>"
                                                             placeholder="<?php echo $a['desc'] ?>" <?php echo isset($a['required']) && $a['required'] ? 'required' : '' ?> />
                                    </div>
                                <?php } ?>
                                <div class="cell">
                                    <button data-action="remove-values-record" class="btn btn-danger btn-xs"
                                            title="<?php echo NFW::i()->lang['Remove'] ?>"><span
                                            class="glyphicon glyphicon-remove"></span></button>
                                </div>
                            </div>
                        <?php } ?>
                    </div>
                    <div style="padding-top: 20px;">
                        <button id="add-values-record" class="btn btn-default">Add value</button>
                        <button type="submit" name="form-send" class="btn btn-primary"><span
                                class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes'] ?></button>
                    </div>
                </form>
            </div>

            <div role="tabpanel" class="tab-pane" style="padding-top: 10px;" id="votelist">
                <form id="votelist" method="POST"
                      action="<?php echo $Module->formatURL('update') . '&record_id=' . $Module->record['id'] . '&force-render=votelist' ?>"
                      target="_blank">
                    <?php
                    echo active_field(array('name' => 'header', 'desc' => 'Header', 'value' => $Module->record['title']));
                    echo active_field(array('name' => 'subheader', 'desc' => 'Subheader', 'value' => 'Main compo votelist'));
                    echo active_field(array('name' => 'description', 'desc' => 'Description', 'type' => 'textarea', 'value' => NFW::i()->getLang('main', 'votelist note'), 'labelCols' => '2'));
                    ?>
                    <table class="table table-striped table-condensed">
                        <thead>
                        <tr>
                            <th><a data-action="toggle-votelist-col" href="#">Include this competition</a></th>
                            <th><a data-action="toggle-votelist-col" href="#">Display works</a></th>
                            <th>Empty rows</th>
                        </tr>
                        </thead>
                        <tbody><?php foreach ($competitions as $c) { ?>
                            <tr>
                                <td>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox" checked="CHECKED" name="competitions[]"
                                                   value="<?php echo $c['id'] ?>"/>
                                            <?php echo htmlspecialchars($c['title']) ?>
                                        </label>
                                    </div>
                                </td>
                                <td><input type="checkbox" checked="CHECKED" name="display_works[]"
                                           value="<?php echo $c['id'] ?>"/></td>
                                <td><input type="text" class="form-control" style="width: 100px;"
                                           name="emptyrows[<?php echo $c['id'] ?>]" value="0"
                                           maxlength="2"/></td>
                            </tr>
                        <?php } ?></tbody>
                    </table>

                    <div style="padding-top: 20px;">
                        <button type="submit" class="btn btn-primary"><span class="fa fa-list-ol"></span> Generate
                            votelist
                        </button>
                    </div>
                </form>
            </div>

            <div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="builders">
                <form id="make">
                    <fieldset>
                        <legend>Generating results.txt</legend>

                        <textarea class="form-control"
                                  name="results_txt"><?php echo $Module->renderAction(array('request' => $_REQUEST), 'update.results.txt') ?></textarea>

                        <br/>
                        <div data-active-container="results_filename">
                            <div class="input-group">
                                    <span class="input-group-addon"
                                          id="sizing-addon1">files/<?php echo $Module->record['alias'] ?>/</span>

                                <input type="text" class="form-control" name="results_filename" value="results.txt"
                                       maxlength="64" placeholder="results.txt">
                                <span class="input-group-btn">
			        							<button name="save_results_txt" value="1" type="submit"
                                                        class="btn btn-primary" title="Save results file"><span
                                                        class="fa fa-save"></span></button>
											</span>
                            </div>
                            <span class="help-block"></span>
                        </div>
                    </fieldset>
                </form>
            </div>

        </div>
    </div>

    <div class="col-md-3">
        <?php /* Right bar */ ?>
        <h3>Preview image:</h3>
        <?php echo $preview_form ?>

        <h3>Large preview:</h3>
        <?php echo $preview_large_form ?>
        <br/>
        <br/>

        <div class="panel panel-primary">
            <div class="panel-heading">Related links</div>
            <div class="panel-body">
                <ul class="nav nav-pills nav-stacked">
                    <li role="presentation"><a
                            href="<?php echo NFW::i()->base_path . 'admin/competitions?event_id=' . $Module->record['id'] ?>"
                            title="Manage competitions of this events">Manage competitions</a></li>
                    <li role="presentation"><a
                            href="<?php echo NFW::i()->base_path . 'admin/works?event_id=' . $Module->record['id'] ?>"
                            title="Manage works of this events">Manage works</a></li>
                    <li role="presentation"><a
                            href="<?php echo NFW::i()->base_path . 'admin/vote?event_id=' . $Module->record['id'] ?>"
                            title="Manage voting of this events">Manage voting</a></li>
                </ul>

                <?php if (!empty($competitions)): ?>
                    <hr/>
                    <?php foreach ($competitions as $competition) { ?>
                        <p><?php echo $competition['position'] ?>.&nbsp;<a
                                href="<?php echo NFW::i()->base_path . 'admin/competitions?action=update&record_id=' . $competition['id'] ?>"
                                title="Manage `<?php echo htmlspecialchars($competition['title']) ?>` competition"><?php echo htmlspecialchars($competition['title']) ?></a>
                        </p>
                    <?php } ?>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>