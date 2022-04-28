<?php ob_start(); ?>
{
	"sEcho":<?php echo $_POST['sEcho']?>, 
	"iTotalRecords":<?php echo $iTotalRecords?>, 
	"iTotalDisplayRecords":<?php echo $iTotalDisplayRecords?>, 
	"aaData": [
	<?php $logs_counter = 0; 
		foreach ($logs as $log) { ?>[
		<?php echo $log['posted']?>,
		"<?php echo htmlspecialchars($log['message_full'])?>",
		"<?php echo htmlspecialchars($log['poster_username'])?>",
		{ "browser": "<?php echo (($log['browser']) ? htmlspecialchars($log['browser']) : 'unknown')?>", "url": "<?php echo $log['url']?>" }, <?php /*{ "browser" : "<?php echo (($log['browser']) ? htmlspecialchars($log['browser']) : 'unknown')?>", "url": "<?php echo $log['url']?>" }, */?>
		"<?php echo $log['ip']?>"
	]<?php if ($logs_counter++ < count($logs) - 1) echo ','; }?>
]}
<?php echo preg_replace('!\s+!u', ' ', ob_get_clean());