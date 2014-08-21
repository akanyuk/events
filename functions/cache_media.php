<?php
/*
 * Кэшируем `media` файл в каталог `cache`
 * Например, при проигрывании аудио-файлов
*/
function cache_media($record) {
	$basename = $record['id'].'_'.$record['basename'];
	if (file_exists(PROJECT_ROOT.'cache/'.$basename)) {
		return NFW::i()->absolute_path.'/cache/'.$basename;
	}
		
	copy($record['fullpath'], PROJECT_ROOT.'cache/'.$basename);
	
	return NFW::i()->absolute_path.'/cache/'.$basename;
}