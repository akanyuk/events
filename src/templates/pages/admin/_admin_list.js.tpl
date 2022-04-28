<?php ob_start(); ?>
{ "aaData": [
	<?php $records_counter = 0; 
		foreach ($records as $r) { ?>[
		{ "id": <?php echo $r['id']?>, "is_active": <?php echo $r['is_active']?> },
		<?php echo json_encode($r['title'])?>,
		"<?php echo htmlspecialchars($r['path'])?>",
		<?php echo intval($r['edited'])?>,
		<?php echo json_encode($r['edited_username'])?>
	]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
]}
<?php echo preg_replace('!\s+!u', ' ', ob_get_clean()); 