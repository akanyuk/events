<?php
/**
 * @var object $Module
 * @var array $owner
 *
 * @var string $session_id
 * @var integer $owner_id
 * @var string $owner_class
 * @var integer $MAX_FILE_SIZE
 * @var integer $MAX_SESSION_SIZE
 * @var integer $image_max_x
 * @var integer $image_max_y
 */

NFW::i()->registerResource('jquery.file-upload');
$lang_media = NFW::i()->getLang('media');

// Calculate session size
$session_size = 0;
foreach ($owner['media_info'] as $record) {
	$session_size += $record['filesize'];
}
?>
<script>
$(function () {
    const form = $('form[id="<?php echo $session_id?>"]');
    const mediaContainer = form.find('#media-list');
    const propertiesDialog = $('#<?php echo $session_id?>-properties-dialog');

    form.trigger('reset');
	
	form.find('input[type="file"]').fileupload({
        dataType: 'json',
        dropZone: form.find('#dropzone'),
		add: function (e, data) {
			$.each(data.files, function (index, file) {
				form.find('#uploading-status').show();	// show log
				form.find('#uploading-status > p').slice(0, -5).remove();	// reduce log
				data.context = $('<p/>').html('<div class="status"><span class="fa fa-spinner"></span></div><div class="log"><?php echo $lang_media['Uploading']?>: ' + file.name + '</div>').appendTo(form.find('#uploading-status'));
			});
			
			data.submit();
		},    
        done: function (e, data) {
            const response = data.result;

            data.context.find('.status').remove();	// remove spinner
            
            if (response.result === 'error') {
            	data.context.append('<div class="text-danger error">' + response.last_message + '</div>');
                return;
            }

            data.context.prepend('<div class="text-success status"><span class="fa fa-check"></span></div>');

            mediaContainer.appendRow(response);
            
            form.find('*[id="session-size"]').text(number_format(response.iSessionSize/1048576, 2, '.', ' '));
        }
    });

 	// Sortable `media`
	mediaContainer.sortable({
		items: 'div[role="record"]', 
		axis: 'y',
		update: function() {
            const aPositions = [];
            let iCurPos = 1;
            mediaContainer.find('[role="record"]').each(function(){
 				aPositions.push({ 'id': $(this).attr('id'), 'position': iCurPos++ });
 			});

			$.post('<?php echo NFW::i()->base_path.'media.php?action=sort&session_id='.$session_id?>', { 'positions': aPositions }, function(response){
				if (response !== 'success') {
					alert(response);
				}
				return false;
 			});
		}
	});

	mediaContainer.appendRow = function(data) {
        let tpl = form.find('#record-template').html();

        tpl = tpl.replace(/%id%/g, data.id);
		tpl = tpl.replace(/%basename%/g, data.basename);
		tpl = tpl.replace(/%filesize%/g, data.filesize_str);
		tpl = tpl.replace(/%type%/g, data.type); 
		tpl = tpl.replace(/%url%/g, data.url);
		tpl = tpl.replace(/%comment%/g, data.comment);
		tpl = tpl.replace(/%posted%/g, data.posted);
		tpl = tpl.replace(/%posted_username%/g, data.posted_username);
		tpl = tpl.replace(/%posted_str%/g, formatDateTime(data.posted, true, true));

		if (data.type === 'image') {
			tpl = tpl.replace(/%iconsrc%/g, 'src="' + data.tmb_prefix + '64x64-cmp.' + data.extension + '"');
		}
		else {
			tpl = tpl.replace(/%iconsrc%/g, 'src="' + data.icons['64x64'] + '"');
		}
		
		mediaContainer.append(tpl);
	};
 	
	// Properties buttons
	$(document).on('click', '[role="<?php echo $session_id?>-prop"]', function(){
		$(this).hasClass('active') ? $(this).removeClass('active btn-info') : $(this).addClass('active btn-info');

		// Only one screenshot allowed		
		if ($(this).attr('id') === 'screenshot') {
			$('[role="<?php echo $session_id?>-prop"][id="screenshot"]').not($(this)).removeClass('active btn-info');
		}
		
		$(this).blur(); 

		// Save properties immediately
		var aPost = [];
		mediaContainer.find('[role="record"]').each(function(){
			aPost.push({ 
				'id': $(this).attr('id'),
				'screenshot': $(this).find('button[id="screenshot"].active').length,
				'voting': $(this).find('button[id="voting"].active').length,
				'image': $(this).find('button[id="image"].active').length,
				'audio': $(this).find('button[id="audio"].active').length,
				'release': $(this).find('button[id="release"].active').length
			});
		});

		$.post('<?php echo NFW::i()->base_path.'admin/works_media?action=update_properties&record_id='.$owner_id?>', { 'media': aPost }, function(response){
			if (response !== 'success') {
				alert(response);
			}
			return false;
		});
		
	});	

	// File properties dialog
	
	propertiesDialog.modal({ 'show': false });

	$(document).on('click', '[role="<?php echo $session_id?>-file-properties"]', function(){
		if ($(this).data('type') === 'image') {
			propertiesDialog.find('#type-image').show();
			propertiesDialog.find('#type-file').hide();
		} else {
			propertiesDialog.find('#type-image').hide();
			propertiesDialog.find('#type-file').show();
		}

        const recordID = $(this).closest('[role="record"]').attr('id');

        propertiesDialog.find('[id="preview"]').attr('src', $(this).attr('href'));
		propertiesDialog.find('[id="url"]').html('<a href="' + $(this).attr('href') + '" target="_blank">' + $(this).data('basename') + '</a>');
		propertiesDialog.find('[id="filesize"]').text($(this).data('filesize'));
		propertiesDialog.find('[id="posted"]').text(formatDateTime($(this).data('posted'), true, true));

		propertiesDialog.find('[name="record_id"]').val(recordID);
		propertiesDialog.find('[name="basename"]').val($(this).data('basename'));
		propertiesDialog.find('[name="comment"]').val( $(this).closest('[role="record"]').find('#comment').text());				

		// ZX Spectrum screen converter
		mcF.resetForm().trigger('cleanErrors');
		mcF.find('input[name="file_id"]').val(recordID);
			
		propertiesDialog.modal('show');
		return false;
	});

	propertiesDialog.find('form[role="update"]').each(function(){
 		$(this).activeForm({
 	 		action: '<?php echo NFW::i()->base_path?>media.php?action=update&record_id=' + propertiesDialog.data('record-id'),
 			success: function(response) {
                const oRow = mediaContainer.find('[role="record"][id="' + propertiesDialog.find('[name="record_id"]').val() + '"]');
                oRow.find('#comment').text(response.comment);
 				oRow.find('[id="basename"]').text(response.basename);
 				oRow.find('a[role="<?php echo $session_id?>-file-properties"]').attr('href', response.url);
 				oRow.find('a[role="<?php echo $session_id?>-file-properties"]').data('basename', response.basename); 

 				propertiesDialog.modal('hide');	 			
 			}
 		});
	});


	propertiesDialog.find('[role="save"]').click(function(){
		propertiesDialog.find('form[role="update"]:visible').submit();
		return false;
	});
		
	propertiesDialog.find('[role="delete"]').click(function(){
        const recordID = propertiesDialog.find('[name="record_id"]').val();
        if (!recordID) return;
		
		if (!confirm('<?php echo $lang_media['Remove confirm']?>')) return false;

		$.post('<?php echo NFW::i()->base_path?>media.php?action=remove', { 'file_id': recordID }, function(response){
			if (response !== 'success') {
				alert(response);
				return;
			}
			
			mediaContainer.find('[role="record"][id="' + recordID + '"]').remove();
			propertiesDialog.modal('hide');
		});
		
		return false;
	});

	// ZX Spectrum screen converter
	const mcF = propertiesDialog.find('form[id="media-convert-zx"]');
	mcF.activeForm({
		'success': function(response) {
			mediaContainer.appendRow(response);
			propertiesDialog.modal('hide');
		}
	});

	// file_id.diz
	form.find('button[id="file_id.diz"]').click(function(){
		$.post('<?php echo NFW::i()->base_path.'admin/works_media?action=file_id_diz&record_id='.$owner_id?>',  function(response) {
			if (response.result !== 'success') {
				alert(response['last_message']);
				return;
			}
				
			mediaContainer.appendRow(response);
		}, 'json');

		return false;
	});
	
	
	// DropZones for multiple forms
	
	$(document).bind('dragover', function (e) {
        const dropZones = $('.dropzone');
        const timeout = window.dropZoneTimeout;

        if (timeout) {
			clearTimeout(timeout);
		} else {
			dropZones.addClass('in');
		}

        const hoveredDropZone = $(e.target).closest(dropZones);

        dropZones.not(hoveredDropZone).removeClass('hover');

		hoveredDropZone.addClass('hover');
		
		window.dropZoneTimeout = setTimeout(function () {
			window.dropZoneTimeout = null;
			dropZones.removeClass('in hover');
		}, 100);
	});

	$('form[id="make-release"]').activeForm({
		'action': '<?php echo NFW::i()->base_path.'admin/works_media?action=make_release&record_id='.$owner_id?>',
		'success': function(response) {
            const sUrl = decodeURIComponent(response.url);
            $('span[id="permanent-link"]').html('<a href="' + sUrl + '">' + sUrl + '</a>');
			$('button[id="media-remove-release"]').show();
		}
	});
	
	$('button[id="media-remove-release"]').click(function(){
		if (!confirm('Remove release file?')) return false;
		
		$.post('<?php echo NFW::i()->base_path.'admin/works_media?action=remove_release&record_id='.$owner_id?>', function(response) {
			if (response !== 'success') {
				alert(response);
			}
			else {
				$('span[id="permanent-link"]').html('<em>none</em>');
				$('button[id="media-remove-release"]').hide();
				$.jGrowl('File removed.');
			}
		});

		return false;
	});
});
</script>
<style>
	FORM#<?php echo $session_id?> .dropzone { display: none; background-color: #b6efb6; border-color: #769e84; padding-top: 50px; padding-bottom: 50px; text-align: center; font-weight: bold; }
	FORM#<?php echo $session_id?> .dropzone.in { display: block; }
	FORM#<?php echo $session_id?> .dropzone.hover { display: block; background: #46af46; }
	FORM#<?php echo $session_id?> .dropzone.fade { -webkit-transition: all 0.3s ease-out; -moz-transition: all 0.3s ease-out; -ms-transition: all 0.3s ease-out; -o-transition: all 0.3s ease-out; transition: all 0.3s ease-out; opacity: 1;	}

	FORM#<?php echo $session_id?> .uploading-status { margin-top: 20px; background-color: #f4f4f4; border: 1px solid #cacaca; border-radius: 4px; padding: 10px; }
	FORM#<?php echo $session_id?> .uploading-status .log { white-space: nowrap; overflow: hidden; margin-right: 20px; font-size: 14px; }
	FORM#<?php echo $session_id?> .uploading-status .status { float: right; position: absolute; right: 24px; }
	FORM#<?php echo $session_id?> .uploading-status .error { overflow: auto; white-space: normal; font-size: 90%; }

	@media (max-width: 768px) {
		LABEL[for="<?php echo $session_id?>-upload-button"] {
			display: block; width: 100%;
		}
	}
	
	FORM#<?php echo $session_id?> #media-list { padding-bottom: 20px; }
	FORM#<?php echo $session_id?> #media-list .cell-i { padding-left: 10px; min-width: 74px; }
	FORM#<?php echo $session_id?> #media-list .cell-f { width: 100%; padding: 5px 10px; }
	FORM#<?php echo $session_id?> #media-list .cell-settings { min-width: 280px; white-space: nowrap; text-align: right; padding-right: 10px; }	
	
	@media (max-width: 768px) {
		FORM#<?php echo $session_id?> #media-list .cell { display: inline-block; }
		FORM#<?php echo $session_id?> #media-list .cell-i { vertical-align: top; padding-top: 10px; }
		FORM#<?php echo $session_id?> #media-list .cell-f { width: inherit; max-width: 230px; overflow: hidden; }
		FORM#<?php echo $session_id?> #media-list .cell-f .info { font-size: 12px; color: #999; }
		FORM#<?php echo $session_id?> #media-list .cell-settings { text-align: left; padding-bottom: 20px; padding-left: 90px; padding-top: 0; }
		FORM#<?php echo $session_id?> #media-list .cell-settings .btn-group > .btn { padding: 5px 10px; font-size: 15px; }
	}
		
	DIV[id="<?php echo $session_id?>-properties-dialog"] .preview-container { text-align: center; }
	
	DIV[id="<?php echo $session_id?>-properties-dialog"] #preview { max-height: 600px; max-width: 600px; }
	@media (max-width: 768px) {
		DIV[id="<?php echo $session_id?>-properties-dialog"] #preview { max-height: 256px; max-width: 256px; }
	}
	DIV[id="<?php echo $session_id?>-properties-dialog"] FORM[role="update"] LABEL { padding-top: 0; margin-bottom: 0; }
