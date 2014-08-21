<?php
NFW::i()->registerResource('dataTables');
NFW::i()->registerResource('jquery.activeForm');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action 'insert'
	$(document).on('click', 'button[id="works-insert"]', function(){
		$('div[id="works-container"]').empty().load('<?php echo $Module->formatURL('insert')?>&event_id=' + $('select[id="filter-event"]').val());
		return false;
	});

	// Update positions
	$(document).on('click', 'button[id="works-update-pos"]', function(){
		$.post('<?php echo $Module->formatURL('update')?>&part=update_pos', oTable.find('input[rel="pos"]').serialize(), function(response){
			if (response != 'success') {
				$(document).trigger('uiDialog', [ response, { state: 'error' }]);
				return false;
			}
			
			oTable.fnDraw();
		});
		return false;
	});
	
	// Action 'admin'
	var availableCompetitions = [];
				
	var dtCfg = dataTablesDefaultConfig;
	dtCfg.aoColumns = [
		{ 'bSortable': false, 'sClass': 'icon-column' }, 		// status icon
		{ 'bSortable': false, 'sClass': 'nowrap-column right strong' },// Position
	  	{ 'bSortable': false, 'sWidth': '100%'},				// Prod title
		{ 'bSortable': false, 'sClass': 'nowrap-column' },		// Prod author
	  	{ 'bSortable': false, 'sClass': 'nowrap-column' },		// Competition
		{ 'bSortable': false, 'sClass': 'nowrap-column' },		// Platform
		{ 'bSortable': false, 'sClass': 'nowrap-column' },		// Format
		{ 'bSortable': false, 'sClass': 'nowrap-column' }		// posted
	];
	
	dtCfg.aaSorting = [[1,'asc']];
		
	// AjaxSource
	// Server-side
	dtCfg.bServerSide = true;
	dtCfg.bProcessing = false;
	dtCfg.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';
	dtCfg.fnServerData = function (sSource, aoData, fnCallback) {
		aoData.push({ 'name':'event_id','value':  $('select[id="filter-event"]').val() });
		aoData.push({ 'name':'competition_id','value':  $('select[id="filter-compo"]').val() });

		$.ajax( {
			'dataType': 'json', 
			'type': "POST", 
			'url': sSource, 
			'data': aoData, 
			'success': function(response){
				// Update available competitions
				availableCompetitions = [];
				$('select[id="filter-compo"]').empty().append('<option value="-1">--- all compos ---</option>');

				$.each(response.available_competitions, function(i, c) {
					availableCompetitions[c.id] = c.title;
					$('select[id="filter-compo"]').append('<option value="' + c.id + '"' + (c.id==response.current_competition ? ' selected="selected"' : '') + '>' + c.title + '</option>');
				});
				
				$.uniform.update($('select[id="filter-compo"]'));
				
				fnCallback(response);
			}			
		});
	}
	
	// Infinity scrolling
	dtCfg.bScrollInfinite = true;
	dtCfg.bScrollCollapse = true;
	dtCfg.iDisplayLength = 100;
	dtCfg.sScrollY = $(window).height() - $('table[id="works"]').offset().top - 102;

	// Save state
	dtCfg.bStateSave = true;
	dtCfg.iCookieDuration = 864000;
	dtCfg.sCookiePrefix = '';
	
	// Search & filters
	dtCfg.fnStateLoadParams = function(oSettings, oData) {
		// Set initial state of filters
		$('select[id="filter-event"] option[value="' + oData.event + '"]').attr('selected', 'selected');
	};

	dtCfg.fnStateSaveParams = function(oSettings, oData) {
		oData.event = $('select[id="filter-event"]').val();
	};

	dtCfg.fnDrawCallback = function(oSettings) {
		if (oSettings.fnRecordsDisplay()) {
			$('button[id="works-update-pos"]').show();
		}
		else {
			$('button[id="works-update-pos"]').hide();
		}
	};
	
	dtCfg.fnRowCallback = function(nRow, aData, iDisplayIndex) {
		// Status icons
		$('td:eq(0)', nRow).html('');
		if (!aData[0].v || !aData[0].r) {
			var strTitle = 'Status: <strong>' + aData[0].s + '</strong><br />';
			strTitle = strTitle + 'Voting: <strong>' + (aData[0].v ? 'on' : 'off') + '</strong><br />';
			strTitle = strTitle + 'Release: <strong>' + (aData[0].r ? 'on' : 'off') + '</strong><br />';
			$('<div class="ui-icon ui-icon-alert" title="' + strTitle + '"></div>').tooltip({ 'show': false, 'hide': false }).appendTo($(nRow).find('td:eq(0)'));
		}

		<?php if (NFW::i()->checkPermissions('works', 'update')): ?>
		// Position
		if ($('select[id="filter-event"]').val() != '-1') {
			$('td:eq(1)', nRow).html('<input rel="pos" name="pos[' + aData[0].id + ']" value="' + aData[1] + '" type="text" style="width: 15px;" maxlength="2" />');
			$('td:eq(1)', nRow).find('input').spinner({ min: 1, max: 99 });
		}

		// Update
		$('td:eq(2)', nRow).html('<a href="<?php echo $Module->formatURL('update')?>&record_id=' + aData[0].id + '">' + aData[2] + '</a>');
		<?php endif; ?>

		// Compo
		$('td:eq(4)', nRow).html(availableCompetitions[aData[4]]);
		
		// Dates
		$('td:eq(7)', nRow).html(formatDateTime(aData[7][0], true) + ' by ' + aData[7][1]);
		
		return nRow;
	};
		
	var oTable = $('table[id="works"]').dataTable(dtCfg);

	
	// Custom filtering function 
	$('.dataTables_filter').prepend($('div[id="custom-filters"]').html()).css('width', '100%');
	$('div[id="custom-filters"]').remove();

	$('select[id="filter-event"], select[id="filter-compo"]').change(function(){
		oTable.fnDraw();
	}).uniform();

	$(document).trigger('refresh');
});
</script>

<div id="custom-filters" style="display: none;">
	<div style="float: left; text-align: left;">
		<select id="filter-event">
<?php
	foreach ($events as $e) { 
		echo '<option value="'.$e['id'].'">'.htmlspecialchars($e['title']).'</option>';
	} 
?>
		</select>
		<select id="filter-compo"></select>
	</div>
	
	<?php if (NFW::i()->checkPermissions('works', 'insert')): ?>	
		<button id="works-insert" class="nfw-button" icon="ui-icon-circle-plus" title="Add record to selected event">Add work</button>
	<?php endif; ?>
	<?php if (NFW::i()->checkPermissions('works', 'update')): ?>	
		<button id="works-update-pos" class="nfw-button" icon="ui-icon-disk">Update positions</button>
	<?php endif; ?>
</div>

<div id="works-container"></div>

<table id="works" class="dataTables">
	<thead>
		<tr>
			<th></th>
			<th>Pos</th>
			<th>Title</th>
			<th>Author</th>
			<th>Competition</th>
			<th>Platform</th>
			<th>Format</th>
			<th>Posted</th>
		</tr>
	</thead>
</table>