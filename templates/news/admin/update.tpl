<?php
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerFunction('ui_message');
?>
<script type="text/javascript">
$(document).ready(function(){
 	$('form[rel="news-update"]').each(function(){
 		$(this).activeForm({
 	 		beforeSubmit: function(){
 	 			$('div[id="news-update-media"]').find('form').trigger('save-comments');
 	 	 	},
 	 		action: '<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>',
 			success: function(response) {
 	 			if (response.is_updated) {
 	 				$(document).trigger('uiDialog', 'Изменения сохранены');
 	 			}
 			}
 		});
	});

	$('button[id="news-save"]').click(function(){
		$(this).closest('div[rel="tab-container"]').find('form[rel="news-update"]').submit();
	});

	// Visual edit
	$('textarea[name="content"]').CKEDIT({ 'media': 'news', 'media_owner': '<?php echo $Module->record['id']?>' });
		
	$('a[id="news-delete"]').click(function(){
		if (!confirm('Удалить запись?')) return false;

		$.post('<?php echo $Module->formatURL('delete')?>', { record_id: '<?php echo $Module->record['id']?>' }, function(response){
			if (response) {
				$(document).trigger('uiDialog', [ response, { state: 'error' }]);
				return false;
			}
			else {
				window.location.href = '<?php echo $Module->formatURL('admin')?>';
			}
		});
	});

	$('div[id="news-update-tabs"]').tabs().show();

	$(document).trigger('refresh');
});
</script>

<div id="news-update-tabs" style="display: none;">
	<?php if (NFW::i()->checkPermissions('news', 'delete')): ?>
		<div class="ui-state-error ui-corner-all" style="float: right; margin-right: 0.5em; margin-top: 0.2em; padding-right: 1px;"> 
			<a id="news-delete" href="#" class="ui-icon ui-icon-trash nfw-tooltip" title="Удалить запись"></a>
		</div>
	<?php endif; ?>
	<div style="float: right; padding-right: 1em; padding-top: 0.2em;">
		<p style="font-size: 85%; text-align: right;">Добавлено: <?php echo date('d.m.Y H:i:s', $Module->record['posted']).' ('.$Module->record['posted_username'].')'?></p>
		<?php if ($Module->record['edited']): ?>
			<p style="font-size: 85%; text-align: right;">Обновлено: <?php echo date('d.m.Y H:i:s', $Module->record['edited']).' ('.$Module->record['edited_username'].')'?></p>
		<?php endif; ?>
	</div>
	
	<ul>
		<li><a href="#tabs-1">Текст</a></li>
		<li><a href="#tabs-2">Параметры</a></li>
	</ul>
    
    <div id="tabs-1">
		<form rel="news-update">
			<textarea name="content"><?php echo htmlspecialchars($Module->record['content'])?></textarea>
		</form>    
    </div>
    <div id="tabs-2" rel="tab-container">
		<form rel="news-update">
			<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
			<?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes'=>$Module->attributes['announcement'], 'width'=>"500px;", 'height'=>"50px;"))?>
		</form>
		<div id="news-update-media" style="padding-top: 1em; padding-left: 105px;">
			<?php echo $media_form?>
			<button id="news-save" class="nfw-button" icon="ui-icon-disk">Сохранить изменения</button>
		</div>			
    </div>
</div>	    	
	