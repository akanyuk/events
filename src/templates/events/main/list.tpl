<?php
/**
 * @var array $events
 */
$is_closed_events = false;
$is_first = true;
foreach ($events as $record) {
	if (!$is_closed_events &&  $record['date_from'] < time()) {
		echo $is_first ? '' : '<hr style="margin-top: 0;"/>';
		$is_closed_events = true;
	}
?>
<div style="padding-bottom: 2em;">
	<div class="pull-left">
		<a href="<?php echo NFW::i()->base_path.$record['alias']?>"><img class="media-object" src="<?php echo $record['preview_img']?>" /></a>
	</div>
	<div style="margin-left: 80px;">
		<h4 style="margin-bottom: 0;"><a href="<?php echo NFW::i()->base_path.$record['alias']?>"><?php echo htmlspecialchars($record['title'])?></a></h4>
		<div class="text-muted"><?php echo $record['dates_desc']?></div>
		<div><?php echo $record['status_label']?></div>
	</div>
	<div class="clearfix"></div>
   	<?php if ($record['announcement']): ?>
   	<p style="padding-top: 0.5em;"><?php echo nl2br($record['announcement'])?></p>
   	<?php endif; ?>
</div>
<?php $is_first = false; } ?>