<?php
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerFunction('ui_message');
?>
<script type="text/javascript">
$(document).ready(function(){
 	$('form[rel="events-insert"]').each(function(){
 		$(this).activeForm({
 	 		beforeSubmit: function(){
 	 			$('div[id="events-update-media"]').find('form').trigger('save-comments');
 	 	 	},
 	 		action: '<?php echo $Module->formatURL('insert')?>',
 			success: function(response) {
 				window.location.href = '<?php echo $Module->formatURL()?>';
 			}
 		});
	});

	$('button[id="events-save"]').click(function(){
		$(this).closest('div[rel="tab-container"]').find('form[rel="events-insert"]').submit();
	});

	// Visual edit
	$('textarea[name="content"]').CKEDIT({ 'media': 'events' });

	$('div[id="events-update-tabs"]').tabs().show();

	$(document).trigger('refresh');
});
</script>

<div id="events-update-tabs" style="display: none;">
	<ul>
		<li><a href="#tabs-1">Settings</a></li>
		<li><a href="#tabs-2">Description</a></li>
	</ul>

    <div id="tabs-1" rel="tab-container">
		<form rel="events-insert">
			<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
			<?php echo active_field(array('name' => 'alias', 'attributes'=>$Module->attributes['alias'], 'width'=>"200px;"))?>
			<?php echo active_field(array('name' => 'date_from', 'attributes'=>$Module->attributes['date_from']))?>
			<?php echo active_field(array('name' => 'date_to', 'attributes'=>$Module->attributes['date_to']))?>
			<?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes'=>$Module->attributes['announcement'], 'width'=>"500px;", 'height'=>"50px;"))?>
			<?php echo active_field(array('name' => 'is_hidden', 'attributes'=>$Module->attributes['is_hidden']))?>
		</form>
		<div id="events-update-media" style="padding-top: 1em; padding-left: 105px;">
			<?php echo $media_form?>
			<button id="events-save" class="nfw-button" icon="ui-icon-disk">Save changes</button>
		</div>
    </div>
    <div id="tabs-2">
		<form rel="events-insert">
			<textarea name="content"></textarea>
		</form>
    </div>
</div>
