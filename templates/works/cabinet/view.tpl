<?php
	$CCompetitions = new competitions($Module->record['competition_id']);
	$lang_main = NFW::i()->getLang('main');
	NFW::i()->assign('page_title', $Module->record['title'].' / '.$lang_main['cabinet prods']);
	NFW::i()->registerResource('colorbox');

	$place_title = '';
	if ($Module->record['average_vote']) $place_title .= '<p class="smalldesc">'.$lang_main['works average_vote'].': <strong>'.$Module->record['average_vote'].'</strong></p>';
	if ($Module->record['num_votes']) $place_title .= '<p class="smalldesc">'.$lang_main['works num_votes'].': <strong>'.$Module->record['num_votes'].'</strong></p>';
	if ($Module->record['total_scores']) $place_title .= '<p class="smalldesc">'.$lang_main['works total_scores'].': <strong>'.$Module->record['total_scores'].'</strong></p>';
?>
<script type="text/javascript">
$(document).ready(function(){
	// Colorbox
	$('a[type="image"]').colorbox({ maxWidth:'96%', maxHeight:'96%', current: '', transition: 'none', fadeOut: 0 });

	// Tooltips
	$('div[rel="status-tooltip"]').tooltip({ 'animation': false, 'html': true });

	// Tabs
	 $('ul[id="works-view-menu"] a').on('click', function(){
		$(this).tab('show');
		return false;
	 });

});
</script>
<style>
	p.smalldesc { margin: 0; line-height: 1.2; font-size: 85%; }
	div[rel="status-tooltip"] { cursor: default; }
	TD.filestatus DIV.glyphicon { font-size: 200%; }
	div.tooltip-inner { white-space: normal; max-width: 350px; }	  
</style>
<dl class="dl-horizontal">
	<div class="pull-right">
		<?php if ($Module->record['screenshot']): ?><img src="<?php echo $Module->record['screenshot']['tmb_prefix']?>192" /><?php endif; ?>		
	</div>
	<div class="pull-left">
		<dt><?php echo $lang_main['works title']?>:</dt><dd><?php echo htmlspecialchars($Module->record['title'].($Module->record['author'] ? ' by '.$Module->record['author'] : ''))?></dd>
		<dt><?php echo $lang_main['works status']?>:</dt><dd><div rel="status-tooltip" title="<?php echo $Module->record['status_info']['desc_full']?>" class="label <?php echo $Module->record['status_info']['label-class']?>"><?php echo $Module->record['status_info']['desc']?></div></dd>
		<dt><?php echo $lang_main['works platform']?>:</dt><dd><?php echo htmlspecialchars($Module->record['platform'].($Module->record['format'] ? ' ('.$Module->record['format'].')' : ''))?></dd>
		<dt><?php echo $lang_main['event']?>:</dt><dd><?php echo $Module->record['event_title']?></dd>
		<dt><?php echo $lang_main['competition']?>:</dt><dd><?php echo $Module->record['competition_title']?> <em>(<?php echo $Module->record['works_type']?>)</em></dd>
		<dt><?php echo $lang_main['works posted']?>:</dt><dd><?php echo date('d.m.Y H:i:s', $Module->record['posted'])?></dd>
		<?php if ($Module->record['place']): ?>
			<dt><?php echo $lang_main['works place']?>:</dt><dd><div rel="status-tooltip" class="label label-success" title='<?php echo $place_title?>' style="font-size: 100%;"><?php echo $Module->record['place']?></div></dd>
		<?php else: ?>
			<dt><?php echo $lang_main['works voting']?>:</dt><dd class="<?php echo $CCompetitions->record['voting_status']['text-class']?>"><?php echo $CCompetitions->record['voting_status']['desc']?></dd>
		<?php endif; ?>
	</div>
	<div class="clearfix"></div>
</dl>

<ul id="works-view-menu" class="nav nav-tabs">
	<li class="active"><a href="#files"><?php echo $lang_main['works files']?></a></li>
</ul>
<div class="tab-content works-view">
	<div class="tab-pane active" id="files">
		<br />
		<table class="table table-condensed table-striped dm">
			<tbody>
<?php 
	foreach ($Module->record['media_info'] as $a) {
		if ($a['type'] == 'image') {
			list($width, $height) = getimagesize($a['fullpath']);
			$a['image_size'] = '['.$width.'x'.$height.']';
			$a['icon'] = $a['tmb_prefix'].'64';
		}
		else {
			$a['image_size'] = false;
			$a['icon'] = $a['icons']['64x64'];
		}
?>
	<tr>
		<td><a type="<?php echo $a['type']?>" href="<?php echo $a['url']?>"><img src="<?php echo $a['icon']?>" /></a></td>
		<td class="full">
			<strong><a type="<?php echo $a['type']?>" href="<?php echo $a['url']?>"><?php echo htmlspecialchars($a['basename'])?></a></strong>
			<p class="text-muted smalldesc">
				<?php echo $lang_main['works uploaded'].': '.date('d.m.Y H:i:s', $a['posted']).' by '.$a['posted_username']?><br />
				<?php echo $lang_main['works filesize'].': '.$a['filesize_str'].' '.$a['image_size']?>
			</p>
		</td>
		<td class="nw filestatus">
			<div class="glyphicon glyphicon-list-alt <?php echo $a['is_voting'] ? 'text-info' : 'text-muted'?>" rel="status-tooltip" title="<?php echo $lang_main['filestatus voting']?>"></div>
			<div class="glyphicon glyphicon-picture <?php echo $a['is_image'] ? 'text-info' : 'text-muted'?>" rel="status-tooltip" title="<?php echo $lang_main['filestatus image']?>"></div>
			<div class="glyphicon glyphicon-music <?php echo $a['is_audio'] ? 'text-info' : 'text-muted'?>" rel="status-tooltip" title="<?php echo $lang_main['filestatus audio']?>"></div>
			<div class="glyphicon glyphicon-download-alt <?php echo $a['is_release'] ? 'text-info' : 'text-muted'?>" rel="status-tooltip" title="<?php echo $lang_main['filestatus release']?>"></div>
		</td>
		<td></td>
	</tr>
<?php } ?>			
			</tbody>
		</table>
	</div>
</div>