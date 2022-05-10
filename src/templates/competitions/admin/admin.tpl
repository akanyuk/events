<?php	
NFW::i()->assign('page_title', $event['title'].' / competitions');

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.ui.interactions');

NFW::i()->breadcrumb = array(
	array('url' => 'admin/events?action=update&record_id='.$event['id'], 'desc' => $event['title']),
	array('desc' => 'Competitions')
);
?>
<script type="text/javascript">
$(document).ready(function(){
	var setDatesDialog = $('div[id="competitions-setdates-dialog"]');
	var setDatesForm = setDatesDialog.find('form');
	setDatesDialog.modal({ 'show': false });

	$(document).on('click', 'button[id="competitions-setdates"]', function(e, message){
		setDatesForm.resetForm().trigger('cleanErrors');
		
		setDatesForm.find('div[id="competitions-list"]').empty();
		$('div[id="competitions"]').find('.record').each(function(){
			var id = $(this).attr('id');
			var title = $(this).find('#title').text();

			setDatesForm.find('div[id="competitions-list"]').append('<div class="checkbox"><label><input type="checkbox" name="competition[]" value="' + id + '" /> ' + title + '</label></div>');
 		});

		
		setDatesDialog.modal('show');
	});

	setDatesForm.activeForm({
		'success': function(response) {
			setDatesDialog.modal('hide');

			if (response.is_updated) {
				$(document).trigger('admin-reload-competitions-list');
			}
			
			return false;
		}
	});

	$('button[id="competitions-setdates-submit"]').click(function(){
		setDatesDialog.find('form').submit();
	});

	$('[role="competitions-setdates-toggle-all"]').click(function(){
		var oContainer = setDatesForm.find('div[id="competitions-list"]');
		var newState = oContainer.find('input[type="checkbox"]:not(:checked)').length ? true : false;

		oContainer.find('input[type="checkbox"]').prop('checked', newState);
		$(this).prop('checked', newState);
	});

	// Action 'admin'

 	// Sortable `values`
 	$('div[id="competitions"]').sortable({
		items: '.record',
 		axis: 'y', 
 		cursor: 'default',
 		stop: function(event, ui) {
 	 		var aPositions = [];
 	 		var iCurPos = 1;
 			$('div[id="competitions"]').find('.record').each(function(){
 				aPositions.push({ 'record_id': $(this).attr('id'), 'position': iCurPos });
 				$(this).find('#position').text(iCurPos++);
 			});

 			$(document).trigger('admin-competitions-colorize');
 			
 			// Update positions
			$.post('<?php echo $Module->formatURL('set_pos')?>', { 'position': aPositions }, function(response){
				if (response != 'success') {
					alert(response);
					return false;
				}
 			});
 			
 			return true;
 	 	}
	});

	// Colorize different dates of competitions
	$(document).on('admin-competitions-colorize', function(){
		var aColors = ['','#000','#080','#770','#555','#077','#707','#000','#080','#770','#555','#077','#707','#000','#080','#770','#555','#077','#707','#000','#080','#770','#555','#077','#707','#000','#080','#770','#555','#077','#707'];

		var aAnchors = ['.cell:eq(4)', '.cell:eq(5)', '.cell:eq(6)', '.cell:eq(7)'];
		var curValues = [];
		var curIndexes = [];
		
		$.each(aAnchors, function(i, a){
			curValues.push(0);
			curIndexes.push(0);
		});
		
		$('div[id="competitions"]').find('.record').each(function(){
			var curRow = $(this);
			
			$.each(aAnchors, function(i, a){
				var curValue = curRow.find(a).text();
				var curIndex = curIndexes[i];

				if (curValue != curValues[i]) {
					curValues[i] = curValue;

					curIndex = curIndex + 1;
					curIndexes[i] = curIndex;
				} 
				
				curRow.find(a).css('color', aColors[curIndex]);
			});
		});
	});
	
	// (Re) load competitions list
	$(document).on('admin-reload-competitions-list', function(){
		$('div[id="competitions"]').find('.header').hide();
		$('div[id="competitions"]').find('.record').remove();
		
		$.get('<?php echo $Module->formatURL('admin').'&event_id='.$event['id'].'&part=list'?>', function(response) {
			if (response) {
				$('div[id="competitions"]').append(response);
				$('div[id="competitions"]').find('.header').show();

				$(document).trigger('admin-competitions-colorize');
			}
		});
	}).trigger('admin-reload-competitions-list');


	var insertDialog = $('div[id="competitions-insert-dialog"]');
	insertDialog.modal({ 'show': false });

	$(document).on('click', 'button[id="competitions-insert"]', function(e, message){
		insertDialog.find('form').resetForm().trigger('cleanErrors');
		insertDialog.modal('show');
	});

	insertDialog.find('form').activeForm({
		'success': function(response) {
			insertDialog.modal('hide');
			$(document).trigger('admin-reload-competitions-list');
			return false;
		}
	});
	
	$('button[id="competitions-insert-submit"]').click(function(){
		insertDialog.find('form').submit();
	});
});
</script>
<style>
	#competitions .cell { white-space: nowrap; padding: 10px; }
	#competitions .cell:nth-child(1) { font-weight: bold; text-align: right; }
	#competitions .cell:nth-child(2) { width: 100%; }	
