<?php
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->assign('page_title', NFW::i()->lang['Authorization']);
    NFWX::i()->main_search_box = false;
    NFWX::i()->main_right_pane = false;

    $lang_main = NFW::i()->getLang('main');
	$lang_users = NFW::i()->getLang('users');
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="login"]');
	f.activeForm({
		success: function(response) {
			if (response.redirect) {
				window.location.href = response.redirect;
			}
			else {
				window.location.reload();
			}
		}
	});
});
</script>
<form id="login" class="form-horizontal"><fieldset>
	<legend><?php echo NFW::i()->lang['Authorization']?></legend>
	
	<?php echo active_field(array('name' => 'username', 'desc'=> NFW::i()->lang['Login'], 'labelCols' => 1, 'inputCols' => 3))?>
	<?php echo active_field(array('name' => 'password', 'type' => 'password', 'desc'=> NFW::i()->lang['Password'], 'labelCols' => 1, 'inputCols' => 3))?>

	<div class="form-group">
		<div class="col-md-7 col-md-offset-1">
			<button name="login" class="btn btn-primary" type="submit"><?php echo NFW::i()->lang['GoIn']?></button>
			&nbsp;<a href="<?php echo NFW::i()->base_path?>users?action=restore_password"><?php echo $lang_users['Restore password']?></a><br />
		</div>
	</div>
	<br />
	<div class="form-group">
		<div class="col-md-7 col-md-offset-1">
			<a class="btn btn-default" href="<?php echo NFW::i()->base_path?>users?action=register"><?php echo $lang_users['Registration']?></a>
		</div>
	</div>
</fieldset></form>