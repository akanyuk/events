<?php
NFW::i()->registerFunction('cache_media');

/**
 * @param array $work
 * @param array $options :
 *        $options['rel']            string     required    Relation to 'voting' or 'release'
 *        $options['single']         bool       required    Is single work or list
 *        $options['vote_options']   array
 * @return false|string
 */
function display_work_media($work = array(), $options = array()) {
	$links_icons = array(
		'download' => array('bg_pos' => '-16px 0px'),
		'default' => array('bg_pos' => '-32px 0px'),
			
		'youtube.com' 			=> array('title' => 'YouTube', 		'bg_pos' => '-48px 0px'),
		'youtu.be' 				=> array('title' => 'YouTube', 		'bg_pos' => '-48px 0px'),
		'csdb.dk' 				=> array('title' => 'CSDb', 		'bg_pos' => '-64px 0px'),
		'zxart.ee' 				=> array('title' => 'ZX-Art', 		'bg_pos' => '-80px 0px'),
		'demozoo.org' 			=> array('title' => 'Demozoo', 		'bg_pos' => '-96px 0px'),
		'artcity.bitfellas.org' => array('title' => 'ArtCity', 		'bg_pos' => '-112px 0px'),
		'pouet.net' 			=> array('title' => 'pouët.net',	'bg_pos' => '-128px 0px'),
		'soundcloud.com' 		=> array('title' => 'SoundCloud',	'bg_pos' => '-144px 0px'),
		'bbb.retroscene.org' 	=> array('title' => 'BBB',			'bg_pos' => '-160px 0px'),
		'zxn.ru' 				=> array('title' => 'BBB',			'bg_pos' => '-160px 0px'),
		'hypr.ru' 				=> array('title' => 'HYPE!',		'bg_pos' => '-176px 0px'),
		'hype.retroscene.org' 	=> array('title' => 'HYPE!',		'bg_pos' => '-176px 0px'),
		'pixeljoint.com' 		=> array('title' => 'Pixeljoint',	'bg_pos' => '-192px 0px'),
		'github.com' 			=> array('title' => 'GitHub',		'bg_pos' => '-208px 0px'),
		'scenemusic.net' 		=> array('title' => 'Nectarine',	'bg_pos' => '-224px 0px'),
		'scenestream.net' 		=> array('title' => 'Nectarine',	'bg_pos' => '-224px 0px'),
		'bandcamp.com' 			=> array('title' => 'Bandcamp',		'bg_pos' => '-240px 0px'),
	);
	
	// Resize images to
	$IMAGE_WIDTH = 640;

	$lang_main = NFW::i()->getLang('main');

	ob_start();
	echo '<div class="label label-platform" title="'.$lang_main['works platform'].'">'.htmlspecialchars($work['platform']).'</div>';
	if ($work['format']) {
		echo '<div class="label label-format" title="'.$lang_main['works format'].'">'.htmlspecialchars($work['format']).'</div>';
	}
	$platform_format = ob_get_clean();
	
	ob_start();
	
	echo '<div class="works-media-container" id="work-'.$work['id'].'">';	# special for external custom styling

	// Display header

	if ($options['rel'] == 'preview') {
		$header_title = '<h2>'.htmlspecialchars($work['title'].($work['author'] ? ' by '.$work['author'] : '')).'</h2>';
	} elseif ($options['rel'] == 'voting' && $options['single']) {
		$header_title = '<h2>'.htmlspecialchars($work['title']).'</h2>';
	} else if ($options['rel'] == 'voting' && !$options['single']) {
		$header_title = '<h3><a href="'.$work['main_link'].'">'.htmlspecialchars($work['title']).'</a></h3>';
	} else if ($options['rel'] == 'release' && $options['single']) {
		$header_title = '<h2>'.htmlspecialchars($work['title'].($work['author'] ? ' by '.$work['author'] : '')).'</h2>';
	} else if ($options['rel'] == 'release' && !$options['single']) {
		$header_title = '<h3><a href="'.$work['main_link'].'"/>'.htmlspecialchars($work['title'].($work['author'] ? ' by '.$work['author'] : '')).'</a></h3>';
	} else {
        $header_title = "";
    }
	
	if ($options['rel'] == 'voting' && !$options['single']) {
		$header_number = '<h3>'.$work['position'].'.</h3>';
	} elseif($options['rel'] == 'release' && $work['place']) {
		$header_number = '<span class="label label-success" style="font-size: 150%;">'.$work['place'].'</span>';
	} else {
		$header_number = false;
	}
	
	echo '<div class="header">';
	echo '<div class="row">';
	echo $header_number ? '<div class="cell cell-number">'.$header_number.'</div>' : '';
	echo '<div class="cell">'.$header_title.'</div>';
	echo '</div>';
		
	echo '<div class="row">';
	echo $header_number ? '<div class="cell"></div>' : '';
	echo '<div class="cell cell-platform">'.$platform_format.'</div>';
	echo '</div>';
	echo '</div>';

	// Try to fetch platform description into 'external_html'
	$lang_platform_description = NFW::i()->getLang('platform_description');
	if ($work['format'] && isset($lang_platform_description[$work['platform']][$work['works_type']][$work['format']])) {
		$pd = $lang_platform_description[$work['platform']][$work['works_type']][$work['format']];
	} else if (isset($lang_platform_description[$work['platform']][$work['works_type']]['default'])) {
		$pd = $lang_platform_description[$work['platform']][$work['works_type']]['default'];
	} else if (isset($lang_platform_description[$work['platform']]['default'][$work['format']])) {
		$pd = $lang_platform_description[$work['platform']]['default'][$work['format']];
	} else if (isset($lang_platform_description[$work['platform']]['default']['default'])) {
		$pd = $lang_platform_description[$work['platform']]['default']['default'];
	} else {
        $pd = array();
    }

	echo empty($pd) ? '' : '<ul class="platform-description"><li>'.implode('</li><li>', $pd).'</li></ul>';
	
	echo $work['author_note'] ? '<div class="author-note"><strong>'.$lang_main['works author note'].':</strong><br />'.nl2br($work['author_note']).'</div>' : '';
	
	echo $work['external_html'] ? '<div id="external-html">'.$work['external_html'].'</div>' : '';

	// Display content (image, audio, video)
	if (count($work['image_files']) > 1) {
		NFW::i()->registerResource('owl-carousel');

		echo '<div class="owl-carousel owl-theme">';
		foreach ($work['image_files'] as $f) {
			echo '<div class="item img-container"><img src="'.cache_media($f, $IMAGE_WIDTH).'" alt="" /></div>';
		}
		echo '</div>';
		
	} else {
		foreach ($work['image_files'] as $f) {
		    echo '<div class="img-container"><img src="'.cache_media($f, $IMAGE_WIDTH).'" alt="" /></div>';
        }
	}
	
	if (!empty($work['audio_files'])) {
		echo '<div style="padding: 5px 0;"><audio controls="controls" preload="">';
		foreach ($work['audio_files'] as $f) echo '<source src="'.cache_media($f).'" type="'.$f['mime_type'].'" />';
		echo $lang_main['voting audio not support'].'</audio></div>';
	}
	
	// Generate links row
	
	$links = array();
	
	if ($work['release_link']) {
		$links[] = array('is_dl' => true, 'url' => $work['release_link']['url'], 'title' => $lang_main['download'].' '.strtoupper(pathinfo($work['release_link']['url'], PATHINFO_EXTENSION)).' ('.$work['release_link']['filesize_str'].')');
	}
	elseif (($options['rel'] == 'voting' || $options['rel'] == 'preview')  && !empty($work['voting_files'])) {
		foreach ($work['voting_files'] as $f) {
			$links[] = array('is_dl' => true, 'url' => cache_media($f), 'title' => $lang_main['download'].' '.strtoupper($f['extension']).' ('.$f['filesize_str'].')');
		}
	}
	elseif ($options['rel'] == 'release' && !empty($work['release_files'])) {
		foreach ($work['release_files'] as $f) {
			$links[] = array('is_dl' => true, 'url' => cache_media($f), 'title' => $lang_main['download'].' '.strtoupper($f['extension']).' ('.$f['filesize_str'].')');
		}
	}
	
	$links = array_merge($links, $work['links']);
	
	if (!empty($links)) {
		echo '<div class="links">';
		
		foreach ($links as $l) {
			
			if (isset($l['is_dl']) &&  $l['is_dl']) {
				$title = $l['title'];
				$bg_pos = $links_icons['download']['bg_pos'];
			} else {
				$url = preg_replace('#^www\.(.+\.)#i', '$1', parse_url($l['url'], PHP_URL_HOST));
				if (isset($links_icons[$url])) {
					$title = $l['title'] ? $l['title'] : $links_icons[$url]['title'];
					$bg_pos = $links_icons[$url]['bg_pos'];
				} else {
					$title = $l['title'] ? $l['title'] : $url;
					$bg_pos = $links_icons['default']['bg_pos'];
				}
			}
			
			echo '<div class="item"><a href="'.$l['url'].'"><span class="icon" style="background-position: '.$bg_pos.';"></span>'.$title.'</a></div>';
		}
		
		echo '</div>';
	}

	echo '<div style="padding-top: 10px;">';
	
	if ($options['rel'] == 'voting' && isset($options['vote_options']) && !empty($options['vote_options'])) {
		echo '<select name="votes['.$work['id'].']" id="'.$work['id'].'" class="form-control" style="display: inline;">';
		foreach ($options['vote_options'] as $i=>$d) echo '<option value="'.$i.'">'.$d.'</option>';
		echo '</select>&nbsp;';
	}
	elseif ($options['rel'] == 'release' && $work['num_votes']) {
		echo 'vts:<strong>'.$work['num_votes'].'</strong> pts:<strong>'.$work['total_scores'].'</strong> avg:<strong>'.$work['average_vote'].'</strong>';
		if (isset($work['iqm_vote']) && $work['iqm_vote'] > 0) {
            echo ' iqm:<strong>'.$work['iqm_vote'].'</strong>';
        }
	}

	echo '</div>';	# <div style="padding-top: 10px;">

    if ($options['rel'] != 'preview' && !$options['single']) {
        echo '<div style="padding-top: 10px;"><a href="'.NFW::i()->absolute_path.'/'.$work['event_alias'].'/'.$work['competition_alias'].'/'.$work['id'].'#comments">'.$lang_main['works comments count'].': '.($work['comments_count'] ? '<span class="badge">'.$work['comments_count'].'</span>' : $work['comments_count']).'</a></div>';
    }

	echo '</div>';	# <div class="works-media-container">
	return ob_get_clean();
}