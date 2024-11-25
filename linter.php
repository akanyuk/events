<?php

$CVote = new vote();
$CVote->actionAdminVotekeys();
$CVote->actionAdminVotes();
$CVote->actionAdminAddVote();
$CVote->actionAdminResults();

$CWorks = new works();
$CWorks->actionAdminAdmin();
$CWorks->actionAdminGetPos();
$CWorks->actionAdminSetPos();
$CWorks->actionAdminInsert();
$CWorks->actionAdminUpdate();
$CWorks->actionAdminDelete();
$CWorks->actionAdminPreview();
$CWorks->actionAdminUpdateWork();
$CWorks->actionAdminUpdateStatus();
$CWorks->actionAdminUpdateLinks();
$CWorks->actionAdminMyStatus();

$CWorkInteraction = new works_interaction();
$CWorkInteraction->actionAdminList();