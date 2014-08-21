<?php

if (!NFW::i()->checkPermissions('settings', 'update')) {
	NFW::i()->stop('Wrong way!');
}

cleanAssets(PROJECT_ROOT.'assets');
NFW::i()->stop('done');


function cleanAssets($dir = '') {
	$files = scandir($dir);
	
	foreach($files as $f) {
		if ($f == '.' || $f == '..') continue;
		
		if (is_dir($dir.'/'.$f)) {
			cleanAssets($dir.'/'.$f);
			rmdir($dir.'/'.$f);
			continue;
		}
		
		unlink($dir.'/'.$f);
	}
}