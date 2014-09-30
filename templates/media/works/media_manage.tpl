<?php
	$lang_media = NFW::i()->getLang('media');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Set session cookie
	$.cookie('<?php echo $session_id?>', '<?php echo $cookie_data?>', { path: '/' });
	
	var form = $('form[id="<?php echo $session_id?>"]');
	form.activeForm({
		success: function(response) {
			form.resetForm().trigger('cleanErrors').trigger('load');
			$.uniform.update(form.find('input[name="local_file"]'));
		}
	});

	form.find('input[name="local_file"]').change(function() {
		form.trigger('save-comments').submit();
    }).uniform({ 'fileDefaultHtml': '<?php echo $lang_media['fileDefaultHtml']?>', 'fileButtonHtml': '<?php echo $lang_media['fileButtonHtml']?>' });

	form.bind('load', function(){
		$.get("<?php echo NFW::i()->base_path.'admin/works?action=media_manage&record_id='.$owner_id.'&ts='?>" + new Date().getTime(), function(response){
			if (response.iTotalRecords == 0) {
				form.find('*[id="media-list"]').hide();
				return false;
			}

			form.find('*[id="session_size"]').text(response.iSessionSize_str);
			
			var rowTemplate = '<tr class="zebra"><td><a href="%url%" type="%type%"><img src="%icon%"/></a></td><td><a href="%url%" type="%type%"><strong>%basename%</strong></a><div class="info">Uploaded: %posted_str% by %posted_username%<br />Filesize: %filesize_str% %image_size%</div></td><td class="st"><input type="checkbox" name="media_info[%id%][screenshot]" %screenshot%/></td><td class="st"><input type="checkbox" name="media_info[%id%][voting]" %voting%/></td><td class="st"><input type="checkbox" name="media_info[%id%][image]" %image%/></td><td class="st"><input type="checkbox" name="media_info[%id%][audio]" %audio%/></td><td class="st"><input type="checkbox" name="media_info[%id%][release]" %release%/></td><td><div class="ui-corner-all ui-state-error" title="Remove file"><a rel="remove-media-file" href="#" id="%id%" class="ui-icon ui-icon-trash"></a></div></td></tr>';

			form.find('*[id="media-list-rows"]').empty();
			$.each(response.aaData, function(i, r){
				var tpl = rowTemplate.replace(/%id%/g, r.id);
				tpl = tpl.replace(/%type%/g, r.type); 
				tpl = tpl.replace(/%url%/g, r.url);
				tpl = tpl.replace(/%posted_str%/g, r.posted_str);
				tpl = tpl.replace(/%posted_username%/g, r.posted_username);
				tpl = tpl.replace('%filesize_str%', r.filesize_str);
				tpl = tpl.replace('%image_size%', r.image_size);
				tpl = tpl.replace('%icon%', r.icon);
				tpl = tpl.replace('%basename%', r.basename);
				tpl = tpl.replace('%screenshot%', r.is_screenshot == '1' ? ' checked="checked"' : '');
				tpl = tpl.replace('%voting%', r.is_voting == '1' ? ' checked="checked"' : '');
				tpl = tpl.replace('%image%', r.is_image == '1' ? ' checked="checked"' : '');
				tpl = tpl.replace('%audio%', r.is_audio == '1' ? ' checked="checked"' : '');
				tpl = tpl.replace('%release%', r.is_release == '1' ? ' checked="checked"' : '');
				
				form.find('*[id="media-list-rows"]').append(tpl);
			});

			form.find('input:not(.uniformed)').uniform().addClass('uniformed');

			if ($.colorbox) {
				form.find('a[type="image"]').colorbox({ maxWidth:'96%', maxHeight:'96%', current: '', transition: 'none', fadeOut: 0 });
			}

			form.find('*[id="media-list"]').show();
			$(document).trigger('refresh');
					
		}, 'json');
	});

	$(document).off('click', 'a[rel="remove-media-file"]').on('click', 'a[rel="remove-media-file"]', function(){
		if (!confirm('Remove file?')) return false;

		var currentForm = $(this).closest('form');
		var file_id = $(this).attr('id');
		$.post('<?php echo NFW::i()->base_path.'media.php?action=remove&owner_class='.$owner_class.'&owner_id='.$owner_id?>', { 'file_id': file_id }, function(){
			currentForm.trigger('load');
		});
		
		return false;
	});
	
	$(window).on('beforeunload', function() {
		$.removeCookie('<?php echo $session_id?>', { path: '/' })
	});
	
	form.trigger('load');


	// Save setting
	$('button[id="media-manage-save"]').click(function(){
		$.post('<?php echo NFW::i()->base_path.'admin/works?action=media_manage&record_id='.$owner_id?>', form.serialize(), function(response){
			$(document).trigger('uiDialog', response.message);
		}, 'json');
	});
});
</script>
<style>
	table#media-list td { vertical-align: middle; }
	table#media-list div.info { padding-top: 5px; font-style: italic; color: #777; }
	table#media-list td.st, table#media-list th.st { min-width: 50px; text-align: center; }
	table#media-list img.icon { float: left; padding-right: 6px; }

	form#<?php echo $session_id?> { margin-bottom: 1em; }
	form#<?php echo $session_id?> div.uploader { width: 290px; }
	form#<?php echo $session_id?> div.uploader span.filename { width: 185px; }
	form#<?php echo $session_id?> div.checkere { top: 0; }
	form#<?php echo $session_id?> div.info-block { margin-left: 300px; width: 300px; font-size: 85% }
