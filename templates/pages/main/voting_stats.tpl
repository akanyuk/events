<script type="text/javascript">
$(document).ready(function(){
	$('select[name="competition_id"], select[name="event_id"]').change(function(){
		$(this).closest('form').submit();
	}); 
});
</script>
<form id="stats">
	<legend>Voting statistics</legend>
		
	<div class="row">
  		<div class="col-md-5">		
			<select name="event_id" class="form-control"><?php foreach ($events as $e) {
				echo '<option value="'.$e['id'].'"'.($e['id'] == $cur_event['id'] ? ' selected="selected"' : '').'>'.htmlspecialchars($e['title']).'</option>';
			} ?></select>
		</div>
		<div class="col-md-7">
			<select name="competition_id" class="form-control"><?php foreach ($competitions as $c) {
				echo '<option value="'.$c['id'].'"'.($c['id'] == $cur_competition['id'] ? ' selected="selected"' : '').'>'.htmlspecialchars($c['title']).'</option>';
			} ?></select>
		</div>
	</div>
</form>
<br />
<style>
/*			
	.google-visualization-controls-categoryfilter-selected { max-width: inherit !important; }
	.google-visualization-controls-categoryfilter-selected { max-width: 150px; }
	.google-visualization-controls-categoryfilter-selected LI { white-space: nowrap; overflow: hidden; }
*/
	.google-visualization-controls-label { display: none; }
</style>
<?php if ($data): ?>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
google.load("visualization", "1", { packages:["corechart"] });
google.setOnLoadCallback(drawChart);
function drawChart() {
  var data = new google.visualization.arrayToDataTable([<?php echo $data?>]);

  var columnsTable = new google.visualization.DataTable();
  columnsTable.addColumn('number', 'colIndex');
  columnsTable.addColumn('string', 'colLabel');
  var initState= { selectedValues: [] };
  // put the columns into this data table (skip column 0)
  for (var i = 1; i < data.getNumberOfColumns(); i++) {
      columnsTable.addRow([i, data.getColumnLabel(i)]);
      // you can comment out this next line if you want to have a default selection other than the whole list
      initState.selectedValues.push(data.getColumnLabel(i));
  }
  // you can set individual columns to be the default columns (instead of populating via the loop above) like this:
  // initState.selectedValues.push(data.getColumnLabel(4));
  
  var chart = new google.visualization.ChartWrapper({
      chartType: 'LineChart',
      containerId: 'chart_div',
      dataTable: data,
      options: {
    	  'chartArea': { left:32 },
          'title': '<?php echo htmlspecialchars($cur_event['title'].' / '.$cur_competition['title'])?> (Average vote)',
          'width': 1000, 
          'height': 500
      }
  });
  
  var columnFilter = new google.visualization.ControlWrapper({
      controlType: 'CategoryFilter',
      containerId: 'colFilter_div',
      dataTable: columnsTable,
      options: {
          filterColumnLabel: 'colLabel',
          ui: {
              allowTyping: false,
              allowMultiple: true,
              allowNone: false,
              selectedValuesLayout: 'below'
          }
      },
      state: initState
  });
  
  function setChartView () {
      var state = columnFilter.getState();
      var row;
      var view = {
          columns: [0]
      };
      for (var i = 0; i < state.selectedValues.length; i++) {
          row = columnsTable.getFilteredRows([{column: 1, value: state.selectedValues[i]}])[0];
          view.columns.push(columnsTable.getValue(row, 0));
      }
      // sort the indices into their original order
      view.columns.sort(function (a, b) {
          return (a - b);
      });
      chart.setView(view);
      chart.draw();
  }
  google.visualization.events.addListener(columnFilter, 'statechange', setChartView);
  
  setChartView();
  columnFilter.draw();
}
</script>

<div id="colFilter_div"></div>
<div id="chart_div"></div>
<?php else: ?>
<div class="alert alert-info">Nothing found.</div>
<?php endif; ?>	