</style>

<div id="<?php echo $session_id?>-properties-dialog" class="modal fade">
	<div class="modal-dialog modal-lg">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title"><?php echo $lang_media['File properties']?></h4>
			</div>
			
			<div class="modal-body" id="type-image">
				<div class="row">
					<div class="col-md-9 preview-container"><img id="preview" alt="" /></div>
					<div class="col-md-3">
						<form role="update" class="active-form">
							<input type="hidden" name="record_id" />
							
							<div class="form-group">
								<label><strong><?php echo $lang_media['File']?></strong></label>
								<div id="url"></div>
							</div>

							<div class="form-group">
								<label><strong><?php echo $lang_media['Filesize']?></strong></label>
								<div id="filesize"></div>	
							</div>

							<div class="form-group">
								<label><strong><?php echo $lang_media['Uploaded']?></strong></label>
								<div id="posted"></div>	
							</div>

                            <div class="form-group">
                                <a role="delete" href="#" class="text-danger"><span class="fa fa-times"></span> <?php echo $lang_media['Delete']?></a>
                            </div>

							<?php echo active_field(array('name' => 'basename', 'attributes'=>$Module->attributes['basename'], 'desc' => $lang_media['Filename'], 'vertical' => true))?>
							<?php echo active_field(array('name' => 'comment', 'attributes'=>$Module->attributes['comment'], 'desc' => $lang_media['Comment'], 'vertical' => true))?>
						</form>
					</div>
				</div>
			</div>
			
			<div class="modal-body" id="type-file">
				<form role="update" class="form-horizontal active-form">
					<input type="hidden" name="record_id" />
				
					<div class="form-group">
						<label for="title" class="col-md-2 control-label"><strong><?php echo $lang_media['File']?></strong></label>
						<div class="col-md-10">
							<div id="url"></div>
						</div>
					</div>

					<div class="form-group">
						<label for="title" class="col-md-2 control-label"><strong><?php echo $lang_media['Filesize']?></strong></label>
						<div class="col-md-10">
							<div id="filesize"></div>
						</div>			
					</div>

					<div class="form-group">
						<label for="title" class="col-md-2 control-label"><strong><?php echo $lang_media['Uploaded']?></strong></label>
						<div class="col-md-10">
							<div id="posted"></div>
						</div>			
					</div>

                    <div class="form-group">
                        <div class="col-md-10 col-md-offset-2">
                            <a role="delete" href="#" class="text-danger"><span class="fa fa-times"></span> <?php echo $lang_media['Remove']?></a>
                        </div>
                    </div>

					<?php echo active_field(array('name' => 'basename', 'attributes'=>$Module->attributes['basename'], 'desc' => $lang_media['Filename']))?>
					<?php echo active_field(array('name' => 'comment', 'attributes'=>$Module->attributes['comment'], 'desc' => $lang_media['Comment']))?>
				</form>
				
				<form id="media-convert-zx" class="form-inline" action="<?php echo NFW::i()->base_path.'admin/works_media?action=convert_zx&record_id='.$owner_id?>">
					<input name="file_id" type="hidden" value="0" />
				
					<fieldset>
						<legend><small>ZX Spectrum screen converter</small></legend>
					
						<div class="form-group">
							<label for="border_color">Border</label>
							<select name="border_color" class="form-control">
								<option value="none">no border</option>
								<option value="0" style="background-color: #000000;" selected="selected">black</option>
								<option value="1" style="background-color: #0000cc;">blue</option>
								<option value="2" style="background-color: #cc0000;">red</option>
								<option value="3" style="background-color: #cc00cc;">magenta</option>
								<option value="4" style="background-color: #00cc00;">green</option>
								<option value="5" style="background-color: #00cccc;">cyan</option>
								<option value="6" style="background-color: #cccc00;">yellow</option>
								<option value="7" style="background-color: #cccccc;">white</option>
							</select>
						</div>					

						<button type="submit" name="output_type" value="png" class="btn btn-info">Convert to PNG</button>
						<button type="submit" name="output_type" value="gif" class="btn btn-info">Convert to GIF</button>
				    </fieldset>
				</form>
			</div>

			<div class="modal-footer">
				<button role="save" type="button" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
				<button type="button" class="btn btn-default" data-dismiss="modal"><?php echo NFW::i()->lang['Close']?></button>
			</div>
		</div>
	</div>
