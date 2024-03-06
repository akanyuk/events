<?php
/**
 * @var object $Module
 */
NFW::i()->assign('page_title', $Module->current_event['title'].' / works');

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.ui.interactions');
NFW::i()->registerResource('bootstrap3.typeahead');

NFW::i()->breadcrumb = array(
	array('url' => 'admin/events?action=update&record_id='.$Module->current_event['id'], 'desc' => $Module->current_event['title']),
	array('desc' => 'Works'),
);

ob_start();
?>
<div class="text-muted" style="font-size: 80%;">
	Total: <span id="total-works-count" class="badge"></span>&nbsp;&nbsp;
	Approved: <span id="approved-works-count" class="badge"></span>
</div>
<?php 
NFW::i()->breadcrumb_status = ob_get_clean();
?>
<script type="text/javascript">
$(document).ready(function(){
	// (Re) load works list
	$(document).on('admin-reload-works-list', function(){
		$('div[id="works"]').empty();
		
		$.get('<?php echo $Module->formatURL('admin').'&event_id='.$Module->current_event['id'].'&part=list'?>', function(response) {
			if (response) {
				$('div[id="works"]').append(response);
				$('div[id="works"]').find('[data-toggle="tooltip"]').tooltip({ 'html': true });

				$('[id="total-works-count"]').text($('div[id="works"]').find('#counters').data('total'));
				$('[id="approved-works-count"]').text($('div[id="works"]').find('#counters').data('approved'));
				
				updateSortable();
				updateFilters();
			}
		});
	}).trigger('admin-reload-works-list');

	// Filter by competition
	$('select[id="filter-compo"]').change(function(){
        const id = $(this).val();

        if (id === '-1') {
			$('div[role="competiotion-works"]').find('.header').hide();
			$('div[role="competiotion-works"]:first').find('.header').show();
			$('div[role="competiotion-works"]').show();			
		}
		else {
			$('div[role="competiotion-works"]').hide();
			$('div[role="competiotion-works"][id="' + id + '"]').find('.header').show();
			$('div[role="competiotion-works"][id="' + id + '"]').show();
		}
	});

	// Insert work
    const insertDialog = $('div[id="works-insert-dialog"]');
    insertDialog.modal({ 'show': false });

	$(document).on('click', 'button[id="works-insert"]', function(e, message){
		// Set default compo
        const curFilteredCompo = $('select[id="filter-compo"]').val();
        if (curFilteredCompo !== '-1') {
			$('select[name="competition_id"] option').removeAttr('selected');
			$('select[name="competition_id"] option[value="' + curFilteredCompo + '"]').attr('selected', 'selected');
		}
		
		insertDialog.find('form').resetForm().trigger('cleanErrors');
		insertDialog.modal('show');
	});

	insertDialog.find('form').activeForm({
		'success': function(response) {
			insertDialog.modal('hide');
			window.location.href = '<?php echo $Module->formatURL('update')?>&record_id=' + response.record_id;
			return false;
		}
	});

	// Platform typeahead
	let aPlatforms = [];
	<?php foreach ($Module->attributes['platform']['options'] as $p) echo 'aPlatforms.push(\''.htmlspecialchars($p).'\');'."\n"; ?>
	$('input[name="platform"]').typeahead({ 
		source: aPlatforms,
		minLength: 0
	}).attr('autocomplete', 'off');
	
	$('button[id="works-insert-submit"]').click(function(){
		insertDialog.find('form').submit();
	});

	// Generate permanent link
	$(document).on('click', '#make-release-link', function(){
        const obj = $(this);
        const record_id = obj.closest('.record').attr('id');

        $.post('<?php echo NFW::i()->absolute_path?>/admin/works_media?action=make_release&record_id=' + record_id, function(response) {
			if (response.result === 'success') {
				obj.attr('href', decodeURIComponent(response.url));
				obj.addClass('btn-success').removeClass('btn-default').removeAttr('id');
			}
			else {
                if (response['errors']['general'] !== undefined) {
                    alert(response['errors']['general']);
                }
			}
		}, 'json');

		return false;
	});
});

updateFilters = function(){
	$('select[id="filter-compo"]').empty().append('<option value="-1">All competitions</option>');
	
	$('div[role="competiotion-works"]').each(function(){
        const title = $(this).find('#competition-title').text();
        const id = $(this).attr('id');
        $('select[id="filter-compo"]').append('<option value="' + id + '">' + title + '</option>');
	});

	$('select[id="filter-compo"]').trigger('change');
}

