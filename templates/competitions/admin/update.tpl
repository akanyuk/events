<?php
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerFunction('ui_message');
?>
<script type="text/javascript">
$(document).ready(function(){
 	var f = $('form[id="competitions-update"]');
 	
 	f.activeForm({
 		success: function(response) {
 			window.location.href = '<?php echo $Module->formatURL()?>';
 		}
 	});

	$(document).trigger('refresh');
});
</script>

<form id="competitions-update"><fieldset>
	<legend>Update competition</legend>
	<?php echo active_field(array('name' => 'event_id', 'value' => $Module->record['event_id'], 'attributes'=>$Module->attributes['event_id']))?>
	<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
	<?php echo active_field(array('name' => 'alias', 'value' => $Module->record['alias'], 'attributes'=>$Module->attributes['alias'], 'width'=>"200px;"))?>
	<?php echo active_field(array('name' => 'works_type', 'value' => $Module->record['works_type'], 'attributes'=>$Module->attributes['works_type']))?>
	<?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes'=>$Module->attributes['announcement'], 'width'=>"500px;", 'height'=>"50px;"))?>
	<?php echo active_field(array('name' => 'reception_from', 'value' => $Module->record['reception_from'], 'attributes'=>$Module->attributes['reception_from']))?>
	<?php echo active_field(array('name' => 'reception_to', 'value' => $Module->record['reception_to'], 'attributes'=>$Module->attributes['reception_to']))?>
	<?php echo active_field(array('name' => 'voting_from', 'value' => $Module->record['voting_from'], 'attributes'=>$Module->attributes['voting_from']))?>
	<?php echo active_field(array('name' => 'voting_to', 'value' => $Module->record['voting_to'], 'attributes'=>$Module->attributes['voting_to']))?>
	<div class="input-row"><button type="submit" class="nfw-button" icon="ui-icon-disk">Save changes</button></div>
</fieldset></form>