<?php 
$counter = 0;
foreach ($news as $record) {
	$record_image = NFW::i()->assets('main/news-no-image.png');
	foreach ($record['attachments'] as $a) {
		if ($a['type'] != 'image') continue;
		$record_image = $a['tmb_prefix'].'64.'.$a['extension'];
		break;
	}
?>
<div class="media">
	<a class="pull-left" href="<?php echo NFW::i()->base_path.'news.html?id='.$record['id']?>"><img class="media-object" src="<?php echo $record_image?>" /></a>
    <div class="media-body">
    	<div class="pull-right"><span class="label label-info"><?php echo date('d.m.Y', $record['posted'])?></span></div>
    	<h4 class="media-heading"><a href="<?php echo NFW::i()->base_path.'news.html?id='.$record['id']?>"><?php echo htmlspecialchars($record['title'])?></a></h4>
    	<div class="clearfix"></div>
    	<p><?php echo nl2br($record['announcement'])?></p>
    </div>
    <div class="clerafix"></div>
</div>
<?php
	echo $counter++ == count($news) - 1 ? '' : '<hr />'; 
} 
echo $paging_links;