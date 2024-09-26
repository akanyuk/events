<?php
/**
 * @var array $event
 * @var array $competition
 */

NFW::i()->registerFunction('display_work_media');

// Get release works
$CWorks = new works();
list($release_works) = $CWorks->getRecords(array(
    'load_attachments' => true,
    'load_attachments_icons' => false,
    'filter' => array('release_only' => true, 'competition_id' => $competition['id']),
    'ORDER BY' => 'sorting_place, w.average_vote DESC, w.total_scores DESC, w.position'
));

foreach ($release_works as $work) {
    echo display_work_media($work, [
            'rel' => 'release',
            'single' => false,
            'voting_system' => $event['voting_system'],
        ]) . '<hr />';
}
