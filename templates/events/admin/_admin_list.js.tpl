<?php ob_start(); ?>
{ "aaData": [
	<?php $records_counter = 0; 
		foreach ($records as $r) { ?>[
		{ "id": <?php echo $r['id']?>, "hide": <?php echo $r['is_hidden']?> },
		<?php echo json_encode($r['title'])?>,
		<?php echo json_encode($r['alias'])?>,
		<?php echo $r['date_from']?>,
		<?php echo $r['date_to']?>
	]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
]}
<?php echo preg_replace('!\s+!u', ' ', ob_get_clean()); 