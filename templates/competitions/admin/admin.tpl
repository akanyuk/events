<?php
NFW::i()->registerResource('jquery.uniform'); 
NFW::i()->registerResource('dataTables');
NFW::i()->registerResource('jquery.jgrowl');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action `insert`
	$(document).on('click', 'button[id="competitions-insert"]', function(){
		window.location.href = '<?php echo $Module->formatURL('insert')?>&event_id=' + $('select[id="filter-event"]').val(); 
	});
	
	// Update positions
	$(document).on('click', 'button[id="competitions-update-pos"]', function(){
		$.post('<?php echo $Module->formatURL('update')?>&part=update_pos', oTable.find('input[rel="pos"]').serialize(), function(response){
			if (response != 'success') {
				alert(response);
				return false;
			}
			
			oTable.fnReloadAjax();
		});
		return false;
	});
	
	// Action 'admin'
	var dtCfg =  dataTablesDefaultConfig;
	
	// Infinity scrolling
	dtCfg.bScrollInfinite = true;
	dtCfg.bScrollCollapse = true;
	dtCfg.iDisplayLength = 100;
	dtCfg.sScrollY = $(window).height() - $('table[id="competitions"]').offset().top - 102;

	// AJAX-source
	dtCfg.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';

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
			$('button[id="competitions-update-pos"]').show();
		}
		else {
			$('button[id="competitions-update-pos"]').hide();
		}
	};
	
	dtCfg.fnRowCallback = function(nRow, aData, iDisplayIndex) {
		$('td:eq(0)', nRow).html('');

		// Make clickable URL
		<?php if (NFW::i()->checkPermissions('competitions', 'update')): ?>
		// Position
		$('td:eq(1)', nRow).html('<input rel="pos" name="pos[' + aData[0].id + ']" value="' + aData[1] + '" type="text" style="width: 15px;" maxlength="2" />');
		$('td:eq(1)', nRow).find('input').spinner({ min: 1, max: 99 });
		$('td:eq(2)', nRow).html('<a href="<?php echo $Module->formatURL('update')?>&record_id=' + aData[0].id + '" title="Редактировать">' + aData[2] + '</a>');
		<?php endif; ?>
		
		// Dates
		$('td:eq(4)', nRow).html(aData[4] ? formatDateTime(aData[4], true) : '-');
		$('td:eq(5)', nRow).html(aData[5] ? formatDateTime(aData[5], true) : '-');
		$('td:eq(6)', nRow).html(aData[6] ? formatDateTime(aData[6], true) : '-');
		$('td:eq(7)', nRow).html(aData[7] ? formatDateTime(aData[7], true) : '-');
		
		return nRow;
	}
	
	// Create columns
	dtCfg.aoColumns = [
		{ 'bSortable': false, 'sClass': 'icon-column' },								// properties (ID...)
		{ 'bSortable': false, 'bSearchable': false, 'sClass': 'nowrap-column right strong' },	// Position
	    { 'bSortable': false, 'sWidth': '100%' },										// Title
	    { 'bSortable': false, 'sClass': 'nowrap-column' },								// Alias
	    { 'bSortable': false, 'bSearchable': false, 'sClass': 'nowrap-column right' },	// reception from
	    { 'bSortable': false, 'bSearchable': false, 'sClass': 'nowrap-column' }, 		// reception to
	    { 'bSortable': false, 'bSearchable': false, 'sClass': 'nowrap-column right' },	// voting from
	    { 'bSortable': false, 'bSearchable': false, 'sClass': 'nowrap-column' } 		// voting to
	];

	var oTable = $('table[id="competitions"]').dataTable(dtCfg);
	
	// Custom filtering function 
	$('.dataTables_filter').before($('div[id="custom-filters2"]').html());	
	$('.dataTables_filter').prepend($('div[id="custom-filters"]').html()).css('width', '60%');
	$('div[id="custom-filters"], div[id="custom-filters2"]').remove();

	$.fn.dataTableExt.afnFiltering.push(
		function(oSettings, aData, iDataIndex) {
			return aData[0].event_id == $('select[id="filter-event"] option:selected').val() ? true : false;
		}
	);
	
	$('select[id="filter-event"]').change(function(){
		oTable.fnDraw();
	}).uniform();
	

	$(document).trigger('refresh');
});
</script>
<div id="custom-filters2" style="display: none;">
	<select id="filter-event">
<?php
	foreach ($Module->attributes['event_id']['options'] as $e) { 
		echo '<option value="'.$e['id'].'">'.htmlspecialchars($e['desc']).'</option>';
	} 
?>
	</select>
</div>
<div id="custom-filters" style="display: none;">
	<?php if (NFW::i()->checkPermissions('competitions', 'insert')): ?>	
		<button id="competitions-insert" class="nfw-button" icon="ui-icon-circle-plus">Add record</button>
	<?php endif; ?>
	<?php if (NFW::i()->checkPermissions('competitions', 'update')): ?>	
		<button id="competitions-update-pos" class="nfw-button" icon="ui-icon-disk">Update positions</button>
	<?php endif; ?>
</div>

<table id="competitions" class="dataTables">
	<thead>
		<tr>
			<th></th>
			<th>Pos</th>
			<th>Title</th>
			<th>Full alias</th>
			<th>Works accepting start</th>
			<th>Works accepting end</th>
			<th>Voting start</th>
			<th>Voting end</th>
		</tr>
	</thead>
	<tbody></tbody>
</table>