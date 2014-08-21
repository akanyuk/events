<?php
	NFW::i()->registerResource('jquery.activeForm');
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="activate"]');
	f.activeForm({
		'success': function(response) {
			window.location.href = '/';
		}
	});
});
</script>
<form id="activate" class="form-horizontal">
	<fieldset>
		<legend><?php echo $lang_main['register']['activation']?></legend>
		<dl class="dl-horizontal">
			<dt><?php echo $lang_main['register']['username']?></dt>
			<dd><?php echo htmlspecialchars($user['username'])?></dd>
			
			<dt>E-mail</dt>
			<dd><?php echo htmlspecialchars($user['email'])?></dd>
		</dl>
	
		<?php echo active_field(array('name' => 'password', 'type' => 'password', 'desc' => $lang_main['register']['password'], 'required' => true, 'maxlength' => 32))?>
		<?php echo active_field(array('name' => 'password2', 'type' => 'password', 'desc' => $lang_main['register']['re-password'], 'required' => true, 'maxlength' => 32))?>
	
		<div class="form-group">
			<div class="col-md-9 col-md-offset-3">
				<button type="submit" class="btn btn-primary"><?php echo $lang_main['register']['activate']?></button>
			</div>
		</div>
	</fieldset>
</form>