<?php
/**
 * @var $Module events
 */

// Custom rendering: votelist, results.txt, etc...
$custom_render = isset($_REQUEST['force-render']) ?  'update.'.$_REQUEST['force-render'] : false;
if ($custom_render && file_exists(SRC_ROOT.'/templates/events/admin/'.$custom_render.'.tpl')) {
	NFW::i()->stop($Module->renderAction(array('request' => $_REQUEST), $custom_render));
}

NFW::i()->assign('page_title', $Module->record['title'].' / edit');

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.jgrowl');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerResource('colorbox');
NFW::i()->registerResource('jquery.ui.interactions');

active_field('set_defaults', array('labelCols' => '2', 'inputCols' => '10'));

// Preload competitions array
$CCompetitions = new competitions();
$competitions = $CCompetitions->getRecords(array('filter' => array('event_id' => $Module->record['id'])));


// Generate breadcrumbs

NFW::i()->breadcrumb = array(
	array('url' => 'admin/events', 'desc' => 'Events'),
	array('desc' => $Module->record['title'])
);

$hint = 'Posted: '.date('d.m.Y H:i', $Module->record['posted']).' ('.$Module->record['posted_username'].')';
if ($Module->record['edited']) {
	$hint .= "<br />".'Updated: '.date('d.m.Y H:i', $Module->record['edited']).' ('.$Module->record['edited_username'].')';
}
NFW::i()->breadcrumb_status = '<div class="text-muted" style="font-size: 80%;">'.$hint.'</div>';


// Logotype form

$CMedia = new media();

$preview_form = $CMedia->openSession(array(
	'owner_class' => 'events_preview',
	'owner_id' => $Module->record['id'],
	'single_upload' => true,
	'images_only' => true,
	'template' => '_admin_events_preview_form',
	'preview_default' => NFW::i()->assets('main/news-no-image.png'),
	'preview' => $Module->record['preview'] ? $Module->record['preview'] : array('id' => false, 'url' => false),
));

$preview_large_form = $CMedia->openSession(array(
	'owner_class' => 'events_preview_large',
	'owner_id' => $Module->record['id'],
	'single_upload' => true,
	'images_only' => true,
	'template' => '_admin_events_preview_form',
	'preview_default' => NFW::i()->assets('main/news-no-image.png'),
	'preview' => $Module->record['preview_large'] ? $Module->record['preview_large'] : array('id' => false, 'url' => false),
));

// Success dialog
NFW::i()->registerFunction('ui_dialog');
$succes_dialog = new ui_dialog();
$succes_dialog->render();
?>
<script type="text/javascript">
$(document).ready(function(){
	// Main action
 	$('form[role="events-update"]').each(function(){
 		$(this).activeForm({
 	 		action: '<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>',
 			success: function(response) {
 	 			if (response.is_updated) {
 	 				$.jGrowl('Event profile updated.');
 	 			}
 			}
 		});
	});

	// Visual edit
	$('textarea[name="content"]').CKEDIT({ 'media': 'events', 'media_owner': '<?php echo $Module->record['id']?>' });
	
    // Voting settings
 	var sF = $('form[id="voting-settings-update"]');
 	 sF.activeForm({
 		success: function(response) {
 	 		if (response.is_updated) {
 	 			$.jGrowl('Voting settings updated.');
 	 		}
 		}
	});

 	// Sortable `values`
 	sF.find('div[id="values-area"]').sortable({ items: 'div[id="record"]', axis: 'y', handle: '.icon' });

 	$(document).off('click', '*[data-action="remove-values-record"]').on('click', '*[data-action="remove-values-record"]', function(event){
 	 	if ($(this).closest('div[id="record"]').data('role') == 'update') {
 	 		if (!confirm('Remove value')) {
 	 			event.preventDefault();
 	 	 		return false;
 	 		}
 	 	}

 	 	$(this).closest('div[id="record"]').remove();
	});

 	sF.find('button[id="add-values-record"]').click(function(){
 	 	var tpl = $('div[id="voting-settings-record-template"]').html();
 	 	sF.find('div[id="values-area"]').append(tpl);
 	 	return false;
	});
 	

	// Votelist
	$('a[role="toogle-votelist-col"]').attr('title', 'Toggle all').click(function(){
		var tbody = $(this).closest('table').find('tbody');
		var index = $(this).closest('th').index();

		// Determine new state
		var newState = false;
		tbody.find('tr').each(function(){
			if ($(this).find('td').eq(index).find('input[type="checkbox"]:not(:checked)').length) {
				newState = true;
				return;
			}
		});

		// Set new state
		tbody.find('tr').each(function(){
			$(this).find('td').eq(index).find('input[type="checkbox"]').prop('checked', newState);
		});

		return false;
	});

	
	// Make `results.txt`, works pack
	
	$('[role="builders-toggle-competitions"]').attr('title', 'Toggle all').click(function(){
		var oContainer = $(this).closest('#competitions-conatiner');
		var newState = oContainer.find('input[type="checkbox"]:not(:checked)').length ? true : false;

		oContainer.find('input[type="checkbox"]').prop('checked', newState);
		return false;
		
	});

	// Refresh result.txt
	$('a[role="result.txt-layout"]').click(function(){
		$('a[role="result.txt-layout"]').removeClass('active');
		$(this).addClass('active');	

		var layout = $(this).text();
		
		var platform = [];
		$('input[role="result.txt-platform"]:checked').each(function(){
			platform.push($(this).val());
		});

		$.post('<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id'].'&force-render=results.txt'?>', { 'layout': layout, 'platform': platform }, function(response){
			$('textarea[name="results_txt"]').val(response);
		});
		
		return false;
	});
	
	$('form[id="make"]').activeForm({
		success: function(response) {
			$(document).trigger('show-<?php echo $succes_dialog->getID()?>', [ '<a href="' + response.url + '">' + response.url + '</a>' ]);
		}
	});
});

