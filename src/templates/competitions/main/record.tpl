<?php
/**
 * @var object $Module
 * @var array $event
 * @var array $competitions
 * @var string $content
 * @var string $announcement
 */

$compoList = '';
if (!empty($competitions)) {
    ob_start();
    foreach ($competitions as $c) {
        echo '<h6>';
        if ($c['id'] == $Module->record['id']) {
            echo '<strong>' . htmlspecialchars($c['title']) . '</strong>';
        } else if ($c['release_status']['available'] && $c['release_works']) {
            echo '<a href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        } else if ($c['voting_status']['available'] && $c['voting_works']) {
            echo '<a href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        }
        echo '</h6>';
    }
    echo '<div class="mb-3">&nbsp;</div>';
    $compoList = ob_get_clean();
}

// NFWX::i()->mainLayoutRightContent contains `username` and `votekey` fields

// Main content
echo '<div class="d-block d-md-none"><div class="mb-5">' . $announcement . '</div>' . NFWX::i()->mainLayoutRightContent . '</div>' . $content;

NFWX::i()->mainLayoutRightContent = '<div class="d-none d-md-block"><div class="mb-5">' . $announcement . '</div>' . NFWX::i()->mainLayoutRightContent . '</div>' . $compoList;