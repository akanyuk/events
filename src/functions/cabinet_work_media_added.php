<?php

function cabinet_work_media_added(media $CMedia) {
    works_activity::authorAddFile($CMedia->record['owner_id'], $CMedia->record['basename']);
}