<?php ob_start(); ?>
{ "aaData": [
	<?php $records_counter = 0; 
		foreach ($records as $r) { ?>[
		{ "id": <?php echo $r['id']?>, "event_id": <?php echo $r['event_id']?> },
		<?php echo $r['pos']?>,
		<?php echo json_encode($r['title'])?>,
		<?php echo json_encode($r['event_alias'].'/'.$r['alias'])?>,
		<?php echo $r['reception_from']?>,
		<?php echo $r['reception_to']?>,
		<?php echo $r['voting_from']?>,
		<?php echo $r['voting_to']?>
	]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
]}
<?php echo preg_replace('!\s+!u', ' ', ob_get_clean()); 