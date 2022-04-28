<?php
	$lang_main = NFW::i()->getLang('main');
	NFW::i()->assign('page_title', $lang_main['cabinet add choose event']);
	
	NFW::i()->breadcrumb = array(
		array('url' => 'cabinet/works?action=list', 'desc' => $lang_main['cabinet prods']),
		array('desc' => $lang_main['cabinet add choose event'])
	);
	
?>
<div class="row"><?php foreach ($events as $record) { ?>
	<div class="col-md-6 col-sm-12 col-xs-12">
		<div class="thumbnail text-center">
			<br />
			<a href="?action=add&event_id=<?php echo $record['id']?>">
				<img class="media-object" src="<?php echo $record['preview_img']?>" />
			</a>
			<div class="caption">
				<h3><a href="?action=add&event_id=<?php echo $record['id']?>"><?php echo htmlspecialchars($record['title'])?></a></h3>
				<p><?php echo $record['dates_desc']?></p>
			</div>
		</div>
	</div>
<?php } ?></div>
	