</script>

<style>
	FORM#make TEXTAREA { font-family: Consolas, Lucida Console, Courier New, monospace; font-size: 10.5px; color: #444; height: 500px; }
</style>
<div class="row">
	<div id="events-update-record=container" class="col-md-9">
	
		<ul class="nav nav-tabs" role="tablist">
			<li role="presentation" class="active"><a href="#settings" aria-controls="settings" role="tab" data-toggle="tab">Settings</a></li>
			<li role="presentation"><a href="#description" aria-controls="description" role="tab" data-toggle="tab">Description</a></li>
			<li role="presentation"><a href="#voting_settings" aria-controls="voting_settings" role="tab" data-toggle="tab">Voting settings</a></li>
			<li role="presentation"><a href="#votelist" aria-controls="votelist" role="tab" data-toggle="tab">Votelist</a></li>
			<li role="presentation"><a href="#builders" aria-controls="builders" role="tab" data-toggle="tab">Builders</a></li>
			<?php if (NFW::i()->checkPermissions('events', 'manage')):?>
			<li role="presentation"><a href="#manage" aria-controls="manage" role="tab" data-toggle="tab">Manage</a></li>
			<?php endif; ?>
		</ul>
		
		<div class="tab-content">
			<?php if (NFW::i()->checkPermissions('events', 'manage')):?>
			<div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="manage"><?php echo $Module->renderAction('_manage')?></div>
			<?php endif; ?>
		
			<div role="tabpanel" class="tab-pane in active" style="padding-top: 20px;" id="settings">
				<form role="events-update">
					<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title'], 'inputCols' => '8'))?>
					<?php echo active_field(array('name' => 'date_from', 'value' => $Module->record['date_from'], 'attributes'=>$Module->attributes['date_from'], 'endDate' => -365))?>
					<?php echo active_field(array('name' => 'date_to', 'value' => $Module->record['date_to'], 'attributes'=>$Module->attributes['date_to'], 'endDate' => -365))?>
					<?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes'=>$Module->attributes['announcement'], 'height'=>'100px;'))?>
					<?php echo active_field(array('name' => 'announcement_og', 'value' => $Module->record['announcement_og'], 'attributes'=>$Module->attributes['announcement_og']))?>
					<?php echo active_field(array('name' => 'one_compo_event', 'value' => $Module->record['one_compo_event'], 'attributes'=>$Module->attributes['one_compo_event']))?>
					<?php echo active_field(array('name' => 'hide_works_count', 'value' => $Module->record['hide_works_count'], 'attributes'=>$Module->attributes['hide_works_count']))?>
					
					<div class="form-group">
						<div class="col-md-10 col-md-offset-2">
							<button type="submit" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
						</div>
					</div>
				</form>
				<hr />
				<?php echo $CMedia->openSession(array('owner_class' => get_class($Module), 'owner_id' => $Module->record['id'])); ?>
			</div>
			
			<div role="tabpanel" class="tab-pane" style="padding-top: 10px;" id="description">
				<form role="events-update">
					<textarea name="content"><?php echo htmlspecialchars($Module->record['content'])?></textarea>
				</form>
			</div>
			
			<div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="voting_settings">
				<div id="voting-settings-record-template" style="display: none;">
					<div id="record" class="record">
						<div class="cell"><span class="icon glyphicon glyphicon-sort" title="Sort"></span></div>
						<?php foreach ($Module->options_attributes as $key=>$a) { ?>
							<div class="cell"><input type="text" class="form-control" name="options[<?php echo $key?>][]" style="<?php echo $a['style']?>" placeholder="<?php echo $a['desc']?>" <?php echo isset($a['required']) && $a['required'] ? 'required' : ''?> /></div>
						<?php } ?>
						<div class="cell"><button data-action="remove-values-record" class="btn btn-danger btn-xs" title="<?php echo NFW::i()->lang['Remove']?>"><span class="glyphicon glyphicon-remove"></span></button></div>
					</div>
				</div>
		
				<form id="voting-settings-update">
					<input type="hidden" name="update_record_options" value="1" />
					<div id="values-area" class="settings">
						<?php foreach ($Module->record['options'] as $v) { ?>
							<div id="record" class="record" data-role="update">
								<div class="cell"><span class="icon glyphicon glyphicon-sort" title="Sort"></span></div>
								<?php foreach ($Module->options_attributes as $key=>$a) { ?>
									<div class="cell"><input type="text" class="form-control" name="options[<?php echo $key?>][]" value="<?php echo $v[$key]?>" style="<?php echo $a['style']?>" placeholder="<?php echo $a['desc']?>" <?php echo isset($a['required']) && $a['required'] ? 'required' : ''?> /></div>
								<?php } ?>
								<div class="cell"><button data-action="remove-values-record" class="btn btn-danger btn-xs" title="<?php echo NFW::i()->lang['Remove']?>"><span class="glyphicon glyphicon-remove"></span></button></div>
							</div>
						<?php } ?>
					</div>
					<div style="padding-top: 20px;">
						<button id="add-values-record" class="btn btn-default">Add value</button>
						<button type="submit" name="form-send" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
					</div>
				</form>		
			</div>
		
			<div role="tabpanel" class="tab-pane" style="padding-top: 10px;" id="votelist">
				<form id="votelist" method="POST" action="<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id'].'&force-render=votelist'?>" target="_blank">
