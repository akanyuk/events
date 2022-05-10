<?php
/**
 * @var object $Module
 * @var array $event
 * @var array $competitions
 * @var string $content
 */
NFW::i()->hook("competitions_record", $event['alias'], array('event' => $event));

echo $content;

if (empty($competitions)) {
    return;
}

echo '<div class="event-competitions">';
echo '<h3><a href="'.NFW::i()->absolute_path.'/'.$event['alias'].'">'.htmlspecialchars($event['title']).'</a></h3>';
foreach ($competitions as $key=>$c) {
    $title = $c['position'].'. '.htmlspecialchars($c['title']);

    echo '<h5>';
    if ($c['id'] == $Module->record['id']) {
        echo '<strong>'.$title.'</strong>';
    } else if ($c['release_status']['available'] && $c['release_works']) {
        echo '<a href="'.NFW::i()->absolute_path.'/'.$c['event_alias'].'/'.$c['alias'].'">'.$title.'</a>';
    } else if($c['voting_status']['available'] && $c['voting_works']) {
        echo '<a href="'.NFW::i()->absolute_path.'/'.$c['event_alias'].'/'.$c['alias'].'">'.$title.'</a>';
    } else {
        echo '<div class="text-muted">'.$title.'</div>';
    }
    echo '</h5>';
}
echo '</div>';