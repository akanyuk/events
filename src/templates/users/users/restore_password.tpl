<?php
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->assign('page_title', $Module->lang['Restore password']);
	NFW::i()->main_login_form = false;

	// Success dialog
	NFW::i()->registerFunction('ui_dialog');
	$succes_dialog = new ui_dialog();
	$succes_dialog->render(array('title' => $Module->lang['Restore password']));
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="restore-password"]');
	f.activeForm({
		'beforeSubmit': function(d,f,o) {
			// Reload captcha
			f.find('img[id="captcha"]').attr('src', '<?php echo NFW::i()->base_path?>captcha.png?' +  + Math.floor(Math.random()*10000000));
		},		
		'error': function(response) {
			f.find('input[name="captcha"]').val('');		
		},
		'success': function(response){
			$(document).trigger('show-<?php echo $succes_dialog->getID()?>', [ response.message ]);
		}
	});

	$(document).on('hide-<?php echo $succes_dialog->getID()?>', function(){
		window.location.href = '/';
	});
});
</script>
<form id="restore-password" class="form-horizontal"><fieldset>
	<legend><?php echo $Module->lang['Restore password']?></legend>
	
	<?php echo active_field(array('name' => 'request_email', 'desc' => 'E-mail', 'required' => true, 'inputCols' => '9'));?>
	
    <div class="form-group" data-active-container="captcha">
		<label class="control-label col-md-3" for="captcha"><strong><?php echo NFW::i()->lang['Captcha']?></strong></label>
		<div class="col-md-9">
			<div class="pull-left" style="width: 100px; margin-right: 0.5em;">
				<input type="text" name="captcha" class="form-control" maxlength="6" />
			</div>
			<div class="pull-left">
				<img id="captcha" src="<?php echo NFW::i()->base_path?>captcha.png" style="border: 1px solid #555;" />
			</div>
			<div class="clearfix"></div>
			<span class="help-block"><?php echo NFW::i()->lang['Captcha info']?></span>
		</div>
	</div>

	<div class="form-group">
		<div class="col-md-9 col-md-offset-3">
			<button type="submit" class="btn btn-primary"><?php echo $Module->lang['Restore password send']?></button>
			&nbsp;&nbsp;&nbsp;
			<a href="<?php echo NFW::i()->base_path?>users?action=register"><?php echo $Module->lang['Registration']?></a>			
		</div>
	</div>
</fieldset></form>