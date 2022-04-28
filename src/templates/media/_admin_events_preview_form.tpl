<?php
	if (isset($_POST['make_tmb'])) {
		NFW::i()->stop($_POST['make_tmb']);		
	}
	
	// Custom media form for categories and products preview
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->registerFunction('tmb');
	$lang_media = NFW::i()->getLang('media');
	
	$id = $owner_class.$owner_id;
?>
<script type="text/javascript">
$(document).ready(function(){
	var form = $('form[id="<?php echo $session_id?>"]');
	
	form.activeForm({
		success: function(response) {
			$.post('<?php echo NFW::i()->base_path?>media.php?action=make_tmb', { 
				'file_id': response.id,
				'width': <?php echo $tmb_width?>,
				'height': <?php echo $tmb_height?>,
				'options': { 'complementary': 1 }
			}, function(tmb){
				photoLink.find('img[id="preview-tmb"]').attr('src', tmb);
			});
			
			photoDialog.find('img[id="preview-fullsize"]').attr('src', response.url).show();
			photoDialog.find('button[data-rel="remove-preview-photo"]').attr('id', response.id).show();
			photoDialog.find('p[id="preview-nothing"]').hide();
		}
	});

	form.find('input[name="local_file"]').change(function() {
		form.submit();
    });

	$(document).off('click', 'button[data-rel="remove-preview-photo"]').on('click', 'button[data-rel="remove-preview-photo"]', function(){
		if (!confirm('Remove image?')) return false;

		var file_id = $(this).attr('id');
		$.post('<?php echo NFW::i()->base_path?>media.php?action=remove', { 'file_id': file_id }, function(){
			photoDialog.modal('hide');

			photoDialog.find('img[id="preview-fullsize"]').hide();
			photoDialog.find('button[data-rel="remove-preview-photo"]').hide();
			photoDialog.find('p[id="preview-nothing"]').show();

			photoLink.find('img[id="preview-tmb"]').attr('src', '<?php echo $preview_default?>');			
		});
		
		return false;
	});
	
	// Preview photo
	var photoDialog = $('div[id="upload-<?php echo $id?>-dialog"]');
	photoDialog.modal({ 'show': false });

	var photoLink = $('a[id="upload-<?php echo $id?>"]'); 
	$('a[id="upload-<?php echo $id?>"]').off('click').on('click', function(){
		photoDialog.modal('show');
		return false;
	});
});
</script>

<div id="upload-<?php echo $id?>-dialog" class="modal fade"><div class="modal-dialog"><div class="modal-content">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h4 class="modal-title">Image uploading</h4>
	</div>
	
	<div id="body" class="modal-body" style="text-align: center;">
		<img id="preview-fullsize" src="<?php echo $preview['url']?>" alt="" style="display: <?php echo $preview['url'] ? 'inline' : 'none'?>; max-height: 500px; max-width: 500px;" />
		<p id="preview-nothing" class="text-muted" style="display: <?php echo $preview['url'] ? 'none' : 'inline'?>">Upload image <br />Max. size: <?php echo $image_max_x.'x'.$image_max_y?>px</p>
	</div>
	
	<div class="modal-footer" style="padding-left: 30px;">
		<div class="pull-right">
			<button data-rel="remove-preview-photo" id="<?php echo $preview['id'] ?>" class="btn btn-danger btn-rc" style="display: <?php echo $preview['url'] ? 'block' : 'none'?>"><span class="glyphicon glyphicon-remove"></span> Удалить фото</button>
		</div>
	
		<form id="<?php echo $session_id?>" class="form-horizontal" action="<?php echo NFW::i()->base_path.'media.php?action=upload&session_id='.$session_id?>" enctype="multipart/form-data">
			<input type="hidden" name="owner_id" value="<?php echo $owner_id?>" />
			<input type="hidden" name="owner_class" value="<?php echo $owner_class?>" />
			<input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $MAX_FILE_SIZE?>" />
			<div class="form-group" id="local_file">
				<input type="file" name="local_file" />			
				<span class="help-block"></span>
			</div>
		</form>
	</div>
</div></div></div>

<a id="upload-<?php echo $id?>" href="#" title="Upload image">
	<img id="preview-tmb" src="<?php echo $preview['url'] ? tmb($preview, $tmb_width, $tmb_height, array('complementary' => true)) : $preview_default?>" alt="" class="img-thumbnail" />
</a>
