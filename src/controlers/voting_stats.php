<?php
NFW::i()->current_controler = 'main';

if (isset($_POST['competition_id']) && isset($_POST['chapter']) && in_array($_POST['chapter'], array('timeline', 'countries'))) {
	call_user_func('display_statistic_'.$_POST['chapter'], $_POST['competition_id']);
}

// Main form
$CPages = new pages();

NFW::i()->main_search_box = false;		
NFW::i()->main_right_pane = false;		

NFW::i()->assign('page', array(
	'title' => 'Voting statistics',
	'path' => 'voting_stats',
	'content' => $CPages->renderAction('voting_stats'),
));
NFW::i()->display('main.tpl');


function display_statistic_timeline($competition_id) {
	$CCompetitoins = new competitions($competition_id);
	if (!$CCompetitoins->record['id']) {
		NFW::i()->renderJSON(array('result' => 'error', 'message' => 'Wrong competition.'));
	}
	
	if (!$CCompetitoins->record['release_status']['available']) {
		NFW::i()->renderJSON(array('result' => 'error', 'message' => 'Voting not closed.'));
	}
	
	if (!$CCompetitoins->record['release_works']) {
		NFW::i()->renderJSON(array('result' => 'error', 'message' => 'Released works not found.'));
	}
	
	// Fetch stats
	$CVote = new vote();
	list($votes) = $CVote->getVotes(array(
		'filter' => array(
			'competition_id' => $CCompetitoins->record['id']
		),
		'ORDER BY' => 'v.posted',
	));
	
	if (empty($votes)) {
		NFW::i()->renderJSON(array('result' => 'empty'));
	}
	
	// PreProcess votes

	// Collect offline votes, headers
	$first_vote = reset($votes);
	$first_hour = date('d.m.y H', $first_vote['posted']).'MSK';
	$titles = $header_titles = $count_total = $pre_stats = array();
	foreach ($votes as $vkey=>$v) {
		$key = $v['work_place'] ? sprintf('%02d', $v['work_place']).'-'.$v['work_id'] : $v['work_id'];
		$title = ($v['work_place'] ? $v['work_place'].'. '.$v['work_title'] : $v['work_title']).' by '.$v['work_author'];

		if (!isset($titles[$key])) {
			$titles[$key] = $title;
			$header_titles[$key] = json_encode($title);
			$count_total[$key] = array('num_votes' => 0, 'total_scores' => 0, 'title' => $title);
		}

		if ($v['votekey_id']) continue;

		$count_total[$key]['num_votes']++;
		$count_total[$key]['total_scores'] += $v['vote'];

		if (isset($pre_stats[$first_hour][$key])) {
			$pre_stats[$first_hour][$key]['num_votes']++;
			$pre_stats[$first_hour][$key]['total_scores'] += $v['vote'];
		}
		else {
			$pre_stats[$first_hour][$key] = $count_total[$key];
		}

		unset($votes[$vkey]);
	}

	// Collect online votes
	foreach ($votes as $vkey=>$v) {
		$key = $v['work_place'] ? sprintf('%02d', $v['work_place']).'-'.$v['work_id'] : $v['work_id'];
		$title = ($v['work_place'] ? $v['work_place'].'. '.$v['work_title'] : $v['work_title']).' by '.$v['work_author'];
		$hour = date('d.m.y H', $v['posted']).'MSK';

		if (!isset($count_total[$key])) {
			$titles[$key] = $title;
			$header_titles[$key] = '"'.$title.'"';
			$count_total[$key] = array('num_votes' => 0, 'total_scores' => 0, 'title' => $title);
		}

		$count_total[$key]['num_votes']++;
		$count_total[$key]['total_scores'] += $v['vote'];

		if (isset($pre_stats[$hour][$key])) {
			$pre_stats[$hour][$key]['num_votes']++;
			$pre_stats[$hour][$key]['total_scores'] += $v['vote'];
		}
		else {
			$pre_stats[$hour][$key] = $count_total[$key];
		}
	}

	ksort($titles);
	ksort($header_titles);

	// Calculate average
	$stats = array();
	foreach ($pre_stats as $hour=>$p1) {
		foreach ($p1 as $p) {
			$stats[$hour][$p['title']] = array(
				'tot' => $p['total_scores'],
				'num' => $p['num_votes'],
				'avg' => $p['num_votes'] ? round($p['total_scores'] / $p['num_votes'], 2) : 0
			);
		}
	}

	// Generate output
	$data = '["Average",'.implode(',', $header_titles).'],';

	$counter = 0; $previous = array();
	foreach ($stats as $date=>$row) {
		$votes = array();
		foreach ($titles as $title) {
			$value = isset($row[$title]) ? $row[$title] : (isset($previous[$title]) ? $previous[$title] : array('avg' => 'null', 'num' => 0, 'tot' => 0));
			$previous[$title] = $value;
			$votes[] = '{ "v": '.$value['avg'].', "f": "avg: '.$value['avg'].', pts: '.$value['tot'].', vts: '.$value['num'].'" }';
		}
		$votes = '["'.$date.'",'.implode(',', $votes).']';

		$data .= $counter++ == count($stats) - 1 ? $votes : $votes.',';
	}

	NFW::i()->renderJSON(array('result' => 'success', 'data' => '['.$data.']'));
}

