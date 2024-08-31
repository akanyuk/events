<?php
// Resize images to
const IMAGE_WIDTH = 640;

NFW::i()->registerFunction('cache_media');

/**
 * @param array $work
 * @param array $options :
 *        $options['rel']            string     required    Relation to 'voting' or 'release'
 *        $options['single']         bool       required    Is single work or list
 *        $options['vote_options']   array
 * @return false|string
 */
function display_work_media(array $work = array(), array $options = array()) {
    $linksProps = array(
        'download' => array('bg_pos' => '-16px 0px'),
        'default' => array('bg_pos' => '-32px 0px'),

        'youtube.com' => array('title' => 'YouTube', 'bg_pos' => '-48px 0px', 'iframe' => "youtubeIframeCreator"),
        'youtu.be' => array('title' => 'YouTube', 'bg_pos' => '-48px 0px', 'iframe' => "youtubeIframeCreator"),
        'csdb.dk' => array('title' => 'CSDb', 'bg_pos' => '-64px 0px'),
        'zxart.ee' => array('title' => 'ZX-Art', 'bg_pos' => '-80px 0px'),
        'demozoo.org' => array('title' => 'Demozoo', 'bg_pos' => '-96px 0px'),
        'artcity.bitfellas.org' => array('title' => 'ArtCity', 'bg_pos' => '-112px 0px'),
        'pouet.net' => array('title' => 'pouët.net', 'bg_pos' => '-128px 0px'),
        'soundcloud.com' => array('title' => 'SoundCloud', 'bg_pos' => '-144px 0px'),
        'bbb.retroscene.org' => array('title' => 'BBB', 'bg_pos' => '-160px 0px'),
        'zxn.ru' => array('title' => 'BBB', 'bg_pos' => '-160px 0px'),
        'hypr.ru' => array('title' => 'HYPE!', 'bg_pos' => '-176px 0px'),
        'hype.retroscene.org' => array('title' => 'HYPE!', 'bg_pos' => '-176px 0px'),
        'pixeljoint.com' => array('title' => 'Pixeljoint', 'bg_pos' => '-192px 0px'),
        'github.com' => array('title' => 'GitHub', 'bg_pos' => '-208px 0px'),
        'scenemusic.net' => array('title' => 'Nectarine', 'bg_pos' => '-224px 0px'),
        'scenestream.net' => array('title' => 'Nectarine', 'bg_pos' => '-224px 0px'),
        'bandcamp.com' => array('title' => 'Bandcamp', 'bg_pos' => '-240px 0px'),
        'vk.com' => array('title' => 'VK', 'bg_pos' => '-256px 0px', 'iframe' => "vkVideoIframeCreator"),
    );

    $lang_main = NFW::i()->getLang('main');

    ob_start();
    echo '<div class="label label-platform" title="' . $lang_main['works platform'] . '">' . htmlspecialchars($work['platform']) . '</div>';
    if ($work['format']) {
        echo '<div class="label label-format" title="' . $lang_main['works format'] . '">' . htmlspecialchars($work['format']) . '</div>';
    }
    $platform_format = ob_get_clean();

    ob_start();

    echo '<div class="works-media-container" id="work-' . $work['id'] . '">';    # special for external custom styling

    // Display header

    if ($options['rel'] == 'preview') {
        $header_title = '<h2>' . htmlspecialchars($work['title'] . ($work['author'] ? ' by ' . $work['author'] : '')) . '</h2>';
    } elseif ($options['rel'] == 'voting' && $options['single']) {
        $header_title = '<h2>' . htmlspecialchars($work['title']) . '</h2>';
    } else if ($options['rel'] == 'voting' && !$options['single']) {
        $header_title = '<h3><a href="' . $work['main_link'] . '">' . htmlspecialchars($work['title']) . '</a></h3>';
    } else if ($options['rel'] == 'release' && $options['single']) {
        $header_title = '<h2>' . htmlspecialchars($work['title'] . ($work['author'] ? ' by ' . $work['author'] : '')) . '</h2>';
    } else if ($options['rel'] == 'release' && !$options['single']) {
        $header_title = '<h3><a href="' . $work['main_link'] . '"/>' . htmlspecialchars($work['title'] . ($work['author'] ? ' by ' . $work['author'] : '')) . '</a></h3>';
    } else {
        $header_title = "";
    }

    if ($options['rel'] == 'voting' && !$options['single']) {
        $header_number = '<h3>' . $work['position'] . '.</h3>';
    } elseif ($options['rel'] == 'release' && $work['place']) {
        $header_number = '<span class="label label-place" style="font-size: 150%;">' . $work['place'] . '</span>';
    } else {
        $header_number = false;
    }

    echo '<div class="header">';
    echo '<div class="row">';
    echo $header_number ? '<div class="cell cell-number">' . $header_number . '</div>' : '';
    echo '<div class="cell">' . $header_title . '</div>';
    echo '</div>';

    echo '<div class="row">';
    echo $header_number ? '<div class="cell"></div>' : '';
    echo '<div class="cell cell-platform">' . $platform_format . '</div>';
    echo '</div>';
    echo '</div>';
    echo platformDescription($work);

    echo $work['author_note'] ? '<div class="author-note"><strong>' . $lang_main['works author note'] . ':</strong><br />' . nl2br($work['author_note']) . '</div>' : '';


    list($linksHTML, $navHTML) = prepareWorkLinks($lang_main, $work, $linksProps, $options['rel']);

    echo '<div class="additional-html">' . $work['external_html'] . '</div>' . $navHTML . '<div id="work-iframe"></div>';

    if (!empty($work['audio_files'])) {
        echo '<div style="padding: 5px 0;"><audio controls="controls" preload="">';
        foreach ($work['audio_files'] as $f) echo '<source src="' . cache_media($f) . '" type="' . $f['mime_type'] . '" />';
        echo $lang_main['voting audio not support'] . '</audio></div>';
    }

    echo $linksHTML;

    if ($options['rel'] != 'preview' && !$options['single']) {
        echo '<div style="padding-top: 10px;"><a class="btn btn-default" href="' . NFW::i()->absolute_path . '/' . $work['event_alias'] . '/' . $work['competition_alias'] . '/' . $work['id'] . '#comments">' . $lang_main['works comments count'] . ' ' . ($work['comments_count'] ? '<span class="badge">' . $work['comments_count'] . '</span>' : '') . '</a></div>';
    }

    echo '<div style="padding-top: 15px;">';
    if ($options['rel'] == 'voting' && !empty($options['vote_options'])) {
        echo '<select name="votes[' . $work['id'] . ']" id="' . $work['id'] . '" class="form-control work-vote" style="display: inline;">';
        foreach ($options['vote_options'] as $i => $d) echo '<option value="' . $i . '">' . $d . '</option>';
        echo '</select>';
    } elseif ($options['rel'] == 'release' && $work['num_votes']) {
        echo 'vts:<strong>' . $work['num_votes'] . '</strong> pts:<strong>' . $work['total_scores'] . '</strong> avg:<strong>' . $work['average_vote'] . '</strong>';
        if (isset($work['iqm_vote']) && $work['iqm_vote'] > 0) {
            echo ' iqm:<strong>' . $work['iqm_vote'] . '</strong>';
        }
    }
    echo '</div>'; # <div style="padding-top: 10px;">

    if ($options['rel'] == 'voting') {
        echo '
            <div style="padding-top: 10px;">
                <textarea class="form-control work-comment" name="comment[' . $work['id'] . ']" placeholder="' . $lang_main['works your comment'] . '"></textarea>
            </div>';
    }

    echo '</div>';    # <div class="works-media-container">

    return ob_get_clean();
}