</style>

<div id="competitions-setdates-dialog" class="modal fade">
	<div class="modal-dialog modal-lg">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title">Set dates</h4>
			</div>
			<div class="modal-body">
				<div class="alert alert-info alert-dismissible">
					<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>				
					Empty dates and unchecked competitions will be ignored.
				</div>
				<form action="<?php echo $Module->formatURL('set_dates')?>">
					<div class="row">
						<div class="col-md-7">
							<?php echo active_field(array('name' => 'reception_from', 'attributes'=>$Module->attributes['reception_from'], 'labelCols' => 5))?>
							<?php echo active_field(array('name' => 'reception_to', 'attributes'=>$Module->attributes['reception_to'], 'labelCols' => 5))?>
							<?php echo active_field(array('name' => 'voting_from', 'attributes'=>$Module->attributes['voting_from'], 'labelCols' => 5))?>
							<?php echo active_field(array('name' => 'voting_to', 'attributes'=>$Module->attributes['voting_to'], 'labelCols' => 5))?>
						</div>
						<div class="col-md-5">
							<div class="checkbox"><label><input type="checkbox" role="competitions-setdates-toggle-all" />All competitions</label></div>
							<hr />
							<div id="competitions-list"></div>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button id="competitions-setdates-submit" type="button" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
				<button type="button" class="btn btn-default" data-dismiss="modal"><?php echo NFW::i()->lang['Close']?></button>
			</div>
		</div>
	</div>
</div>

<div id="competitions-insert-dialog" class="modal fade">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title">Insert competition</h4>
			</div>
			<div class="modal-body">
				<form action="<?php echo $Module->formatURL('insert').'&event_id='.$event['id']?>">
					<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'alias', 'attributes'=>$Module->attributes['alias'], 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'works_type', 'attributes'=>$Module->attributes['works_type'], 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'announcement', 'attributes'=>$Module->attributes['announcement'], 'labelCols' => '2'))?>
				</form>
			</div>
			<div class="modal-footer">
				<button id="competitions-insert-submit" type="button" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
				<button type="button" class="btn btn-default" data-dismiss="modal"><?php echo NFW::i()->lang['Close']?></button>
			</div>
		</div>
	</div>
</div>

<button id="competitions-insert" class="btn btn-primary" title="Insert competition"><span class="glyphicon glyphicon-plus"></span> Insert competition</button>
<button id="competitions-setdates" class="btn btn-default" title="Set dates"><span class="glyphicon glyphicon-calendar"></span> Set dates</button>

<div id="competitions" class="settings">
	<div class="header">
		<div class="cell"></div>
		<div class="cell">Title</div>
		<div class="cell">Alias</div>
		<div class="cell">Type</div>
		<div class="cell">Accepting from</div>
		<div class="cell">Accepting to</div>
		<div class="cell">Voting from</div>
		<div class="cell">Voting to</div>
	</div>
</div>