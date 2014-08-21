<?php 
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerFunction('ui_message');
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="news-insert"]');
	f.activeForm({
 		beforeSubmit: function(){
 			$('div[id="news-insert-media"]').find('form').trigger('save-comments');
 	 	},
		success: function(response) {
			window.location.href = '<?php echo $Module->formatURL('update')?>&record_id=' + response.record_id;
		}
	});

	$('button[id="news-save"]').click(function(){
		f.submit();
	});
	
	f.find('textarea[name="content"]').CKEDIT({ 'media': 'news', 'height': 200 });

	$(document).trigger('refresh');
});
</script>

<form id="news-insert">
	<textarea name="content" class="uniformed"></textarea>
	<br />
	<fieldset>
		<legend>Параметры</legend>
		<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
		<?php echo active_field(array('name' => 'announcement', 'attributes'=>$Module->attributes['announcement'], 'width'=>"500px;", 'height'=>"100px;"))?>
	</fieldset>
</form>

<div id="news-insert-media" style="padding-top: 1em; padding-left: 105px;">
	<?php echo $media_form?>
</div>
<div style="padding-top: 1em; padding-bottom: 1em; padding-left: 105px;">
	<button id="news-save" class="nfw-button" icon="ui-icon-disk">Сохранить изменения</button>
</div>			
