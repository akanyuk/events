<?php
	NFW::i()->registerFunction('active_field');
?>
<style>
	/* Custom tooltip */
	.t-s-b { white-space: nowrap; font-size: 90%; max-width: none; }
	
	/* Uniform select */
	.selector { top: -1px; }
		
	div#votekeys_wrapper TH { white-space: nowrap; background-color: #E3E1C4; }
	div#votekeys_wrapper .dataTables_info { float: none; padding-top: 0.5em; border-top: 1px solid #E3E1C4; width: 100%; }
	div#votekeys_wrapper .dataTables_filter { padding-bottom: 1em; }
	div#votekeys_wrapper .v { font-family: "Lucida Console", Monaco, monospace; font-weight: bold; }
	div#votekeys_wrapper .vs { text-decoration: line-through; }
	
	FORM#votekeys-insert LABEL { float: none; text-align: left; padding-bottom: 0.5em; width: 200px; }
	FORM#votekeys-insert .input-row { padding-left: 0; }
</style>

<div id="votekeys-insert-dialog">
	<form id="votekeys-insert" action="<?php echo $Module->formatURL('manage_votekeys')?>&part=add-votekeys">
		<input name="event_id" type="hidden" />
		<input name="count" value="1" type="hidden" />
		
		<label>Amount: <strong><span id="count-value">1</span></strong></label>
		<div id="count-slider"></div>
		<div class="delimiter"></div>
		
		<?php echo active_field(array('name' => 'email', 'desc' => 'E-mail (as comment)', 'type' => 'str', 'width' => '350px', 'maxlength' => 80)); ?>
	</form>
</div>	

<div id="votekeys-custom-filters" style="display: none;">
	<div style="float: left; font-size: 7.5pt;">
		<select id="votekeys-filter-event"><?php foreach ($events as $e) { ?>
			<option value="<?php echo $e['id']?>"><?php echo htmlspecialchars($e['title'])?></option>
		<?php } ?></select>
		<button id="votekeys-insert" class="nfw-button" icon="ui-icon-plus">Add votekeys</button>
	</div>
</div>
<table id="votekeys" class="dataTables">
	<thead>
		<tr>
			<th></th>
			<th>Votekey</th>
			<th>E-mail</th>
			<th>Posted</th>
			<th>Browser</th>
			<th>IP</th>
		</tr>
	</thead>
</table>
<script type="text/javascript">
$(document).ready(function(){
	// Insert votekeys
	var viD = $('div[id="votekeys-insert-dialog"]');
	viD.dialog({ 
		autoOpen:false,draggable:false,modal:true,resizable: false,
		width: 'auto', height: 'auto',
		buttons: {
			'Create': function() {
				viF.submit();
			}
		}
	});	

	$(document).on('click', 'button[id="votekeys-insert"]', function(){
		viF.find('input[name="event_id"]').val($('select[id="votekeys-filter-event"]').val());
		viD.dialog('option', 'title', 'New votekeys for ' + $('select[id="votekeys-filter-event"] option:selected').text());
		viD.dialog('open');
	});
	
	var viF = $('form[id="votekeys-insert"]');
	viF.activeForm({
		success: function(response) {
			viD.dialog('close');
			oTable.fnDraw();
		}
	});

	viF.find('#count-slider').slider({
		value: 1, min: 1, max: 100,
		slide: function(event, ui) {
			viF.find('span[id="count-value"]').text(ui.value);
			viF.find('input[name="count"]').val(ui.value);
		}
	});

	
	// Votekeys list
	var dtCfg = dataTablesDefaultConfig;

	dtCfg.bJQueryUI = false;

	dtCfg.aoColumns = [
		{ 'bSearchable': false, 'bSortable': false, 'sClass': 'icon-column' }, 			// icon
		{ 'bSortable': false, 'sClass': 'nowrap-column' },								// votekey
		{ 'bSortable': false, 'sWidth': '100%' },										// email
		{ 'bSearchable': false, 'bSortable': false, 'sClass': 'nowrap-column' },		// posted
		{ 'bSearchable': false, 'bSortable': false, 'sClass': 'nowrap-column' },		// browser
		{ 'bSearchable': false, 'bSortable': false, 'sClass': 'nowrap-column' }			// IP
	];
		
	// AjaxSource
	// Server-side
	dtCfg.bServerSide = true;
	dtCfg.bProcessing = false;
	dtCfg.sAjaxSource = '<?php echo $Module->formatURL('manage_votekeys').'&part=list.js'?>';
	dtCfg.fnServerData = function (sSource, aoData, fnCallback) {
		aoData.push({ 'name':'event_id','value':  $('select[id="votekeys-filter-event"]').val() });

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
	dtCfg.sScrollY = $(window).height() - $('table[id="votekeys"]').offset().top - 140;

	// Save state
	dtCfg.bStateSave = true;
	dtCfg.iCookieDuration = 864000;
	dtCfg.sCookiePrefix = '';
	
	// Search & filters
	dtCfg.fnStateLoadParams = function(oSettings, oData) {
		// Set initial state of filters
		$('select[id="votekeys-filter-event"] option[value="' + oData.event + '"]').attr('selected', 'selected');
	};

	dtCfg.fnStateSaveParams = function(oSettings, oData) {
		oData.event = $('select[id="votekeys-filter-event"]').val();
	};

	dtCfg.fnRowCallback = function(nRow, aData, iDisplayIndex) {
		$('td:eq(0)', nRow).html('');

		var textClass = aData[1][1] ? 'v vs' : 'v';
		$('td:eq(1)', nRow).html('<span class="' + textClass + '">' + aData[1][0] + '</span>');

		$('td:eq(3)', nRow).html(formatDateTime(aData[3], true));

		// browser
		var text = aData[4][0] ? aData[4][0] : 'unknown'; 
		$('td:eq(4)', nRow).html('<span title="' + aData[4][1] + '">' + text + '</span>').tooltip({ 'tooltipClass': 't-s-b', 'track':false, 'show':false, 'hide':false });
		
		return nRow;
	};
		
	var oTable = $('table[id="votekeys"]').dataTable(dtCfg);
		
	// Filtering 
	$('div[id="votekeys_wrapper"]').find('.dataTables_filter').before($('div[id="votekeys-custom-filters"]').html());	
	$('div[id="votekeys-custom-filters"]').remove();

	$('select[id="votekeys-filter-event"]').change(function(){
		oTable.fnDraw();
	}).uniform();

	// Free filter
	oTable.fnSetFilteringDelay(500);
	$('div[id="votekeys_wrapper"]').find('.dataTables_filter').find('input').uniform();
	
	$(document).trigger('refresh');
});
</script>