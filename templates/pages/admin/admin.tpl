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
	dataTablesConfig.sScrollY = $(window).height() - $('table[id="pages"]').offset().top - 102;

	// AJAX-source
	dataTablesConfig.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';

	dataTablesConfig.fnRowCallback = function( nRow, aData, iDisplayIndex ) {
		// Make clickable URL
		if (aData[0].is_active) {
			$('td:eq(0)', nRow).html('<a href="<?php echo $Module->formatURL('update')?>&record_id=' + aData[0].id + '" title="Редактировать параметры страницы">' + aData[1] + '</a>');
		}
		else {
			$('td:eq(0)', nRow).html('<a class="page-disabled" href="<?php echo $Module->formatURL('update')?>&record_id=' + aData[0].id + '" title="Редактировать параметры страницы">' + aData[1] + '</a>');
		}
		
		$('td:eq(1)', nRow).html('<a href="<?php echo NFW::i()->base_path?>' + aData[2] + '" title="Открыть страницу на сайте">' + aData[2] + '</a>');

		// Dates
		$('td:eq(2)', nRow).html(formatDateTime(aData[3]));
		
		return nRow;
	}
	
	// Create columns
	dataTablesConfig.aoColumns = [
		{ 'bSearchable': false, 'bVisible': false },		// properties (ID...)
	    { 'sClass': 'nowrap-column' },						// Title
	    { 'sClass': 'nowrap-column' },						// Path
	    { 'bSearchable': false, 'sClass': 'nowrap-column' },// Posted
	    { 'sClass': 'nowrap-column' }					// Posted By
    ];
		
	dataTablesConfig.aaSorting = [[0,'desc']];
	dataTablesConfig.oSearch = { 'sSearch': '<?php echo (isset($_GET['filter'])) ? htmlspecialchars($_GET['filter']) : ''?>' };

	var oTable = $('table[id="pages"]').dataTable(dataTablesConfig);
	$(window).bind('resize', function () {
	    oTable.fnAdjustColumnSizing();
	});
	
	// Custom filtering function 
	$('.dataTables_filter').before($('div[id="custom-filters"]').html()).css('width', '60%');	
	$('div[id="custom-filters"]').remove();


	$(document).trigger('refresh');
});
</script>
<style>
	.page-disabled { color: #888; }
</style>
<div id="custom-filters" style="display: none;">
	<div style="float: left;">
		<?php if (NFW::i()->checkPermissions('pages', 'insert')) : ?>
			<a href="<?php echo $Module->formatURL('insert')?>" class="nfw-button nfw-button-small nfw-tooltip" icon="ui-icon-document" title="Новая страница"></a>
		<?php endif; ?>
	</div>
</div>

<table id="pages" class="dataTables">
	<thead>
		<tr>
			<th></th>
			<th>Заголовок</th>
			<th>Путь</th>
			<th>Добавлена</th>
			<th>Кем</th>
		</tr>
	</thead>
	<tbody></tbody>
</table>