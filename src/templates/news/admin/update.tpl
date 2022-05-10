<?php
NFW::i()->assign('page_title', $Module->record['title'].' / Редактирование');

NFW::i()->breadcrumb = array(
	array('url' => 'admin/news', 'desc' => 'Новости'),
	array('desc' => $Module->record['title'])
);

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.jgrowl');
NFW::i()->registerResource('ckeditor');

// Open session for uploading from CKEditor
$CMedia = new media();
$CMedia->openSession(array('owner_class' => get_class($Module), 'owner_id' => $Module->record['id']));

ob_start();
?>
<div class="text-muted" style="font-size: 80%;">
	<div class="pull-right">
		Добавлено: <?php echo date('d.m.Y H:i', $Module->record['posted']).' ('.$Module->record['posted_username'].')'?>
		<?php echo $Module->record['edited'] ? '<br />Отредактировано: '.date('d.m.Y H:i', $Module->record['edited']).' ('.$Module->record['edited_username'].')' : '' ?>	
	</div>
</div>
<?php 
NFW::i()->breadcrumb_status = ob_get_clean();
?>
<script type="text/javascript">
$(document).ready(function(){
 	$('form[role="news-update"]').each(function(){
 		$(this).activeForm({
 	 		action: '<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>',
 			success: function(response) {
 				//$('div[id="news-update-media"]').find('form').trigger('save-comments');
 				
 	 			if (response.is_updated) {
 	 				$.jGrowl('Изменения сохранены');
 	 			}
 			}
 		});
	});

	$('button[id="news-save"]').click(function(){
		$(this).closest('div[role="tabpanel"]').find('form[role="news-update"]').submit();
	});

	// Visual edit
	$('textarea[name="content"]').CKEDIT({ 'toolbar': '!Full', 'media': 'news', 'media_owner': '<?php echo $Module->record['id']?>' });

	<?php if (NFW::i()->checkPermissions('news', 'delete')): ?>
	$('[id="news-delete"]').click(function(){
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
	<li role="presentation"><a href="#params" aria-controls="params" role="tab" data-toggle="tab">Параметры</a></li>
</ul>

<div class="tab-content">
	<div role="tabpanel" class="tab-pane in active" id="content">
    	<form role="news-update" style="margin-top: 3px;">
			<textarea name="content"><?php echo htmlspecialchars($Module->record['content'])?></textarea>
		</form>    
    </div>
    
    <div role="tabpanel" class="tab-pane" id="params">
		<form role="news-update" style="margin-top: 20px;">
			<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title']))?>
			<?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes'=>$Module->attributes['announcement']))?>
			<?php echo active_field(array('name' => 'meta_keywords', 'value' => $Module->record['meta_keywords'], 'attributes'=>$Module->attributes['meta_keywords']))?>
		</form>

		<div id="news-update-media"><?php echo $media_form?></div>
		
		<div class="form-group">
			<div class="col-md-9 col-md-offset-3">
				<?php if (NFW::i()->checkPermissions('news', 'delete')): ?>
				<div class="pull-right">
					<a id="news-delete" href="#" class="text-danger"><span class="glyphicon glyphicon-remove"></span> Удалить запись</a>
				</div>
				<?php endif; ?>
				<button id="news-save" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span> <?php echo NFW::i()->lang['Save changes']?></button>
				<div class="clearfix"></div>
			</div>
		</div>
	</div>
</div>
	