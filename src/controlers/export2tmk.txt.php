<?php
const COMPO_MODE_EXTERNAL_VIEW = 1;
const COMPO_MODE_IMAGES = 2;    // internal show images (jpg, png)
//const COMPO_MODE_AUDIO = 3;     // internal show audio (mp3/ogg)
const COMPO_MODE_VIDEO = 4;     // internal show video (mp4)

$CEvents = new events($_GET['event_id'] ?? false);
if (!$CEvents->record['id']) {
    NFW::i()->stop(404);
}

if (!in_array($CEvents->record['id'], events::getManaged())) {
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

$calcBy = $CEvents->record['voting_system'];

$CVote = new vote();
$votes = array();
foreach ($CVote->getResults($CEvents->record['id'], $calcBy) as $c) {
    foreach ($c['works'] as $v) {
        switch ($calcBy) {
            case "iqm":
                $score = $v['iqm_vote'];
                break;
            case "sum":
                $score = $v['total_scores'];
                break;
            default:
                $score = $v['average_vote'];
        }

        $votes[$v['id']] = array(
            'num_votes' => $v['num_votes'],
            'total_scores' => $v['total_scores'],
            'score' => $score,
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
                'Sum' => $votes[$w['id']]['total_scores'] ?? null,
                'Score' => $votes[$w['id']]['score'] ?? null,
                'Place' => $votes[$w['id']]['place'],
            );
        }
    }
}

ob_start();

if (isset($_GET['ResponseType']) && $_GET['ResponseType'] == 'json') {
    NFWX::i()->jsonSuccess([
        'event' => $event,
        'compos' => $compos,
        'works' => $works
    ]);
}

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

header('Content-type: text/plain');
NFW::i()->stop(ob_get_clean());
