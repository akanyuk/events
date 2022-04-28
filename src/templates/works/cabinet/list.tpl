<?php
$lang_main = NFW::i()->getLang('main');

NFW::i()->assign('page_title', $lang_main['cabinet prods']);

NFW::i()->breadcrumb = array(
	array('desc' => $lang_main['cabinet prods']),
);

if (empty($records)) {
?>		
	<div class="jumbotron">
		<h1>Hey, <?php echo htmlspecialchars(NFW::i()->user['realname'])?>!</h1>
		<p><?php echo $lang_main['works empty']?></p>
		<p><a href="?action=add" class="btn btn-primary btn-lg" role="button"><?php echo $lang_main['cabinet add work']?></a></p>
	</div>
<?php
	return;
}

?>
<script type="text/javascript">
$(document).ready(function(){
	// status hints
	$('div[data-toggle="tooltip"]').tooltip({ 'animation': false, 'html': true });
});
</script>
<style>
.my-prods {	display: table;	}
.my-prods .record { display: table-row; }
.my-prods .cell { display: table-cell; white-space: nowrap; padding: 5px 10px; }

.my-prods .record:nth-child(odd) { background-color: #f4f4f4; }

.my-prods .record .cell:nth-child(1) { vertical-align: middle; font-size: 120%; }
.my-prods .record .cell:nth-child(2) { text-align: center; }
.my-prods .record .cell:nth-child(2) IMG { max-height: 96px; }

.my-prods .record .cell:nth-child(3) { width: 100%; vertical-align: top; }
@media (max-width: 768px) {
	.my-prods .record .cell:nth-child(3) { white-space: inherit; }
}
.my-prods .record .cell:nth-child(4) { text-align: center; vertical-align: middle; }

.my-prods .title, .my-prods .event { overflow: hidden; }
.my-prods .title { font-weight: bold; }
.my-prods .event { font-size: 13px; color: #999; }
</style>
<div class="my-prods">
<?php 
	foreach ($records as $record) {
		switch ($record['place']) {
			case 0:
				$eprefix = '';
				break;
			case 1:
				$eprefix = $record['place'].'st at ';
				break;
			case 2:
				$eprefix = $record['place'].'nd at ';
				break;
			case 3:
				$eprefix = $record['place'].'rd at ';
				break;
			default:
				$eprefix = $record['place'].'th at ';
				break;
		}
?>
<div class="record">
	<div class="cell hidden-xs">
		<div data-toggle="tooltip" title="<?php echo '<strong>'.$record['status_info']['desc'].'</strong><br />Voting: '.($record['status_info']['voting'] ? 'On' : 'Off').'<br />Release: '.($record['status_info']['release'] ? 'On' : 'Off')?>" class="text text-<?php echo $record['status_info']['css-class']?>"><span class="<?php echo $record['status_info']['icon']?>"></span></div>
	</div>
	<div class="cell">
		<a href="<?php echo NFW::i()->base_path.'cabinet/works?action=view&record_id='.$record['id']?>">
			<img src="<?php echo $record['screenshot'] ? $record['screenshot']['tmb_prefix'].'64' : NFW::i()->assets('main/news-no-image.png')?>" />
		</a>

		<div class="hidden-sm hidden-md hidden-lg" style="font-size: 120%;">			
			<div data-toggle="tooltip" title="<?php echo '<strong>'.$record['status_info']['desc'].'</strong><br />Voting: '.($record['status_info']['voting'] ? 'On' : 'Off').'<br />Release: '.($record['status_info']['release'] ? 'On' : 'Off')?>" class="text text-<?php echo $record['status_info']['css-class']?>"><span class="<?php echo $record['status_info']['icon']?>"></span></div>
		</div>
	</div>
	<div class="cell">
		<div class="title">
			<a href="<?php echo NFW::i()->base_path.'cabinet/works?action=view&record_id='.$record['id']?>">
				<?php echo htmlspecialchars($record['title']).' <nobr>by '.htmlspecialchars($record['author']).'</nobr>'?>
			</a>
		</div>
		
		<div class="event">
			<?php echo $eprefix.'<nobr>'.htmlspecialchars($record['event_title']).'</nobr> / <nobr>'.htmlspecialchars($record['competition_title']).'</nobr>'?>
		</div>
		
		<div class="hidden-sm hidden-md hidden-lg">
			<div class="label label-primary label-platform"><?php echo htmlspecialchars($record['platform'])?></div>
			<?php echo $record['format'] ? '<div class="label label-primary label-platform label-format">'.htmlspecialchars($record['format']).'</div>' : ''?>
		</div>
	</div>
	<div class="cell hidden-xs">
		<div>
			<div class="label label-primary label-platform"><?php echo htmlspecialchars($record['platform'])?></div>
		</div>
		<?php echo $record['format'] ? '<div class="label label-primary label-platform label-format">'.htmlspecialchars($record['format']).'</div>' : ''?>
	</div>
</div>	
<?php } ?>	
</div>