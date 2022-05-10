<?php

function works_add_save_success($hook_additional) {
    // Append to description
    if ($hook_additional['post']['agree_join_works']) {
        $message = 'Автор согласен с объединением номинаций';
    } else {
        $message = 'Автор НЕ согласен с объединением номинаций';
    }

    $description = $hook_additional['record']['description'] . "\n\n" . $message;
    $query = array(
        'UPDATE' => 'works',
        'SET' => 'description=\'' . NFW::i()->db->escape($description) . '\'',
        'WHERE' => 'id=' . $hook_additional['record']['id']
    );

    NFW::i()->db->query_build($query);
}

