<?php 
NFW::i()->registerFunction('tmb');

list ($records) = $records;

$counter = 0;
foreach ($records as $record) {
	$record_image = NFW::i()->assets('main/news-no-image.png');
	foreach ($record['media'] as $a) {
		if ($a['type'] != 'image') continue;
		$record_image = tmb($a, 64);
	}
?>
<div class="hidden-md hidden-sm hidden-lg">
	<div style="display: table-row;">
		<div style="display: table-cell; vertical-align: top; width: 82px; text-align: left;">
			<a style="display: inline-block;" href="<?php echo NFW::i()->base_path.'news.html?id='.$record['id']?>"><img class="media-object" src="<?php echo $record_image?>" /></a>
			<div style="padding-top: 3px; font-weight: bold; font-size: 12px;"><?php echo date('d.m.Y', $record['posted'])?></div>
		</div>
		<div style="display: table-cell; vertical-align: top;">
			<p><a href="<?php echo NFW::i()->base_path.'news.html?id='.$record['id']?>"><?php echo nl2br($record['announcement'])?></a></p>
		</div>
	</div>
</div>
<div class="hidden-xs">
	<div style="display: table-row; padding-bottom: 10px;">
		<div style="display: table-cell; width: 80px; vertical-align: top; text-align: left;">
			<a href="<?php echo NFW::i()->base_path.'news.html?id='.$record['id']?>"><img class="media-object" src="<?php echo $record_image?>" /></a>
		</div>
		<div style="display: table-cell; vertical-align: top;">
			<div style="font-weight: bold; font-size: 12px;"><?php echo date('d.m.Y', $record['posted'])?></div>
			<p><a href="<?php echo NFW::i()->base_path.'news.html?id='.$record['id']?>"><?php echo nl2br($record['announcement'])?></a></p>
		</div>
	</div>
</div>
<?php 
	echo $counter++ == count($records) - 1 ? '' : '<hr />'; 
}

echo $paging_links;