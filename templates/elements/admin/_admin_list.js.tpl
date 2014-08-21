{ "aaData": [
	<?php $records_counter = 0; 
		foreach ($records as $r) { ?>[
		<?php echo json_encode($r['title'])?>,
		{ "id": <?php echo $r['id']?>, "editable": <?php echo $r['editable']?> }
	]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
]}