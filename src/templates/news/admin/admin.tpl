<?php
NFW::i()->assign('page_title', 'Новости / список');
 
NFW::i()->registerResource('dataTables');
NFW::i()->registerResource('dataTables/Scroller');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action 'admin'
	var config =  dataTablesDefaultConfig;
	
	// Infinity scrolling
	config.scrollY = $(window).height() - $('table[id="news"]').offset().top - 130;
	config.deferRender = true;
	config.scroller = true;

	// Server-side
	config.bServerSide = true;
	config.bProcessing = false;
	config.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';
	config.fnServerData = function (sSource, aoData, fnCallback) {
		$.ajax( {
			'dataType': 'json', 
			'type': "POST", 
			'url': sSource, 
			'data': aoData, 
			'success': fnCallback
		});
	};
		
	// Create columns
	config.columns = [
		{ 'searchable': false, 'visible': false },		// properties (ID...)
	    { 'className': 'force-wrap-column' },			// Title
	    { 'className': 'nowrap-column' },				// Posted
	    { 'className': 'nowrap-column' }				// Posted By
    ];

	config.order = [[0,'desc']];
	config.search = { 'search': '<?php echo (isset($_GET['filter'])) ? htmlspecialchars($_GET['filter']) : ''?>' };
	
	config.rowCallback = function(row, data, index) {
		// Make clickable URL
		$('td:eq(0)', row).html('<a href="<?php echo $Module->formatURL('update')?>&record_id=' + data[0].id + '" title="Редактировать новость">' + data[1] + '</a>');

		// Dates
		$('td:eq(1)', row).html(formatDateTime(data[2]));
	}

	var oTable = $('table[id="news"]').dataTable(config);

	// Custom filtering function
	$('div[id="news_length"]').empty().html($('div[id="custom-filters"]').html());
	$('div[id="custom-filters"]').remove();
});
</script>
<style>
	.force-wrap-column { white-space: normal !important;}
</style>

<div id="custom-filters" style="display: none;">
	<?php if (NFW::i()->checkPermissions('news', 'insert')) : ?>
		<a href="<?php echo $Module->formatURL('insert')?>" class="btn btn-primary"><span class="glyphicon glyphicon-plus"></span> Добавить новость</a>
	<?php endif; ?>
</div>

<table id="news" class="table table-striped">
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