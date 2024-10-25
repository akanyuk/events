<?php
function competitions_list_short(
    array $competitionsGroups,
    array $competitions,
    bool  $hideWorksCount,
    bool  $shortList = false,
    int   $current = 0): string {
    if (count($competitions) < 2) {
        return '<div class="competitions-list-short"></div>';
    }

    $langMain = NFW::i()->getLang('main');

    foreach ($competitions as $key => $c) {
        if ($c['voting_status']['available'] && $c['voting_works']) {
            $competitions[$key]['second_label'] = '<div class="badge rounded-pill text-bg-danger small" title="Vote now!">!</div>';
        } else if ($c['reception_status']['now']) {
            $competitions[$key]['second_label'] = '<div class="badge rounded-pill text-bg-info small" title="Reception available">+</div>';
        } else {
            $competitions[$key]['second_label'] = '<div></div>';
        }

        if ($hideWorksCount) {
            $competitions[$key]['count_label'] = '<div class="badge badge-cnt text-bg-secondary" title="' . $langMain['competitions received works'] . '">?</div>';
        } elseif (!$competitions[$key]['counter']) {
            $competitions[$key]['count_label'] = '<div class="badge badge-cnt text-bg-secondary" title="' . $langMain['competitions received works'] . '">' . $competitions[$key]['counter'] . '</div>';
        } elseif ($competitions[$key]['counter'] < 3) {
            $competitions[$key]['count_label'] = '<div class="badge badge-cnt text-bg-warning" title="' . $langMain['competitions received works'] . '">' . $competitions[$key]['counter'] . '</div>';
        } else {
            $competitions[$key]['count_label'] = '<div class="badge badge-cnt text-bg-success" title="' . $langMain['competitions received works'] . '">' . $competitions[$key]['counter'] . '</div>';
        }
    }

    $result = '';

    if (empty($competitionsGroups)) {
        $composContent = [];
        foreach ($competitions as $c) {
            if (!$c['is_link'] && $shortList) {
                continue;
            }

            if ($shortList && $c['id'] == $current) {
                $title = '<a class="text-bg-primary fw-bold ps-3" href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            } elseif ($c['is_link']) {
                $title = '<a class="ps-3" href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            } else {
                $title = '<a class="text-muted ps-3" href="#' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            }

            $composContent[] = $title . $c['second_label'] . $c['count_label'];
        }

        if (empty($composContent) || ($shortList && count($composContent) == 1)) {
            return '<div class="competitions-list-short"></div>';
        }

        return '<div class="competitions-list-short d-grid gap-1" style="grid-template-columns: 12fr 1fr 1fr;">' . implode('', $composContent) . '</div>';
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
                $title = '<a class="text-bg-primary fw-bold ps-3" href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
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
            $title = '<a class="text-bg-primary fw-bold ps-3" href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        } elseif ($c['is_link']) {
            $title = '<a href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        } else {
            $title = '<a class="text-muted" href="#' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        }

        $result .= $title . $c['second_label'] . $c['count_label'];
    }

    return '<div class="competitions-list-short d-grid gap-1" style="grid-template-columns: 12fr 1fr 1fr;">' . $result . '</div>';
}