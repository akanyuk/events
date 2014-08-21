<?php
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerFunction('ui_message');
?>
<script type="text/javascript">
$(document).ready(function(){
 	var f = $('form[id="competitions-insert"]');
 	
 	f.activeForm({
 		success: function(response) {
 			window.location.href = '<?php echo $Module->formatURL()?>';
 		}
 	});

	$(document).trigger('refresh');
});
</script>

<form id="competitions-insert"><fieldset>
	<legend>Add competition</legend>
	<?php echo active_field(array('name' => 'event_id', 'value' => isset($_GET['event_id']) ? $_GET['event_id'] : null, 'attributes'=>$Module->attributes['event_id']))?>
	<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
	<?php echo active_field(array('name' => 'alias', 'attributes'=>$Module->attributes['alias'], 'width'=>"200px;"))?>
	<?php echo active_field(array('name' => 'works_type', 'attributes'=>$Module->attributes['works_type']))?>
	<?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes'=>$Module->attributes['announcement'], 'width'=>"500px;", 'height'=>"50px;"))?>
	<?php echo active_field(array('name' => 'reception_from', 'attributes'=>$Module->attributes['reception_from']))?>
	<?php echo active_field(array('name' => 'reception_to', 'attributes'=>$Module->attributes['reception_to']))?>
	<?php echo active_field(array('name' => 'voting_from', 'attributes'=>$Module->attributes['voting_from']))?>
	<?php echo active_field(array('name' => 'voting_to', 'attributes'=>$Module->attributes['voting_to']))?>
	<div class="input-row"><button type="submit" class="nfw-button" icon="ui-icon-disk">Save changes</button></div>
</fieldset></form>