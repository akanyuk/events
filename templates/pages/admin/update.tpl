<?php 
NFW::i()->assign('page_title', $Module->record['title'].' / Редактирование');

NFW::i()->breadcrumb = array(
	array('url' => 'admin/pages', 'desc' => 'Страницы'),
	array('desc' => $Module->record['title'])
);

NFW::i()->breadcrumb_status = '<a href="'.NFW::i()->base_path.$Module->record['path'].'">Открыть страницу на сайте</a>';

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.jgrowl');
NFW::i()->registerResource('ckeditor');

active_field('set_defaults', array('labelCols' => 2, 'inputCols' => 10));

$CMedia = new media();
?>
<script type="text/javascript">
$(document).ready(function(){
 	$('form[role="pages-update"]').each(function(){
 		$(this).activeForm({
 	 		action: '<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>',
 			success: function(response) {
 	 			if (response.is_updated) {
 	 				$.jGrowl('Изменения сохранены');
 	 			}
 			}
 		});
	});

	// Visual edit
	$('textarea[name="content"]').CKEDIT({ 'toolbar': 'Full', 'media': 'pages', 'media_owner': '<?php echo $Module->record['id']?>' });

	<?php if (NFW::i()->checkPermissions('pages', 'delete')): ?>
	// Action 'delete'
	$('[id="pages-delete"]').click(function(){
		if (!confirm('Удалить запись?')) return false;

		$.post('<?php echo $Module->formatURL('delete')?>', { record_id: '<?php echo $Module->record['id']?>' }, function(response){
			if (response != 'success') {
				alert(response);
				return false;
			}
			else {
				window.location.href = '<?php echo $Module->formatURL('admin')?>';
			}
		});
	});
	<?php endif; ?>
});
</script>

<ul class="nav nav-tabs" role="tablist">
	<li role="presentation" class="active"><a href="#content" aria-controls="content" role="tab" data-toggle="tab">Текст</a></li>
	<li role="presentation"><a href="#params" aria-controls="params" role="tab" data-toggle="tab">Параметры страницы</a></li>
	<li role="presentation"><a href="#media" aria-controls="media" role="tab" data-toggle="tab">Файлы</a></li>
</ul>

<div class="tab-content">
	<div role="tabpanel" class="tab-pane in active" id="content" style="padding-top: 3px;">
    	<form role="pages-update">
			<textarea name="content"><?php echo htmlspecialchars($Module->record['content'])?></textarea>
		</form>    
    </div>
    
    <div role="tabpanel" class="tab-pane" id="params" style="padding-top: 20px;">
		<form role="pages-update">
			<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title']))?>
	       	<?php echo active_field(array('name' => 'path', 'value' => $Module->record['path'], 'attributes'=>$Module->attributes['path']))?>
	       	<?php echo active_field(array('name' => 'meta_keywords', 'value' => $Module->record['meta_keywords'], 'attributes'=>$Module->attributes['meta_keywords']))?>
	       	<?php echo active_field(array('name' => 'meta_description', 'value' => $Module->record['meta_description'], 'attributes'=>$Module->attributes['meta_description']))?>
			<?php echo active_field(array('name' => 'is_active', 'value' => $Module->record['is_active'], 'attributes'=>$Module->attributes['is_active']))?>
			
			<div class="form-group">
				<div class="col-md-10 col-md-offset-2">
					<?php if (NFW::i()->checkPermissions('pages', 'delete')): ?>
					<div class="pull-right">
						<a id="pages-delete" href="#" class="text-danger"><span class="glyphicon glyphicon-remove"></span> Удалить страницу</a>
					</div>
					<?php endif; ?>
					<button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span> <?php echo NFW::i()->lang['Save changes']?></button>
					<div class="clearfix"></div>
				</div>
			</div>			
		</form>    
    </div>
    
     <div role="tabpanel" class="tab-pane" id="media" style="padding-top: 20px;">
		<?php echo $CMedia->openSession(array('owner_class' => get_class($Module), 'owner_id' => $Module->record['id']))?>
     </div>
</div>	    	
	