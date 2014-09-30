<?php
$CCompetitoins = new competitions(isset($_GET['competition_id']) ? $_GET['competition_id'] : false);
if (!$CCompetitoins->record['id']) {
	NFW::i()->stop(404);
}

$CVote = new vote();
list($votes) = $CVote->getVotes(array(
	'filter' => array(
		'competition_id' => $CCompetitoins->record['id']
	),
	'ORDER BY' => 'v.posted',
));

if (empty($votes)) {
	NFW::i()->stop('Nothing found', 'error-page');
}

$pre_stats = $count_total = array();
foreach ($votes as $v) {
	$title = $v['work_title'];
	$hour = date('d.m.y H', $v['posted']).'MSK';
	
	if (!isset($count_total[$title])) $count_total[$title] = array('num_votes' => 0, 'total_scores' => 0);

	if (!isset($pre_stats[$hour][$title])) $pre_stats[$hour][$title] = $count_total[$title];

	$pre_stats[$hour][$title]['num_votes']++;
	$pre_stats[$hour][$title]['total_scores'] += $v['vote'];
	
	$count_total[$title]['num_votes']++;
	$count_total[$title]['total_scores'] += $v['vote'];
}

// Calculate average
$stats = array();
foreach ($pre_stats as $hour=>$p1) {
	foreach ($p1 as $title=>$p) {
		$stats[$hour][$title] = array(
			'tot' => $p['total_scores'],
			'num' => $p['num_votes'],
			'avg' => round($p['total_scores'] / $p['num_votes'], 2)
		);
	}
}

// Generate output
$titles = $header_titles = array();
foreach (end($stats) as $title => $foo) {
	$header_titles[] = '"'.htmlspecialchars($title).'"'; 
	$titles[] = $title;
}
$data = '[ \'Average\', '.implode(',', $header_titles).'],'."\n";

$counter = 0; $previous = array();
foreach ($stats as $date=>$row) {
	$votes = array();
	foreach ($titles as $title) {
		$value = isset($row[$title]) ? $row[$title] : (isset($previous[$title]) ? $previous[$title] : array('avg' => 0, 'num' => 0, 'tot' => 0));
		$previous[$title] = $value;
		$votes[] = '{ v: '.$value['avg'].', f: \'avg: '.$value['avg'].'\, pts: '.$value['tot'].'\, vts: '.$value['num'].'\' }';
	}
	$votes = '[\''.$date.'\','.implode(',', $votes).']';
	
	$data .= $counter++ == count($stats) - 1 ? $votes."\n" : $votes.','."\n";
}
/*
FB::log($data);
header('Content-type: text/plain');
NFW::i()->stop($data);
*/
ob_start();
?>
<html><head><title><?php echo htmlspecialchars($CCompetitoins->record['title'])?> (Average vote)</title>
<script type="text/javascript" src="https://www.google.com/jsapi"></script>
<script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        var data = google.visualization.arrayToDataTable([<?php echo $data?>]);

        var options = {
          title: '<?php echo htmlspecialchars($CCompetitoins->record['title'])?> (Average vote)'
        };

        var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

        chart.draw(data, options);
      }
</script>
</head>
<body>
	<div id="chart_div" style="width: 1000px; height: 600px;"></div>
</body>
</html>
<?php
$page_content = ob_get_clean();
NFW::i()->stop($page_content); 