updateSortable = function(){
 	$('div[role="competiotion-works"]').sortable({
		items: '.record',
 		axis: 'y', 
 		cursor: 'default',
 		stop: function() {
            const container = $(this);

            const aPositions = [];
            let iCurPos = 1;
            container.find('.record').each(function(){
 				aPositions.push({ 'record_id': $(this).attr('id'), 'position': iCurPos });
 				$(this).find('#position').text(iCurPos++);
 			});

 			// Update positions
			$.post('<?php echo $Module->formatURL('set_pos')?>', { 'position': aPositions }, function(response){
				if (response !== 'success') {
					alert(response);
					return false;
				}
 			});
 			return true;
 	 	}
	});
}

</script>
<style>
@media (max-width: 768px) {
	.works-menu BUTTON { margin-bottom: 20px; }
}
@media (min-width: 769px) {
	.works-menu SELECT { width: auto; }
	.works-menu BUTTON { float: right; }
}

#works > div { margin-bottom: 20px; }
#works .header { background-color: #ddd; margin-bottom: 5px; }
#works .header .cell { white-space: nowrap; padding: 0 10px; }
#works .header .cell:nth-child(1) { text-align: center; font-size: 120%; } 
#works .header .cell:nth-child(2) { text-align: center; font-size: 120%; }

#works .record .cell { white-space: nowrap; padding: 10px; }

#works .record:nth-child(2n) { background-color: #f4f4f4; }

#works .record .cell:nth-child(1) { min-width: 40px; max-width: 40px; }
#works .record .cell:nth-child(1) #position { text-align: right;  font-weight: bold; font-size: 22px; }
@media (max-width: 768px) {
	#works .record .cell:nth-child(1) { min-width: 74px; max-width: 74px; padding-top: 15px; padding-right: 0; vertical-align: top; text-align: center; }
	#works .record .cell:nth-child(1) .icons { margin-top: 8px; }
	#works .record .cell:nth-child(1) .icons > div { display: inline-block; }
}
@media (min-width: 769px) {
	#works .record .cell:nth-child(1) .icons-xs { display: none; }
}

#works .record .cell:nth-child(2) { min-width: 40px; max-width: 40px; text-align: center; }
#works .record .cell:nth-child(3) { min-width: 40px; max-width: 40px; text-align: center; }
#works .record .cell:nth-child(4) { max-width: 84px; padding: 5px 10px; text-align: center; }
#works .record .cell:nth-child(4) IMG { max-height: 96px; }

#works .record .cell:nth-child(5) { width: 100%; }
#works .record .cell:nth-child(5) .title { display: block; font-weight: bold; }
@media (max-width: 768px) {
	#works .record .cell:nth-child(5) { vertical-align: top; white-space: normal; }
	#works .record .cell:nth-child(5) .title { display: inline; }
	#works .record .cell:nth-child(5) .by { font-weight: bold; }
}

#works .record .cell:nth-child(6) { min-width: 200px; max-width: 200px; text-align: center; }
#works .record .cell:nth-child(7) { line-height: 15px; }

#works .label-platform, #works .label-format { display: inline-block; padding: 3px 10px 4px 10px; }
#works .label-platform { background-color: #6e3731; }
#works .label-format { background-color: #31606e; }
</style>

<div id="works-insert-dialog" class="modal fade">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title">Insert work</h4>
			</div>
			<div class="modal-body">
				<form action="<?php echo $Module->formatURL('insert').'&event_id='.$Module->current_event['id']?>">
					<?php echo active_field(array('name' => 'competition_id', 'attributes'=>$Module->attributes['competition_id'], 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'author', 'attributes'=>$Module->attributes['author'], 'labelCols' => '2'))?>
					<?php echo active_field(array('name' => 'platform', 'attributes'=>$Module->attributes['platform'], 'labelCols' => '2'))?>
				</form>
			</div>
			<div class="modal-footer">
				<button id="works-insert-submit" type="button" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
				<button type="button" class="btn btn-default" data-dismiss="modal"><?php echo NFW::i()->lang['Close']?></button>
			</div>
		</div>
	</div>
</div>

<div class="works-menu">
	<button id="works-insert" class="btn btn-primary" title="Insert work"><span class="fa fa-plus"></span> Insert work</button>
	<select id="filter-compo" class="form-control"></select>
</div>

<div id="works"></div>