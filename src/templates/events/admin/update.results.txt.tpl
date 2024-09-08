<?php
/**
 * @var $Module events
 */

// Generate results.txt

$CWorks = new works();
list($release_works) = $CWorks->getRecords(array('filter' => array('release_only' => true, 'event_id' => $Module->record['id']), 'ORDER BY' => 'c.position, w.status, w.place'));

echo htmlspecialchars($Module->record['title']) . "\n";
echo date('d.m.Y', $Module->record['date_from']) . '-' . date('d.m.Y', $Module->record['date_to']) . "\n";
echo 'Voting system: '.$Module->record['voting_system'] . "\n";

$curCompo = false;
foreach ($release_works as $w) {
    if ($curCompo != $w['competition_id']) {
        $curCompo = $w['competition_id'];
        echo "\n";
        echo htmlspecialchars($w['competition_title']) . "\n";
        echo "\n";
    }

    $desc = $w['title'] . ($w['author'] ? ' by ' . $w['author'] : '');

    $pad = mb_strlen($desc, 'UTF-8') > 66 ? 0 : 66 - mb_strlen($desc, 'UTF-8');

    switch ($Module->record['voting_system']) {
        case "iqm":
            $val = ' ' . $w['iqm_vote'];
            break;
        case "sum":
            $val = '';
            break;
        default:
            $val = ' ' . $w['average_vote'];
    }

    echo ($w['place'] ? sprintf("%2s", $w['place']) . '. ' : ' - ') . $desc . str_repeat(' ', $pad) . str_pad(($w['total_scores']), 3, " ", STR_PAD_LEFT) . $val . "\n";
}
