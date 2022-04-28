<?php

function friendly_filesize($filepath) {
	$lang_media = NFW::i()->getLang('media');
	$size = filesize($filepath);
	
	if ($size >= 1048576)
		return number_format($size/1048576, 2, '.', ' ').$lang_media['mb'];
	elseif ($size >= 1024)
		return number_format($size/1024, 2, '.', ' ').$lang_media['kb'];
	else
		return $size.$lang_media['b'];
	
}