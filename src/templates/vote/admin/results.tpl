<?php
/**
 * @var vote $Module
 * @var array $event
 */
?>
<script type="text/javascript">
    $(document).ready(function () {

        // Save results
        $(document).off('click', 'button[id="save-results"]').on('click', 'button[id="save-results"]', function () {
            if (!confirm('Save current results permanent to works profiles (for publishing)?')) return false;

            $.post('<?php echo $Module->formatURL('results') . '&event_id=' . $event['id'] . '&part=save-results'?>', {
                'order': $('select[id="results-filter-order"]').val()
            }, function (response) {
                $.jGrowl(response);
            });
        });


        // Votes list
        const config = dataTablesDefaultConfig;

        // Infinity scrolling
        config.scrollY = $(window).height() - $('table[id="results"]').offset().top - 130;
        // Fix horizontal scroll
        //config.scrollX = '100%';
        config.deferRender = true;
        config.scroller = true;

        // Server-side
        config.bServerSide = true;
        config.bProcessing = false;
        config.sAjaxSource = '<?php echo $Module->formatURL('results') . '&event_id=' . $event['id'] . '&part=list.js'?>';
        config.fnServerData = function (sSource, aoData, fnCallback) {
            aoData.push({'name': 'order', 'value': $('select[id="results-filter-order"]').val()});

            $.ajax({
                'dataType': 'json',
                'type': "POST",
                'url': sSource,
                'data': aoData,
                'success': fnCallback
            });
        };

        config.aoColumns = [
            {'sortable': false, 'className': 'nowrap-column'}, 	// score (vts)
            {'sortable': false, 'className': 'nowrap-column'}, 	// place
            {'sortable': false, 'width': '100%'},				// work
        ];

        config.fnRowCallback = function (nRow, aData, iDisplayIndex) {
            if (aData[0] === '') {
                // Competition header
                $('td:eq(1)', nRow).html('');
                $('td:eq(2)', nRow).html('<h4>' + aData[1] + '</h4>');
                return;
            }

            $('td:eq(1)', nRow).html('<span class="label label-default">' + aData[0] + '</span>');
            $('td:eq(2)', nRow).html(aData[1]);

            const vts = aData[2];
            let sum = aData[3];
            let avg = number_format(aData[4], 2, '.', '');
            let iqm = number_format(aData[5], 2, '.', '');

            if ($('select[id="results-filter-order"]').val() === 'avg') {
                $('td:eq(0)', nRow).html('<code>' + avg + '</code> (' + vts + ')');
            } else if ($('select[id="results-filter-order"]').val() === 'iqm') {
                $('td:eq(0)', nRow).html('<code>' + iqm + '</code> (' + vts + ')');
            } else {
                $('td:eq(0)', nRow).html('<code>' + sum + '</code> (' + vts + ')');
            }
        };

        const resultsTable = $('table[id="results"]').dataTable(config);

        // Custom filtering function
        $('div[id="results_length"]').empty().html($('div[id="results-custom-filters"]').html());
        $('div[id="results-custom-filters"]').remove();

        $('select[id="results-filter-order"]').change(function () {
            resultsTable.fnDraw();
        });
    });
</script>
<div id="results-custom-filters" style="display: none;">
    <select id="results-filter-order" class="form-control" style="width: inherit;">
        <option value="avg">Calc by Avg</option>
        <option value="iqm">Calc by IQM</option>
        <option value="pts">Calc by Sum</option>
    </select>

    <button id="save-results" class="btn btn-warning" title="Publish results permanently">Save results</button>
</div>

<table id="results" class="table table-striped">
    <thead>
    <tr>
        <th>score</th>
        <th></th>
        <th>Work</th>
    </tr>
    </thead>
</table>