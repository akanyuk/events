<?php 
	if (!empty($records)) {
		$lang_main = NFW::i()->getLang('main');
?>
<style>
	.latest-news { margin-bottom: 20px; }
	.latest-news P { font-size: 85%; }
</style>
<div class="latest-news">
	<?php $counter = 0; foreach ($records as $record) { ?>	
   		<p><strong><?php echo date('d.m.Y', $record['posted'])?></strong>
   		<br /><a href="<?php echo NFW::i()->base_path.'news.html?id='.$record['id']?>"><?php echo nl2br($record['announcement'])?></a></p>
	<?php echo $counter++ == count($records) - 1 ? '' : '<hr />'; } ?>
</div>
<?php } ?>