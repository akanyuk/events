<?php
/**
 * @var array $top_menu
 * @var bool $no_admin_sidebar
 */

if (isset($no_admin_sidebar) && $no_admin_sidebar) {
    return;
}
NFW::i()->registerFunction('page_is');
?>
    <style>
        .metismenu li#selected-menu > a, .metismenu li#selected-event-item > a, .metismenu li#selected-work > a {
            background-color: rgba(59, 150, 204, 0.4);
            color: #fff;
        }

        .metismenu li {
            white-space: nowrap;
        }

        .metismenu li.work {
            font-weight: bold;
        }
    </style>
    <nav class="sidebar-nav">
        <ul class="metismenu" id="sidebar-menu">
            <?php
            foreach (adminSidebarEvents() as $k=>$event) {
                ?>
                <li <?php echo $k == 0 ? 'id="first-event"' : ''?>>
                    <a href="#" title="<?php echo htmlspecialchars($event['title']) ?>"><span
                                class="sidebar-nav-item"><?php echo htmlspecialchars($event['title']) ?></span></a>
                    <ul>
                        <?php echo eventItemLink(NFW::i()->absolute_path . '/admin/events?action=update&record_id=' . $event['id'], 'Manage event') ?>
                        <?php echo eventItemLink(NFW::i()->absolute_path . '/admin/competitions?event_id=' . $event['id'], 'Competitions') ?>
                        <?php echo eventItemLink(NFW::i()->absolute_path . '/admin/works?event_id=' . $event['id'], 'Works') ?>
                        <?php echo eventItemLink(NFW::i()->absolute_path . '/admin/vote?event_id=' . $event['id'], 'Voting') ?>
                        <?php echo eventItemLink(NFW::i()->absolute_path . '/admin/live_voting?event_id=' . $event['id'], 'Live voting') ?>
                        <?php echo eventItemLink(NFW::i()->absolute_path . '/admin/timeline?event_id=' . $event['id'], 'Timeline') ?>
                        <li style="height: 1px;"></li>
                        <?php
                        foreach ($event['competitions'] as $competition) {
                            usort($competition['works'], function ($a, $b): int {
                                if ($a['status'] == $b['status']) {
                                    return $a['position'] < $b['position'] ? -1 : 1;
                                }

                                return $a['voting'] ? -1 : 1;
                            });

                            ?>
                            <li>
                                <a href="#" title="<?php echo htmlspecialchars($competition['title']) ?>">
                                    <span class="sidebar-nav-item"><?php echo htmlspecialchars($competition['title']) ?></span>
                                </a>
                                <ul>
                                    <?php foreach ($competition['works'] as $work) echo workLink($work) ?>
                                </ul>
                            </li>
                        <?php } ?>
                    </ul>
                </li>
                <?php
            }
            echo '<li class="hidden-md hidden-lg"><a href="#"><span class="sidebar-nav-item">Main menu</span></a><ul>';
            foreach ($top_menu as $m) {
                if ($m['url'] != "") {
                    echo menuLink(NFW::i()->absolute_path . '/admin/' . $m['url'], $m['name']);
                }
            }
            echo '</ul></li>';
            ?>
        </ul>
    </nav>
    <script type="text/javascript">
        $(document).ready(function () {
            const menu = $('#sidebar-menu');

            if (menu.find('li#selected-work').length) {
                menu.find('li#selected-work').parent().parent().addClass('active');
                menu.find('li#selected-work').parent().parent().parent().parent().addClass('active');
            } else if (menu.find('li#selected-event-item').length) {
                menu.find('li#selected-event-item').parent().parent().addClass('active');
            } else if (menu.find('li#selected-menu:visible').length) {
                menu.find('li#selected-menu').parent().parent().addClass('active');
            } else {
                menu.find('li#first-event').addClass('active');
            }

            menu.metisMenu();

            const selectedEventItem = document.getElementById("selected-event-item");
            if (selectedEventItem !== null) {
                selectedEventItem.scrollIntoView({
                    behavior: "smooth",
                    block: "center",
                    inline: "center"
                });
            }

            const selectedWork = document.getElementById("selected-work");
            if (selectedWork !== null) {
                selectedWork.scrollIntoView({
                    behavior: "smooth",
                    block: "center",
                    inline: "center"
                });
            }
        });
    </script>
