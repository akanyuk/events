<?php
	$lang_main = NFW::i()->getLang('main')
?>
<h1><?php echo htmlspecialchars($record['title'])?></h1>
<div style="padding-bottom: 5px;">
	<em><?php echo date('d.m.Y', $record['posted'])?></em>
</div>
<?php echo $record['content']?>
<hr />
<a href="<?php echo NFW::i()->absolute_path?>/news.html"><?php echo $lang_main['all news']?></a>