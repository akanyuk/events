<?php
/**
 * @var vote $Module
 * @var array $event
 */
?>
<script type="text/javascript">
    $(document).ready(function () {
        const table = $('table[id="results"]');
        const calcBy = $('select[id="results-calc-by"]');

        calcBy.change(function () {
            loadTable();
        }).trigger('change');

        $('button[id="save-results"]').click(function () {
            if (!confirm('Save results with "<?php echo $event['voting_system']?>" calculation permanently to works profiles (for publishing)?')) {
                return false;
            }

            $.get('<?php echo $Module->formatURL('results') . '&event_id=' . $event['id']?>&part=save-results', function (response) {
                $.jGrowl(response);
            });
        });

        function loadTable() {
            $.get('<?php echo $Module->formatURL('results') . '&event_id=' . $event['id'] ?>&part=list&calc_by=' + calcBy.val(), function (response) {
                table.find('tbody').html(response);
            });
        }
    });
</script>
<style>
    #results td {
        vertical-align: middle;
    }
</style>
<div class="row">
    <div class="col-sm-9 col-md-8 col-lg-5">
        <div class="input-group">
            <select id="results-calc-by" class="form-control">
                <option <?php echo $event['voting_system'] == "avg" ? 'selected="selected"' : '' ?> value="avg">Preview
                    with Avg
                </option>
                <option <?php echo $event['voting_system'] == "iqm" ? 'selected="selected"' : '' ?> value="iqm">Preview
                    with IQM
                </option>
                <option <?php echo $event['voting_system'] == "sum" ? 'selected="selected"' : '' ?> value="sum">Preview
                    with Sum
                </option>
            </select>

            <div class="input-group-btn">
                <button id="save-results" title="Publish results permanently"
                        class="btn btn-warning">Save results by <strong><?php echo $event['voting_system'] ?></strong>
                </button>
            </div>
        </div>
    </div>
    <div class="hidden-xs col-sm-3 col-md-4 col-lg-7">
        <a class="btn btn-link"
           href="<?php echo NFW::i()->absolute_path . '/admin/events?action=update&record_id=' . $event['id'] ?>">Change
            voting system</a>
    </div>
</div>

<table id="results" class="table table-striped">
    <thead>
    <tr>
        <th>Score</th>
        <th>#</th>
        <th>Work</th>
    </tr>
    </thead>
    <tbody></tbody>
</table>