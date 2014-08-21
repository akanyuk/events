<?php
	NFW::i()->registerFunction('active_field');
?>
<div id="works-insert-dialog"><form id="works-insert" action="<?php echo $Module->formatURL('insert').'&event_id='.$event['id']?>">
	<?php echo active_field(array('name' => 'title', 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
	<?php echo active_field(array('name' => 'author', 'attributes'=>$Module->attributes['author'], 'width'=>"500px;"))?>
	<?php echo active_field(array('name' => 'competition_id', 'attributes'=>$Module->attributes['competition_id']))?>
	<?php echo active_field(array('name' => 'platform', 'attributes'=>$Module->attributes['platform'], 'width'=>"210px;"))?>
	<?php echo active_field(array('name' => 'format', 'attributes'=>$Module->attributes['format'], 'width'=>"210px;"))?>
	<?php echo active_field(array('name' => 'description', 'attributes'=>$Module->attributes['description'], 'width'=>"500px;", 'height'=>"50px;"))?>
	<?php echo active_field(array('name' => 'external_html', 'attributes'=>$Module->attributes['external_html'], 'width'=>"500px;", 'height'=>"50px;"))?>
</form></div>
<script type="text/javascript">
$(document).ready(function(){
	var wiD = $('div[id="works-insert-dialog"]');
	wiD.dialog({ 
		autoOpen:true,draggable:false,modal:true,resizable: false,
		title: 'Insert work for event: <?php echo htmlspecialchars($event['title'])?>',
		width: 'auto', height: 'auto',
		buttons: {
			'Save': function() {
				wiF.submit();
			}
		},
		close: function(event, ui) {
			wiD.dialog('destroy').remove();
		}
	});	

	var wiF = $('form[id="works-insert"]');
	wiF.activeForm({
		success: function(response) {
			window.location.href = '<?php echo $Module->formatURL('update')?>&record_id=' + response.record_id;
		}
	});

	// Platform
	var aPlatforms = [];
<?php foreach ($Module->attributes['platform']['options'] as $p) echo 'aPlatforms.push(\''.htmlspecialchars($p).'\');'."\n"; ?>	
	$('input[name="platform"]').autocomplete({
		source: aPlatforms,
		minLength: 0
	}).click(function(){
		$(this).autocomplete('search', '');
	});
	
	$(document).trigger('refresh');
});
</script>