<?php

function menuLink($url, $text): string {
    $p = parse_url($url);
    if ($p['path'] == '/admin/') {
        $class = "";
    } else {
        $check = $p['path'] . (isset($p['query']) ? '?' . $p['query'] : '');
        $class = page_is($check) ? ' id="selected-menu"' : '';
    }
    return '<li' . $class . '><a href="' . $url . '">' . $text . '</a></li>';
}

function eventItemLink($url, $text): string {
    $p = parse_url($url);
    $check = $p['path'] . (isset($p['query']) ? '?' . $p['query'] : '');
    $class = page_is($check) ? ' id="selected-event-item"' : '';
    return '<li' . $class . '><a href="' . $url . '">' . $text . '</a></li>';
}

function workLink($work): string {
    $i = page_is('admin/works?action=update&record_id=' . $work['id']) ? 'id="selected-work"' : '';
    $title = htmlspecialchars($work['title'] . ' by ' . $work['author']);
    return '<li ' . $i . ' class="work"><a title="' . $title . '" href="' . NFW::i()->absolute_path . '/admin/works?action=update&record_id=' . $work['id'] . '">' . htmlspecialchars($work['title']) . '</a></li>';
}

function adminSidebarEvents() {
    $managed_events = events::getManaged();
    if (empty($managed_events)) return array();

    $query = array(
        'SELECT' => 'e.id AS event_id, e.title AS event_title, c.id AS competition_id, c.title AS competition_title, w.id AS work_id, w.title AS work_title, w.author, w.status, w.position',
        'FROM' => 'works AS w',
        'JOINS' => array(
            array('INNER JOIN' => 'competitions AS c', 'ON' => 'c.id=w.competition_id'),
            array('INNER JOIN' => 'events AS e', 'ON' => 'e.id=c.event_id'),
        ),
        'WHERE' => 'e.id IN(' . implode(',', array_splice($managed_events, 0, 5)) . ')',
        'ORDER BY' => 'e.date_from DESC, c.position'
    );
    if (!$result = NFW::i()->db->query_build($query)) {
        return false;
    }
    if (!NFW::i()->db->num_rows($result)) {
        return array();
    }

    $CWorks = new works();
    $events = array();
    while ($r = NFW::i()->db->fetch_assoc($result)) {
        $event_key = false;
        foreach ($events as $eKey => $e) {
            if ($e['id'] == $r['event_id']) {
                $event_key = $eKey;
                break;
            }
        }

        if ($event_key !== false) {
            $competition_found = false;
            foreach ($events[$event_key]['competitions'] as $cKey => $c) {
                if ($c['id'] == $r['competition_id']) {
                    $events[$event_key]['competitions'][$cKey]['works'][] = array(
                        'id' => $r['work_id'],
                        'title' => $r['work_title'],
                        'position' => $r['position'],
                        'author' => $r['author'],
                        'status' => $r['status'],
                        'voting' => $CWorks->attributes['status']['options'][$r['status']]['voting'],
                    );
                    $competition_found = true;
                    break;
                }
            }

            if (!$competition_found) {
                $events[$event_key]['competitions'][] = array('id' => $r['competition_id'], 'title' => $r['competition_title'], 'works' => array(
                    array(
                        'id' => $r['work_id'],
                        'title' => $r['work_title'],
                        'position' => $r['position'],
                        'author' => $r['author'],
                        'status' => $r['status'],
                        'voting' => $CWorks->attributes['status']['options'][$r['status']]['voting'],
                    )
                ));
            }
        } else {
            // New record
            $events[] = array('id' => $r['event_id'], 'title' => $r['event_title'], 'competitions' => array(
                array('id' => $r['competition_id'], 'title' => $r['competition_title'], 'works' => array(
                    array(
                        'id' => $r['work_id'],
                        'title' => $r['work_title'],
                        'position' => $r['position'],
                        'author' => $r['author'],
                        'status' => $r['status'],
                        'voting' => $CWorks->attributes['status']['options'][$r['status']]['voting'],
                    )
                ))
            ));
        }
    }

    return $events;
}
