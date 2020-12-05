<?php 
NFW::i()->registerResource('jquery.activeForm');

$CEvents = new events();
$events = $CEvents->getRecords();

$CCompetitoins = new competitions();
$competitions = $CCompetitoins->getRecords();
?>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
$(document).ready(function(){
	$('select[id="competition_id"]').change(function(){
		loadStatistic();
	});
	
	$('select[id="event_id"]').change(function(){
		$('select[id="competition_id"]').empty();

		var curEvent = $(this).val();
		
		$('#competitions-full-list div').each(function(){
			if ($(this).data('event-id') == curEvent) {
				$('select[id="competition_id"]').append('<option value="' + $(this).data('id') + '">' + $(this).text() + '</option>');
			} 
		});

		loadStatistic();
		
	}).trigger('change');

	$('#chapter').on('click', 'a[role="tab"]', function (e) {
	    loadStatistic($(this).attr('aria-controls'));
	});	

	function loadStatistic(chapter) {
		if (!chapter) {
			chapter = $('#chapter').find('li.active a').attr('aria-controls');
		}
		
		var competition_id = $('select[id="competition_id"]').val();

		if (chapter == 'timeline') {
			$.post(null, { 'chapter': 'timeline', 'competition_id': competition_id}, function(response){

				switch (response.result) {
				case 'error':
					$('div[id="timeline-container"]').html('<div class="alert alert-danger">' + response.message + '</div>');
					break;
				case 'empty':
					$('div[id="timeline-container"]').html('<div class="alert alert-info">Empty result.</div>');
					break;
				case 'success':
					$('div[id="timeline-container"]').html('<div id="colFilter_div"></div><div id="chart_div"></div>');							
					drawChart(JSON.parse(response.data));
					break;

				}
			}, 'json');
		}

		if (chapter == 'countries') {
			$.post(null, { 'chapter': 'countries', 'competition_id': competition_id}, function(response){
				$('div[id="countries-container"]').html(response);
			}, 'html');
		}
	}
});


// Google charts
google.load("visualization", "1", { packages:["corechart"] });
//google.setOnLoadCallback(drawChart);
function drawChart(data) {
  data = new google.visualization.arrayToDataTable(data);

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
      options: { 'chartArea': { left:32 }, 'width': 1000, 'height': 500 }
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
<style>
	.tab-pane { padding-top: 20px; }
	.google-visualization-controls-label { display: none; }
</style>

<div id="competitions-full-list" style="display: none;"><?php foreach ($competitions as $c) { ?>
	<div data-event-id="<?php echo $c['event_id']?>" data-id="<?php echo $c['id']?>"><?php echo htmlspecialchars($c['title'])?></div>
<?php } ?></div>

<h1>Voting statistics</h1>
	 
<div class="row">
	<div class="col-md-5">		
		<select id="event_id" class="form-control"><?php foreach ($events as $e) {
			echo '<option value="'.$e['id'].'">'.htmlspecialchars($e['title']).'</option>';
		} ?></select>
	</div>
	<div class="col-md-7"><select id="competition_id" class="form-control"></select></div>
</div>
<br />

<ul id="chapter" class="nav nav-tabs" role="tablist">
	<li role="presentation" class="active"><a href="#timeline" aria-controls="timeline" role="tab" data-toggle="tab">Timeline</a></li>
	<li role="presentation"><a href="#countries" aria-controls="countries" role="tab" data-toggle="tab">Countries</a></li>
</ul>

<div class="tab-content">
	<div role="tabpanel" class="tab-pane active" id="timeline">
		<div id="timeline-container"></div>
	</div>
	
	<div role="tabpanel" class="tab-pane" id="countries">
		<div id="countries-container"></div>
	</div>
</div>
