<?php

// Ajax & html responses
if (isset($_POST['dbg_actual_date']) && isset($_POST['protect_code'])) {
	if ($_POST['protect_code'] != '70011') {
		NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('protect_code' => 'Wrong protect code')));
	}
	
	if ($_POST['dbg_actual_date']) {
		$dbg_date = date('Y/m/d H:i', $_POST['dbg_actual_date']);
		NFW::i()->setCookie('DBG_ACTUAL_DATE', $dbg_date);
		NFW::i()->renderJSON(array('result' => 'success', 'message' => 'New debugging date: '.$dbg_date));
	}
	else {
		NFW::i()->setCookie('DBG_ACTUAL_DATE', null);
		NFW::i()->renderJSON(array('result' => 'success', 'message' => 'Debugging date cleared.'));
	}
}

NFW::i()->registerResource('jquery.activeForm');
ob_start();
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="dbg"]');
	f.activeForm({
		'ui': 'bootstrap',
 	 	'cleanErrors': function() {
 	 		f.find('div[class~="form-group"]').find('*[class="help-block"]').empty();
 	 		f.find('div[class~="form-group"]').removeClass('has-error');
 	 	},
		'error': function(response) {
			$.each(response.errors, function(i, e) {
				if (f.find('div[class~="form-group"][id="'+i+'"]').length) {
					f.find('div[class~="form-group"][id="'+i+'"]').addClass('has-error');
					f.find('div[class~="form-group"][id="'+i+'"]').find('*[class="help-block"]').html(e);
				}
				else if (i != 'general') {
					alert(e);
				}
			});			
		},
		'success': function(response){
			alert(response.message);
		}
	});
});
</script>

<form id="dbg" class="form-horizontal"><fieldset>
	<legend>Debugging</legend>
	<?php echo active_field(array('name' => 'dbg_actual_date', 'desc' => 'Actual date', 'type' => 'date', 'startDate' => 1, 'endDate' => -365, 'withTime' => true)); ?>
	<?php echo active_field(array('name' => 'protect_code', 'desc' => 'Protect code', 'maxlength' => 6, 'inputCols' => 3)); ?>
	<div class="form-group">
		<div class="col-md-offset-3 col-md-8">
			<button type="submit" class="btn btn-lg btn-primary">Send</button>
		</div>
	</div>	
</fieldset></form>
<?php 
$page = array(
	'title' => 'debug',
	'path' => 'dbg',
	'content' => ob_get_clean()
);
		
NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');	