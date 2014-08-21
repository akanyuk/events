<script type="text/javascript">
$(document).ready(function(){

	// Globals
	$(document).off('votes-list-reload').on('votes-list-reload', function(){
		oTable.fnDraw();
	});

	// Insert vote
	$(document).off('click', 'button[id="vote-insert"]').on('click', 'button[id="vote-insert"]', function(){
		$('div[id="vote-insert-container"]').empty().load('<?php echo $Module->formatURL('manage_votes').'&part=add-vote&event_id='?>' + $('select[id="votes-filter-event"]').val());
	});
	

	// Votes list
	var dtCfg = dataTablesDefaultConfig;

	dtCfg.bJQueryUI = false;

	dtCfg.aoColumns = [
		{ 'bSortable': false, 'sClass': 'icon-column' }, 	// icon
		{ 'sWidth': '100%' },								// work 
		{ 'sClass': 'strong center' },								// vote
		{ 'sClass': 'nowrap-column' },						// username  
		{ 'sClass': 'nowrap-column' },						// votekey
		{ 'sClass': 'nowrap-column' },						// votekey email
		{ 'sClass': 'nowrap-column' },						// posted
		{ 'sClass': 'nowrap-column' },						// browser
		{ 'sClass': 'nowrap-column' }						// IP
	];
		
	// AjaxSource
	// Server-side
	dtCfg.bServerSide = true;
	dtCfg.bProcessing = false;
	dtCfg.sAjaxSource = '<?php echo $Module->formatURL('manage_votes').'&part=list.js'?>';
	dtCfg.fnServerData = function (sSource, aoData, fnCallback) {
		aoData.push({ 'name':'event_id','value':  $('select[id="votes-filter-event"]').val() });

		$.ajax( {
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
	dtCfg.sScrollY = $(window).height() - $('table[id="votes"]').offset().top - 140;

	// Save state
	dtCfg.bStateSave = true;
	dtCfg.iCookieDuration = 864000;
	dtCfg.sCookiePrefix = '';
	
	// Search & filters
	dtCfg.fnStateLoadParams = function(oSettings, oData) {
		// Set initial state of filters
		$('select[id="votes-filter-event"] option[value="' + oData.event + '"]').attr('selected', 'selected');
	};

	dtCfg.fnStateSaveParams = function(oSettings, oData) {
		oData.event = $('select[id="votes-filter-event"]').val();
	};

	dtCfg.fnRowCallback = function(nRow, aData, iDisplayIndex) {
		$('td:eq(0)', nRow).html('');
		$('td:eq(4)', nRow).html('<span class="v">' + aData[4] + '</span>');
		$('td:eq(6)', nRow).html(formatDateTime(aData[6], true));

		// browser
		var text = aData[7][0] ? aData[7][0] : 'unknown'; 
		$('td:eq(7)', nRow).html('<span title="' + aData[7][1] + '">' + text + '</span>').tooltip({ 'tooltipClass': 't-s-b', 'track':false, 'show':false, 'hide':false });
		
		return nRow;
	};
		
	var oTable = $('table[id="votes"]').dataTable(dtCfg);
		
	// Filtering 
	$('div[id="votes_wrapper"]').find('.dataTables_filter').before($('div[id="votes-custom-filters"]').html());	
	$('div[id="votes-custom-filters"]').remove();

	$('select[id="votes-filter-event"]').change(function(){
		oTable.fnDraw();
	}).uniform();

	// Free filter
	oTable.fnSetFilteringDelay(500);
	$('div[id="votes_wrapper"]').find('.dataTables_filter').find('input').uniform();
	
	$(document).trigger('refresh');
});
</script>
<style>
	/* Custom tooltip */
	.t-s-b { white-space: nowrap; font-size: 90%; max-width: none; }

	/* Uniform select */
	.selector { top: -1px; }
		
	div#votes_wrapper TH { white-space: nowrap; background-color: #E3E1C4; }
	div#votes_wrapper .dataTables_info { float: none; padding-top: 0.5em; border-top: 1px solid #E3E1C4; width: 100%; }
	div#votes_wrapper .dataTables_filter { padding-bottom: 1em; }
	div#votes_wrapper .v { font-family: "Lucida Console", Monaco, monospace; }
</style>

<div id="vote-insert-container"></div>

<div id="votes-custom-filters" style="display: none;">
	<div style="float: left; font-size: 7.5pt;">
		<select id="votes-filter-event"><?php foreach ($events as $e) { ?>
			<option value="<?php echo $e['id']?>"><?php echo htmlspecialchars($e['title'])?></option>
		<?php } ?></select>
	</div>
	<button id="vote-insert" class="nfw-button" icon="ui-icon-plus">Add vote</button>
</div>
<table id="votes" class="dataTables">
	<thead>
		<tr>
			<th></th>
			<th>Work</th>
			<th>Vote&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
			<th>Name&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</th>
			<th>Key</th>
			<th>E-mail</th>
			<th>Posted</th>
			<th>Browser</th>
			<th>IP</th>
		</tr>
	</thead>
</table>