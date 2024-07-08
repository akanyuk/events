<?php
/**
 * @var $Module object
 */
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('bootstrap3.typeahead');

$lang_main = NFW::i()->getLang('main');
NFW::i()->assign('page_title', $lang_main['cabinet add work']);

NFW::i()->breadcrumb = array(
	array('url' => 'cabinet/works?action=add', 'desc' => $lang_main['cabinet add work']),
	array('desc' => $Module->current_event['title'])
);

// Success dialog
NFW::i()->registerFunction('ui_dialog');
$successDialog = new ui_dialog();
$successDialog->render();
?>
<script type="text/javascript">
$(document).ready(function(){
    const f = $('form[id="works-add"]');
    f.activeForm({
		'success': function(response){
			$('div[id="on-complete-removable-aria"]').remove();
			
			$(document).trigger('show-<?php echo $successDialog->getID()?>', [ response.message ]);
			$(document).on('hide-<?php echo $successDialog->getID()?>', function(){
				window.location.href = '?action=list';
			});
		}
	});
	
	// Platform typeahead
    const aPlatforms = [];
    <?php foreach ($Module->attributes['platform']['options'] as $p) echo 'aPlatforms.push('.json_encode($p).');'."\n"; ?>
	$('input[name="platform"]').typeahead({ source: aPlatforms, minLength: 0 }).attr('autocomplete', 'off');
	
	$('button[id="add-work"]').click(function(){
		f.submit();
	});
});
</script>

<div id="on-complete-removable-aria">
	<form id="works-add">
		<?php echo active_field(array('name' => 'competition_id', 'attributes' => $Module->attributes['competition_id'], 'desc' => $lang_main['competition']))?>
		<?php echo active_field(array('name' => 'title', 'attributes' => $Module->attributes['title'], 'desc' => $lang_main['works title']))?>
		<?php echo active_field(array('name' => 'author', 'attributes' => $Module->attributes['author'], 'desc' => $lang_main['works author']))?>
		<?php echo active_field(array('name' => 'platform', 'attributes' => $Module->attributes['platform'], 'type' => 'str', 'desc' => $lang_main['works platform'], 'inputCols' => '5'))?>
		<?php echo active_field(array('name' => 'format', 'attributes' => $Module->attributes['format'], 'type' => 'str', 'desc' => $lang_main['works format'], 'inputCols' => '5'))?>
		<?php echo active_field(array('name' => 'description_public', 'attributes' => $Module->attributes['description'], 'desc' => $lang_main['works description public']))?>
		
		<div class="form-group">
			<label class="col-md-3 control-label"><?php echo $lang_main['works description refs']?></label>
			<div class="col-md-9">	
				<?php $is_first = true; foreach ($lang_main['works description refs options'] as $o) { ?>
				<div class="radio">
  					<label>
					    <input type="radio" name="description_refs" id="description_refs" value="<?php echo $o?>" <?php echo $is_first ? 'checked="checked"' : ''?>/>
						<?php echo $o?>
					</label>
				</div>
				<?php $is_first = false;  } ?>
				<span class="help-block"></span>
			</div>			
		</div>
		
		<?php echo active_field(array('name' => 'description', 'attributes' => $Module->attributes['description'], 'desc' => $lang_main['works description']))?>
		
		<?php echo NFWX::i()->hook("works_add_form_append", $Module->current_event['alias'])?>
	</form>

	<div class="row">
		<div class="col-md-offset-3 col-md-9">
<?php 
$CMedia = new media();
echo $CMedia->openSession(array(
	'owner_class' => get_class($Module),
	'secure_storage' => true,
	'template' => '_cabinet_add_work',
));
?>
		</div>
	</div>
	
	<div class="row">
		<div class="col-md-offset-3 col-md-9">
			<div class="alert alert-info dm-alert-cond"><?php echo $lang_main['works upload info']?></div>
			<button id="add-work" class="btn btn-primary"><?php echo $lang_main['works send']?></button>
		</div>
	</div>
</div>