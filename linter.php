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

$CWorksMedia = new works_media();
$CWorksMedia->actionAdminRenameFile();
$CWorksMedia->actionAdminPreviewZx();
$CWorksMedia->actionAdminConvertZx();
$CWorksMedia->actionAdminFileIdDiz();
$CWorksMedia->actionAdminMakeRelease();
$CWorksMedia->actionAdminRemoveRelease();
$CWorksMedia->actionAdminUpdateProperties();

$CWorksInteraction = new works_interaction();
$CWorksInteraction->actionAdminList();
$CWorksInteraction->actionAdminMessage();
