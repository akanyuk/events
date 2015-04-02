<?php 
	NFW::i()->registerResource('dataTables');
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->registerResource('jquery.jgrowl');
?>
<script type="text/javascript">
$(document).ready(function(){
	$('div[id="vote-tabs"]').tabs().show();

	$(document).trigger('refresh');
});
</script>

<div id="vote-tabs" style="display: none;">
	<ul>
		<li><a href="<?php echo $Module->formatURL('manage_votekeys')?>">Votekeys</a></li>
		<li><a href="<?php echo $Module->formatURL('manage_votes')?>">Votes</a></li>
		<li><a href="<?php echo $Module->formatURL('manage_results')?>">Results</a></li>
	</ul>
</div>	    	
	