</div>
	
<form id="<?php echo $session_id?>" action="<?php echo NFW::i()->base_path.'media.php?action=upload&session_id='.$session_id?>" method="POST" enctype="multipart/form-data">
	<input type="hidden" name="owner_id" value="<?php echo $owner_id?>" />
	<input type="hidden" name="owner_class" value="<?php echo $owner_class?>" />
	<input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $MAX_FILE_SIZE?>" />

	<div id="record-template" style="display: none;">
		<div id="%id%" role="record" class="record">
			<div id="comment" style="display: none;">%comment%</div>
			<div class="cell cell-i">
				<a role="<?php echo $session_id?>-file-properties" href="%url%" data-type="%type%" data-basename="%basename%" data-posted="%posted%" data-filesize="%filesize%">
					<img <?php echo '%iconsrc%'?> alt="" />
				</a>
			</div>
			<div class="cell cell-f">
				<a role="<?php echo $session_id?>-file-properties" href="%url%" data-type="%type%" data-basename="%basename%" data-posted="%posted%" data-filesize="%filesize%">
					<strong id="basename">%basename%</strong>
				</a>
				<div class="info">
					<div>Uploaded: %posted_str% by %posted_username%</div>
					<div>Filesize: %filesize%</div>
				</div>
			</div>
			<div class="cell cell-settings">
				<div class="btn-group btn-group-lg" role="group">
					<button role="<?php echo $session_id?>-prop" id="screenshot" type="button" class="btn btn-default" title="screenshot"><span class="fa fa-camera"></span></button>
					<button role="<?php echo $session_id?>-prop" id="image" type="button" class="btn btn-default" title="image"><span class="fa fa-image"></span></button>
					<button role="<?php echo $session_id?>-prop" id="audio" type="button" class="btn btn-default" title="audio"><span class="fa fa-headphones"></span></button>
					<button role="<?php echo $session_id?>-prop" id="voting" type="button" class="btn btn-default" title="voting"><span class="fa fa-poll"></span></button>
					<button role="<?php echo $session_id?>-prop" id="release" type="button" class="btn btn-default" title="release"><span class="fa fa-file-archive"></span></button>
				</div>
			</div>
		</div>
	</div>

	<div class="row">
		<div class="col-md-8">
			<div class="row">
				<div id="media-list" class="settings">
