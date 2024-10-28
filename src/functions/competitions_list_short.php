<?php
function competitions_list_short(
    array $competitionsGroups,
    array $competitions,
    bool  $hideWorksCount,
    bool  $shortList = false,
    int   $current = 0): string {
    if (count($competitions) < 2) {
        return '';
    }

    $langMain = NFW::i()->getLang('main');

    foreach ($competitions as $key => $c) {
        if ($c['voting_status']['available'] && $c['voting_works']) {
            $competitions[$key]['second_label'] = '<div title="Vote now!"><svg class="text-danger" width="0.7em" height="0.7em"><use href="#icon-bar-chart-line-fill"></use></svg></div>';
        } else if ($c['reception_status']['now']) {
            $competitions[$key]['second_label'] = '<div title="Reception available"><svg class="text-info" width="0.7em" height="0.7em"><use href="#icon-plus-circle-fill"></use></svg></div>';
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

    if (empty($competitionsGroups)) {
        $composContent = [];
        foreach ($competitions as $c) {
            if (!$c['is_link'] && $shortList) {
                continue;
            }

            if ($shortList && $c['id'] == $current) {
                $title = '<div class="text-bg-primary fw-bold ps-3">' . htmlspecialchars($c['title']) . '</div>';
            } elseif ($c['is_link']) {
                $title = '<a class="ps-3" href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            } else {
                $title = '<a class="text-muted ps-3" href="#' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            }

            $composContent[] = $title . $c['second_label'] . $c['count_label'];
        }

        if (empty($composContent) || ($shortList && count($composContent) == 1)) {
            return '';
        }

        return '<div class="competitions-list-short d-grid gap-2 align-items-center" style="grid-template-columns: 12fr 1fr 1fr;">' . implode('', $composContent) . '</div>';
    }

    $result = '';
    $totalCompoCnt = 0;
    foreach ($competitionsGroups as $group) {
        if ($shortList) {
            $groupContent = '<b>' . htmlspecialchars($group['title']) . '</b><div></div><div></div>';
        } else {
            $groupContent = '<a class="text-muted" href="#' . str_replace(" ", "_", htmlspecialchars($group['title'])) . '"><b>' . htmlspecialchars($group['title']) . '</b></a><div></div><div></div>';
        }

        $composContent = [];
        foreach ($competitions as $c) {
            if ($c['competitions_groups_id'] != $group['id'] || (!$c['is_link'] && $shortList)) {
                continue;
            }

            if ($shortList && $c['id'] == $current) {
                $title = '<div class="text-bg-primary fw-bold ps-3">' . htmlspecialchars($c['title']) . '</div>';
            } elseif ($c['is_link']) {
                $title = '<a class="ps-3" href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            } else {
                $title = '<a class="ps-3 text-muted" href="#' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
            }

            $composContent[] = $title . $c['second_label'] . $c['count_label'];
            $totalCompoCnt++;
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
            $title = '<div class="text-bg-primary fw-bold ps-3">' . htmlspecialchars($c['title']) . '</div>';
        } elseif ($c['is_link']) {
            $title = '<a href="' . NFW::i()->absolute_path . '/' . $c['event_alias'] . '/' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        } else {
            $title = '<a class="text-muted" href="#' . $c['alias'] . '">' . htmlspecialchars($c['title']) . '</a>';
        }

        $result .= $title . $c['second_label'] . $c['count_label'];
        $totalCompoCnt++;
    }

    if ($totalCompoCnt < 2) {
        return '';
    }

    return '<div class="competitions-list-short d-grid gap-2 align-items-center" style="grid-template-columns: 12fr 1fr 1fr;">' . $result . '</div>';
}