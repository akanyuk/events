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
            if (!confirm('Save current results permanent to works profiles (for publishing)?')) {
                return false;
            }

            $.get('<?php echo $Module->formatURL('results') . '&event_id=' . $event['id']?>&part=save-results&calc_by=' + calcBy.val(), function (response) {
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
    <div class="col-md-6 col-lg-4">
        <div class="input-group">
            <select id="results-calc-by" class="form-control">
                <option value="avg">Calc by Avg</option>
                <option value="iqm">Calc by IQM</option>
                <option value="pts">Calc by Sum</option>
            </select>

            <div class="input-group-btn">
                <button id="save-results" class="btn btn-warning" title="Publish results permanently">Save results
                </button>
            </div>
        </div>
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