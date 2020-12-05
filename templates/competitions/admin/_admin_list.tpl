<?php foreach ($records as $r) { ?>
<div class="record" id="<?php echo $r['id']?>">
	<div class="cell" id="position"><?php echo $r['position']?></div>
	<div class="cell" id="title">
		<a href="<?php echo $Module->formatURL('update').'&record_id='.$r['id']?>"><?php echo htmlspecialchars($r['title'])?></a>
	</div>
	<div class="cell"><?php echo htmlspecialchars($r['alias'])?></div>
	<div class="cell"><?php echo htmlspecialchars($r['works_type'])?></div>
	<div class="cell"><?php echo $r['reception_from'] ? date('d.m.Y H:i', $r['reception_from']) : '-'?></div>
	<div class="cell"><?php echo $r['reception_to'] ? date('d.m.Y H:i', $r['reception_to']) : '-'?></div>
	<div class="cell"><?php echo $r['voting_from'] ? date('d.m.Y H:i', $r['voting_from']) : '-'?></div>
	<div class="cell"><?php echo $r['voting_to'] ? date('d.m.Y H:i', $r['voting_to']) : '-'?></div>
</div>
<?php } ?>