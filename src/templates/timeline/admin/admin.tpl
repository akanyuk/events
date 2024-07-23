<?php
/**
 * @var timeline $Module
 * @var array $event
 * @var array $competitions
 * @var array $records
 */

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.min.js');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.min.css');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.ru.js');
NFW::i()->registerResource('jquery.jgrowl');

NFW::i()->assign('page_title', $event['title'] . ' / timeline');
NFW::i()->assign('no_admin_sidebar', true);

NFW::i()->breadcrumb = array(
    array('url' => 'admin/events?action=update&record_id=' . $event['id'], 'desc' => $event['title']),
    array('desc' => 'Timeline'),
);

ob_start();
?>
<button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapseHelp"
        aria-expanded="false" aria-controls="collapseExample"><span class="fa fa-question-circle"></span>
</button>
<?php
NFW::i()->breadcrumb_status = ob_get_clean();

$now = time() - time() % 3600 + 3600;

// linter related
ob_start(); ?>
<script type="text/javascript">
    $.jGrowl = function (timelineSaved) {
    };
    const dp = {};
    dp.datetimepicker = function (param) {
    };
</script><?php ob_end_clean();
?>
<script type="text/javascript">
    $(document).ready(function () {
        const f = $('form[id="timeline"]');
        f.activeForm({
            'action': '<?php echo $Module->formatURL('update') . '&event_id=' . $event['id'] ?>',
            'error': function (response) {
                if (response['responseJSON']['errors']['general'] !== undefined) {
                    alert(response['responseJSON']['errors']['general']);
                }
            },
            'success': function () {
                $.jGrowl('Timeline saved');
            }
        });

        $(document).on('click', '*[data-action="remove-values-record"]', function () {
            $(this).closest('div[id="record"]').remove();
        });

        f.find('button[id="add-values-record"]').click(function () {
            f.addValue(<?php echo $now?>, <?php echo $now?>, 0, 0, '', '', '', '', '');
            return false;
        });

        f.addValue = function (begin, end, competitionID, isPublic, title, description, type, beginSource, endSource) {
            const record = $('<div id="record" class="record">');
            record.append($('div[id="timeline-record-template"]').html()
                .replace(/%title%/g, title)
                .replace(/%description%/g, description)
                .replace(/%type%/g, type))
            if (isPublic) {
                record.find('input[name="is_public[]"]').attr('checked', 'checked');
            }

            $(this).find('div[id="values-area"]').append(record);

            const beginSrcObj = record.find('select[name="begin_source[]"]')
            const endSrcObj = record.find('select[name="end_source[]"]')

            // date/time source selector
            beginSrcObj.val(beginSource);
            beginSrcObj.change(function () {
                const compoObj = record.find('select[name="competition_id[]"] option:selected');
                updateDatepicker(beginDp, compoObj, beginSrcObj.val(), beginInput, initialTs);
            });

            endSrcObj.val(endSource);
            endSrcObj.change(function () {
                const compoObj = record.find('select[name="competition_id[]"] option:selected');
                updateDatepicker(endDp, compoObj, endSrcObj.val(), endInput, initialTs);
            });


            // competition
            record.find('select[name="competition_id[]"]').val(competitionID);
            record.find('select[name="competition_id[]"]').change(function () {
                const compoObj = record.find('select[name="competition_id[]"]');

                let placeholder = record.find('select[name="competition_id[]"] option:selected').text();
                if (compoObj.val() === "0") {
                    placeholder = "";
                }
                record.find('input[name="title[]"]').attr("placeholder", placeholder);

                if (compoObj.val() === "0") {
                    // Reset to "Manual input"
                    beginSrcObj.val("");
                    endSrcObj.val("");
                }

                updateDatepicker(beginDp, compoObj, beginSrcObj.val(), beginInput, initialTs);
                updateDatepicker(endDp, compoObj, endSrcObj.val(), endInput, initialTs);
            });

            // Datepicker
            const initialTs = begin;
            const beginDp = record.find('input[name="begin[]"]');
            const beginInput = createDatepicker(record, beginDp, beginSrcObj);
            const endDp = record.find('input[name="end[]"]')
            const endInput = createDatepicker(record, endDp, endSrcObj);

            // Set initial datepicker values
            record.find('select[name="competition_id[]"]').trigger("change");
        }

        <?php foreach ($records as $r) echo "\t\t" . 'f.addValue(
        ' . $r['begin'] . ', 
        ' . $r['end'] . ', 
        ' . $r['competition_id'] . ', 
        ' . $r['is_public'] . ',
        ' . json_encode($r['title']) . ', 
        ' . json_encode($r['description']) . ',
        ' . json_encode($r['type']) . ', 
        ' . json_encode($r['begin_source']) . ', 
        ' . json_encode($r['end_source']) . '
        );' . "\n"; ?>
    });

    function createDatepicker(record, dp, srcObj) {
        const name = dp.attr('name');
        record.append('<input name="' + name + '" type="hidden" />');
        dp.attr({'readonly': '1'}).removeAttr('name');

        const input = record.find('input[name="' + name + '"]');

        dp.datetimepicker({
            'autoclose': true,
            'todayBtn': true,
            'todayHighlight': true,
            'format': 'dd.mm.yyyy hh:ii',
            'minView': 0,
            'weekStart': <?php echo NFW::i()->user['language'] == 'English' ? '0' : '1'?>,
            'language': '<?php echo NFW::i()->user['language'] == 'English' ? 'en' : 'ru'?>',
            'startDate': '<?php echo date('d.m.Y H:i', time() - 86400 * 365)?>',
            'endDate': '<?php echo date('d.m.Y H:i', time() + 86400 * 365)?>'
        }).on('changeDate', function (e) {
            const TimeZoned = new Date(e['date'].setTime(e['date'].getTime() + (e['date'].getTimezoneOffset() * 60000)));
            dp.datetimepicker('setDate', TimeZoned);
            input.val(TimeZoned.valueOf() / 1000);

            // Reset to "Manual input"
            srcObj.val("");
        });

        return input;
    }

    function updateDatepicker(dp, compoObj, src, input, initialTs) {
        if (compoObj.val() === "0" || typeof (compoObj.data(src)) !== "number") {
            dp.datetimepicker('setDate', new Date(initialTs * 1000));
            input.val(initialTs);
            return;
        }

        dp.datetimepicker('setDate', new Date(compoObj.data(src) * 1000));
        input.val(0);
    }