<?php
	echo active_field(array('name' => 'header', 'desc' => 'Header', 'value' => $Module->record['title']));
	echo active_field(array('name' => 'subheader', 'desc' => 'Subheader', 'value' => 'Main compo votelist'));
	echo active_field(array('name' => 'description', 'desc' => 'Description', 'type' => 'textarea', 'value' => NFW::i()->getLang('main', 'votelist note'), 'labelCols' => '2'));
?>
					<table  class="table table-striped table-condensed">
						<thead>
							<tr>
								<th><a role="toogle-votelist-col" href="#">Include this competition</a></th>
								<th><a role="toogle-votelist-col" href="#">Display works</a></th>
								<th>Empty rows</th>
							</tr>
						</thead>
						<tbody><?php foreach ($competitions as $c) { ?>
							<tr>
								<td>
									<div class="checkbox">
   										<label>	
   											<input type="checkbox" checked="CHECKED" name="competitions[]" value="<?php echo $c['id']?>" />
   											<?php echo htmlspecialchars($c['title'])?>
   										</label>
									</div>
								</td>
								<td><input type="checkbox" checked="CHECKED" name="display_works[]" value="<?php echo $c['id']?>" /></td>
								<td><input class="form-control" style="width: 100px;" name="emptyrows[<?php echo $c['id']?>]" value="0" type="text" style="width: 15px;" maxlength="2" /></td>
							</tr>
						<?php } ?></tbody>
					</table>
			
					<div style="padding-top: 20px;">
						<button type="submit" class="btn btn-primary"><span class="fa fa-list-ol"></span> Generate votelist</button>
					</div>
				</form>
			</div>
		
			<div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="builders">
				<form id="make">
					<div class="row">
						<div class="col-md-8">
							<textarea class="form-control" name="results_txt"><?php echo $Module->renderAction(array('request' => $_REQUEST), 'update.results.txt')?></textarea>
						</div>
						<div class="col-md-4">
							<ul class="nav nav-tabs" role="tablist">
								<li role="presentation" class="active"><a href="#builders-results" aria-controls="builders-results" role="tab" data-toggle="tab">results.txt</a></li>
								<li role="presentation"><a href="#builders-pack" aria-controls="builders-pack" role="tab" data-toggle="tab">pack.zip</a></li>
							</ul>
							
							<div class="tab-content">
								<div role="tabpanel" class="tab-pane active" style="padding-top: 20px;" id="builders-results">
									<div id="competitions-conatiner">
										<h4><a role="builders-toggle-competitions" href="#">Compos with platform displayed:</a></h4>
										<?php foreach ($competitions as $c) { ?>
										<div class="checkbox">
											<label>	
										   		<input role="result.txt-platform" type="checkbox" value="<?php echo $c['id']?>" />
												<?php echo htmlspecialchars($c['title'])?>
											</label>
										</div> 
										<?php } ?>
									</div>
									
									<br />					 
									<label>Refresh with layout: </label>
									<a role="result.txt-layout" href="#" class="btn btn-default btn-sm active">nyuk</a>
									<a role="result.txt-layout" href="#" class="btn btn-default btn-sm">diver</a>
									
									<hr />
									
									<div data-active-container="results_filename">
										<div class="input-group">
											<span class="input-group-addon" id="sizing-addon1">files/<?php echo $Module->record['alias']?>/</span>
											
			      							<input type="text" class="form-control" name="results_filename" value="results.txt" maxlength="64" placeholder="results.txt">
											<span class="input-group-btn">
			        							<button name="save_results_txt" value="1" type="submit" class="btn btn-primary" title="Save results file"><span class="fa fa-save"></span></button>
											</span>
										</div>
										<span class="help-block"></span>
									</div>
								</div>
								<div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="builders-pack">
									<div id="competitions-conatiner">
										<h4><a role="builders-toggle-competitions" href="#">Attach competitions:</a></h4>
													
										<?php foreach ($competitions as $c) { ?>
										<div class="checkbox">
											<label>	
										   		<input type="checkbox" checked="checked" name="competitions[]" value="<?php echo $c['id']?>" />
												<?php echo htmlspecialchars($c['title'])?>
											</label>
										</div> 
										<?php } ?>
									</div>
									
									<br />
									
									<div class="checkbox">
										<label>	
									   		<input type="checkbox" checked="CHECKED" name="attach_results_txt" /> Attach `results.txt` into archive
										</label>
									</div> 
									
									<div class="checkbox">
										<label>	
									   		<input type="checkbox" checked="CHECKED" name="attach_media" /> Attach Event's media files
										</label>
									</div> 
							
									<hr />
									
									<div data-active-container="pack_filename">
										<div class="input-group">
											<span class="input-group-addon" id="sizing-addon1">files/<?php echo $Module->record['alias']?>/</span>
											
			      							<input type="text" class="form-control" name="pack_filename" value="<?php echo $Module->record['alias'].'-pack.zip'?>" maxlength="64" placeholder="<?php echo $Module->record['alias'].'-pack.zip'?>">
											<span class="input-group-btn">
			        							<button name="save_pack" value="1" type="submit" class="btn btn-primary" title="Save pack archive"><span class="fa fa-save"></span></button>
											</span>
										</div>
										<span class="help-block"></span>
									</div>
								</div>
							</div>					
						</div>
					</div>
				</form>
			</div>
	
		</div>
	</div>
		
	<div class="col-md-3">
		<?php /* Right bar */ ?>
		<h3>Preview image:</h3>
		<?php echo $preview_form?>
	
		<h3>Large preview:</h3>
		<?php echo $preview_large_form ?>
		<br />
		<br />
		
		<div class="panel panel-primary">
			<div class="panel-heading">Related links</div>
			<div class="panel-body">
				<ul class="nav nav-pills nav-stacked">
					<li role="presentation"><a href="<?php echo NFW::i()->base_path.'admin/competitions?event_id='.$Module->record['id']?>" title="Manage competitions of this events">Manage competitions</a></li>
					<li role="presentation"><a href="<?php echo NFW::i()->base_path.'admin/works?event_id='.$Module->record['id']?>" title="Manage works of this events">Manage works</a></li>
					<li role="presentation"><a href="<?php echo NFW::i()->base_path.'admin/vote?event_id='.$Module->record['id']?>" title="Manage voting of this events">Manage voting</a></li>
				</ul>
				
				<?php if (!empty($competitions)): ?>
				<hr />
				<?php foreach ($competitions as $competition) { ?>
				<p><?php echo $competition['position']?>.&nbsp;<a href="<?php echo NFW::i()->base_path.'admin/competitions?action=update&record_id='.$competition['id']?>" title="Manage `<?php echo htmlspecialchars($competition['title'])?>` competition"><?php echo htmlspecialchars($competition['title'])?></a></p>
				<?php } ?>
				<?php endif;?>
			</div>
		</div>
	</div>
</div>