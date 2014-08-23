<style>
	.latest-news P { font-size: 85%; }
</style>
<div class="latest-news">
<?php foreach ($news as $record) { ?>	
   	<p><strong><?php echo date('d.m.Y', $record['posted'])?></strong>
   	<br /><a href="<?php echo NFW::i()->base_path.'news.html?id='.$record['id']?>"><?php echo nl2br($record['announcement'])?></a></p>
   	<hr />
<?php } ?>
</div>