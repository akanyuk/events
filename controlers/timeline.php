<?php
$CTimeline = new timeline();
$CTimeline->path_prefix = 'main';

NFW::i()->assign('records', $CTimeline->getRecords());
NFW::i()->display('timeline.tpl');