</style>

<form id="<?php echo $session_id?>" action="<?php echo NFW::i()->base_path.'media.php?action=upload'?>" enctype="multipart/form-data">
	<input type="hidden" name="owner_id" value="<?php echo $owner_id?>" />
	<input type="hidden" name="owner_class" value="<?php echo $owner_class?>" />
	<input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $MAX_FILE_SIZE?>" />
	
	<div style="float: left;">
		<input type="file" name="local_file" class="uniformed" />
		<div rel="error-info" id="local_file" class="error-info"></div>
	</div>
		
	<?php ob_start(); ?>
	<div><?php echo $lang_media['MaxFileSize']?>: <strong><?php echo number_format($MAX_FILE_SIZE / 1048576, 2, '.', ' ')?><?php echo $lang_media['mb']?></strong></div>
	<div><?php echo $lang_media['MaxSessionSize']?>: <strong><?php echo number_format($MAX_SESSION_SIZE / 1048576, 2, '.', ' ')?><?php echo $lang_media['mb']?></strong></div>
	<?php if (!$owner_id): ?>
		<div><?php echo $lang_media['CurrentSessionSize']?>: <strong><span id="session_size">0</span><?php echo $lang_media['mb']?></strong></div>
	<?php endif; ?>
	<?php $info_text = ob_get_clean(); ?>
	<div class="info-block">
		<?php echo ui_message(array('text' => $info_text))?>
	</div>
	<div style="clear: both;"></div>
    
	<table id="media-list" class="main-table" style="display: none;">
		<thead>
			<tr>
				<th>&nbsp;</th>
				<th style="width: 100%;">&nbsp;</th>
				<th class="st">Screenshot</th>
				<th class="st">Voting</th>
				<th class="st">Image</th>
				<th class="st">Audio</th>
				<th class="st">Release</th>
				<th>&nbsp;</th>
			</tr>
		</thead>
		<tbody id="media-list-rows"></tbody>
	</table>
</form>

<div class="ui-widget ui-widget-content ui-corner-all" style="float: right; font-size: 90%; padding: 10px;">
	<strong>screenshot:</strong> screenshot in work profile<br />
	<strong>voting:</strong> download link on voting page<br />
	<strong>image:</strong> voting-image<br />
	<strong>audio:</strong>	files for audio player (mp3 &amp; ogg)<br />
	<strong>release:</strong> include this file in release pack (standalone files or zip-archive)
</div>
<div style="float: left;">
	<button id="media-manage-save" class="nfw-button" icon="ui-icon-disk">Save media settings</button>
</div>
<div style="clear: both;"></div>