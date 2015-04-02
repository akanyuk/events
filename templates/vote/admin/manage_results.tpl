<script type="text/javascript">
$(document).ready(function(){

	// Save results
	$(document).off('click', 'button[id="save-results"]').on('click', 'button[id="save-results"]', function(){
		if (!confirm('Save current results permanent to works profiles (for publishing)?')) return false;
		
		$.post('<?php echo $Module->formatURL('manage_results').'&part=save-results'?>', { 
			'event_id': $('select[id="results-filter-event"]').val(),
			'votekey': $('select[id="results-filter-votekey"]').val()
		}, function(response){
			$.jGrowl(response);
		});
	});

	// Votes list
	var dtCfg = dataTablesDefaultConfig;

	dtCfg.bJQueryUI = false;

	dtCfg.aoColumns = [
		{ 'bSortable': false, 'sClass': 'strong icon-column' }, // position
		{ 'bSortable': false, 'sWidth': '100%' },				// work 
		{ 'bSortable': false, 'sClass': 'center' },				// summary
		{ 'bSortable': false, 'sClass': 'center' },				// summary
		{ 'bSortable': false, 'sClass': 'strong center' }		// summary
	];
		
	// AjaxSource
	// Server-side
	dtCfg.bServerSide = true;
	dtCfg.bProcessing = false;
	dtCfg.sAjaxSource = '<?php echo $Module->formatURL('manage_results').'&part=list.js'?>';
	dtCfg.fnServerData = function (sSource, aoData, fnCallback) {
		aoData.push({ 'name':'event_id','value':  $('select[id="results-filter-event"]').val() });
		aoData.push({ 'name':'votekey','value':  $('select[id="results-filter-votekey"]').val() });

		$.ajax({
			'dataType': 'json', 
			'type': "POST", 
			'url': sSource, 
			'data': aoData, 
			'success': function(response){
				fnCallback(response);
			}
		});
	};
	
	// Infinity scrolling
	dtCfg.bScrollInfinite = true;
	dtCfg.bScrollCollapse = true;
	dtCfg.iDisplayLength = 100;
	dtCfg.sScrollY = $(window).height() - $('table[id="results"]').offset().top - 140;

	// Save state
	dtCfg.bStateSave = true;
	dtCfg.iCookieDuration = 864000;
	dtCfg.sCookiePrefix = '';
	
	// Search & filters
	dtCfg.fnStateLoadParams = function(oSettings, oData) {
		// Set initial state of filters
		$('select[id="results-filter-event"] option[value="' + oData.event + '"]').attr('selected', 'selected');
	};

	dtCfg.fnStateSaveParams = function(oSettings, oData) {
		oData.event = $('select[id="results-filter-event"]').val();
	};

	dtCfg.fnRowCallback = function(nRow, aData, iDisplayIndex) {
		if (aData[0] == '') {
			// Competition header
			$('td:eq(1)', nRow).html('<h4>' + aData[1] + '</h4>');
			return;
		}

		$('td:eq(4)', nRow).html(number_format(aData[4], 2, '.', ''));
	};
	
	var resultsTable = $('table[id="results"]').dataTable(dtCfg);
		
	// Filtering 
	$('div[id="results_wrapper"]').find('.dataTables_filter').before($('div[id="results-custom-filters"]').html());
	$('div[id="results_wrapper"]').find('.dataTables_filter').remove();	
	$('div[id="results-custom-filters"]').remove();

	$('select[id="results-filter-event"], select[id="results-filter-votekey"]').change(function(){
		resultsTable.fnDraw();
	}).uniform();

	// Free filter
	resultsTable.fnSetFilteringDelay(500);
	$('div[id="results_wrapper"]').find('.dataTables_filter').find('input').uniform();
	
	$(document).trigger('refresh');
});
</script>
<style>
	/* Uniform select */
	.selector { top: -1px; }
		
	div#results_wrapper TH { white-space: nowrap; background-color: #E3E1C4; }
	div#results_wrapper .dataTables_info { float: none; padding-top: 0.5em; border-top: 1px solid #E3E1C4; width: 100%; }
	div#results_wrapper .dataTables_filter { padding-bottom: 1em; }
</style>

<div id="results-custom-filters" style="display: none;">
	<div style="padding-bottom: 0.5em;">
		<select id="results-filter-event"><?php foreach ($events as $e) { ?>
			<option value="<?php echo $e['id']?>"><?php echo htmlspecialchars($e['title'])?></option>
		<?php } ?></select>
		<select id="results-filter-votekey">
			<option value="-1">--- all ---</option>
			<option value="1">with votekey (online)</option>
			<option value="0">without votekey (partyplace)</option>
		</select>
		<button id="save-results" class="nfw-button" icon="ui-icon-check">Save results</button>
	</div>
</div>
<table id="results" class="dataTables">
	<thead>
		<tr>
			<th></th>
			<th>Work</th>
			<th>Num votes</th>
			<th>Total</th>
			<th>Average</th>
		</tr>
	</thead>
</table>