<?php 
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerFunction('ui_message');
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="pages-insert"]').activeForm({
 		beforeSubmit: function(){
 			$('div[id="pages-insert-media"]').find('form').trigger('save-comments');
 	 	},
 	 	success: function(response) {
			window.location.href = '<?php echo $Module->formatURL('update')?>&record_id=' + response.record_id;
		}
	});

	$('button[id="pages-save"]').click(function(){
		f.submit();
	});
	
	f.find('textarea[name="content"]').CKEDIT({ 'media': 'pages', 'height': 200 });
	
	$(document).trigger('refresh');
});
</script>

<form id="pages-insert">
	<textarea name="content"></textarea>
	<br />
	<fieldset>
		<legend>Параметры страницы</legend>
		<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
		<?php echo active_field(array('name' => 'path', 'attributes'=>$Module->attributes['path'], 'width'=>"150px;"))?>
		
	    <label></label>
	    <div class="input-row" style="width: 400px;">
	    	<?php echo ui_message(array('icon' => 'info', 'text' => 'Для заглавной страницы сайта укажите путь "/"'))?>
       	</div>
	    <div class="delimiter"></div>
		
		<?php echo active_field(array('name' => 'is_active', 'value' => '1', 'attributes'=>$Module->attributes['is_active']))?>
	</fieldset>
</form>

<div id="pages-insert-media" style="padding-top: 1em; padding-left: 105px;">
	<?php echo $media_form?>
</div>
<div style="padding-top: 1em; padding-bottom: 1em; padding-left: 105px;">
	<button id="pages-save" class="nfw-button" icon="ui-icon-disk">Сохранить изменения</button>
</div>			
