<?php
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->assign('page_title', $Module->lang['Activation']);
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
		<legend><?php echo $Module->lang['Activation']?></legend>
		
		<div class="form-group">
			<label class="col-md-3 control-label"><strong><?php echo $Module->lang['Username']?></strong></label>
			<div class="col-md-9 input-wrapper"><?php echo htmlspecialchars($account['username'])?></div>
		</div>
		
		<div class="form-group">
			<label class="col-md-3 control-label"><strong>E-mail</strong></label>
			<div class="col-md-9 input-wrapper"><?php echo htmlspecialchars($account['email'])?></div>
		</div>
				
		<?php echo active_field(array('name' => 'password', 'type' => 'password', 'desc' => $Module->lang['New_password'], 'required' => true, 'maxlength' => 32, 'inputCols' => 5))?>
		<?php echo active_field(array('name' => 'password2', 'type' => 'password', 'desc' => $Module->lang['Retype_password'], 'required' => true, 'maxlength' => 32, 'inputCols' => 5))?>
	
		<div class="form-group">
			<div class="col-md-9 col-md-offset-3">
				<button type="submit" class="btn btn-primary"><?php echo $Module->lang['Activation send']?></button>
			</div>
		</div>
	</fieldset>
</form>