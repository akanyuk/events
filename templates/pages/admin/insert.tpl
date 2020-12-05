<?php
NFW::i()->assign('page_title', 'Страницы / добавить');

NFW::i()->breadcrumb = array(
	array('url' => 'admin/pages', 'desc' => 'Страницы'),
	array('desc' => 'Добавить')
);

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('ckeditor');

active_field('set_defaults', array('vertical' => true));
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="pages-insert"]').activeForm({
 	 	success: function(response) {
			window.location.href = '<?php echo $Module->formatURL('update')?>&record_id=' + response.record_id;
		}
	});

	$('textarea[name="content"]').CKEDIT({ 'media': 'pages', 'height': 200 });
});
</script>

<form id="pages-insert" class="active-form">
	<fieldset>
		<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title']))?>
       	<?php echo active_field(array('name' => 'path', 'value' => $Module->record['path'], 'attributes'=>$Module->attributes['path']))?>
       	<?php echo active_field(array('name' => 'is_active', 'value' => $Module->record['is_active'], 'attributes'=>$Module->attributes['is_active']))?>
       	
		<div class="form-group">
			<textarea name="content"></textarea>
		</div>
		
       	<div class="form-group">
			<button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span> <?php echo NFW::i()->lang['Save changes']?></button>
		</div>
	</fieldset>
</form>