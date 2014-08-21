{ "aaData": [
	<?php $records_counter = 0; 
		foreach ($records as $r) { ?>[
		{ "id": <?php echo $r['id']?>, "is_active": <?php echo $r['is_active']?> },
		"<?php echo htmlspecialchars($r['title'])?>",
		"<?php echo htmlspecialchars($r['path'])?>",
		<?php echo $r['posted']?>,
		"<?php echo htmlspecialchars($r['posted_username'])?>"
	]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
]}