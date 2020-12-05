<?php
/**
 * @var object $Module
 */
NFW::i()->assign('page_title', $Module->record['title'].' / edit');

NFW::i()->breadcrumb = array(
	array('url' => 'admin/events?action=update&record_id='.$Module->record['event_id'], 'desc' => $Module->record['event_title']),
	array('url' => 'admin/competitions?action=update&record_id='.$Module->record['competition_id'], 'desc' => $Module->record['competition_title']),
	array('url' => 'admin/works?event_id='.$Module->record['event_id'], 'desc' => 'Works'),
	array('desc' => $Module->record['title']),
);

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('colorbox');				// images preview
NFW::i()->registerResource('jquery.jgrowl');
NFW::i()->registerResource('bootstrap3.typeahead');
NFW::i()->registerResource('jquery.ui.interactions');

active_field('set_defaults', array('labelCols' => '2', 'inputCols' => '10'));

// Fetch personal info
if (!$result = NFW::i()->db->query_build(array('SELECT'	=> 'is_checked, is_marked, comment', 'FROM' => 'works_managers_notes', 'WHERE' => 'work_id='.$Module->record['id'].' AND user_id='.NFW::i()->user['id']))) {
	echo '<div class="alert alert-danger">Unable to fetch personal information</div>';
	return;
}
if (NFW::i()->db->num_rows($result)) {
	$manager_note = NFW::i()->db->fetch_assoc($result);
}
else {
	$manager_note = array('is_checked' => false, 'is_marked' => false, 'comment' => '');
}

ob_start();
?>
<div class="text-muted" style="display: inline-block; font-size: 11px; line-height: 12px;">
	Posted: <?php echo date('d.m.Y H:i', $Module->record['posted']).' ('.$Module->record['posted_username'].')'?>
	<?php echo $Module->record['edited'] ? '<br />Updated: '.date('d.m.Y H:i', $Module->record['edited']).' ('.$Module->record['edited_username'].')' : '' ?>	
</div>
<?php 
NFW::i()->breadcrumb_status = ob_get_clean();

// Collect available links titles
$titles = array();
if (!$result = NFW::i()->db->query_build(array('SELECT'	=> 'DISTINCT title', 'FROM' => 'works_links', 'ORDER BY' => 'title'))) {
	NFW::i()->stop('Unable to fetch titles');
}
while ($record = NFW::i()->db->fetch_assoc($result)) {
	$titles[] = $record['title'];
}

$CMedia = new media();
?>
<script type="text/javascript">
$(document).ready(function(){
	var wuF = $('form[id="works-update"]');
	wuF.activeForm({
		'beforeSubmit': function(d,f,o) {
			var isLinksErrror = false;
			
			$('#work-links').find('#record').each(function(){
				input = $(this).find('input[data-type="links-url"]'); 
				if (input.val()) {
					input.parent().removeClass('has-error');
				}
				else {
					input.parent().addClass('has-error');
					isLinksErrror = true;					
				}				
			});

			if (isLinksErrror) {
				$.jGrowl('Please fill out all links field.', { theme: 'error' });
				return false;
			}

			return true;
		},		
		success: function(response) {
 			if (response.is_updated) {
 				$.jGrowl('Work profile updated.');
 			}
		}
	});

	$('[role="works-update"]').click(function(){
		wuF.submit();
	});
	
	// Status buttons
	$('[role="status-change-buttons"]').click(function(){
		$('[role="status-change-buttons"]').removeClass('active btn-info');
		$(this).addClass('active btn-info');

		$('input[name="status"]').val($(this).data('status-id'));
		
		$('#status-description').html($(this).data('description'));
		$('#status-description').removeClass('alert-default alert-success alert-info alert-warning alert-danger');
		$('#status-description').addClass('alert-' + $(this).data('css-class'));
	});
	$('[role="status-change-buttons"][class~="active"]').trigger('click');
	
	
	// Platform typeahead
	var aPlatforms = [];
	<?php foreach ($Module->attributes['platform']['options'] as $p) echo 'aPlatforms.push('.json_encode($p).');'."\n"; ?>
	$('input[name="platform"]').typeahead({ source: aPlatforms, minLength: 0 }).attr('autocomplete', 'off');


	// LINKS
	
 	$('#work-links').sortable({ items: '#record', axis: 'y', handle: '.icon' });

 	$(document).on('click', '[data-action="toggle-title"]', function(event){
 	 	$(this).closest('div[id="record"]').find('input[data-type="links-title"]').closest('div').toggle();
 	 	return false;
	});

 	$(document).on('click', '[data-action="remove-link"]', function(event){
 	 	if ($(this).closest('div[id="record"]').attr('data-rel') == 'update') {
 	 		if (!confirm('Remove link?')) {
 	 			event.preventDefault();
 	 	 		return false;
 	 		}
 	 	}

 	 	$(this).closest('div[id="record"]').remove();
 	 	return false;
	});
 	
 	$('button[id="add-link"]').click(function(){
 	 	var tpl = $('div[id="links-record-template"]').html();
 	 	$('div[id="work-links"]').append(tpl);
 	 	$('input[data-type="links-title"]:last').typeahead({ source: aTitles, minLength: 1, items: 20, showHintOnFocus: true }).focus();
 	 	$('input[data-type="links-url"]:last').focus();
 	 	 	 	
 	 	return false;
	});

	// Autocomplete link title
	var aTitles = [];
	<?php foreach ($titles as $t) echo 'aTitles.push(\''.htmlspecialchars($t).'\');'."\n"; ?>
	$('input[data-type="links-title"]').typeahead({ source: aTitles, minLength: 1, items: 20, showHintOnFocus: true });

	// Generate YouTube embed html
	$(document).on('click', '[data-action="auto-youtube"]', function(event){
		var url = $(this).closest('#record').find('input[data-type="links-url"]').val();
		var videoID = url.match(/(?:https?:\/{2})?(?:w{3}\.)?youtu(?:be)?\.(?:com|be)(?:\/watch\?v=|\/)([^\s&]+)/);
		
		if (videoID != null) {
			var tpl = '<?php echo NFW::i()->project_settings['works_youtube_tpl']?>';
			tpl = tpl.replace('%id%', videoID[1]);

			var existVal = wuF.find('[name="external_html"]').val();
			wuF.find('[name="external_html"]').val(existVal ? existVal + "\n\n" + tpl : tpl);
		} else { 
			$.jGrowl('The youtube url is not valid.', { theme: 'error' });
		}
		
		return false;
	});


	$('[role="works-delete"]').click(function(){
		if (!confirm("Remove work?\nCAN NOT BE UNDONE!")) return false;

		$.post('<?php echo $Module->formatURL('delete').'&record_id='.$Module->record['id']?>', function(response){
			response == 'success' ? window.location.href = '<?php echo $Module->formatURL().'?event_id='.$Module->record['event_id']?>' : alert(response);
		});
		return false;
	});	
});
</script>
<style>
	.author-note { white-space: pre; font-family: monochrome; overflow: auto; }
	#status-description { margin-top: 10px; margin-bottom: 0; padding: 10px 15px; font-size: 85%; }
	#work-links .fa-youtube { padding-left: 2px; }
