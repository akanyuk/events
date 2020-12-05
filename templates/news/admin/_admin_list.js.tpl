<?php ob_start(); ?>
{ 
"sEcho":<?php echo $_POST['sEcho']?>, 
"iTotalRecords":<?php echo $iTotalRecords?>, 
"iTotalDisplayRecords":<?php echo $iTotalDisplayRecords?>, 
"aaData": [
	<?php $records_counter = 0; 
		foreach ($records as $r) { ?>[
		{ "id": <?php echo $r['id']?> },
		<?php echo json_encode($r['title'])?>,
		<?php echo $r['posted']?>,
		"<?php echo htmlspecialchars($r['posted_username'])?>"
	]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
]}
<?php echo preg_replace('!\s+!u', ' ', ob_get_clean()); 