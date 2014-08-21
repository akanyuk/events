<?php 
NFW::i()->registerResource('dataTables');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action 'admin'
	
	// Current user manager of...
	var managedEvents = [];
	<?php foreach (NFW::i()->user['manager_of_events'] as $e) { ?>
	managedEvents.push(<?php echo $e?>);
	<?php } ?>
	
	var dataTablesConfig =  dataTablesDefaultConfig;

	// Infinity scrolling
	dataTablesConfig.bScrollInfinite = true;
	dataTablesConfig.bScrollCollapse = true;
	dataTablesConfig.iDisplayLength = 100;
	dataTablesConfig.sScrollY = $(window).height() - $('table[id="events"]').offset().top - 102;

	// AJAX-source
	dataTablesConfig.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';

	dataTablesConfig.fnRowCallback = function( nRow, aData, iDisplayIndex ) {
		// Status icons
		if (aData[0].hide) {
			$(nRow).addClass('old');
			$('td:eq(0)', nRow).html('<div class="ui-icon ui-icon-alert" title="Disabled"></div>');
		}
		else {
			$('td:eq(0)', nRow).html('');
		}
		
		// Make clickable URL
		if ($.inArray(aData[0].id, managedEvents) != -1) {
			$('td:eq(1)', nRow).html('<a href="<?php echo $Module->formatURL('update')?>&record_id=' + aData[0].id + '" title="Редактировать">' + aData[1] + '</a>');
		}
		
		// Dates
		$('td:eq(3)', nRow).html(aData[3] ? formatDateTime(aData[3]) : '-');
		$('td:eq(4)', nRow).html(aData[4] ? formatDateTime(aData[4]) : '-');
		
		return nRow;
	}
	
	// Create columns
	dataTablesConfig.aoColumns = [
		{ 'bSearchable': false, 'bSortable': false, 'sClass': 'icon-column' },	// properties (ID...)
	    { 'sWidth': '100%' },													// Title
	    { 'sClass': 'nowrap-column' },											// Alias
	    { 'bSearchable': false, 'sClass': 'nowrap-column' },					// Date from
	    { 'bSearchable': false, 'sClass': 'nowrap-column' } 					// Date to
    ];
		
	dataTablesConfig.aaSorting = [[0,'desc']];
	dataTablesConfig.oSearch = { 'sSearch': '<?php echo (isset($_GET['filter'])) ? htmlspecialchars($_GET['filter']) : ''?>' };

	var oTable = $('table[id="events"]').dataTable(dataTablesConfig);
	$(window).bind('resize', function () {
	    oTable.fnAdjustColumnSizing();
	});
	
	// Custom filtering function 
	$('.dataTables_filter').before($('div[id="custom-filters"]').html()).css('width', '60%');	
	$('div[id="custom-filters"]').remove();


	$(document).trigger('refresh');
});
</script>

<div id="custom-filters" style="display: none;">
	<div style="float: left;">
		<?php if (NFW::i()->checkPermissions('events', 'insert')) : ?>
			<a href="<?php echo $Module->formatURL('insert')?>" class="nfw-button" icon="ui-icon-circle-plus">Add record</a>
		<?php endif; ?>
	</div>
</div>

<table id="events" class="dataTables">
	<thead>
		<tr>
			<th></th>
			<th>Title</th>
			<th>Alias</th>
			<th>From</th>
			<th>To</th>
		</tr>
	</thead>
	<tbody></tbody>
</table>