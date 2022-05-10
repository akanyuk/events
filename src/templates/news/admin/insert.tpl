<?php
NFW::i()->assign('page_title', 'Новости / добавить');
 
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('ckeditor');
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="news-insert"]');
	f.activeForm({
		success: function(response) {
			window.location.href = '<?php echo $Module->formatURL('update')?>&record_id=' + response.record_id;
		}
	});

	$('button[id="news-save"]').click(function(){
		f.find('input[name="content"]').val($('textarea[id="content"]').val());
		$('div[id="news-insert-media"]').find('form').trigger('save-comments');
		f.submit();
	});
	
	$('textarea[id="content"]').CKEDIT({ 'media': 'news', 'height': 200 });
});
</script>

<textarea id="content"></textarea>
<form id="news-insert" style="padding-top: 10px;">
	<input name="content" type="hidden" />
	<fieldset>
		<legend>Параметры</legend>
		<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title']))?>
       	<?php echo active_field(array('name' => 'announcement', 'attributes'=>$Module->attributes['announcement'], 'height'=>"100px;"))?>
	</fieldset>
</form>

<div class="form-group">
	<div class="col-md-9 col-md-offset-3">
		<div id="news-insert-media"><?php echo $media_form?></div>
	</div>
</div>

<div class="form-group">
	<div class="col-md-3 col-md-offset-3">
		<button id="news-save" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span> <?php echo NFW::i()->lang['Save changes']?></button>
	</div>
</div>