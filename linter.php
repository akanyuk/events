<?php

$CVote = new vote();
$CVote->actionAdminVotekeys();
$CVote->actionAdminVotes();
$CVote->actionAdminAddVote();
$CVote->actionAdminResults();

$CWorks = new works();
$CWorks->actionCabinetList();
$CWorks->actionCabinetView();
$CWorks->actionCabinetAdd();
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
