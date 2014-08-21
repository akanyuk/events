<?php
NFW::i()->registerFunction('cache_media');
$lang_main = NFW::i()->getLang('main');

echo nl2br($competition['announcement']);

// Get release works
$CWorks = new works();
list($release_works) = $CWorks->getRecords(array(
	'filter' => array('release_only' => true, 'competition_id' => $competition['id']),
	'ORDER BY' => 'w.status, w.place'
));

foreach ($release_works as $w) {
	echo '<h3 style="padding-bottom: 10px;">'.($w['place'] ? '<span class="label label-success" style="font-size: 100%;">'.$w['place'].'</span>&nbsp;' : '').htmlspecialchars($w['title'].' / '.$w['author']).'</h3>';
	
	// Display content (image, audio, video
	foreach ($w['image_files'] as $f) echo '<p><img src="'.cache_media($f).'" /></p>'; 
	
	if (!empty($w['audio_files'])) {
		echo '<audio controls="controls" loop="loop" preload="false">';
		foreach ($w['audio_files'] as $f) echo '<source src="'.cache_media($f).'" type="'.$f['mime_type'].'" />'; 
		echo $lang_main['voting audio not support'].'</audio>';
	}

	echo '<div>'.$w['external_html'].'</div>';
?>
<div class="row"><div class="col-md-11">			
	<p><?php echo $lang_main['works platform']?> / <?php echo $lang_main['works format']?>: <strong><?php echo htmlspecialchars($w['platform']).($w['format'] ? ' / '.htmlspecialchars($w['format']) : '')?></strong></p>
	<p style="white-space: nowrap;">
		<?php echo $w['average_vote'] ? '<strong>'.$lang_main['works average_vote'].':</strong> <span class="label label-success">'.$w['average_vote'].'</span>&nbsp;&nbsp;' : ''?>
		<?php echo $w['num_votes'] ? $lang_main['works num_votes'].': <span class="label label-default">'.$w['num_votes'].'</span>&nbsp;&nbsp;' : ''?>
		<?php echo $w['total_scores'] ? $lang_main['works total_scores'].': <span class="label label-default">'.$w['total_scores'].'</span>&nbsp;&nbsp;' : ''?>
		
		<strong><?php echo $lang_main['voting download']?>:</strong>
		<?php
			if ($w['permanent_file']) {
				echo '<a href="'.$w['permanent_file']['url'].'" title="'.$w['permanent_file']['basename'].'" class="btn btn-default btn-xs"><span class="glyphicon glyphicon-download-alt"></span></a>';
			}
			else {
				foreach ($w['release_files'] as $f) { 
					echo '<a href="'.cache_media($f).'" title="'.$f['basename'].'" class="btn btn-default btn-xs"><span class="glyphicon glyphicon-download-alt"></span></a>';
				}
			} 
		?>				
	</p>
</div></div>
<hr />
<?php  } ?>
<br />