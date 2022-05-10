<?php
NFW::i()->assign('page_title', 'Страницы / редактирование');
 
NFW::i()->registerResource('dataTables');
NFW::i()->registerResource('dataTables/Scroller');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action 'admin'
	var config =  dataTablesDefaultConfig;
	
	// Infinity scrolling
	config.scrollY = $(window).height() - $('table[id="pages"]').offset().top - 130;
	config.deferRender = true;
	config.scroller = true;

	// AJAX-source
	config.ajax = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';

	// Create columns
	config.columns = [
		{ 'searchable': false, 'visible': false },				// properties (ID...)
	    { 'width': '100%' },									// Title
		{ 'className': 'nowrap-column' },						// Path
	    { 'searchable': false, 'className': 'nowrap-column' },	// Edited
	    { 'className': 'nowrap-column' }						// Edited By
    ];
		
	config.order = [[0,'desc']];
	config.search = { 'search': '<?php echo (isset($_GET['filter'])) ? htmlspecialchars($_GET['filter']) : ''?>' };
	
	config.rowCallback = function(row, data, index) {
		// Make clickable URL
		if (data[0].is_active) {
			$('td:eq(0)', row).html('<a href="<?php echo $Module->formatURL('update')?>&record_id=' + data[0].id + '" title="Редактировать параметры страницы">' + data[1] + '</a>');
		}
		else {
			$('td:eq(0)', row).html('<a class="text-muted" href="<?php echo $Module->formatURL('update')?>&record_id=' + data[0].id + '" title="Редактировать параметры страницы">' + data[1] + '</a>');
		}
		
		$('td:eq(1)', row).html('<a href="<?php echo NFW::i()->base_path?>' + data[2] + '" title="Открыть страницу на сайте">' + (data[2] ? data[2] : '/') + '</a>');

		// Dates
		$('td:eq(2)', row).html(data[3] ? formatDateTime(data[3]) : '');
	}
	
	var oTable = $('table[id="pages"]').dataTable(config);

	// Custom filtering function
	$('div[id="pages_length"]').empty().html($('div[id="custom-filters"]').html());
	$('div[id="custom-filters"]').remove();
});
</script>
<div id="custom-filters" style="display: none;">
	<?php if (NFW::i()->checkPermissions('pages', 'insert')) : ?>
		<a href="<?php echo $Module->formatURL('insert')?>" class="btn btn-primary"><span class="glyphicon glyphicon-plus"></span> Новая страница</a>
	<?php endif; ?>
</div>

<table id="pages" class="table table-striped">
	<thead>
		<tr>
			<th></th>
			<th>Заголовок</th>
			<th>Путь</th>
			<th>Изменена</th>
			<th>Кем</th>
		</tr>
	</thead>
	<tbody></tbody>
</table>