<?php
/**
 * @var timeline $Module
 * @var array $event
 * @var array $competitions
 * @var array $records
 */

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.maskedinput');
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

$now = date("Y-m-d 00:00", $event['date_from']);

// linter related
ob_start(); ?>
<script type="text/javascript">
    $.jGrowl = function (timelineSaved) {
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
                return false;
            },
            'success': function () {
                $.jGrowl('Timeline saved');
            }
        });

        $(document).on('click', '[data-action="remove-values-record"]', function () {
            $(this).closest('div[id="record"]').remove();
        });

        f.find('[id="add-values-record"]').click(function () {
            f.addValue('<?php echo $now?>', '<?php echo $now?>', 0, 0, '', '', '', '', '');
            return false;
        });

        f.addValue = function (begin, end, competitionID, isPublic, title, description, type, beginSource, endSource) {
            const record = $('<div id="record" class="record">');
            record.append($('div[id="timeline-record-template"]').html()
                .replace(/%begin%/g, begin)
                .replace(/%end%/g, end)
                .replace(/%title%/g, title.replace(/"/g, '&quot;'))
                .replace(/%description%/g, description)
                .replace(/%type%/g, type))
            if (isPublic) {
                record.find('input[data-role="is_public"]').attr('checked', 'checked');
                record.find('input[name="is_public[]"]').val(1);
            }

            $(this).find('div[id="values-area"]').append(record);

            record.find('input[data-role="is_public"]').click(function () {
                if (this.checked) {
                    record.find('input[name="is_public[]"]').val(1);
                } else {
                    record.find('input[name="is_public[]"]').val("");
                }
            });

            record.find('input[data-role="date"]').mask("9999-99-99 99:99", {placeholder: "_"});

            const beginSrcObj = record.find('select[name="begin_source[]"]');
            const endSrcObj = record.find('select[name="end_source[]"]');
            const compoObj = record.find('select[name="competition_id[]"]');

            // date/time source selector
            beginSrcObj.val(beginSource).change(function () {
                const compoObj = record.find('select[name="competition_id[]"] option:selected');
                if (compoObj.val() === "0" || $(this).val() === "") {
                    record.find('input[name="begin[]"]').val(begin).removeAttr("readonly");
                } else {
                    record.find('input[name="begin[]"]').val(compoObj.data($(this).val())).attr("readonly", "readonly");
                }
            });

            endSrcObj.val(endSource).change(function () {
                const compoObj = record.find('select[name="competition_id[]"] option:selected');
                if (compoObj.val() === "0" || $(this).val() === "") {
                    record.find('input[name="end[]"]').val(end).removeAttr("readonly");
                } else {
                    record.find('input[name="end[]"]').val(compoObj.data($(this).val())).attr("readonly", "readonly");
                }
            });

            // competition
            compoObj.val(competitionID).change(function () {
                // Reset to "Manual input"
                if (compoObj.val() === "0") {
                    beginSrcObj.val("");
                    endSrcObj.val("");

                    beginSrcObj.children().each(function () {
                        if ($(this).val() !== "") {
                            $(this).attr("disabled", "disabled");
                        }
                    });

                    endSrcObj.children().each(function () {
                        if ($(this).val() !== "") {
                            $(this).attr("disabled", "disabled");
                        }
                    });
                } else {
                    beginSrcObj.children().each(function () {
                        $(this).removeAttr("disabled");
                    });

                    endSrcObj.children().each(function () {
                        $(this).removeAttr("disabled");
                    });
                }

                beginSrcObj.trigger("change");
                endSrcObj.trigger("change");
            });

            // Set initial state
            compoObj.trigger("change");
        }

        <?php foreach ($records as $r) echo "\t\t" . 'f.addValue(
        ' . json_encode(date("Y-m-d H:i", $r['begin'])) . ', 
        ' . json_encode(date("Y-m-d H:i", $r['end'])) . ', 
        ' . $r['competition_id'] . ', 
        ' . $r['is_public'] . ',
        ' . json_encode($r['title']) . ', 
        ' . json_encode($r['description']) . ',
        ' . json_encode($r['type']) . ', 
        ' . json_encode($r['begin_source']) . ', 
        ' . json_encode($r['end_source']) . '
        );' . "\n"; ?>
    });
</script>
<style>
    .settings {
        width: 100%;
    }
</style>
<div id="timeline-record-template" style="display: none;">
    <div class="cell"><input name="begin[]" value="%begin%" type="text" data-role="date" class="form-control"/></div>
    <div class="cell">
        <select name="begin_source[]" class="form-control">
            <?php foreach ($Module->beginSources() as $src) { ?>
                <option value="<?php echo $src['val'] ?>"><?php echo $src['text'] ?></option>
            <?php } ?>
        </select>
    </div>
    <div class="cell"><input name="end[]" value="%end%" type="text" data-role="date" class="form-control"/></div>
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
                        data-reception_from="<?php echo date("Y-m-d H:i", $competition['reception_from']) ?>"
                        data-reception_to="<?php echo date("Y-m-d H:i", $competition['reception_to']) ?>"
                        data-voting_from="<?php echo date("Y-m-d H:i", $competition['voting_from']) ?>"
                        data-voting_to="<?php echo date("Y-m-d H:i", $competition['voting_to']) ?>"
                ><?php echo htmlspecialchars($competition['title']) ?></option>
            <?php } ?>
        </select>
    </div>
    <div class="cell"><input name="title[]" value="%title%" placeholder="Using competition title if blank"
                             title="Using competition title if blank" class="form-control"/></div>
    <div class="cell"><textarea name="description[]" class="form-control">%description%</textarea></div>
    <div class="cell"><input name="type[]" value="%type%" class="form-control"/></div>
    <div class="cell">
        <label>
            <input name="is_public[]" type="hidden"/>
            <input data-role="is_public" type="checkbox"/>
        </label>
    </div>
    <div class="cell">
        <a data-action="remove-values-record" class="btn btn-danger btn-xs"
           title="<?php echo NFW::i()->lang['Remove'] ?>"><span class="fa fa-times"></span></a>
    </div>
</div>

<div class="collapse" id="collapseHelp">
    <div class="well">
        <p>Sort rows by date. When adding new rows, the correct sorting is done after the page is refreshed.</p>

        <p>For all "Date/time source" options except "Manual input", the time will be replaced by the corresponding
            field of the competition.</p>

        <p>If there is a link to the competition and the "Title" field is not filled in, then the name of the
            competition will be used as the title.</p>

        <p>You can preview JSON response <a href="/api/v2/timeline?event=<?php echo $event['alias']?>">here</a>.</p>
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
        <a id="add-values-record" class="btn btn-default">Add value</a>
        <button type="submit" name="form-send" class="btn btn-primary"><span
                    class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes'] ?></button>
    </div>
</form>