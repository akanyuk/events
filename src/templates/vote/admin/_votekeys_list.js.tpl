<?php ob_start(); ?>
{ 
	"sEcho":<?php echo $_POST['sEcho']?>, 
	"iTotalRecords":<?php echo $iTotalRecords?>, 
	"iTotalDisplayRecords":<?php echo $iTotalDisplayRecords?>, 
	"aaData": [
<?php
	$records_counter = 0; 
	foreach ($records as $record) { ?>
	[
	    [<?php echo $record['id'].',"'.$record['votekey'].'", '.$record['is_used']?>],
	    "<?php echo $record['email']?>",
		<?php echo $record['posted']?>,
		[ "<?php echo logs::get_browser($record['useragent'])?>", "<?php echo $record['useragent']?>" ],
		"<?php echo $record['poster_ip']?>"
	]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
]}
<?php echo preg_replace('!\s+!u', ' ', ob_get_clean()); 