// Generate links row
function prepareWorkLinks($langMain, $work, $linksProps, $rel): array {
    $linksHTML = [];
    $navHTML = [];

    foreach ($work['image_files'] as $f) {
        $iframe = '<div class="img-container"><img src="' . cache_media($f, IMAGE_WIDTH) . '" alt="" /></div>';
        $navHTML[] = '<li><a data-role="work-iframe-toggle" data-iframe="' . htmlspecialchars($iframe) . '" href="' . $f['url'] . '">' . ucfirst($f['filename']) . '</a></li>';
    }

    foreach ($work['links'] as $l) {
        $linkURL = $l['url'];
        if (stripos($linkURL, 'vk.com/video_ext.php') !== false) {
            $linkURL = vkVideoIframeParse($l['url']);
            if ($linkURL == "") {
                continue;
            }
        }

        $url = preg_replace('#^www\.(.+\.)#i', '$1', parse_url($linkURL, PHP_URL_HOST));
        if (isset($linksProps[$url])) {
            $title = $l['title'] ?: $linksProps[$url]['title'];
            $bgPos = $linksProps[$url]['bg_pos'];
            if (isset($linksProps[$url]['iframe'])) {
                list($iframe, $linkURL) = $linksProps[$url]['iframe']($linkURL);
                if ($iframe != "") {
                    $navHTML[] = '<li role="presentation"><a href="' . $linkURL . '" data-role="work-iframe-toggle" data-iframe="' . htmlspecialchars($iframe) . '"><span class="icon" style="background-position: ' . $bgPos . ';"></span>' . $title . '</a></li>';
                    continue;
                }
            }
        } else {
            $title = $l['title'] ?: $url;
            $bgPos = $linksProps['default']['bg_pos'];
        }

        $linksHTML[] = '<div class="item"><a href="' . $linkURL . '"><span class="icon" style="background-position: ' . $bgPos . ';"></span>' . $title . '</a></div>';
    }

    if ($work['release_link']) {
        $linksHTML[] = '<div class="item"><a href="' . $work['release_link']['url'] . '"><span class="icon" style="background-position: ' . $linksProps['download']['bg_pos'] . ';"></span>' . $langMain['download'] . ' ' . strtoupper(pathinfo($work['release_link']['url'], PATHINFO_EXTENSION)) . ' (' . $work['release_link']['filesize_str'] . ')' . '</a></div>';
    } else if (($rel == 'voting' || $rel == 'preview') && !empty($work['voting_files'])) {
        foreach ($work['voting_files'] as $f) {
            $linksHTML[] = '<div class="item"><a href="' . cache_media($f) . '"><span class="icon" style="background-position: ' . $linksProps['download']['bg_pos'] . ';"></span>' . $langMain['download'] . ' ' . strtoupper($f['extension']) . ' (' . $f['filesize_str'] . ')' . '</a></div>';
        }
    } else if ($rel == 'release' && !empty($work['release_files'])) {
        foreach ($work['release_files'] as $f) {
            $linksHTML[] = '<div class="item"><a href="' . cache_media($f) . '"><span class="icon" style="background-position: ' . $linksProps['download']['bg_pos'] . ';"></span>' . $langMain['download'] . ' ' . strtoupper($f['extension']) . ' (' . $f['filesize_str'] . ')' . '</a></div>';
        }
    }

    return [
        empty($linksHTML) ? '' : '<div class="links">' . implode('', $linksHTML) . '</div>',
        empty($navHTML) ? '' : '<ul id="work-frames-nav" class="nav nav-pills" style="display: ' . (count($navHTML) > 1 ? 'block' : 'none') . '">' . implode('', $navHTML) . '</ul>',
    ];
}

