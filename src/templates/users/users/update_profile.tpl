<?php
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->registerResource('bootstrap3.typeahead');
	NFW::i()->registerResource('jquery.jgrowl');
	
	NFW::i()->assign('page_title', $Module->lang['My profile']);
	NFW::i()->breadcrumb = array(
		array('desc' => $Module->lang['My profile'])
	);
?>
<script type="text/javascript">
$(document).ready(function(){
	$('form[role="update-profile"]').each(function(){
		$(this).activeForm({
			'success': function(response){
				if (response.is_updated) {
					$.jGrowl(response.message);
				}
			}
		});
	});

	var aCities = [];
	<?php foreach ($Module->getCities() as $c) echo 'aCities.push('.json_encode($c).');'."\n";?>
	$('input[name="city"]').typeahead({ source: aCities }).attr('autocomplete', 'off');
});
</script>

<ul class="nav nav-tabs" role="tablist">
	<li role="presentation" class="active"><a href="#profile" aria-controls="profile" role="tab" data-toggle="tab"><?php echo $Module->lang['Profile tab']?></a></li>
	<li role="presentation"><a href="#password" aria-controls="password" role="tab" data-toggle="tab"><?php echo $Module->lang['Password tab']?></a></li>
</ul>

<div class="tab-content">
	<div role="tabpanel" class="tab-pane in active" id="profile">
		<br />
		<form role="update-profile">
			<fieldset>
				<div class="form-group">
					<label class="col-md-3 control-label"><?php echo $Module->lang['Username']?></label>
					<div class="col-md-9"><p class="form-control-static"><?php echo htmlspecialchars($Module->record['username'])?></p></div>
				</div>
				
				<div class="form-group">
					<label class="col-md-3 control-label">E-mail</label>
					<div class="col-md-9"><p class="form-control-static"><?php echo $Module->record['email']?></p></div>
				</div>

				<?php echo active_field(array('name' => 'realname', 'value' => $Module->record['realname'], 'attributes'=>$Module->attributes['realname']))?>
				<?php echo  empty($Module->attributes['language']['options']) ? '' : active_field(array('name' => 'language', 'value' => $Module->record['language'], 'attributes'=>$Module->attributes['language'], 'inputCols' => 6))?>
				<?php echo active_field(array('name' => 'country', 'value' => $Module->record['country'], 'attributes'=>$Module->attributes['country'], 'inputCols' => 6))?>
				<?php echo active_field(array('name' => 'city', 'value' => $Module->record['city'], 'attributes'=>$Module->attributes['city'], 'inputCols' => 6))?>
		
				<div class="form-group">
					<div class="col-md-9 col-md-offset-3">
						<button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span> <?php echo NFW::i()->lang['Save changes']?></button>
					</div>
				</div>
			</fieldset>
		</form>
	</div>	

	<div role="tabpanel" class="tab-pane" id="password">
		<br />
		<form role="update-profile" action="?action=update_password">
			<fieldset>
				<?php echo active_field(array('name' => 'old_password', 'type' => 'password', 'desc'=>$Module->lang['Old password'], 'maxlength' => '32', 'inputCols' => 6))?>
				<?php echo active_field(array('name' => 'password', 'type' => 'password', 'desc'=>$Module->lang['New_password'], 'maxlength' => '32', 'inputCols' => 6))?>
				<?php echo active_field(array('name' => 'password2', 'type' => 'password', 'desc'=>$Module->lang['Retype_password'], 'maxlength' => '32', 'inputCols' => 6))?>
		
				<div class="form-group">
					<div class="col-md-9 col-md-offset-3">
						<button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span> <?php echo $Module->lang['Save password']?></button>
					</div>
				</div>
			</fieldset>
		</form>
	</div>
</div>