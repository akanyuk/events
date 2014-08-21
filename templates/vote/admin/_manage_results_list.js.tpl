<?php 
$rows = array();
foreach ($records as $competition) {
	$rows[] = '["",'.json_encode($competition['title']).',"","",""]';

	foreach ($competition['works'] as $record) {
		$rows[] = '['.$record['place'].','.json_encode($record['title']).','.$record['num_votes'].','.$record['total_scores'].','.$record['average_vote'].']';
	}
}
?>
{
	"iTotalRecords":<?php echo count($rows)?>, 
	"iTotalDisplayRecords":<?php echo count($rows)?>,
	"aaData": [<?php echo implode(',', $rows)?>]
} 