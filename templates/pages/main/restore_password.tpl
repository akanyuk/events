<?php
	NFW::i()->registerResource('jquery.activeForm');
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
			$('div[id="success-dialog"]').find('div[id="message"]').html(response.message);
			$('div[id="success-dialog"]').modal('show').on('hide.bs.modal', function () {
				window.location.href = '/';
			});
		}
	});
});
</script>
<div id="success-dialog" class="modal fade"><div class="modal-dialog"><div class="modal-content">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h4 class="modal-title"><?php echo $lang_main['register']['restore complete caption']?></h4>
	</div>
	<div id="message" class="modal-body"></div>
	<div class="modal-footer">
		<button type="button" class="btn btn-default" data-dismiss="modal">Ok</button>
	</div>
</div></div></div>

<form id="restore-password" class="form-horizontal"><fieldset>
	<legend><?php echo $lang_main['register']['restore password label']?></legend>
	
	<?php echo active_field(array('name' => 'request_email', 'desc' => 'E-mail', 'required' => true, 'inputCols' => '9'));?>
	
    <div class="form-group" id="captcha">
		<label class="control-label col-md-3" for="captcha"><strong><?php echo $lang_main['register']['captcha']?></strong></label>
		<div class="col-md-9">
			<div class="pull-left" style="width: 100px; margin-right: 0.5em;">
				<input type="text" name="captcha" class="form-control" maxlength="6" />
			</div>
			<div class="pull-left">
				<img id="captcha" src="<?php echo NFW::i()->base_path?>captcha.png" style="border: 1px solid #555;" />
			</div>
			<div class="clearfix"></div>
			<span class="help-block"><?php echo $lang_main['register']['captcha info']?></span>
		</div>
	</div>

	<div class="form-group">
		<div class="col-md-9 col-md-offset-3">
			<div class="alert alert-info"><?php echo $lang_main['register']['restore password info']?></div>
			<button type="submit" class="btn btn-primary"><?php echo $lang_main['register']['restore send']?></button>
			&nbsp;&nbsp;&nbsp;
			<a href="<?php echo NFW::i()->base_path?>register.html"><?php echo $lang_main['register']['registration']?></a>			
		</div>
	</div>
</fieldset></form>