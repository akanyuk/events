<?php 
NFW::i()->registerFunction('active_field');
NFW::i()->registerFunction('ui_message');
?>
<script type="text/javascript">
$(document).ready(function(){
	$('form[id="elements-insert"]').activeForm({
		success: function(response) {
			window.location.href = '<?php echo $Module->formatURL('admin')?>';
		}
	});

	$(document).trigger('refresh');
});
</script>

<form id="elements-insert">
	<fieldset>
		<legend>Параметры элемента</legend>
		<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
		<?php echo active_field(array('name' => 'alias', 'attributes'=>$Module->attributes['alias'], 'width'=>"100px;"))?>
		<?php echo active_field(array('name' => 'content', 'attributes'=>$Module->attributes['content'], 'width'=>"500px;", 'height'=>"200px;"))?>
		
		<?php echo active_field(array('name' => 'editable', 'value' => $Module->record['editable'], 'attributes'=>$Module->attributes['editable']))?>
		<?php echo active_field(array('name' => 'visual_editor', 'value' => $Module->record['visual_editor'], 'attributes'=>$Module->attributes['visual_editor']))?>
		<?php echo active_field(array('name' => 'with_attachments', 'value' => $Module->record['with_attachments'], 'attributes'=>$Module->attributes['with_attachments']))?>
		
		<div class="input-row">
			<button type="submit" class="nfw-button" icon="ui-icon-disk">Сохранить изменения</button>
		</div>
	</fieldset>
</form>