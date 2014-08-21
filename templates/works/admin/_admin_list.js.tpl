<?php ob_start(); ?>
{ 
	"sEcho":<?php echo $_POST['sEcho']?>, 
	"iTotalRecords":<?php echo $iTotalRecords?>, 
	"iTotalDisplayRecords":<?php echo $iTotalDisplayRecords?>, 
	"aaData": [
	<?php $records_counter = 0; 
		foreach ($records as $record) { ?>[
		    {
		    	"id": <?php echo $record['id']?>,    	
		    	"v": <?php echo $record['status_info']['voting'] ? '1' : '0'?>,
		    	"r": <?php echo $record['status_info']['release'] ? '1' : '0'?>,
		    	"s": "<?php echo $record['status_info']['desc']?>"
			},
			<?php echo $record['pos']?>,
			<?php echo json_encode($record['title'])?>,
			<?php echo json_encode($record['author'])?>,
			<?php echo $record['competition_id']?>,
			<?php echo json_encode($record['platform'])?>,
			<?php echo json_encode($record['format'])?>,
			[<?php echo $record['posted']?>, <?php echo json_encode($record['posted_username'])?>]
		]<?php if ($records_counter++ < count($records) - 1) echo ','; }?>
	],
	"current_competition": <?php echo intval($_POST['competition_id'])?>,
	"available_competitions": [
	<?php $records_counter = 0; 
		foreach ($available_competitions as $c) { ?>{
	    	"id": <?php echo $c['id']?>,    	
	    	"title": <?php echo json_encode($c['title'])?>
		}<?php if ($records_counter++ < count($available_competitions) - 1) echo ','; }?>
	]
}
<?php echo preg_replace('!\s+!u', ' ', ob_get_clean()); 