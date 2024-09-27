<?php
/**
 * @var competitions $Module
 * @var array $event
 * @var array $competitions
 * @var array $competitionsGroups
 * @var string $content
 * @var string $announcement
 */

NFW::i()->registerFunction('competitions_list_short');
$compoList = competitions_list_short(
    $competitionsGroups,
    $competitions,
    $event['hide_works_count'],
    true,
    $Module->record['id']
);

// !!! NFWX::i()->mainLayoutRightContent already contains `username` and `votekey` fields

// Main content
echo '<div class="d-block d-md-none"><div class="mb-5">' . $announcement . '</div>' . NFWX::i()->mainLayoutRightContent . '</div>' . $content;

NFWX::i()->mainLayoutRightContent = '<div class="d-none d-md-block"><div class="mb-5">' . $announcement . '</div>' . NFWX::i()->mainLayoutRightContent . '</div>' . $compoList;