</style>

<div id="links-record-template" style="display: none;">
	<div id="record" class="record" data-rel="insert">
		<div class="cell"><span class="icon fa fa-sort" title="Sort"></span></div>
		<div class="cell" style="width: 100%;">
			<div class="input-group" style="margin-bottom: 3px;">
				<input type="text" class="form-control" data-type="links-url" autocomplete="off" name="links[url][]" placeholder="Url" />
				<span class="input-group-btn">
					<button data-action="toggle-title" class="btn btn-default" tabindex="-1" title="Show custom tittle"><span class="fa fa-chevron-down"></span></button>
					<button data-action="auto-youtube" class="btn btn-default" tabindex="-1" title="Create YouTube HTML"><span class="fab fa-youtube"></span></button>
					<button data-action="remove-link" class="btn btn-default" tabindex="-1" title="Remove link"><span class="fa fa-times"></span></button>
				</span>
			</div>
			<div class="input-group"  style="width: 100%; display: none;">
				<input type="text" class="form-control" data-type="links-title" autocomplete="off" name="links[title][]" placeholder="Cutom title (not requiered)" />
			</div>
		</div>
	</div>
</div>

<ul class="nav nav-tabs" role="tablist">
	<li role="presentation" class="active"><a href="#main" aria-controls="main" role="tab" data-toggle="tab">Main</a></li>
	<li role="presentation"><a href="#files" aria-controls="files" role="tab" data-toggle="tab">Manage files</a></li>
