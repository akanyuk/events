<?php
function works_add_form_append() {
    $desc = 'Я согласен с переносом моей работы в другую номинацию, если в моей номинации не наберется 3х работ';
    $response = active_field(array('name' => 'agree_join_works', 'type' => 'bool', 'value' => true, 'desc' => $desc)).'<br /><br />';

    return $response;
}