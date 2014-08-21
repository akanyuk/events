<?php
NFW::i()->registerResource('jquery.countdown'); 
?>
<html lang="<?php echo NFW::i()->lang['lang']?>"><head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<title>Timeline</title>
<style>
	body { overflow: hidden; margin: 0; padding: 1em; background-color: #000000; color: #ffffff; } 
	body, p { font: 18pt Arial; }
	
	.timeline-record { margin-bottom: 2.5em; padding-left: 1em; clear: both; }
	
	.timeline-record .countdown { 
		float: right; text-align: right;
		font-family: Consolas, Lucida Console, Courier New, monospace; font-size: 50pt; font-weight: bold;
		color: #080; 
		text-shadow: 1px 0px 10px #080;
	}
	
	.timeline-record .date { 
		margin-bottom: 0.2em; 
		padding: 0.2em 0.5em; width: 150pt; 
		background: #4A0505; 
		background: linear-gradient(to right, #800A0A, #000000);
		color: #fff; font-size: 85%; font-weight: bold; 
	}
	
	.timeline-record hr { 
		margin: 0 0 0 -0.3em; width: 300pt; height: 1px;
		border: none; background: linear-gradient(to right, #C95B1C, #000000);
	}
	
	.timeline-record .desc { font-weight: bold;  }
</style>
<script type="text/javascript">
$(document).ready(function(){
	$('div[rel="countdown"]').each(function(){
		$(this).countdown({
			until: new Date($(this).text()), 
			compact: true, 
			format: 'HMS',
			onExpiry: function(){
				$(this).closest('div[id="obj"]').remove();
			}			
		});
	});
});
</script>				
</head>
<body>
<?php foreach ($records as $record) { ?>
	<div id="obj" class="timeline-record">
		<div rel="countdown" class="countdown"><?php echo date('r', $record['date_from'])?></div>
   		<div class="date"><?php echo date('d.m.Y H:i', $record['date_from'])?></div>
   		<div class="desc"><?php echo str_replace('<br', '<hr', nl2br($record['content']))?></div>
   	</div>   	
<?php } ?>
</body></html>