<?php
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->registerResource('bootstrap3.typeahead');
	
	NFW::i()->assign('page_title', $Module->lang['Registration']);
	NFW::i()->main_login_form = false;
	
	$lang_main = NFW::i()->getLang('main');
	
	$default_country = $default_city = '';
	if (file_exists(PROJECT_ROOT.'var/SxGeoCity.dat')) {
		require_once(NFW_ROOT.'helpers/SxGeo/SxGeo.php');
		$SxGeo = new SxGeo(PROJECT_ROOT.'var/SxGeoCity.dat');
		if ($geo = $SxGeo->getCityFull($_SERVER['REMOTE_ADDR'])) {
			$default_country = $geo['country']['iso'];
			$default_city = NFW::i()->user['language'] == 'Russian' ? $geo['city']['name_ru'] : $geo['city']['name_en'];
			//$default_city = '';
		}
	}
	
	// Success dialog
	NFW::i()->registerFunction('ui_dialog');
	$succes_dialog = new ui_dialog();
	$succes_dialog->render(array('title' => $Module->lang['Registration complete']));
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="register"]');
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

	var aCities = [];
	<?php foreach ($Module->getCities() as $c) echo 'aCities.push('.json_encode($c).');'."\n";?>
	f.find('input[name="city"]').typeahead({ source: aCities }).attr('autocomplete', 'off');
});
</script>

<form id="register" class="form-horizontal"><fieldset>
	<legend><?php echo $Module->lang['Registration']?></legend>
	<?php echo active_field(array('name' => 'username', 'desc'=> NFW::i()->lang['Login'], 'required' => true))?>
	<?php echo active_field(array('name' => 'email', 'attributes' => $Module->attributes['email']))?>
	<?php echo active_field(array('name' => 'realname', 'attributes' => $Module->attributes['realname']))?>
	<?php echo  empty($Module->attributes['language']['options']) ? '' : active_field(array('name' => 'language', 'attributes' => $Module->attributes['language'], 'value' => NFW::i()->user['language'], 'inputCols' => 6))?>
	<?php echo active_field(array('name' => 'country', 'attributes' => $Module->attributes['country'], 'value' => $default_country, 'inputCols' => 6))?>
	<?php echo active_field(array('name' => 'city', 'attributes' => $Module->attributes['city'], 'value' => $default_city, 'inputCols' => 6))?>

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
			<button type="submit" class="btn btn-primary"><?php echo $Module->lang['Registration send']?></button>
		</div>
	</div>
</fieldset></form>