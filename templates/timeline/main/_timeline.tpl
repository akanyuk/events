<?php
	$records = $Module->getRecords();
	if (empty($records)) return;
	
	NFW::i()->registerResource('jquery.countdown'); 
?>
<script type="text/javascript">
$(document).ready(function(){
	$('div[rel="countdown"]').each(function(){
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
	.timeline-record { padding: 5px !important; margin-bottom: 10px !important; }
	.timeline-record HR { margin: 0 !important; }
	.timeline-record .countdown { float: right; text-align: right; font-family: Consolas, Lucida Console, Courier New, monospace; font-weight: bold; color: #fff; text-shadow: 1px 0 6px #F9FF2F;	}
	.timeline-record .date { margin-bottom: 3px; padding: 0 5px; background-color: #328CAA; color: #fff; font-size: 85%; font-weight: bold; }
	.timeline-record .desc { font-size: 90%;  }
</style>
<div style="margin-bottom: 20px;">
<?php foreach ($records as $record) { ?>
	<div id="obj" class="timeline-record alert alert-info">
   		<div class="date">
   			<div rel="countdown" class="countdown"><?php echo date('r', $record['date_from'])?></div>
   			<?php echo date('d.m.Y H:i', $record['date_from'])?>
   		</div>
   		<div class="desc"><?php echo str_replace('<br', '<hr', nl2br($record['content']))?></div>
   	</div>   	
<?php } ?>
<a href="<?php echo NFW::i()->base_path?>timeline" class="btn btn-info btn-sm">Fullscreen Timeline</a>
</div>