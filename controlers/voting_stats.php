<?php
$CEvents = new events();
$events = $CEvents->getRecords();
NFW::i()->setUI('bootstrap');

// Determine current event
$cur_event = reset($events);
if (isset($_GET['event_id'])) foreach ($events as $e) {
	if ($e['id'] == $_GET['event_id']) {
		$cur_event = $e; 
		break;
	}	
}

$CCompetitoins = new competitions();
$competitions = $CCompetitoins->getRecords(array('filter' => array('event_id' => $cur_event['id'])));

// Determine current competition
$cur_competition = reset($competitions);
if (isset($_GET['competition_id'])) foreach ($competitions as $c) {
	if ($c['id'] == $_GET['competition_id']) {
		$cur_competition = $c;
		break;
	}
}

// No competitions in selected event
if (!$cur_competition) {
	$CPages = new pages();
	$CPages->path_prefix = 'main';
	$page = $CPages->loadPage('/');
	$page['title'] = 'Voting statistics';
	$page['content'] = $CPages->renderAction(array(
			'events' => $events,
			'cur_event' => $cur_event,
	), 'voting_stats');
	$page['disable_right_pane'] = true;
	NFW::i()->assign('page', $page);
	NFW::i()->display('main.tpl');	
} 

// Fetch stats
$CVote = new vote();
list($votes) = $CVote->getVotes(array(
	'filter' => array(
		'competition_id' => $cur_competition['id']
	),
	'ORDER BY' => 'v.posted',
));

if (empty($votes)) {
	$data = false;
}
else {
	// PreProcess votes
	
	// Collect offline votes, headers
	$first_vote = reset($votes);
	$first_hour = date('d.m.y H', $first_vote['posted']).'MSK';
	$titles = $header_titles = $count_total = $pre_stats = array();
	foreach ($votes as $vkey=>$v) {
		$key = $v['work_place'] ? sprintf('%02d', $v['work_place']).'-'.$v['work_id'] : $v['work_id']; 
		$title = $v['work_place'] ? $v['work_place'].'. '.$v['work_title'] : $v['work_title'];
		
		if (!isset($titles[$key])) {
			$titles[$key] = $title;
			$header_titles[$key] = '"'.$title.'"';
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
		$title = $v['work_place'] ? $v['work_place'].'. '.$v['work_title'] : $v['work_title'];
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
	$data = '[ \'Average\', '.implode(',', $header_titles).'],'."\n";
	
	$counter = 0; $previous = array();
	foreach ($stats as $date=>$row) {
		$votes = array();
		foreach ($titles as $title) {
			$value = isset($row[$title]) ? $row[$title] : (isset($previous[$title]) ? $previous[$title] : array('avg' => 'null', 'num' => 0, 'tot' => 0));
			$previous[$title] = $value;
			$votes[] = '{ v: '.$value['avg'].', f: \'avg: '.$value['avg'].', pts: '.$value['tot'].', vts: '.$value['num'].'\' }';
		}
		$votes = '[\''.$date.'\','.implode(',', $votes).']';
	
		$data .= $counter++ == count($stats) - 1 ? $votes."\n" : $votes.','."\n";
	}
}

// Render page

$CPages = new pages();
$CPages->path_prefix = 'main';
$page = $CPages->loadPage('/');
$page['title'] = 'Voting statistics';
$page['content'] = $CPages->renderAction(array(
	'events' => $events,
	'cur_event' => $cur_event,
	'competitions' => $competitions,
	'cur_competition' => $cur_competition,
	'data' => $data
), 'voting_stats');
$page['disable_right_pane'] = true;
NFW::i()->assign('page', $page);
NFW::i()->display('main.tpl');