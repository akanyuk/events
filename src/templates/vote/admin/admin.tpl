<?php 
	NFW::i()->registerResource('dataTables');
	NFW::i()->registerResource('dataTables/Scroller');
	NFW::i()->registerResource('jquery.activeForm');
	NFW::i()->registerResource('jquery.jgrowl');
	
	NFW::i()->assign('page_title', $event['title'].' / voting');
	
	// Generate breadcrumbs
	
	NFW::i()->breadcrumb = array(
		array('url' => 'admin/events?action=update&record_id='.$event['id'], 'desc' => $event['title']),
		array('desc' => 'Voting'),
	);
?>
<script type="text/javascript">
$(document).ready(function(){

	$('#vote-tabs').on('click', 'a[role="tab"]', function (e) {
	    e.preventDefault();
	    var pane = $(this);

        $('div[role="tabpanel"]' + this.hash).load($(this).attr('data-url'), function(result){      
            pane.tab('show');
        });
	});	

	$('#vote-tabs a[role="tab"]:first').trigger('click');
	
});
</script>
<ul id="vote-tabs" class="nav nav-tabs" role="tablist">
	<li role="presentation" class="active"><a href="#votekeys" data-url="<?php echo $Module->formatURL('votekeys').'&event_id='.$event['id']?>" aria-controls="votekeys" role="tab" data-toggle="tab">Votekeys</a></li>
	<li role="presentation"><a href="#votes" data-url="<?php echo $Module->formatURL('votes').'&event_id='.$event['id']?>" aria-controls="votes" role="tab" data-toggle="tab">Votes</a></li>
	<li role="presentation"><a href="#results" data-url="<?php echo $Module->formatURL('results').'&event_id='.$event['id']?>" aria-controls="results" role="tab" data-toggle="tab">Results</a></li>
</ul>
<div class="tab-content">
	<div role="tabpanel" class="tab-pane in active" style="padding-top: 20px;" id="votekeys"></div>
	<div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="votes"></div>
	<div role="tabpanel" class="tab-pane" style="padding-top: 20px;" id="results"></div>
</div>

