<?php
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->registerResource('bootstrap3.typeahead');
	
	$lang_main = NFW::i()->getLang('main');
	NFW::i()->assign('page_title', $lang_main['cabinet add work']);
?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="works-add"]');
	f.activeForm({
		'success': function(response){
			$('div[id="success-dialog"]').find('div[id="message"]').html(response.message);
			$('div[id="success-dialog"]').modal('show').on('hide.bs.modal', function () {
				window.location.href = '?action=list';
			});
		}
	});

	// Platform typeahead
	var aPlatforms = [];
	<?php foreach ($attributes['platform']['options'] as $p) echo 'aPlatforms.push(\''.htmlspecialchars($p).'\');'."\n"; ?>
	$('input[name="platform"]').typeahead({ 
		source: aPlatforms,
		minLength: 0
	});

	$('button[id="add-work"]').click(function(){
		f.submit();
	});
});
</script>
<div id="success-dialog" class="modal fade"><div class="modal-dialog"><div class="modal-content">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h4 class="modal-title"><?php echo $lang_main['works upload success label']?></h4>
	</div>
	<div id="message" class="modal-body"></div>
	<div class="modal-footer">
		<button type="button" class="btn btn-default" data-dismiss="modal">Ok</button>
	</div>
</div></div></div>

<form id="works-add" class="form-horizontal"><fieldset>
	<legend><?php echo $lang_main['cabinet add work']?></legend>
	<?php echo active_field(array('name' => 'competition_id', 'attributes' => $attributes['competition_id'], 'desc' => $lang_main['competition'], 'labelCols' => '2', 'inputCols' => '10'))?>
	<?php echo active_field(array('name' => 'title', 'attributes' => $attributes['title'], 'desc' => $lang_main['works title'], 'labelCols' => '2', 'inputCols' => '10'))?>
	<?php echo active_field(array('name' => 'author', 'attributes' => $attributes['author'], 'desc' => $lang_main['works author'], 'labelCols' => '2', 'inputCols' => '10'))?>
	<?php echo active_field(array('name' => 'platform', 'attributes' => $attributes['platform'], 'type' => 'str', 'desc' => $lang_main['works platform'], 'labelCols' => '2', 'inputCols' => '5'))?>
	<?php echo active_field(array('name' => 'format', 'attributes' => $attributes['format'], 'type' => 'str', 'desc' => $lang_main['works format'], 'labelCols' => '2', 'inputCols' => '5'))?>
	<?php echo active_field(array('name' => 'description', 'attributes' => $attributes['description'], 'desc' => $lang_main['works description'], 'labelCols' => '2', 'inputCols' => '10'))?>
</fieldset></form>

<div id="media-form"><?php echo $media_form?></div>


<div class="form-horizontal"><div class="form-group">
	<div class="col-md-offset-3 col-md-9">
		<div class="alert alert-info dm-alert-cond"><?php echo $lang_main['works upload info']?></div>
		<button id="add-work" class="btn btn-primary"><?php echo $lang_main['works send']?></button>
	</div>
</div></div>