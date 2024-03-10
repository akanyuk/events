<?php
// Generate results.txt

$layout_type = isset($_REQUEST['layout']) ? $_REQUEST['layout'] : false;
$platform_show = isset($_REQUEST['platform']) && is_array($_REQUEST['platform']) ? $_REQUEST['platform'] : array();

// Get release works
$CWorks = new works();
list($release_works) = $CWorks->getRecords(array('filter' => array('release_only' => true, 'event_id' => $Module->record['id']), 'ORDER BY' => 'c.position, w.status, w.place'));

if ($layout_type == "diver") {
	
	$totalvotes = 0;
	if ($result = NFW::i()->db->query_build(array('SELECT'	=> 'count(distinct(`votekey_id`)) as `total`,`event_id` ', 'FROM' => 'votes', 'GROUP BY' => 'event_id', 'WHERE' => '`votekey_id`> 0 and `event_id` = '.$Module->record['id']))) {
		while ($record = NFW::i()->db->fetch_assoc($result)) {
			$totalvotes = $record["total"];
		}
	}
	
	$offline = 0;
	if ($result = NFW::i()->db->query_build(array('SELECT'	=> 'count(distinct(`username`)) as `total`,`event_id` ', 'FROM' => 'votes', 'GROUP BY' => 'event_id', 'WHERE' => '`votekey_id` = 0 and `event_id` = '.$Module->record['id']))) {
		while ($record = NFW::i()->db->fetch_assoc($result)) {
			$offline = $record["total"];
		}
	}
	
	echo '   '.htmlspecialchars($Module->record['title'])."\n";
	echo '   '.date('d.m.Y', $Module->record['date_from']).'-'.date('d.m.Y', $Module->record['date_to'])."\n";

	$header =  " # title                                                            vts pts  avg";
	$cur_competition = false;
	foreach ($release_works as $w) {
		if ($cur_competition != $w['competition_id']) {
			$cur_competition = $w['competition_id'];
			echo "\n";
			echo '   '.($w['competition_title']).str_repeat(' ',80-3 - mb_strlen(($w['competition_title']),'UTF-8'))."\n";
			echo "\n";
			echo $header."\n"."\n";
		}

		$desc = $w['title'].($w['author'] ? ' by '.$w['author'] : '');
		if (in_array($w['competition_id'], $platform_show)) $desc .= " [".($w["platform"])."]";

		echo ($w['place'] ? sprintf("%2s", $w['place']).' ' : ' - ');
		if (in_array($w['competition_id'], $platform_show)) $w['title'] = $w['title']." [".($w["platform"])."]";
		
		$pad = mb_strlen($w['title'],'UTF-8') > 35 ? 0 : 35 - mb_strlen($w['title'],'UTF-8');
		echo ($w['title']).str_repeat(' ', $pad);

		if (mb_strlen(($w['title']),'UTF-8')>35) echo "\n".str_repeat(' ',35+3);

		$pad = mb_strlen($w['author'],'UTF-8') > 30 ? 0 : 30 - mb_strlen($w['author'],'UTF-8');
		echo ($w['author']).str_repeat(' ', $pad);

		if (mb_strlen(($w['author']),'UTF-8')>30) echo "\n".str_repeat(' ',35+3+30);

		echo str_pad(($w['num_votes']),3," ",STR_PAD_LEFT)." ";
		echo str_pad(($w['total_scores']),3," ",STR_PAD_LEFT)." ";

		echo str_replace(".",",",$w['average_vote'])."\n";
	}

	echo "\n";
	echo ($totalvotes + $offline)." voters: ";
	if ($totalvotes) echo $totalvotes." online";
	if ($totalvotes && $offline) echo  " + ";
	if ($offline) echo $offline." at partyplace";
	echo "\n";
	echo "online party management system provided by nyuk";
}
else {
	echo htmlspecialchars($Module->record['title'])."\n";
	echo date('d.m.Y', $Module->record['date_from']).'-'.date('d.m.Y', $Module->record['date_to'])."\n";

	$cur_competition = false;
	foreach ($release_works as $w) {
		if ($cur_competition != $w['competition_id']) {
			$cur_competition = $w['competition_id'];
			echo "\n";
			echo '________'.htmlspecialchars($w['competition_title']).str_repeat('_',72 - mb_strlen(htmlspecialchars($w['competition_title']),'UTF-8'))."\n";
			echo "\n";
		}

		$desc = $w['title'].($w['author'] ? ' by '.$w['author'] : '');
		if (in_array($w['competition_id'],$platform_show)) $desc .= " [".($w["platform"])."]";

		$pad = mb_strlen($desc,'UTF-8') > 66 ? 0 : 66 - mb_strlen($desc,'UTF-8');
		echo ($w['place'] ? sprintf("%2s", $w['place']).'. ' : ' - ').$desc.str_repeat(' ', $pad).str_pad(($w['total_scores']),3," ",STR_PAD_LEFT)." ".$w['average_vote']."\n";
	}
}