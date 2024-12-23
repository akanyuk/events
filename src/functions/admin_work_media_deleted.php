<?php

function admin_work_media_deleted(media $CMedia) {
    works_interaction::adminDeleteFile($CMedia->record['owner_id'], $CMedia->record['basename']);
}