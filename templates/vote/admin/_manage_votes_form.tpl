<style>
	FORM#vote .v { padding: 2px; }
	FORM#vote .v:nth-child(odd) { background-color: #eee; }
	FORM#vote .v .i { float: right; margin-left: 3px; }
	FORM#vote .v .d { float: left; width: 300px; max-width: 300px; overflow: hidden; white-space: nowrap; padding-top: 1px; }
	FORM#vote .v .e { clear: both; }
	FORM#vote .v INPUT { width:20px !important; }
		
	FORM#vote H3 { border-bottom: 1px solid #aaa; margin-bottom: 5px; padding: 5px 0 0 5px; }
</style>
<div id="vote-insert-dialog">
	<form id="vote" action="<?php echo $Module->formatURL('manage_votes').'&part=add-vote&event_id='.$event['id']?>">
<?php 
	$cur_competition = 0;
	foreach ($works as $work) {
		if ($cur_competition != $work['competition_id']) {
			echo '<h3>'.htmlspecialchars($work['competition_title']).'</h3>';
			$cur_competition = $work['competition_id'];
		}
		 
		echo '<div class="v">';
		echo '<div class="i"><input rel="vote" type="text" name="votes['.$work['id'].']" class="uniformed" /></div>';
		echo '<div class="d">'.$work['pos'].'. '.htmlspecialchars($work['title']).'</div>';
		echo '<div class="e"></div></div>';
	}	
?>
		<div style="padding-top: 10px;">
			<input type="text" name="username" value="" maxlength="200" style="width: 350px" placeholder="Name / Nick / Comment">
		</div>
	</form>
</div>
<script type="text/javascript">
$(document).ready(function(){
	// Insert vote
	var viD = $('div[id="vote-insert-dialog"]');
	viD.dialog({ 
		title: 'Add vote for: <?php echo htmlspecialchars($event['title'])?>',
		autoOpen:true,draggable:false,modal:true,resizable: false,
		width: 'auto', height: 'auto',
		buttons: {
			'Save vote': function() {
				viD.find('form').submit();
			}
		},
		close: function(event, ui) {
			viD.dialog('destroy').remove();
		}
	});	

	viD.find('form').activeForm({
		success: function(response) {
			$(document).trigger('votes-list-reload');
			viD.dialog('close');
		}
	});

	viD.find('input[rel="vote"]').spinner({
		 spin: function( event, ui ) {
			 if (ui.value > 10) {
				 $(this).spinner('value', '');
				 return false;
		 	} else if (ui.value == 0) {
			 	$(this).spinner('value', '');
			 	return false;
		 	} else if (ui.value < 0) {
			 	$(this).spinner('value', 10);
			 	return false;
		 	}
		}
	});
		
	$(document).trigger('refresh');
});
</script>