function display_statistic_countries($competition_id) {
	$CCompetitoins = new competitions($competition_id);
	if (!$CCompetitoins->record['id']) {
		NFW::i()->stop('<div class="alert alert-danger">Wrong competition.</div>');
	}
	
	if (!$CCompetitoins->record['release_status']['available']) {
		NFW::i()->stop('<div class="alert alert-danger">Voting not closed.</div>');
	}
	
	if (!$CCompetitoins->record['release_works']) {
		NFW::i()->stop('<div class="alert alert-danger">Released works not found.</div>');
	}
	
	
	// Fetch stats
	
	$query = array(
		'SELECT' => 'w.title, IF(v.votekey_id,\'online\',\'partyplace\') AS source, v.poster_ip',
		'FROM' => 'votes AS v',
		'JOINS' => array(
			array(
				'INNER JOIN'=> 'works AS w',
				'ON'		=> 'w.id=v.work_id'
			),
		),
		'WHERE' => 'w.competition_id='.$CCompetitoins->record['id'],
		'ORDER BY' => 'source, v.posted'
	);
	if (!$result = NFW::i()->db->query_build($query)) {
		NFW::i()->stop('<div class="alert alert-danger">Unable to fetch stats</div>');
	}
	if (!NFW::i()->db->num_rows($result)) {
		NFW::i()->stop('<div class="alert alert-info">Nothing found.</div>');
	}
	
	require_once(NFW_ROOT.'helpers/SxGeo/SxGeo.php');
	$SxGeo = new SxGeo(PROJECT_ROOT.'var/SxGeo.dat');
	
	$stats = array();
	$countries = array();
	while($record = NFW::i()->db->fetch_assoc($result)) {
		$key = $record['source'] == 'partyplace' ? 'Partyplace' : $SxGeo->get($record['poster_ip']);
		$countries[$key] = 1;
	
		if (isset($stats[$record['title']][$key])) {
			$stats[$record['title']][$key]++;
		}
		else {
			$stats[$record['title']][$key] = 1;
		}
		
		
	}
	

	// Generate output
	
	ob_start();
?>
<table class="table table-striped table-condensed table-hover"><thead>
	<tr>
		<th>&nbsp;</th>
		<?php foreach ($countries as $country=>$foo) echo '<th>'.$country.'</th>'?>
	</tr>
</thead><tbody>
<?php foreach ($stats as $title=>$stat) { ?>
	<tr>
		<td><?php echo htmlspecialchars($title)?></td>
		<?php foreach ($countries as $country=>$foo) {
			echo '<td>'.(isset($stat[$country]) ? $stat[$country] : '0') .'</th>';
		} ?>
	</tr>
<?php } ?>
</tbody></table>
<?php 	

	NFW::i()->stop(ob_get_clean());
}