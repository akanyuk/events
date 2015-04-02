<?php 
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerResource('jquery.jgrowl');
?>
<script type="text/javascript">
$(document).ready(function(){
 	var f = $('form[rel="pages-update"]').each(function(){
 		$(this).activeForm({
 	 		beforeSubmit: function(){
 	 			$('div[id="pages-update-media"]').find('form').trigger('save-comments');
 	 	 	},
 	 		action: '<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>',
 			success: function(response) {
 				$('input[name="local_file"]').closest('form').trigger('save-comments');
 				
 	 			if (response.is_updated) {
 	 				$.jGrowl('Changes sucesfully saved.');
 	 			}
 			}
 		});
	});

	$('button[id="pages-save"]').click(function(){
		$(this).closest('div[rel="tab-container"]').find('form[rel="pages-update"]').submit();
	});
 	
	f.find('div[rel="active-field-info"]').each(function(){
		f.find('div[class="active-field"][id="' + this.id + '"]').find('.error-info').before($(this).html());
	});

	// Visual edit
	$('textarea[name="content"]').CKEDIT({ 'media': 'pages', 'media_owner': '<?php echo $Module->record['id']?>' });
	
	// Action 'delete'
	$('a[id="pages-delete"]').click(function(){
		if (!confirm('Удалить запись?')) return false;

		$.post('<?php echo $Module->formatURL('delete')?>', { record_id: '<?php echo $Module->record['id']?>' }, function(response){
			if (response) {
				alert(response);
				return false;
			}
			else {
				window.location.href = '<?php echo $Module->formatURL('admin')?>';
			}
		});
	});

	$('div[id="pages-update-tabs"]').tabs().show();

	$(document).trigger('refresh');
});
</script>

<div id="pages-update-tabs" style="display: none;">
	<?php if (NFW::i()->checkPermissions('pages', 'delete')): ?>
		<div class="ui-state-error ui-corner-all" style="float: right; margin-right: 0.5em; margin-top: 0.2em; padding-right: 1px;"> 
			<a id="pages-delete" href="#" class="ui-icon ui-icon-trash nfw-tooltip" title="Удалить страницу"></a>
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
		<li><a href="#tabs-2">Параметры страницы</a></li>
		<li><a href="#tabs-3">Элементы</a></li>
	</ul>
    
    <div id="tabs-1">
		<form rel="pages-update">
			<textarea name="content"><?php echo htmlspecialchars($Module->record['content'])?></textarea>
		</form>    
    </div>
    <div id="tabs-2" rel="tab-container">
		<form rel="pages-update">
			<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title'], 'width'=>"550px;"))?>
			
	       	<?php echo active_field(array('name' => 'path', 'value' => $Module->record['path'], 'attributes'=>$Module->attributes['path'], 'width'=>"200px;"))?>
		    <div rel="active-field-info" id="path" style="display: none;">
	    		<span class="ui-icon ui-icon-highlight ui-icon-info nfw-tooltip" title="Для заглавной страницы сайта укажите путь '/'" style="display: inline-block;"></span>
	       	</div>
			
			<?php echo active_field(array('name' => 'is_active', 'value' => $Module->record['is_active'], 'attributes'=>$Module->attributes['is_active']))?>
		</form>    
		
		<div id="pages-update-media" style="padding-top: 1em; padding-left: 105px;">
			<?php echo $media_form?>
			<button id="pages-save" class="nfw-button" icon="ui-icon-disk">Сохранить изменения</button>
		</div>			
    </div>
    <div id="tabs-3" rel="tab-container">
		<form rel="pages-update">
			<?php foreach ($elements as $e) { ?>
				<div>
					<input type="checkbox" class="checkbox" name="elements[]" value="<?php echo $e['id']?>" <?php echo in_array($e['id'], $Module->record['elements']) ? ' checked="CHECKED"' : ''?> />
					<?php echo htmlspecialchars($e['title'])?>
				</div>
			<?php } ?>		
			<div class="input-row">
				<button type="submit" class="nfw-button" icon="ui-icon-disk">Сохранить изменения</button>
			</div>
		</form>   
    </div>
</div>	    	
	