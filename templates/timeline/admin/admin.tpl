<?php 
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.activeForm/jqueryui.timepicker.min.js');
NFW::i()->registerResource('jquery.activeForm/jqueryui.timepicker.js');

$now =  time() - time()%3600 + 3600;
?>
<script type="text/javascript">
$(document).ready(function(){
 	// Action 'update'
 	var f = $('form[id="timeline"]');
 	f.activeForm({
		success: function(response) {
			window.location.reload();
		}
	});

 	$(document).on('click', '*[rel="remove-values-record"]', function(){
 	 	$(this).closest('div[rel="record"]').remove();
	});

 	f.find('button[id="add-line"]').click(function(){
		// Find last ID
		var curKEY = 1;
		f.find('div[id="values-area"]').find('div[rel="record"]').each(function(){
			var rowKEY = parseInt($(this).attr('id'));
			if (curKEY <= rowKEY) curKEY = rowKEY + 1;  
		});
		
 	 	var tpl = $('div[id="timeline-record-template"]').html().replace(/%KEY%/g, curKEY);
 	 	f.find('div[id="values-area"]').append(tpl);
 	 	f.find('textarea').uniform();

 	 	updateDatepickers(f);
 	 	
 	 	return false;
	});

 	<?php if (empty($records)):?>
 	f.find('button[id="add-line"]').trigger('click');
 	<?php else: ?>
 	updateDatepickers(f);
 	<?php endif; ?>

	$(document).trigger('refresh');
});

function updateDatepickers(f) {
	f.find('input[rel="datepicker"]').each(function(){
		var id = 'adp' + Math.floor(Math.random()*10000000);
		var name = $(this).attr('name');
		var value = $(this).val();

		$(this).after('<input type="hidden" id="' + id + '" name="' + name + '" value="' + value + '" />').datetimepicker({ 
			'altField': '#' + id, 
			'altFormat' : '@',
			'altFieldTimeOnly': false,
			'onSelect' : function(dateText, inst) {
				$('#' + id).val($.datepicker.formatDate('@', $(this).datepicker('getDate')) / 1000);
			},
			'onClose': function(dateText, inst) {
				$('input[id="' + id + '"]').val($.datepicker.formatDate('@', $(this).datepicker('getDate')) / 1000);
			}
		});

		$(this).val(formatDateTime(value, true, true)).uniform().removeAttr('rel').removeAttr('name').attr('disabled', 'disabled');
	});	
}

</script>
<style>
	.settings {	display: table;	}
	.settings .record, .settings .header { display:table-row; }
	.settings .record:nth-child(even) { background-color: #E2E4FF; }
	.settings .cell { display:table-cell; padding: 5px 2px; vertical-align: top; }
	.settings .cell:nth-child(1) { padding-left: 5px; }
	.settings .header .cell { font-size: 90%; font-weight: bold; }
	
	FORM#timeline TEXTAREA { background-color: white; }
	FORM#timeline INPUT.d { width: 100px; }
</style>

<div id="timeline-record-template" style="display: none;">
	<div rel="record" id="%KEY%" class="record">
		<div class="cell" style="padding-top: 12px;"><input type="text" class="d" rel="datepicker" name="records[%KEY%][date_from]" value="<?php echo $now?>" /></div>
		<div class="cell"><textarea name="records[%KEY%][content]" style="height: 30px;"></textarea></div>
		<div class="cell"><span rel="remove-values-record" class="ui-icon ui-icon-trash ui-state-disabled" title="Remove"></span></div>
	</div>
</div>

<form id="timeline">
	<div id="values-area" class="settings">
		<div class="header">
			<div class="cell">From</div>
			<div class="cell">Description</div>
		</div>
		<?php $cur_key = 1; foreach ($records as $r) { ?>
			<div rel="record" id="<?php echo $cur_key?>" class="record">
				<div class="cell" style="padding-top: 12px;"><input type="text" class="d" rel="datepicker" name="records[<?php echo $cur_key?>][date_from]" value="<?php echo $r['date_from']?>" /></div>
				<div class="cell"><textarea name="records[<?php echo $cur_key?>][content]" style="height: 30px;"><?php echo $r['content']?></textarea></div>
				<div class="cell"><span rel="remove-values-record" class="ui-icon ui-icon-trash ui-state-disabled" title="Remove"></span></div>
			</div>
		<?php $cur_key++; } ?>
	</div>
	
	<div style="padding-top: 0.5em;">
		<button type="submit" class="nfw-button" icon="ui-icon-disk">Save changes</button>
		<button id="add-line" class="nfw-button" icon="ui-icon-plus">Add line</button>
	</div>
</form>