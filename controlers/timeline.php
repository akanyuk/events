<?php
$CTimeline = new timeline();
NFW::i()->assign('records', $CTimeline->getRecords());
NFW::i()->display('timeline.tpl');