<?php 
foreach ($owner['media_info'] as $record) {
	if ($record['type'] == 'image') {
		list($width, $height) = getimagesize($record['fullpath']);
		$record['image_size'] = '['.$width.'x'.$height.']';
		$record['icon'] = $record['tmb_prefix'].'64';
	}
	else {
		$record['image_size'] = '';
		$record['icon'] = $record['icons']['64x64'];
	}
?>
<div id="<?php echo $record['id']?>" role="record" class="record">
	<div id="comment" style="display: none;"><?php echo htmlspecialchars($record['comment'])?></div>
	
	<div class="cell cell-i">
		<a role="<?php echo $session_id?>-file-properties" href="<?php echo $record['url']?>" data-type="<?php echo $record['type']?>" data-basename="<?php echo $record['basename']?>" data-posted="<?php echo $record['posted']?>" data-filesize="<?php echo $record['filesize_str']?>">
			<img src="<?php echo $record['icon']?>" />
		</a>
	</div>
	<div class="cell cell-f">
		<a role="<?php echo $session_id?>-file-properties" href="<?php echo $record['url']?>" data-type="<?php echo $record['type']?>" data-basename="<?php echo $record['basename']?>" data-posted="<?php echo $record['posted']?>" data-filesize="<?php echo $record['filesize_str']?>">
			<strong id="basename"><?php echo $record['basename']?></strong>
		</a>
		<div class="info">
			<div>Uploaded: <?php echo date('d.m.Y H:i', $record['posted'])?> by <?php echo $record['posted_username']?></div>
			<div>Filesize: <?php echo $record['filesize_str']?> <?php echo $record['image_size']?></div>
		</div>
	</div>
	<div class="cell cell-settings">
		<div class="btn-group btn-group-lg" role="group">
			<button role="<?php echo $session_id?>-prop" id="screenshot" type="button" class="btn btn-default<?php echo $record['is_screenshot'] ? ' btn-info active' : ''?>" title="screenshot"><span class="fa fa-camera"></span></button>
			<button role="<?php echo $session_id?>-prop" id="image" type="button" class="btn btn-default<?php echo $record['is_image'] ? ' btn-info active' : ''?>" title="image"><span class="fa fa-image"></span></button>
			<button role="<?php echo $session_id?>-prop" id="audio" type="button" class="btn btn-default<?php echo $record['is_audio'] ? ' btn-info active' : ''?>" title="audio"><span class="fa fa-headphones"></span></button>
			<button role="<?php echo $session_id?>-prop" id="voting" type="button" class="btn btn-default<?php echo $record['is_voting'] ? ' btn-info active' : ''?>" title="voting"><span class="fa fa-poll"></span></button>
			<button role="<?php echo $session_id?>-prop" id="release" type="button" class="btn btn-default<?php echo $record['is_release'] ? ' btn-info active' : ''?>" title="release"><span class="fa fa-file-archive"></span></button>
		</div>
	</div>
</div>
<?php 
	} 
