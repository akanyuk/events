<?php

function works_add_form_before_submit() {
    ob_start();

?>
    <h2>Советы перед отправкой работы на конкурс</h2>

    <ol>
        <li>Не перепутать фестиваль. В данный момент работы принимаются сразу на два фестиваля в разных местах. Сейчас вы отправляете работу на фестиваль Undefined в Санкт-Петербурге</li>
        <li>Внимательно прочитайте правила на сайте, разделы [<a href="https://undefined.chaosconstructions.ru/#rules">rules</a>] и [<a href="https://undefined.chaosconstructions.ru/#compo">compo</a>]</li>
        <li>После отправки работы свяжитесь с модератором конкурса любым способом</li>
    </ol>
<?php
    return ob_get_clean();
}
