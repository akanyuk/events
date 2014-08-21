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
		<?php echo $record['id']?>,
	    ["<?php echo $record['votekey']?>", <?php echo $record['numvotes']?>],
	    "<?php echo $record['email']?>",
		<?php echo $record['posted']?>,
		[ "<?php echo $record['browser']?>", "<?php echo $record['useragent']?>" ],
		"<?php echo $record['poster_ip']?>"
	]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
]}
<?php echo preg_replace('!\s+!u', ' ', ob_get_clean()); 