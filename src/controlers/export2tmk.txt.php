<?php 

$CEvents = new events(isset($_GET['event_id']) ? $_GET['event_id'] : false);
if (!$CEvents->record['id']) {
	NFW::i()->stop(404);
}

if (!in_array($CEvents->record['id'], events::get_managed())) {
	NFW::i()->stop(404);
}

$CCompetitions = new competitions();
$cur_index = 1;
$compos = $c2i = array();
foreach ($CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))) as $c) {
	$c2i[$c['id']] = $cur_index;
	
	$compos[$cur_index] = array(
		'compoName' => $c['title'],
		'compoWorksType' => $c['works_type']				
	);
	
	switch ($c['works_type']) {
		case 'demo':
			$compos[$cur_index]['compoShowAuthor'] = 1;
			$compos[$cur_index]['compoMode'] = 1;
			break;
		case 'picture':
			$compos[$cur_index]['compoShowAuthor'] = 0;
			$compos[$cur_index]['compoMode'] = 2;
			break;
		case 'music':
			$compos[$cur_index]['compoShowAuthor'] = 3;
			$compos[$cur_index]['compoMode'] = 2;
			break;
		case 'other':
			$compos[$cur_index]['compoShowAuthor'] = 1;
			$compos[$cur_index]['compoMode'] = 4;
			break;
		default:
			$compos[$cur_index]['compoShowAuthor'] = 0;
			$compos[$cur_index]['compoMode'] = 1;
			break;			
	}
	
	$cur_index++;
}

$CWorks = new works();
$works_plain = array();
foreach ($CWorks->getRecords(array(
	'filter' => array('event_id' => $CEvents->record['id'], 'voting_only' => true),
	'load_attachments' => true,
	'skip_pagination' => true)) as $w) {
	$works_plain[] = $w;
}

$works = array();
foreach ($compos as $compo_index=>$c) {
	$works[$compo_index] = array();
	$cur_index = 1;
	foreach ($works_plain as $w) {
		if ($c2i[$w['competition_id']] == $compo_index) {
			$images = array();
			foreach ($w['image_files'] as $f) $images[] = $f['url'];
			
			$audio = array();
			foreach ($w['audio_files'] as $f) $audio[] = $f['url'];
				
			$voting_files = array();
			foreach ($w['voting_files'] as $f) $voting_files[] = $f['url'];
				
			$works[$compo_index][$cur_index++] = array(
				'workTitle' => $w['title'],
				'workAuthor' => $w['author'],
				'Platform' => $w['platform'],
				'Format' => $w['format'],
				'Images' => $images,
				'Audio' => $audio,
				'VotingFiles' => $voting_files
			);
		}
	}
}

ob_start();
if (isset($_GET['ResponseType']) && $_GET['ResponseType'] == 'json') {
	echo json_encode(array(
		'compos' => $compos,
		'works' => $works
		)
	);
}
else {
	echo '$compos = ';
	var_export($compos); echo ';';
	echo "\n\n";
	echo '$works = ';
	var_export($works); echo ';';
}

header('Content-type: text/plain');
NFW::i()->stop(ob_get_clean());

/*
compoMode:
1 - external view
2 - internal show images (jpg, png)
3 - internal show audio (mp3/ogg)
4 - internal show video (mp4)

$compos = array(
1 => array(
'compoName' => 'HiEnd 1k Intro',
'compoShowAuthor' => 1,
'compoMode' => 1,
),
2 => array(
'compoName' => 'HiEnd 16mb Demo',
'compoShowAuthor' => 1,
'compoMode' => 1,
),
);
$works = array(
1 => array(
1 => array(
'workTitle' => 'ii',
'workAuthor' => 'g0blinish',
),
2 => array(
'workTitle' => 'Tet 1k intro',
'workAuthor' => 'Sh',
),

),
);
 */