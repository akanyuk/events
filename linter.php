<?php

youtubeIframeCreator('');
vkVideoIframeCreator('');
rutubeIframeCreator('');
plvideoIframeCreator('');

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
$CWorksMedia->actionAdminDownloadFiles();

$CWorksActivity = new works_activity();
$CWorksActivity->actionAdminList();
$CWorksActivity->actionAdminMessage();