function vkVideoIframeParse($iframe): string {
    preg_match('/src=\"(.*)\".*/isU', $iframe, $match);
    if (count($match) < 2) {
        return "";
    }
    $src = $match[1];

    $query = parse_url($src, PHP_URL_QUERY);
    if (!$query) {
        return "";
    }

    parse_str($query, $params);
    if (!isset($params['oid']) || !isset($params['id'])) {
        return "";
    }

    return 'https://vk.com/video-' . str_replace('-', '', $params['oid']) . '_' . $params['id'] . (isset($params['hash']) ? '&hash=' . $params['hash'] : '');
}

function vkVideoIframeCreator($url): array {
    preg_match('%video-(\d*)_(\d*)%i', $url, $match);
    if (count($match) < 3) {
        return ["", $url];
    }
    $oid = $match[1];
    $id = $match[2];

    $hashStr = '';
    $query = parse_url($url, PHP_URL_QUERY);
    if ($query) {
        parse_str($query, $params);
        $hashStr = isset($params['hash']) ? '&hash=' . $params['hash'] : '';
    }

    return [
        '<iframe src="https://vk.com/video_ext.php?oid=-' . $oid . '&id=' . $id . $hashStr . '&hd=1" width="640" height="360" allow="autoplay; encrypted-media; fullscreen; picture-in-picture; screen-wake-lock;" allowfullscreen style="border: none;"></iframe>',
        preg_replace('%(&hash=.*)&?#?%i', '', $url),
    ];
}

function youtubeIframeCreator($url): array {
    preg_match('%(?:youtube(?:-nocookie)?\.com/(?:[^/]+/.+/|(?:v|e(?:mbed)?)/|.*[?&]v=)|youtu\.be/)([^"&?/ ]{11})%i', $url, $match);
    if (count($match) < 2) {
        return ["", $url];
    }
    return [
        '<iframe width="640" height="360" src="https://www.youtube.com/embed/' . $match[1] . '" allow="autoplay; encrypted-media; fullscreen; picture-in-picture; screen-wake-lock;" allowfullscreen style="border: none;"></iframe>',
        $url
    ];
}

function platformDescription($work): string {
    if (!isset($work['platform']) || $work['platform'] == "") {
        return '';
    }

    // Try to fetch platform description into 'external_html'
    $langPD = NFW::i()->getLang('platform_description');

    if ($work['format'] && isset($langPD[$work['platform']][$work['works_type']][$work['format']])) {
        $pd = $langPD[$work['platform']][$work['works_type']][$work['format']];
    } else if (isset($langPD[$work['platform']][$work['works_type']]['default'])) {
        $pd = $langPD[$work['platform']][$work['works_type']]['default'];
    } else if (isset($langPD[$work['platform']]['default'][$work['format']])) {
        $pd = $langPD[$work['platform']]['default'][$work['format']];
    } else if (isset($langPD[$work['platform']]['default']['default'])) {
        $pd = $langPD[$work['platform']]['default']['default'];
    } else {
        return '';
    }

    return '<ul class="platform-description"><li>' . implode('</li><li>', $pd) . '</li></ul>';
}