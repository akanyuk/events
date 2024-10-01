<?php
function competitions_list_short(
    array $competitionsGroups,
    array $competitions,
    bool  $hideWorksCount,
    bool  $shortList = false,
    int   $current = 0): string {
    if (count($competitions) < 2) {
        return "";
    }

    $langMain = NFW::i()->getLang('main');

    foreach ($competitions as $key => $c) {
        if ($c['voting_status']['available'] && $c['voting_works']) {
            $competitions[$key]['second_label'] = '<small><div class="badge rounded-pill text-bg-danger" title="Vote now!">!</div></small>';
        } else if ($c['reception_status']['now']) {
            $competitions[$key]['second_label'] = '<small><div class="badge rounded-pill text-bg-info" title="Reception available">+</div></small>';
        } else {
            $competitions[$key]['second_label'] = '<small><div></div></small>';
        }

        if ($hideWorksCount) {
            $competitions[$key]['count_label'] = '<div class="badge text-bg-secondary" title="' . $langMain['competitions received works'] . '">?</div>';
        } elseif (!$competitions[$key]['counter']) {
            $competitions[$key]['count_label'] = '<div class="badge text-bg-secondary" title="' . $langMain['competitions received works'] . '">' . $competitions[$key]['counter'] . '</div>';
        } elseif ($competitions[$key]['counter'] < 3) {
            $competitions[$key]['count_label'] = '<div class="badge text-bg-warning" title="' . $langMain['competitions received works'] . '">' . $competitions[$key]['counter'] . '</div>';
        } else {
            $competitions[$key]['count_label'] = '<div class="badge text-bg-success" title="' . $langMain['competitions received works'] . '">' . $competitions[$key]['counter'] . '</div>';
        }
    }

    $result = '';

    if (empty($competitionsGroups)) {
        foreach ($competitions as $c) {
            if (!$c['is_link'] && $shortList) {
                continue;
            }

            if ($shortList && $c['id'] == $current) {
                $title = '<strong class="text-bg-primary ps-3">' . htmlspecialchars($c['title']) . '</strong>';
            } elseif ($c['is_link']) {
                $title = '<a class="ps-3" href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            } else {
                $title = '<a class="text-muted ps-3" href="#' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            }

            $result .= $title . $c['second_label'] . $c['count_label'];
        }
        return '<div class="d-grid gap-1" style="grid-template-columns: 12fr 1fr 1fr;">' . $result . '</div>';
    }

    foreach ($competitionsGroups as $group) {
        if ($shortList) {
            $groupContent = '<b>' . htmlspecialchars($group['title']) . '</b><div></div><div></div>';
        } else {
            $groupContent = '<a href="#' . str_replace(" ", "_", htmlspecialchars($group['title'])) . '"><b>' . htmlspecialchars($group['title']) . '</b></a><div></div><div></div>';
        }

        $composContent = [];
        foreach ($competitions as $c) {
            if ($c['competitions_groups_id'] != $group['id'] || (!$c['is_link'] && $shortList)) {
                continue;
            }

            if ($shortList && $c['id'] == $current) {
                $title = '<strong class="text-bg-primary ps-3">' . htmlspecialchars($c['title']) . '</strong>';
            } elseif ($c['is_link']) {
                $title = '<a class="ps-3" href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            } else {
                $title = '<a class="ps-3 text-muted" href="#' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            }

            $composContent[] = $title . $c['second_label'] . $c['count_label'];
        }

        if (count($composContent) > 0) {
            $result .= $groupContent . implode('', $composContent);
        }
    }

    // Without group
    foreach ($competitions as $c) {
        if ($c['competitions_groups_id'] != 0 || (!$c['is_link'] && $shortList)) {
            continue;
        }

        if ($shortList && $c['id'] == $current) {
            $title = '<strong class="text-bg-primary ps-3">' . htmlspecialchars($c['title']) . '</strong>';
        } elseif ($c['is_link']) {
            $title = '<a href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        } else {
            $title = '<a class="text-muted" href="#' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        }

        $result .= $title . $c['second_label'] . $c['count_label'];
    }

    return '<div class="d-grid gap-1" style="grid-template-columns: 12fr 1fr 1fr;">' . $result . '</div>';
}