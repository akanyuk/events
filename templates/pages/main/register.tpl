<?php
	NFW::i()->registerResource('jquery.activeForm');

	require_once(PROJECT_ROOT.'include/helpers/SxGeo/SxGeo.php');
	$SxGeo = new SxGeo(PROJECT_ROOT.'var/SxGeoCity.dat');
	if ($geo = $SxGeo->getCityFull($_SERVER['REMOTE_ADDR'])) {
		$default_country = $geo['country']['iso'];
		//$default_city = NFW::i()->user['language'] == 'Russian' ? $geo['city']['name_ru'] : $geo['city']['name_en'];
		$default_city = '';
	}
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="competitors-register"]');
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
		<h4 class="modal-title"><?php echo $lang_main['register']['label success']?></h4>
	</div>
	<div id="message" class="modal-body"></div>
	<div class="modal-footer">
		<button type="button" class="btn btn-default" data-dismiss="modal">Ok</button>
	</div>
</div></div></div>

<form id="competitors-register" class="form-horizontal" action="?action=send"><fieldset>
	<legend><?php echo $lang_main['register']['label info']?></legend>
	<?php echo active_field(array('name' => 'username', 'attributes' => $attributes['username']))?>
	<?php echo active_field(array('name' => 'email', 'attributes' => $attributes['email']))?>
	<?php echo active_field(array('name' => 'realname', 'attributes' => $attributes['realname']))?>
	<?php echo active_field(array('name' => 'language', 'attributes' => $attributes['language'], 'value' => NFW::i()->user['language']))?>
	<?php echo active_field(array('name' => 'country', 'attributes' => $attributes['country'], 'value' => $default_country))?>
	<?php echo active_field(array('name' => 'city', 'attributes' => $attributes['city'], 'value' => $default_city))?>

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
			<button type="submit" class="btn btn-primary"><?php echo $lang_main['register']['send']?></button>
		</div>
	</div>
</fieldset></form>