</script>
<style>
    .settings {
        width: 100%;
    }
    .dp {
        display: inline;
        /*width: 138px;*/
    }
</style>
<div id="timeline-record-template" style="display: none;">
    <div class="cell"><input name="begin[]" type="text" class="form-control dp"/></div>
    <div class="cell">
        <select name="begin_source[]" class="form-control">
            <?php foreach ($Module->beginSources() as $src) { ?>
                <option value="<?php echo $src['val'] ?>"><?php echo $src['text'] ?></option>
            <?php } ?>
        </select>
    </div>
    <div class="cell"><input name="end[]" type="text" class="form-control dp"/></div>
    <div class="cell">
        <select name="end_source[]" class="form-control">
            <?php foreach ($Module->endSources() as $src) { ?>
                <option value="<?php echo $src['val'] ?>"><?php echo $src['text'] ?></option>
            <?php } ?>
        </select>
    </div>
    <div class="cell">
        <select name="competition_id[]" class="form-control">
            <option value="0">--- no bindings ---</option>
            <?php foreach ($competitions as $competition) { ?>
                <option value="<?php echo $competition['id'] ?>"
                        data-reception_from="<?php echo $competition['reception_from'] ?>"
                        data-reception_to="<?php echo $competition['reception_to'] ?>"
                        data-voting_from="<?php echo $competition['voting_from'] ?>"
                        data-voting_to="<?php echo $competition['voting_to'] ?>"
                ><?php echo htmlspecialchars($competition['title']) ?></option>
            <?php } ?>
        </select>
    </div>
    <div class="cell"><input name="title[]" value="%title%" class="form-control"/></div>
    <div class="cell"><textarea name="description[]" class="form-control">%description%</textarea></div>
    <div class="cell"><input name="type[]" value="%type%" class="form-control"/></div>
    <div class="cell">
        <label>
            <input name="is_public[]" type="checkbox" />
        </label>
    </div>
    <div class="cell">
        <button data-action="remove-values-record" class="btn btn-danger btn-xs"
                title="<?php echo NFW::i()->lang['Remove'] ?>"><span class="fa fa-times"></span></button>
    </div>
</div>

<div class="collapse" id="collapseHelp">
    <div class="well">
        <p>Sort rows by date. When adding new rows, the correct sorting is done after the page is refreshed.</p>

        <p>For all "Date/time source" options except "Manual input", the time will be replaced by the corresponding
            field of the competition.</p>

        <p>If there is a link to the competition and the "Custom title" field is not filled in, then the name of the
            competition will be used as the title.</p>
    </div>
</div>

<form id="timeline">
    <div id="values-area" class="settings">
        <div class="header">
            <div class="cell">Begin</div>
            <div class="cell">Begin source</div>
            <div class="cell">End</div>
            <div class="cell">End source</div>
            <div class="cell">Competition</div>
            <div class="cell">Title</div>
            <div class="cell">Description</div>
            <div class="cell">Type</div>
            <div class="cell">Public</div>
        </div>
    </div>
    <div style="padding-top: 20px;">
        <button id="add-values-record" class="btn btn-default">Add value</button>
        <button type="submit" name="form-send" class="btn btn-primary"><span
                    class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes'] ?></button>
    </div>
</form>