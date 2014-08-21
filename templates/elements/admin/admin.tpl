<?php
NFW::i()->registerResource('dataTables');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerResource('jquery.activeForm');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action 'admin'
	var dataTablesConfig =  dataTablesDefaultConfig;

	// Infinity scrolling
	dataTablesConfig.bScrollInfinite = true;
	dataTablesConfig.bScrollCollapse = true;
	dataTablesConfig.iDisplayLength = 100;
	dataTablesConfig.sScrollY = $(window).height() - $('table[id="elements"]').offset().top - 102;

	// AJAX-source
	dataTablesConfig.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';

	dataTablesConfig.fnRowCallback = function( nRow, aData, iDisplayIndex ) {
		// Make clickable URL
		<?php if (NFW::i()->checkPermissions('elements', 'update')): ?>
		if (aData[1].editable) {
			$('td:eq(0)', nRow).html('<a rel="elements-update" href="#" id="' + aData[1].id + '">' + aData[0] + '</a>');
		}
		<?php endif; ?>

		<?php if (NFW::i()->checkPermissions('elements', 'delete')): ?>
			$('td:eq(1)', nRow).html('<a rel="elements-delete" href="#" id="' + aData[1].id + '" class="ui-icon ui-icon-red ui-icon-trash" title="Удалить элемент"></a>');
		<?php else: ?>	
			$('td:eq(1)', nRow).html('');
		<?php endif; ?>
			
		
		return nRow;
	}
	
	// Create columns
	dataTablesConfig.aoColumns = [
	    { 'sClass': 'nowrap-column' },											// Title
	    { 'bSearchable': false, 'bSortable': false, 'sClass': 'icon-column' },	// Action
    ];
		
	dataTablesConfig.aaSorting = [[0,'asc']];
	dataTablesConfig.oSearch = { 'sSearch': '<?php echo (isset($_GET['filter'])) ? htmlspecialchars($_GET['filter']) : ''?>' };
	var oTable = $('table[id="elements"]').dataTable(dataTablesConfig);
	
	// Custom filtering function 
	$('.dataTables_filter').before($('div[id="custom-filters"]').html()).css('width', '60%');	
	$('div[id="custom-filters"]').remove();

	// Action 'update'
	$(document).on('click', 'a[rel="elements-update"]', function(){
		<?php if (NFW::i()->checkPermissions('elements', 'update')): ?>
			$('div[id="elements-update-container"]').empty().load('<?php echo $Module->formatURL("update")?>&record_id=' + this.id);
		<?php endif; ?>

		return false;
	});

	// Action 'delete'
	$(document).on('click', 'a[rel="elements-delete"]', function(){
		if (!confirm('Удалить элемент без возможности восстановления?')) return false;
		
		$.post('<?php echo $Module->formatURL('delete')?>', { record_id: this.id }, function(response){
			if (response) {
				alert(response);
			}
			else {
				window.location.reload();
			}
		});

		return false;
	});
	
	$(document).trigger('refresh');
});
</script>

<div id="elements-update-container"></div>

<div id="custom-filters" style="display: none;">
	<div style="float: left;">
		<?php if (NFW::i()->checkPermissions('elements', 'insert')) : ?>
			<a href="<?php echo $Module->formatURL('insert')?>" class="nfw-button nfw-button-small nfw-tooltip" icon="ui-icon-document" title="Добавить"></a>
		<?php endif; ?>
	</div>
</div>

<table id="elements" class="dataTables">
	<thead>
		<tr>
			<th>Заголовок</th>
			<th>&nbsp;</th>
		</tr>
	</thead>
	<tbody></tbody>
</table>