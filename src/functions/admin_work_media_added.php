<?php

function admin_work_media_added(media $CMedia) {
    works_interaction::adminAddFile($CMedia->record['owner_id'], $CMedia->record['basename']);
}