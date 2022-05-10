<?php
/**
 * @var object $Module
 * @var array $records
 */
// Create tree of works, count works
$total_works_count = count($records);
$approved_works_count = 0;
$cur_competition = 0;	
$records_tree = array();
foreach ($records as $r) {
	if ($cur_competition != $r['competition_id']) {
		$cur_competition = $r['competition_id'];
		$records_tree[$cur_competition] = array('title' => $r['competition_title'], 'works' => array());
	}
	
	$records_tree[$cur_competition]['works'][] = $r;
	
	if ($r['status_info']['voting'] && $r['status_info']['release']) {
		$approved_works_count++;
	}
}

echo '<div id="counters" data-total="'.$total_works_count.'" data-approved="'.$approved_works_count.'" style="display: none;"></div>';
foreach ($records_tree as $competition_id => $c) {
?>
	<div role="competiotion-works" id="<?php echo $competition_id?>">
		<h3 id="competition-title"><?php echo htmlspecialchars($c['title'])?></h3>
					
		<div class="settings">
			<div class="header hidden-xs">
				<div class="cell"></div>
				<div class="cell"><span class="fa fa-wheelchair" title="Personal status"></span></div>
				<div class="cell"><span class="fa fa-globe" title="Global status"></span></div>
				<div class="cell"></div>
				<div class="cell">Title / author</div>
				<div class="cell">Platform / Format</div>
				<div class="cell">Posted</div>
				<div class="cell"></div>
			</div>
<?php foreach ($c['works'] as $r) { ?>
<div class="record" id="<?php echo $r['id']?>">
	<div class="cell">
		<div class="hidden-sm hidden-md hidden-lg" style="float: left;">
			<a href="<?php echo $Module->formatURL('update').'&record_id='.$r['id']?>">
				<img src="<?php echo $r['screenshot'] ? $r['screenshot']['tmb_prefix'].'64' : NFW::i()->assets('main/news-no-image.png')?>" />
			</a>
			
			<div class="icons">
				<?php if ($r['managers_notes_is_marked']): ?>
					<div data-toggle="tooltip" title="<?php echo htmlspecialchars(nl2br($r['managers_notes_comment']))?>" class="text-danger"><span class="fa fa-question-circle"></span></div>			
				<?php elseif ($r['managers_notes_is_checked']): ?>
					<div data-toggle="tooltip" title="I checked this prod" class="text-success"><span class="fa fa-check-circle"></span></div>
				<?php else: ?>
					<div data-toggle="tooltip" title="Not checked by myself" class="text-muted"><span class="fa fa-question-circle"></span></div>
				<?php endif; ?>
				<div data-toggle="tooltip" title="<?php echo '<strong>'.$r['status_info']['desc'].'</strong><br />Voting: '.($r['status_info']['voting'] ? 'On' : 'Off').'<br />Release: '.($r['status_info']['release'] ? 'On' : 'Off')?>" class="text text-<?php echo $r['status_info']['css-class']?>"><span class="<?php echo $r['status_info']['icon']?>"></span></div>
			</div>
		</div>
		
		<div id="position"><?php echo $r['position']?></div>
	</div>
	<div class="cell hidden-xs">
		<?php if ($r['managers_notes_is_marked']): ?>
			<div data-toggle="tooltip" title="<?php echo htmlspecialchars(nl2br($r['managers_notes_comment']))?>" class="text-warning"><span class="fa fa-question-circle"></span></div>			
		<?php elseif ($r['managers_notes_is_checked']): ?>
			<div data-toggle="tooltip" title="I checked this prod" class="text-success"><span class="fa fa-check-circle"></span></div>
		<?php endif; ?>
	</div>
	<div class="cell hidden-xs">
		<div data-toggle="tooltip" title="<?php echo '<strong>'.$r['status_info']['desc'].'</strong><br />Voting: '.($r['status_info']['voting'] ? 'On' : 'Off').'<br />Release: '.($r['status_info']['release'] ? 'On' : 'Off')?>" class="text text-<?php echo $r['status_info']['css-class']?>"><span class="<?php echo $r['status_info']['icon']?>"></span></div>
	</div>
	<div class="cell hidden-xs">
		<a href="<?php echo $Module->formatURL('update').'&record_id='.$r['id']?>">
			<img src="<?php echo $r['screenshot'] ? $r['screenshot']['tmb_prefix'].'64' : NFW::i()->assets('main/news-no-image.png')?>" />
		</a>
	</div>
	<div class="cell">
		<a href="<?php echo $Module->formatURL('update').'&record_id='.$r['id']?>">
			<span class="title"><?php echo htmlspecialchars($r['title'])?></span>
			<span class="by">by <?php echo htmlspecialchars($r['author'])?></span>
		</a>
		<div class="clearfix"></div>
		
		<div class="hidden-sm hidden-md hidden-lg">
			<div class="label label-primary label-platform"><?php echo htmlspecialchars($r['platform'])?></div>
			<?php echo $r['format'] ? '<div class="label label-primary label-platform label-format">'.htmlspecialchars($r['format']).'</div>' : ''?>
			
			<div class="text-muted" style="padding-top: 8px; padding-bottom: 8px; font-size: 10px; white-space: nowrap; overflow: scroll;"><em>Posted <?php echo date('d.m.Y H:i', $r['posted'])?> by <?php echo htmlspecialchars($r['posted_username'])?></em></div>
			
			<?php if ($r['release_link']): ?>
				<a href="<?php echo $r['release_link']['url']?>" class="btn btn-xs btn-success" title="Permanent archive link"><span class="fa fa-download" aria-hidden="true"></span> Download release</a>			
			<?php else: ?>
				<a id="make-release-link" href="#" class="btn btn-xs btn-default" title="Create permanent archive link"><span class="fa fa-download" aria-hidden="true"></span> Make release</a>
			<?php endif; ?>
		</div>
	</div>
	<div class="cell hidden-xs">
		<div>
			<div class="label label-primary label-platform"><?php echo htmlspecialchars($r['platform'])?></div>
		</div>
		<?php echo $r['format'] ? '<div class="label label-primary label-platform label-format">'.htmlspecialchars($r['format']).'</div>' : ''?>
	</div>
	<div class="cell hidden-xs">
		<div><?php echo date('d.m.Y H:i', $r['posted'])?></div>
		<div>by <?php echo htmlspecialchars($r['posted_username'])?></div>
	</div>
	<div class="cell hidden-xs">
		<?php if ($r['release_link']): ?>
			<a href="<?php echo $r['release_link']['url']?>" class="btn btn-sm btn-success" title="Permanent archive link"><span class="fa fa-download" aria-hidden="true"></span></a>			
		<?php else: ?>
			<a id="make-release-link" href="#" class="btn btn-sm btn-default" title="Create permanent archive link"><span class="fa fa-download" aria-hidden="true"></span></a>
		<?php endif; ?>
	</div>
</div>
<?php } ?>
		</div>
	</div>
<?php 		
	}