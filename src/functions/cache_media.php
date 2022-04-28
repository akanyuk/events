<?php
/*
 * Кэшируем `media` файл в каталог `cache`
 * Например, при проигрывании аудио-файлов
*/
function cache_media($record, $new_width = false, $new_height = false) {
	$basename = iconv("UTF-8", NFW::i()->cfg['media']['fs_encoding'], $record['id'].'_'.$record['basename']);
    $src_path = iconv("UTF-8", NFW::i()->cfg['media']['fs_encoding'], $record['fullpath']);

	if (!file_exists($src_path)) {
	    return '';
    }

	if (!file_exists(PROJECT_ROOT.'cache/'.$basename)) {
		copy($src_path, PROJECT_ROOT.'cache/'.$basename);
	}
		
	if ($new_width || $new_height) {
		// resize image
		$new_file = _cache_media_tmb($basename, $new_width, $new_height);
	} else {
		$new_file = NFW::i()->absolute_path.'/cache/'.$basename;
	}
	
	return iconv(NFW::i()->cfg['media']['fs_encoding'], "UTF-8", $new_file);
}

/*
 * Генератор превью картинок из каталога `cache` в том же каталоге
* Размер превью определяется ключами --w% --h% в имени файла.
*/
function _cache_media_tmb($basename, $tmb_width = 0, $tmb_height = 0) {
	if (!file_exists(PROJECT_ROOT.'/cache/'.$basename)) {
	    return false;
    }

	if (!$tmb_width && !$tmb_height) {
	    return NFW::i()->absolute_path.'/cache/'.$basename;
    }

	$path_parts = pathinfo($basename);
	$filename = rawurldecode($path_parts['filename']);
	$basename = $filename.(isset($path_parts['extension']) ? '.'.rawurldecode($path_parts['extension']) : '');

	$tmb_dir = NFW::i()->absolute_path.'/cache/';
	$tmb_filename = $filename;
	if ($tmb_width) {
	    $tmb_filename .= '--w'.$tmb_width;
    }
	if ($tmb_height) {
	    $tmb_filename .= '--h'.$tmb_height;
    }
	if (isset($path_parts['extension'])) {
	    $tmb_filename = $tmb_filename.'.'.$path_parts['extension'];
    }
	if (file_exists(PROJECT_ROOT.'/cache/'.$tmb_filename)) {
	    return $tmb_dir.$tmb_filename;
    }

	if (!$result = getimagesize(PROJECT_ROOT.'/cache/'.$basename)) {
	    return false;
    }
	list($src_width, $src_height, $img_type) = $result;
	$img_type = str_replace('jpeg', 'jpg', image_type_to_extension($img_type, false));

	// Determine new image dimension
	$max_width  = $tmb_width > 0 && $tmb_width < 16384 ? intval($tmb_width) : 16384;
	$max_height  = $tmb_height > 0 && $tmb_height < 16384 ? intval($tmb_height) : 16384;

	if ($max_width > $src_width) {
	    $max_width = $src_width;
    }
	if ($max_height > $src_height) {
	    $max_height = $src_height;
    }

	$ratio = 1;

	if ($max_width) {
        $ratio = $max_width / $src_width;
    }
	if ($max_height) {
        $ratio = ($max_height / $src_height < $ratio) ? $max_height / $src_height : $ratio;
    }

	$width  = intval($src_width * $ratio);
	$height = intval($src_height * $ratio);

	if (!$width) {
	    $width = 1;
    }
	if (!$height) {
	    $height = 1;
    }

	if ($ratio == 1) {
		// Show original image without resizing
		return NFW::i()->absolute_path.'/cache/'.$basename;
	}

	// Create resized image
	switch ($img_type) {
		case 'jpg':
			$src_img = @imagecreatefromjpeg(PROJECT_ROOT.'/cache/'.$basename);
			$img = imagecreatetruecolor($width, $height);
			imagecopyresampled ($img, $src_img, 0,0,0,0, $width, $height, $src_width, $src_height);
			imagejpeg($img, PROJECT_ROOT.'cache/'.$tmb_filename, media::JPEG_QUALITY);
			break;
		case 'png':
			$src_img = @imagecreatefrompng(PROJECT_ROOT.'/cache/'.$basename);
			$img = imagecreatetruecolor($width, $height);
			imagecopyresampled ($img, $src_img, 0,0,0,0, $width, $height, $src_width, $src_height);
			imagepng($img, PROJECT_ROOT.'cache/'.$tmb_filename);
			break;
		case 'gif':
			$src_img = @imagecreatefromgif(PROJECT_ROOT.'/cache/'.$basename);
			$img = imagecreate($width, $height);
			imagecopyresampled ($img, $src_img, 0,0,0,0, $width, $height, $src_width, $src_height);
			imagegif($img, PROJECT_ROOT.'cache/'.$tmb_filename);
			break;
        default:
            return false;
	}

	imagedestroy($img);
	imagedestroy($src_img);

	return $tmb_dir.$tmb_filename;
}