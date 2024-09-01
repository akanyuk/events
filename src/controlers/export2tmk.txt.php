<?php
const COMPO_MODE_EXTERNAL_VIEW = 1;
const COMPO_MODE_IMAGES = 2;    // internal show images (jpg, png)
//const COMPO_MODE_AUDIO = 3;     // internal show audio (mp3/ogg)
const COMPO_MODE_VIDEO = 4;     // internal show video (mp4)

$CEvents = new events($_GET['event_id'] ?? false);
if (!$CEvents->record['id']) {
    NFW::i()->stop(404);
}

if (!in_array($CEvents->record['id'], events::get_managed())) {
    NFW::i()->stop(404);
}

$event = array(
    'eventTitle' => $CEvents->record['title'],
    'eventAlias' => $CEvents->record['alias']
);

$CCompetitions = new competitions();
$cur_index = 1;
$compos = $c2i = array();
foreach ($CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id']))) as $c) {
    $c2i[$c['id']] = $cur_index;

    $compos[$cur_index] = array(
        'compoId' => $c['id'],
        'compoAlias' => $c['alias'],
        'compoName' => $c['title'],
        'compoWorksType' => $c['works_type']
    );

    switch ($c['works_type']) {
        case 'demo':
            $compos[$cur_index]['compoShowAuthor'] = 1;
            $compos[$cur_index]['compoMode'] = COMPO_MODE_EXTERNAL_VIEW;
            break;
        case 'music':
        case 'picture':
            $compos[$cur_index]['compoShowAuthor'] = 0;
            $compos[$cur_index]['compoMode'] = COMPO_MODE_IMAGES;
            break;
        case 'other':
            $compos[$cur_index]['compoShowAuthor'] = 1;
            $compos[$cur_index]['compoMode'] = COMPO_MODE_VIDEO;
            break;
        default:
            $compos[$cur_index]['compoShowAuthor'] = 0;
            $compos[$cur_index]['compoMode'] = COMPO_MODE_EXTERNAL_VIEW;
            break;
    }

    $cur_index++;
}

$CWorks = new works();
$works_plain = array();
foreach ($CWorks->getRecords(array(
    'filter' => array('event_id' => $CEvents->record['id'], 'voting_only' => true),
    'load_attachments' => true,
    'load_attachments_icons' => false,
    'skip_pagination' => true)) as $w) {
    $works_plain[] = $w;
}

$CVote = new vote();
$votes = array();
foreach ($CVote->getResults($CEvents->record['id']) as $c) {
    foreach ($c['works'] as $v) {
        $votes[$v['id']] = array(
            'num_votes' => $v['num_votes'],
            'total_scores' => $v['total_scores'],
            'average_vote' => $v['average_vote'],
            'iqm_vote' => $v['iqm_vote'],
            'place' => $v['place'],
        );
    }
}

$works = array();
foreach ($compos as $compo_index => $c) {
    $works[$compo_index] = array();
    $cur_index = 1;
    foreach ($works_plain as $w) {
        if ($c2i[$w['competition_id']] == $compo_index) {
            $screenshot = $w['screenshot'] ? array(
                'url' => $w['screenshot']['url'],
                'filesize' => $w['screenshot']['filesize'],
                'mime_type' => $w['screenshot']['mime_type']
            ) : null;

            $images = array();
            foreach ($w['image_files'] as $f)
                $images[] = array(
                    'url' => $f['url'],
                    'filesize' => $f['filesize'],
                    'mime_type' => $f['mime_type']
                );

            $audio = array();
            foreach ($w['audio_files'] as $f)
                $audio[] = array(
                    'url' => $f['url'],
                    'filesize' => $f['filesize'],
                    'mime_type' => $f['mime_type']
                );

            $voting_files = array();
            foreach ($w['voting_files'] as $f)
                $voting_files[] = array(
                    'url' => $f['url'],
                    'filesize' => $f['filesize'],
                    'mime_type' => $f['mime_type']
                );

            $works[$compo_index][$cur_index++] = array(
                'workId' => $w['id'],
                'workTitle' => $w['title'],
                'workAuthor' => $w['author'],
                'workAuthorNote' => $w['author_note'],
                'Platform' => $w['platform'],
                'Format' => $w['format'],
                'Images' => $images,
                'Audio' => $audio,
                'VotingFiles' => $voting_files,
                'Screenshot' => $screenshot,
                'NumVotes' => $votes[$w['id']]['num_votes'] ?? null,
                'TotalScores' => $votes[$w['id']]['total_scores'] ?? null,
                'AverageVote' => $votes[$w['id']]['average_vote'] ?? null,
                'IQMVote' => $votes[$w['id']]['iqm_vote'] ?? null,
                'Place' => $votes[$w['id']]['place'] ?? null,
            );
        }
    }
}

ob_start();
if (isset($_GET['ResponseType']) && $_GET['ResponseType'] == 'json') {
    echo json_encode(array(
            'event' => $event,
            'compos' => $compos,
            'works' => $works
        )
    );
} else {
    echo '$event = ';
    var_export($event);
    echo ';';
    echo "\n\n";
    echo '$compos = ';
    var_export($compos);
    echo ';';
    echo "\n\n";
    echo '$works = ';
    var_export($works);
    echo ';';
}

header('Content-type: text/plain');
NFW::i()->stop(ob_get_clean());
