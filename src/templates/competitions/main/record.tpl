<?php
/**
 * @var object $Module
 * @var array $event
 * @var array $competitions
 * @var string $content
 */
echo $content;

if (empty($competitions)) {
    return;
}

echo '<div class="event-competitions">';
echo '<h3><a href="'.NFW::i()->absolute_path.'/'.$event['alias'].'">'.htmlspecialchars($event['title']).'</a></h3>';
foreach ($competitions as $c) {
    echo '<h5>';
    if ($c['id'] == $Module->record['id']) {
        echo '<strong>'.htmlspecialchars($c['title']).'</strong>';
    } else if ($c['release_status']['available'] && $c['release_works']) {
        echo '<a href="'.NFW::i()->absolute_path.'/'.$c['event_alias'].'/'.$c['alias'].'">'.htmlspecialchars($c['title']).'</a>';
    } else if($c['voting_status']['available'] && $c['voting_works']) {
        echo '<a href="'.NFW::i()->absolute_path.'/'.$c['event_alias'].'/'.$c['alias'].'">'.htmlspecialchars($c['title']).'</a>';
    }
    echo '</h5>';
}
echo '</div>';