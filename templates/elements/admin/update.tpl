<?php 
NFW::i()->registerFunction('ui_message');
?>
<div id="elements-update-dialog">
	<form id="elements-update" action="<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>">
		<div class="active-field">			
			<textarea name="content" style="width: 100%; height: 300px;"><?php echo htmlspecialchars($Module->record['content'])?></textarea>
			<div class="error-info"></div>
		</div>
	</form>
			
	<?php if (NFW::i()->checkPermissions('elements', 'media_upload') && $Module->record['with_attachments']): ?>
		<div id="elements-update-media">
			<?php echo ui_message(array('text' => "Во время вставки в текст ссылки или изображения нажмите кнопку «Выбор на сервере» и кликните на имя файла.")) ?>
			<?php echo $media_form?>
		</div>			
	<?php endif;?>
</div>
<script type="text/javascript">
$(document).ready(function(){
	var euD = $('div[id="elements-update-dialog"]').dialog({ 
		autoOpen: true,draggable: false,modal: true, resizable: false,
		title: 'Редактирование элемента "<?php echo htmlspecialchars($Module->record['title'])?>"',
		width: 850, height: $(window).height() - 20,
		<?php if (!$Module->record['visual_editor']): ?>
		buttons: {
			'Сохранить': function() {
				euF.submit();
			}
		},
		<?php endif; ?>
		close: function(event, ui) {
			euD.dialog('destroy').remove();
		}
	});	
		
	var euF = $('form[id="elements-update"]').activeForm({
		success: function(response) {
			// Save attachments comment
			$('div[id="elements-update-media"]').find('form').trigger('save-comments');

			alert('Изменения в тексте и комментарии к файлам сохранены на сервере');
			//euD.dialog('close');
		}
	});

 	<?php if ($Module->record['visual_editor']): ?>
		euF.find('textarea[name="content"]').CKEDIT({ <?php echo $Module->record['with_attachments'] ? '"media": "elements", "media_owner": "'.$Module->record['id'].'"' : ''?> });
	<?php endif; ?>

	$(document).trigger('refresh');
});
</script>