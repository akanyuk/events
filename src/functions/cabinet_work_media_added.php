<?php

function cabinet_work_media_added(media $CMedia) {
    // Reset `checked` status for all managers
    NFW::i()->db->query_build([
    'UPDATE' => 'works_managers_notes',
        'SET' => 'is_checked=0',
        'WHERE' => 'work_id=' . $CMedia->record['owner_id'],
    ]);
}