<?php

function competitions_record($hook_additional) {
    // Finding votekey from request
    if (isset($_GET['key'])) {
        $CVote = new vote();

        if ($CVote->checkVotekey($_GET['key'], $hook_additional['event']['id'])) {
            $votekey = $_GET['key'];
            NFW::i()->setCookie('votekey', $votekey);
        }
    }
}