<?php
// Resize images to
const IMAGE_WIDTH = 640;

NFW::i()->registerFunction('cache_media');
NFW::i()->registerFunction('place_suffix');

/**
 * @param array $work
 * @param array $options :
 *        $options['rel']            string   required    Relation to 'voting' or 'release'
 *        $options['single']         bool     required    Is single work or list
 *        $options['vote_options']   array
 *        $options['voting_system']  string               enum: avg, iqm, sum
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
        'vkvideo.ru' => array('title' => 'VK', 'bg_pos' => '-256px 0px', 'iframe' => "vkVideoIframeCreator"),
        'modarchive.org' => array('title' => 'The Mod Archive', 'bg_pos' => '-272px 0px'),
        'rutube.ru' => array('title' => 'Rutube', 'bg_pos' => '-288px 0px', 'iframe' => 'rutubeIframeCreator'),
        'plvideo.ru' => array('title' => 'Platforma', 'bg_pos' => '-304px 0px', 'iframe' => 'plvideoIframeCreator'),
        'disk.yandex.ru' => array('title' => 'Yandex Disk', 'bg_pos' => '-320px 0px'),
    );

    $langMain = NFW::i()->getLang('main');

    $platformFormat = '<div class="badge badge-platform me-1 mb-2" title="' . $langMain['works attributes']['platform'] . '">' . htmlspecialchars($work['platform']) . '</div>';
    if ($work['format']) {
        $platformFormat .= '<div class="badge badge-format" title="' . $langMain['works attributes']['format'] . '">' . htmlspecialchars($work['format']) . '</div>';
    }

    ob_start();

    echo '<div class="work-container">';

    // Display header

    if ($options['rel'] == 'release' && $work['place']) {
        $place = '<span class="badge badge-place me-2">' . $work['place'] . '<span class="suffix">' . place_suffix($work['place']) . '</span></span>';
    } else {
        $place = "";
    }

    if ($options['rel'] == 'preview') {
        $title = '<h2>' . htmlspecialchars($work['title'] . ($work['author'] ? ' by ' . $work['author'] : '')) . '</h2>';
    } elseif ($options['rel'] == 'voting' && $options['single']) {
        $title = '<h2>' . htmlspecialchars($work['title']) . '</h2>';
    } else if ($options['rel'] == 'voting' && !$options['single']) {
        $title = '<h2>' . $work['position'] . '. <a href="' . $work['main_link'] . '#title">' . htmlspecialchars($work['title']) . '</a></h2>';
    } else if ($options['rel'] == 'release' && $options['single']) {
        $title = '<h2>' . htmlspecialchars($work['title'] . ($work['author'] ? ' by ' . $work['author'] : '')) . '</h2>';
    } else if ($options['rel'] == 'release' && !$options['single']) {
        $title = '<h2><a href="' . $work['main_link'] . '#title"/>' . htmlspecialchars($work['title'] . ($work['author'] ? ' by ' . $work['author'] : '')) . '</a></h2>';
    } else {
        $title = "";
    }

    echo '<section id="title">';
    echo '<div class="d-flex align-items-center gap-1 mb-2">' . $place . $title . '</div>';
    echo $platformFormat . platformDescription($work);
    echo '</section>';

    if ($work['author_note']) {
        echo '<div class="alert alert-info d-flex align-items-center">
        <svg class="flex-shrink-0 me-3" width="2em" height="2em" data-bs-toggle="tooltip"
             data-bs-title="' . $langMain['works attributes']['author_note'] . '">
            <use xlink:href="#icon-circle-fill"/>
        </svg>
        <div>' . nl2br($work['author_note']) . '</div>
    </div>';
    }

    list($linksHTML, $navHTML) = prepareWorkLinks($langMain, $work, $linksProps, $options['rel']);

    echo '<div class="mb-3">' . $work['external_html'] . '</div>' . $navHTML . '<div id="work-iframe"></div>';

    if (!empty($work['audio_files'])) {
        echo '<div class="mb-3"><audio controls="controls" preload="">';
        foreach ($work['audio_files'] as $f) echo '<source src="' . cache_media($f) . '" type="' . $f['mime_type'] . '" />';
        echo $langMain['voting audio not support'] . '</audio></div>';
    }

    echo $linksHTML;

    echo '<div class="mb-3 d-flex gap-2">';
    if ($options['rel'] == 'voting' && !empty($options['vote_options'])) {
        echo '<div class="btn-group btn-group-sm gap-2 w-640" role="group" aria-label="Voting options">';
        foreach ($options['vote_options'] as $i => $d) {
            if ($i == 0) {
                continue;
            }

            $tooltip = $d === "" || strval($i) === $d ? '' : 'data-bs-toggle="tooltip" data-bs-title="' . htmlspecialchars($d) . '"';
            echo '<button type="button" class="btn btn-outline-success btn-vote" ' . $tooltip . '
                data-role="vote" data-work-id="' . $work['id'] . '" data-vote-value="' . $i . '">' . $i . '</button>';
        }
        echo '</div>';
    } elseif ($options['rel'] == 'release' && $work['num_votes']) {
        $vs = isset($options['voting_system']) && $options['voting_system'] ? $options['voting_system'] : 'avg';

        echo '<div>vts:<strong>' . $work['num_votes'] . '</strong></div>';

        $sum = 'sum:<strong>' . $work['total_scores'] . '</strong>';
        if ($vs == 'sum') {
            $sum = '<span class="badge badge-vts">' . $sum . '</span>';
        }
        echo '<div>' . $sum . '</div>';

        $avg = 'avg:<strong>' . $work['average_vote'] . '</strong>';
        if ($vs == 'avg') {
            $avg = '<span class="badge badge-vts">' . $avg . '</span>';
        }
        echo '<div>' . $avg . '</div>';

        if (isset($work['iqm_vote']) && $work['iqm_vote'] > 0) {
            $iqm = 'iqm:<strong>' . $work['iqm_vote'] . '</strong>';
            if ($vs == 'iqm') {
                $iqm = '<span class="badge badge-vts">' . $iqm . '</span>';
            }
            echo '<div>' . $iqm . '</div>';
        }
    }
    echo '</div>';

    $actionLinks = [];
    if ($options['rel'] != 'preview' && !$options['single']) {
        $actionLinks[] = '<a class="btn btn-primary" href="' . $work['main_link'] . '#comments">' . $langMain['works comments count'] . ' ' . ($work['comments_count'] ? '<span class="badge rounded-circle text-bg-secondary">' . $work['comments_count'] . '</span>' : '') . '</a>';
    }
    if ($work['posted_by'] == NFW::i()->user['id'] && $options['rel'] != 'preview') {
        $actionLinks[] = '<a class="btn btn-warning" href="' . NFW::i()->absolute_path . '/cabinet/works_view?record_id=' . $work['id'] . '" title="Open in &laquo;My Files&raquo;"><svg width="1em" height="1em"><use href="#icon-house-gear-fill"></use></svg></a>';
    }
    if (in_array($work['event_id'], events::getManaged()) && $options['rel'] != 'preview') {
        $actionLinks[] = '<a class="btn btn-warning" href="' . NFW::i()->absolute_path . '/admin/works?action=update&record_id=' . $work['id'] . '" title="Edit work"><svg width="1em" height="1em"><use href="#icon-gear-fill"></use></svg></a>';
    }
    if (count($actionLinks) > 0) {
        echo '<div class="mb-3 d-flex gap-1">' . implode('', $actionLinks) . '</div>';
    }

    echo '</div>';

    return ob_get_clean();
}

// Generate links row
function prepareWorkLinks($langMain, $work, $linksProps, $rel): array {
    $linksHTML = [];
    $navHTML = [];

    foreach ($work['image_files'] as $f) {
        $iframe = '<div class="img-container mb-3"><img src="' . cache_media($f, IMAGE_WIDTH) . '" alt="" /></div>';
        $navHTML[] = '<li class="nav-item"><a class="nav-link" data-role="work-iframe-toggle" data-iframe="' . htmlspecialchars($iframe) . '" href="' . $f['url'] . '">' . ucfirst($f['filename']) . '</a></li>';
    }

    foreach ($work['links'] as $l) {
        $linkURL = $l['url'];
        if (stripos($linkURL, 'vk.com/video_ext.php') !== false || stripos($linkURL, 'vkvideo.ru/video_ext.php') !== false) {
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
                    $navHTML[] = '<li class="nav-item"><a class="nav-link" href="' . $linkURL . '" data-role="work-iframe-toggle" data-iframe="' . htmlspecialchars($iframe) . '"><span class="icon" style="background-position: ' . $bgPos . ';"></span>' . $title . '</a></li>';
                    $linksHTML[] = '<div class="item"><a href="' . $linkURL . '" target="_blank"><span class="icon" style="background-position: ' . $bgPos . ';"></span>' . $title . '</a></div>';
                    continue;
                }
            }
        } else {
            $title = $l['title'] ?: $url;
            $bgPos = $linksProps['default']['bg_pos'];
        }

        $linksHTML[] = '<div class="item"><a href="' . $linkURL . '" target="_blank"><span class="icon" style="background-position: ' . $bgPos . ';"></span>' . $title . '</a></div>';
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
        empty($navHTML) ? '' : '<ul id="work-frames-nav" class="nav nav-underline mb-2" style="display: ' . (count($navHTML) > 1 ? 'flex' : 'none') . '">' . implode('', $navHTML) . '</ul>',
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

    return 'https://vkvideo.ru/video-' . str_replace('-', '', $params['oid']) . '_' . $params['id'] . (isset($params['hash']) ? '?hash=' . $params['hash'] : '');
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
        '<iframe width="640" height="360" src="https://vkvideo.ru/video_ext.php?oid=-' . $oid . '&id=' . $id . $hashStr . '&hd=1" allow="autoplay; encrypted-media; fullscreen; picture-in-picture; screen-wake-lock;" allowfullscreen style="border: none;"></iframe>',
        preg_replace('%([&?]hash=.*)&?#?%i', '', $url),
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

function rutubeIframeCreator($url): array {
    $parsedURL = parse_url($url);
    $p = explode('/', trim($parsedURL['path'], '/'));

    $url = 'https://rutube.ru/play/embed/' . end($p);

    parse_str($parsedURL['query'], $q);
    if (!empty($q['p'])) {
        $url .= '?p=' . $q['p'];
    }

    return [
        '<iframe width="640" height="360" src="' . $url . '" allow="autoplay; encrypted-media; fullscreen; picture-in-picture; screen-wake-lock;" allowfullscreen style="border: none;"></iframe>',
        $url
    ];
}

function plvideoIframeCreator($url): array {
    parse_str(parse_url($url, PHP_URL_QUERY), $q);
    if (empty($q['v'])) {
        return ["", $url];
    }

    return [
        '<iframe width="640" height="360" src="https://plvideo.ru/embed/' . $q['v'] . '" allow="autoplay; encrypted-media; fullscreen; picture-in-picture; screen-wake-lock;" allowfullscreen style="border: none;"></iframe>',
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

    return '<ul><li>' . implode('</li><li>', $pd) . '</li></ul>';
}