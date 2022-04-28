<?php
/**
 * @var string $session_id
 * @var integer $owner_id
 * @var string $owner_class
 * @var integer $MAX_FILE_SIZE
 * @var integer $MAX_SESSION_SIZE
 */
NFW::i()->registerResource('jquery.blockUI');	// too long requests

$lang_media = NFW::i()->getLang('media');
$lang_main = NFW::i()->getLang('main');
?>
<script type="text/javascript">
$(document).ready(function(){
    const form = $('form[id="<?php echo $session_id?>"]');
    const submitAvailable = $('*[data-role="submit-available"]');

    form.activeForm({
		success: function() {
			form.resetForm().trigger('cleanErrors').trigger('load');
		}
	});

	form.find('input[name="local_file"]').change(function() {
		form.submit();
    });
		
	form.bind('load', function(){
		$.get("<?php echo NFW::i()->base_path.'media.php?action=list&session_id='.$session_id.'&ts='?>" + new Date().getTime(), function(response){
			if (response['iTotalRecords'] === 0) {
                submitAvailable.hide();
				return false;
			}

			form.find('*[id="session_size"]').text(response['iSessionSize_str']);
			form.find('*[id="media-list-rows"]').empty();

			const rowTemplate = '<tr><td style="white-space: nowrap;"><a href="%url%" target="_blank"><img src="%icon%" title="%basename%" /></a></td><td style="width: 100%;"><a href="%url%" target="_blank">%basename%</a></td><td style="white-space: nowrap;"><a rel="remove-media-file" href="#" id="%id%" class="btn btn-sm btn-danger" title="<?php echo $lang_media['Remove']?>"><span class="fa fa-times"></span></a></td>';
			
			$.each(response.aaData, function(i, r){
                let tpl = rowTemplate.replace(/%id%/g, r.id);
                tpl = tpl.replace(/%basename%/g, r.basename);
				tpl = tpl.replace(/%url%/g, r.url);
				tpl = tpl.replace('%icon%', r.icon_medium); 
				form.find('*[id="media-list-rows"]').append(tpl);
			});

			// Show submit block
            submitAvailable.show();
            const scrollTo = $('*[data-role="submit-available"]:last').offset().top - 128;
            $('html, body').animate({ scrollTop: scrollTo }, 500);
		}, 'json');
	});

	$(document).off('click', 'a[rel="remove-media-file"]').on('click', 'a[rel="remove-media-file"]', function(){
        const file_id = $(this).attr('id');
        $.post('<?php echo NFW::i()->base_path?>media.php?action=remove', { 'file_id': file_id }, function(){
			form.trigger('load');
		});
		
		return false;
	});

    submitAvailable.hide();
});
</script>
<form id="<?php echo $session_id?>" action="<?php echo NFW::i()->base_path.'media.php?action=upload&session_id='.$session_id?>" enctype="multipart/form-data"><fieldset>
	<legend><?php echo $lang_main['works add files']?></legend>
	<input type="hidden" name="owner_id" value="<?php echo $owner_id?>" />
	<input type="hidden" name="owner_class" value="<?php echo $owner_class?>" />
	<input type="hidden" name="MAX_FILE_SIZE" value="<?php echo $MAX_FILE_SIZE?>" />
	
	<div class="form-group" id="local_file">
		 <div class="col-md-6">
		 	<input type="file" name="local_file" />
		 	<span class="help-block"></span>
		 </div>
		<div class="col-md-6">
			<div class="alert alert-warning dm-alert-cond">
				<p><?php echo $lang_media['MaxFileSize']?>: <strong><?php echo number_format($MAX_FILE_SIZE / 1048576, 2, '.', ' ')?>Mb</strong></p>
				<p><?php echo $lang_media['MaxSessionSize']?>: <strong><?php echo number_format($MAX_SESSION_SIZE / 1048576, 2, '.', ' ')?>Mb</strong></p>
				<p><?php echo $lang_media['CurrentSessionSize']?>: <strong><span id="session_size">0</span>Mb</strong></p>
			</div>
		</div>
	</div>
	
	<div data-role="submit-available">
		<table id="media-list" class="table table-striped table-condensed table-hover">
			<thead>
				<tr>
					<th></th>
					<th><?php echo $lang_media['File']?></th>
					<th></th>
				</tr>
			</thead>
			<tbody id="media-list-rows"></tbody>
		</table>
	</div>
</fieldset></form>