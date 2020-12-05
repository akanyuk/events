<?php
NFW::i()->assign('page_title', 'Events / list');

NFW::i()->registerResource('dataTables');
NFW::i()->registerResource('dataTables/Scroller');
NFW::i()->registerResource('jquery.activeForm');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action 'admin'
	var config =  dataTablesDefaultConfig;
	
	// Infinity scrolling
	config.scrollY = $(window).height() - $('table[id="events"]').offset().top - 130;
	config.deferRender = true;
	config.scroller = true;

	// Create columns
	config.columns = [
	    { 'width': '100%' },									// Title
		{ 'className': 'nowrap-column' },						// Alias
	    { 'searchable': false, 'className': 'nowrap-column' },	// From
	    { 'searchable': false, 'className': 'nowrap-column' }	// To
    ];
	config.order = [[2,'desc']];

	config.rowCallback = function(row, data, index) {
		// Dates
		$('td:eq(2)', row).html(formatDateTime(data[2]));
		$('td:eq(3)', row).html(formatDateTime(data[3]));
	}
	
	var oTable = $('table[id="events"]').dataTable(config);

	// Custom filtering function
	$('div[id="events_length"]').empty().html($('div[id="custom-filters"]').html());
	$('div[id="custom-filters"]').remove();


	<?php if (NFW::i()->checkPermissions('events', 'insert')) : ?>
	// Action 'insert
	var insertDialog = $('div[id="events-insert-dialog"]');
	insertDialog.modal({ 'show': false });

	$(document).on('click', 'button[id="events-insert"]', function(e, message){
		$('form[id="events-insert"]').resetForm().trigger('cleanErrors');
		insertDialog.modal('show');
	});

	insertDialog.find('form').activeForm({
		'success': function(response) {
			insertDialog.modal('hide');
			window.location.href = '<?php echo $Module->formatURL('update')?>&record_id=' + response.record_id;
			return false;
		}
	});
	
	$('button[id="events-insert-submit"]').click(function(){
		insertDialog.find('form').submit();
	});
	<?php endif; ?>
});
</script>

<?php if (NFW::i()->checkPermissions('events', 'insert')) : ?>
<div id="events-insert-dialog" class="modal fade">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title">Insert event</h4>
			</div>
			<div class="modal-body">
				<form action="<?php echo $Module->formatURL('insert')?>">
					<input type="hidden" name="is_hidden" value="1" />
					<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'alias', 'attributes'=>$Module->attributes['alias'], 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'date_from', 'attributes'=>$Module->attributes['date_from'], 'startDate' => 1, 'endDate' => -365, 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'date_to', 'attributes'=>$Module->attributes['date_to'], 'startDate' => 1, 'endDate' => -365, 'labelCols' => '2'))?>
				</form>
			</div>
			<div class="modal-footer">
				<button id="events-insert-submit" type="button" class="btn btn-primary"><span class="fa fa-floppy-o"></span> <?php echo NFW::i()->lang['Save changes']?></button>
				<button type="button" class="btn btn-default" data-dismiss="modal"><?php echo NFW::i()->lang['Close']?></button>
			</div>
		</div>
	</div>
</div>
<?php endif; ?>

<div id="custom-filters" style="display: none;">
	<?php if (NFW::i()->checkPermissions('events', 'insert')) : ?>
		<button id="events-insert" class="btn btn-primary" title="Insert event"><span class="glyphicon glyphicon-plus"></span> Insert event</button>
	<?php endif; ?>
</div>

<table id="events" class="table table-striped">
	<thead>
		<tr>
			<th>Title</th>
			<th>Alias</th>
			<th>From</th>
			<th>To</th>
		</tr>
	</thead>
	<tbody>
		<?php foreach ($records as $e) { ?>
		<tr>
			<td><?php echo '<a '.($e['is_hidden'] ? ' class="text-muted" title="Hidden event"' : '').' href="'.$Module->formatURL('update').'&record_id='.$e['id'].'">'.htmlspecialchars($e['title']).'</a>' ?></td>
			<td><?php echo $e['alias']?></td>
			<td><?php echo $e['date_from']?></td>
			<td><?php echo $e['date_to']?></td>
		</tr>
		<?php } ?>
	</tbody>
</table>