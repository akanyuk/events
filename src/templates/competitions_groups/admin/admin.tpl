<?php
/**
 * @var competitions_groups $Module
 * @var array $records
 * @var array $event
 */

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.ui.interactions');
NFW::i()->registerResource('jquery.jgrowl');

NFW::i()->assign('page_title', $event['title'] . ' / Groups of competitions');

NFW::i()->breadcrumb = array(
    array('url' => 'admin/events?action=update&record_id=' . $event['id'], 'desc' => $event['title']),
    array('url' => 'admin/competitions?event_id=' . $event['id'], 'desc' => 'Competitions'),
    array('desc' => 'Groups of competitions'),
);

?>
<style>
    .record INPUT[type="text"] {
        width: 100%;
    }

    .record TEXTAREA {
        width: 100%;
        height: 150px;
    }
</style>
<div id="template" style="display: none;">
    <div id="record" class="record">
        <div class="cell"><span class="icon fa fa-sort" title="Sort"></span></div>
        <div class="cell"><input type="text" class="form-control" name="title[]"/></div>
        <div class="cell"><textarea class="form-control" name="announcement[]"><div class="hidden-lang-en">Русский текст</div><div class="hidden-lang-ru">English text</div></textarea>
        </div>
        <div class="cell">
            <button id="competitions-groups-remove" class="btn btn-xs btn-link"
                    title="<?php echo NFW::i()->lang['Remove'] ?>"><span
                        class="fa fa-times-circle text-danger"></span></button>
        </div>
    </div>
</div>

<form id="competitions-groups">
    <div id="values-area" class="settings">
        <div class="header">
            <div class="cell"></div>
            <div class="cell" style="width: 30%;"><?php echo $Module->attributes['title']['desc'] ?></div>
            <div class="cell" style="width: 70%;"><?php echo $Module->attributes['announcement']['desc'] ?></div>
        </div>
        <?php foreach ($records as $record) { ?>
            <input type="hidden" name="id[]" value="<?php echo $record['id'] ?>"/>
            <div id="record" class="record">
                <div class="cell"><span class="icon fa fa-sort" title="Sort"></span></div>
                <div class="cell"><input type="text" class="form-control" name="title[]"
                                         value="<?php echo htmlspecialchars($record['title']) ?>"/></div>
                <div class="cell"><textarea class="form-control"
                                            name="announcement[]"><?php echo $record['announcement'] ?></textarea></div>
                <div class="cell">
                    <button id="competitions-groups-remove" class="btn btn-xs btn-link"
                            title="<?php echo NFW::i()->lang['Remove'] ?>"><span
                                class="fa fa-times-circle text-danger"></span></button>
                </div>
            </div>
        <?php } ?>
    </div>

    <div style="padding-top: 20px;">
        <button id="add-group" class="btn btn-default">Add value</button>
        <button type="submit" name="form-send" class="btn btn-primary"><span
                    class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes'] ?></button>
    </div>
</form>


<script type="text/javascript">
    $(document).ready(function () {
        const f = $('form[id="competitions-groups"]');
        f.activeForm({
            action: '<?php echo $Module->formatURL('update') . '&event_id=' . $event['id'] ?>',
            success: function () {
                $.jGrowl('Groups of competitions saved');
            }
        });

        const values = $('div[id="values-area"]');

        values.sortable({items: '[id="record"]', axis: 'y', handle: '.icon'});

        $(document).on('click', '[id="competitions-groups-remove"]', function () {
            $(this).closest('[id="record"]').remove();
            return false;
        });

        $('button[id="add-group"]').click(function () {
            const tpl = $('[id="template"]').html();
            values.append(tpl);
            return false;
        });
    });
</script>