</ul>
<div class="tab-content">
<div role="tabpanel" class="tab-pane in active" style="padding-top: 20px;" id="main">
	<form id="works-update">
		<div class="row">
			<div class="col-md-7">
				<input name="send_notify" type="hidden" />
				<input name="status" type="hidden" value="<?php echo $Module->record['status']?>" />
				
				<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title']))?>
				<?php echo active_field(array('name' => 'author', 'value' => $Module->record['author'], 'attributes'=>$Module->attributes['author']))?>
				<?php echo active_field(array('name' => 'competition_id', 'value' => $Module->record['competition_id'], 'attributes'=>$Module->attributes['competition_id']))?>
				<?php echo active_field(array('name' => 'platform', 'value' => $Module->record['platform'], 'attributes'=>$Module->attributes['platform'], 'inputCols' => '6'))?>
				<?php echo active_field(array('name' => 'format', 'value' => $Module->record['format'], 'attributes'=>$Module->attributes['format'], 'inputCols' => '6'))?>
				<?php echo active_field(array('name' => 'author_note', 'value' => $Module->record['author_note'], 'attributes'=>$Module->attributes['author_note'], 'height'=>"60px;"))?>
				<?php echo active_field(array('name' => 'external_html', 'value' => $Module->record['external_html'], 'attributes'=>$Module->attributes['external_html'], 'height'=>"100px;"))?>
						
				<div data-active-container="status" class="form-group">
					<label for="status" class="col-md-2 control-label"><strong>Status</strong></label>
					<div class="col-md-10">	
						<div id="status-buttons" class="btn-group" role="group">
						<?php foreach ($Module->attributes['status']['options'] as $s) { ?>
							<button role="status-change-buttons" data-status-id="<?php echo $s['id']?>" data-css-class="<?php echo $s['css-class']?>" type="button" class="<?php echo 'btn btn-default '.($Module->record['status'] == $s['id'] ? 'active btn-info' : '')?>" title="<?php echo $s['desc']?>" data-description="<?php echo $s['desc_full'].'<br />Voting: <strong>'.($s['voting'] ? 'On' : 'Off').'</strong>. Release: <strong>'.($s['release'] ? 'On' : 'Off').'</strong>'?>"><span class="<?php echo $s['icon']?>"></span></button>
						<?php } ?>
						</div>
						<div id="status-description" class="alert alert-info"></div>
					</div>
				</div>
			</div>
			<div class="col-md-5">
				<?php if ($Module->record['description']):?>			
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title"><span class="fa fa-exclamation-circle text-danger"></span> Author's note</h4>
					</div>
					<div class="panel-body author-note"><?php echo htmlspecialchars($Module->record['description'])?></div>
				</div>
				<?php endif;?>
			
				<div class="panel panel-default">
					<div class="panel-heading">
						<h4 class="panel-title">Personal note (visible only for you)</h4>
					</div>
					<div class="panel-body">
						<div style="padding-bottom: 10px;">
							<label>Comment</label>
							<textarea class="form-control" name="manager_note[comment]"><?php echo $manager_note['comment']?></textarea>
						</div>
						
						<label class="checkbox-inline">
							<input type="hidden" name="manager_note[is_checked]" value="0" />
							<input type="checkbox" name="manager_note[is_checked]" value="1" <?php echo $manager_note['is_checked'] ? ' checked="checked"' : ''?>/> Checked
						</label>
						
						<label class="checkbox-inline">
							<input type="hidden" name="manager_note[is_marked]" value="0" />
							<input type="checkbox" name="manager_note[is_marked]" value="1" <?php echo $manager_note['is_marked'] ? ' checked="checked"' : ''?>/> Marked
						</label>
						<div class="clearfix"></div>
					</div>
				</div>
							
				<h3>Links</h3>
				<div id="work-links" class="settings">
					<?php foreach ($Module->record['links'] as $v) { ?>
						<div id="record" class="record" data-rel="update">
							<div class="cell"><span class="icon fa fa-sort" title="Sort"></span></div>
							<div class="cell" style="width: 100%;">
								<div class="input-group" style="margin-bottom: 3px;">
									<input type="text" class="form-control" data-type="links-url" autocomplete="off" name="links[url][]" value="<?php echo $v['url']?>" placeholder="Url" />
									<span class="input-group-btn">
										<button data-action="toggle-title" class="btn btn-default" tabindex="-1" title="Show custom tittle"><span class="glyphicon glyphicon-chevron-down"></span></button>
										<button data-action="auto-youtube" class="btn btn-default" tabindex="-1" title="Create YouTube HTML"><span class="fab fa-youtube"></span></button>
										<button data-action="remove-link" class="btn btn-default" tabindex="-1" title="Remove link"><span class="glyphicon glyphicon-remove"></span></button>
									</span>
								</div>
								<div class="input-group"  style="width: 100%; display: <?php echo $v['title'] ? 'block' : 'none'?>;">
									<input type="text" class="form-control" data-type="links-title" autocomplete="off" name="links[title][]" value="<?php echo $v['title']?>" placeholder="Cutom title (not requiered)" />
								</div>
							</div>
						</div>
					<?php } ?>
				</div>
				
				<div style="padding-top: 20px; padding-bottom: 20px;">
					<button id="add-link" class="btn btn-default"><span class="glyphicon glyphicon-plus"></span> Add link</button>
				</div>
			</div>
		</div>
	</form>
	
	<div class="row">
		<div class="col-md-7">
			<div class="row">
				<div class="col-md-5 col-md-offset-2">
					<button role="works-update" class="btn btn-lg btn-primary btn-full-xs"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
				</div>
				<div class="col-md-5" style="padding-top: 10px;">
					<label class="checkbox-inline">
						<input type="checkbox" name="send_notify" /> Send notify to author
					</label>
				</div>
			</div>
		</div>
		<div class="col-md-5 text-right" style="padding-top: 20px;">
			<a role="works-delete" href="#" class="text-danger" title=""><span class="fa fa-times"></span> Delete work</a>		
		</div>
	</div>

</div>

<div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="files">
	<div id="media-form-container">
<?php echo $CMedia->openSession(
	array(
		'owner_class' => get_class($Module),
		'owner_id' => $Module->record['id'],
		'secure_storage' => true,
		'MAX_SESSION_SIZE' => 1024*1024*256,
		'template' => '_admin_works_media',
	),
	array('owner' => $Module->record)
)?>
	</div>	
</div>

</div>