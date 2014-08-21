<?php
	NFW::i()->registerResource('jquery.cookie');
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
		}
	});

	form.find('input[name="local_file"]').change(function() {
		form.trigger('save-comments').submit();
    });
		
	form.bind('load', function(){
		$.get("<?php echo NFW::i()->base_path.'media.php?action=list&owner_class='.$owner_class.'&owner_id='.$owner_id.(NFW::i()->getUI() ? '&ui='.NFW::i()->getUI() : '').'&ts='?>" + new Date().getTime(), function(response){
			if (response.iTotalRecords == 0) {
				form.find('*[id="media-list"]').hide();
				$('button[id="add-work"]').attr('disabled', 'disabled');
				return false;
			}

			form.find('*[id="session_size"]').text(response.iSessionSize_str);
			form.find('*[id="media-list-rows"]').empty();
			
			var rowTemplate = '<tr><td style="white-space: nowrap;"><a href="%url%" target="_blank"><img src="%icon%" title="%basename%" /></a></td><td style="width: 100%;"><input id="%id%" rel="comment" type="text" class="form-control" value="%comment%" /></td><td style="white-space: nowrap;"><a rel="remove-media-file" href="#" id="%id%" class="btn btn-sm btn-danger" title="<?php echo $lang_media['Remove']?>">x</a></td>';
			
			$.each(response.aaData, function(i, r){
				var tpl = rowTemplate.replace(/%id%/g, r.id);
				tpl = tpl.replace('%icon%', r.icon_medium); 
				tpl = tpl.replace('%url%', r.url);
				tpl = tpl.replace('%basename%', r.basename);
				tpl = tpl.replace('%comment%', r.comment);
				form.find('*[id="media-list-rows"]').append(tpl);
			});

			form.find('*[id="media-list"]').show();
			$('button[id="add-work"]').removeAttr('disabled', 'disabled');
					
		}, 'json');
	});

	form.bind('save-comments', function(){
		var commentsArray = [];
		form.find('input[rel="comment"]').each(function(){
			commentsArray.push({ 'file_id': $(this).attr('id'), 'comment': $(this).val() });
		});
		
		if (commentsArray.length) {
			$.ajax({
				type: 'POST', async: false,
				url: '<?php echo NFW::i()->base_path.'media.php?action=update_comment&owner_class='.$owner_class.'&owner_id='.$owner_id?>',
				data: { 'comments': commentsArray }
			});
		}
	});
	
	form.find('button[id="form-submit"]').click(function(){
		form.trigger('save-comments');

		// Close session
		$.post('?action=attachments', { 'close_session': 1 }, function(){
			window.location.reload();
		});

		return false;
	});

	$(document).off('click', 'a[rel="remove-media-file"]').on('click', 'a[rel="remove-media-file"]', function(){
		form.trigger('save-comments');
		
		var file_id = $(this).attr('id');
		$.post('<?php echo NFW::i()->base_path.'media.php?action=remove&owner_class='.$owner_class.'&owner_id='.$owner_id?>', { 'file_id': file_id }, function(){
			form.trigger('load');
		});
		
		return false;
	});

	$(window).on('beforeunload', function() {
		$.removeCookie('<?php echo $session_id?>', { path: '/' })
	});
	
	// Disable main form submiting on open page
	$('button[id="add-work"]').attr('disabled', 'disabled');
});
</script>
<form id="<?php echo $session_id?>" class="form-horizontal" action="<?php echo NFW::i()->base_path.'media.php?action=upload'?>" enctype="multipart/form-data">
	<input type="hidden" name="owner_id" value="<?php echo $owner_id?>" />
	<input type="hidden" name="owner_class" value="<?php echo $owner_class?>" />
	<input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $MAX_FILE_SIZE?>" />
	
	<div class="form-group" id="local_file">
		 <div class="col-md-offset-3 col-md-4">
		 	<input type="file" name="local_file" />
		 	<span class="help-block"></span>
		 </div>
		<div class="col-md-5 alert alert-warning dm-alert-cond">
			<p><?php echo $lang_media['MaxFileSize']?>: <strong><?php echo number_format($MAX_FILE_SIZE / 1048576, 2, '.', ' ')?>Mb</strong></p>
			<p><?php echo $lang_media['MaxSessionSize']?>: <strong><?php echo number_format($MAX_SESSION_SIZE / 1048576, 2, '.', ' ')?>Mb</strong></p>
			<p><?php echo $lang_media['CurrentSessionSize']?>: <strong><span id="session_size">0</span>Mb</strong></p>
		</div>
	</div>
	
	<div class="form-group"><div class="col-md-offset-3 col-md-9">
		<table id="media-list" class="attachments table table-bordered table-striped table-condensed table-hover" style="display: none;">
			<thead>
				<tr>
					<th></th>
					<th><?php echo $lang_media['Comment']?></th>
					<th></th>
				</tr>
			</thead>
			<tbody id="media-list-rows"></tbody>
		</table>
	</div></div>
</form>