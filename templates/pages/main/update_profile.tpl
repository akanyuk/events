<?php
	NFW::i()->registerResource('jquery.activeForm');

	$CProfile = new profile();
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="update-profile"]');
	f.activeForm({
		'success': function(response) {
			window.location.reload();
		}
	});
});
</script>
<form id="update-profile" class="form-horizontal"><fieldset>
	<legend><?php echo $lang_main['cabinet']['edit profile']?></legend>

	<dl class="dl-horizontal">
	  <dt><?php echo $lang_main['register']['username']?></dt>
	  <dd><?php echo NFW::i()->user['username']?></dd>

	  <dt>E-mail</dt>
	  <dd><?php echo NFW::i()->user['email']?></dd>
	</dl>
<?php
	echo active_field(array('name' => 'realname', 'value' => NFW::i()->user['realname'], 'attributes' => $CProfile->attributes['realname'], 'desc' => $lang_main['register']['realname'], 'inputCols' => '9'));
	echo active_field(array('name' => 'language', 'value' => NFW::i()->user['language'], 'attributes' => $CProfile->attributes['language'], 'desc' => $lang_main['register']['language']));
	echo active_field(array('name' => 'country', 'value' => NFW::i()->user['country'], 'attributes' => $CProfile->attributes['country'], 'desc' => $lang_main['register']['country']));
	echo active_field(array('name' => 'city', 'value' => NFW::i()->user['city'], 'attributes' => $CProfile->attributes['city'], 'desc' => $lang_main['register']['city']));
	echo active_field(array('name' => 'old_password', 'type' => 'password', 'desc' => $lang_main['cabinet']['old-password']));
	echo active_field(array('name' => 'new_password', 'type' => 'password', 'desc' => $lang_main['register']['password']));
	echo active_field(array('name' => 'password2', 'type' => 'password', 'desc' => $lang_main['register']['re-password']));

?>
	<div class="form-group">
		<div class="col-md-9 col-md-offset-3">
			<div class="alert alert-warning"><?php echo $lang_main['cabinet']['do not change password']?></div>
			<button type="submit" class="btn btn-primary"><?php echo $lang_main['cabinet']['save profile']?></button>
		</div>
	</div>
</fieldset></form>