?>
				</div>  
			</div>
			
			<div id="dropzone" class="fade well dropzone"><?php echo $lang_media['Messages']['Dropzone']?></div>
		</div>
		<div class="col-md-4">
			<div class="alert alert-info alert-cond alert-dismisable" role="alert">
				<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
				<small>					
					<span class="fa fa-camera"></span>&nbsp; screenshot in work profile and social sharing<br />
					<span class="fa fa-image"></span>&nbsp; image on work page (can be multiple)<br />
					<span class="fa fa-headphones"></span>&nbsp; files for audio player (mp3 &amp; ogg)<br />
					<span class="fa fa-poll"></span>&nbsp; download link during voting<br />
					<span class="fa fa-file-archive"></span>&nbsp; download link after voting (include this file in release)
				</small>
			</div>
		
			<div class="alert alert-warning alert-cond alert-dismisable" role="alert">
				<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
				<p><?php echo $lang_media['MaxFileSize']?>: <strong><?php echo number_format($MAX_FILE_SIZE/1048576, 2, '.', ' ').$lang_media['mb']?></strong></p>
				<p><?php echo $lang_media['MaxSessionSize']?>: <strong><?php echo number_format($MAX_SESSION_SIZE/1048576, 2, '.', ' ').$lang_media['mb']?></strong></p>
				<p><?php echo $lang_media['CurrentSessionSize']?>: <strong><span id="session-size"><?php echo number_format($session_size/1048576, 2, '.', ' ')?></span><?php echo $lang_media['mb']?></strong></p>
				<?php if ($image_max_x && $image_max_y):?>
				<p><?php echo $lang_media['MaxImageSize']?>: <strong><?php echo $image_max_x.'x'.$image_max_y?>px</strong></p>
				<?php endif; ?>
			</div>
			
			<label for="<?php echo $session_id?>-upload-button">
      			<span class="btn btn-success btn-lg btn-full-xs"><span class="fa fa-folder-open" aria-hidden="true"></span> <?php echo $lang_media['Upload files']?></span>
				<input type="file" name="local_file" id="<?php echo $session_id?>-upload-button" style="display:none" multiple />
			</label>
			
			<button id="file_id.diz" class="btn btn-primary btn-lg btn-full-xs"><span class="fa fa-file-text"></span> Generate `file_id.diz`</button>
			
			<div id="uploading-status" class="uploading-status" style="display: none;"></div>
		</div>
	</div>
</form>

<form id="make-release" class="form-inline" style="padding-top: 20px;">
	<fieldset>
		<legend>Permanent link: </legend>
		<span id="permanent-link"><?php echo $owner['release_link'] ? '<a href="'.$owner['release_link']['url'].'">'.$owner['release_link']['url'].'</a>' : '<em>none</em>'?></span>
		
		<div class="form-group">
			<button id="media-remove-release"  class="btn btn-sm btn-danger btn-full-xs" <?php echo $owner['release_link'] ? '' : 'style="display: none;"'?> title="Delete file"><span class="hidden-xs"><span class="fa fa-times"></span></span><span class="hidden-sm hidden-md hidden-lg"> Delete file</span></button>
		</div>
		
		<div class="clearfix" style="padding-top: 10px;"></div>
		
		<div class="form-group">
			<div class="input-group">
				<input type="text" class="form-control" name="release_basename" placeholder="filename" value="<?php echo NFW::i()->safeFilename($owner['title'])?>">
				<div class="input-group-addon">.zip</div>
			</div>
		</div>
		<button class="btn btn-primary btn-full-xs"><span class="fa fa-save"></span> Generate new permanent archive</button>
	</fieldset>
</form>
