<?php
	$records = $Module->getRecords();
	if (empty($records)) return;
	
	NFW::i()->registerResource('jquery.countdown'); 
?>
<script type="text/javascript">
$(document).ready(function(){
	$('div[role="countdown"]').each(function(){
		var dateTo = new Date($(this).text());
		$(this).countdown({
			until: dateTo, 
			compact: true, 
			onExpiry: function(){
				$(this).closest('div[id="obj"]').remove();
			}
		});
	});
});
</script>				
<style>
	.timeline .btn-fullscreen { font-weight: bold; }
		
	.timeline-record { 
		border: 1px solid #888;
		border-radius: 5px; 
		background-color: #eee; 
		padding: 2px; 
		margin-bottom: 8px; 
	}
	.timeline-record HR { border: none; border-bottom: 1px dotted #888; margin: 0 !important; }
	.timeline-record .countdown { float: right; text-align: right; font-family: Consolas, Lucida Console, Courier New, monospace; font-weight: bold; color: #fff; text-shadow: 1px 0 6px #F9FF2F;	}
	.timeline-record .date { padding: 2px 5px; background-color: #444; color: #fff; font-size: 90%; font-weight: bold; }
	.timeline-record .desc { background-color: #4a6b77; color: #fff; padding: 5px 10px; }
</style>
<div class="timeline">
	<?php foreach ($records as $record) { ?>
		<div id="obj" class="timeline-record">
	   		<div class="date">
	   			<div role="countdown" class="countdown"><?php echo date('r', $record['date_from'])?></div>
	   			<?php echo date('d.m.Y H:i', $record['date_from'])?>
	   		</div>
	   		<div class="desc"><?php echo str_replace('<br', '<hr', nl2br($record['content']))?></div>
	   	</div>   	
	<?php } ?>
	<div class="hidden-xs">
		<div class="text-center" style="padding-top: 10px;">
			<a href="<?php echo NFW::i()->base_path?>timeline" class="btn-fullscreen">Fullscreen Timeline</a>
		</div>
	</div>
</div>