<?php 
NFW::i()->registerResource('dataTables');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action 'admin'
	
	var dataTablesConfig =  dataTablesDefaultConfig;

	// Infinity scrolling
	dataTablesConfig.bScrollInfinite = true;
	dataTablesConfig.bScrollCollapse = true;
	dataTablesConfig.iDisplayLength = 100;
	dataTablesConfig.sScrollY = $(window).height() - $('table[id="news"]').offset().top - 102;

	// AJAX-source
	dataTablesConfig.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';

	dataTablesConfig.fnRowCallback = function( nRow, aData, iDisplayIndex ) {
		// Make clickable URL
		<?php if (NFW::i()->checkPermissions('news', 'update')): ?>
		$('td:eq(0)', nRow).html('<a href="<?php echo $Module->formatURL('update')?>&record_id=' + aData[0].id + '" title="Редактировать параметры">' + aData[1] + '</a>');
		<?php endif; ?>
		
		// Dates
		$('td:eq(1)', nRow).html(formatDateTime(aData[2]));
		
		return nRow;
	}
	
	// Create columns
	dataTablesConfig.aoColumns = [
		{ 'bSearchable': false, 'bVisible': false },		// properties (ID...)
	    { 'sClass': 'nowrap-column' },						// Title
	    { 'bSearchable': false, 'sClass': 'nowrap-column' },// Posted
	    { 'sClass': 'nowrap-column' }						// Posted By
    ];
		
	dataTablesConfig.aaSorting = [[0,'desc']];
	dataTablesConfig.oSearch = { 'sSearch': '<?php echo (isset($_GET['filter'])) ? htmlspecialchars($_GET['filter']) : ''?>' };

	var oTable = $('table[id="news"]').dataTable(dataTablesConfig);
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
		<?php if (NFW::i()->checkPermissions('news', 'insert')) : ?>
			<a href="<?php echo $Module->formatURL('insert')?>" class="nfw-button nfw-button-small nfw-tooltip" icon="ui-icon-document" title="Добавить новость"></a>
		<?php endif; ?>
	</div>
</div>

<table id="news" class="dataTables">
	<thead>
		<tr>
			<th></th>
			<th>Заголовок</th>
			<th>Добавлена</th>
			<th>Кем</th>
		</tr>
	</thead>
	<tbody></tbody>
</table>