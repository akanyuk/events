<?php foreach ($events as $record) { ?>
<div class="media" style="padding-bottom: 2em;">
	<div class="pull-left">
		<a href="<?php echo NFW::i()->base_path.$record['alias']?>">
			<img class="media-object" src="<?php echo $record['announce'] ? $record['announce'] : NFW::i()->assets('main/news-no-image.png')?>" />
		</a>
		<div style="line-height: 12px;"><small><?php echo $record['is_one_day'] ? date('d.m.Y', $record['date_from']) : date('d.m.Y', $record['date_from']).' -<br />'.date('d.m.Y', $record['date_to'])?></small></div>
	</div>
    <div class="media-body">
    	<div class="pull-right">
    		<span class="label <?php echo $record['status']['label-class']?>"><?php echo $record['status']['desc']?></span>
    	</div>
    	<h4 class="media-heading"><a href="<?php echo NFW::i()->base_path.$record['alias']?>"><?php echo htmlspecialchars($record['title'])?></a></h4>
    	<div class="clearfix"></div>
    	<?php if ($record['announcement']): ?>
    		<p style="padding-top: 0.5em;"><?php echo nl2br($record['announcement'])?></p>
    	<?php endif; ?>
    </div>
    <div class="clearfix"></div>
</div>
<?php } ?>