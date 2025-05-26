<?php

// local actions

if (isset($_GET['action']) && $_GET['action'] == 'mark_work_read') {
    $req = json_decode(file_get_contents('php://input'));
    if (!works_activity::markRead($req->workID)) {
        NFWX::i()->jsonError(400, 'Mark work read failed');
    }
    NFWX::i()->jsonSuccess(['unread' => works_activity::adminUnread()]);
}

if (isset($_GET['action']) && $_GET['action'] == 'clear_work_marked') {
    $req = json_decode(file_get_contents('php://input'));
    if (!NFW::i()->db->query_build(array('DELETE' => 'works_managers_notes', 'WHERE' => 'work_id=' . $req->workID . ' AND user_id=' . NFW::i()->user['id']))) {
        NFWX::i()->jsonError(400, 'Clear work marked failed');
    }

    NFWX::i()->jsonSuccess();
}

// New activity, marked prods

$managedEvents = events::getManaged();
$CWorks = new works();

$unread = works_activity::unreadExplained();
$unreadID = array_keys($unread);

$unreadProds = array();
if (!empty($unreadID)) {
    $query = array(
        'SELECT' => 'e.title AS event_title, c.title AS competition_title, w.id, w.status, w.title, w.author, w.posted, w.posted_username',
        'FROM' => 'works AS w',
        'JOINS' => array(
            array('INNER JOIN' => 'competitions AS c', 'ON' => 'c.id=w.competition_id'),
            array('INNER JOIN' => 'events AS e', 'ON' => 'e.id=c.event_id'),
        ),
        'WHERE' => 'w.id IN(' . implode(',', $unreadID) . ')',
        'ORDER BY' => 'w.posted DESC',
    );
    if (!$result = NFW::i()->db->query_build($query)) {
        echo '<div class="alert alert-danger">Unable to fetch unread prods</div>';
        return false;
    }
    while ($r = NFW::i()->db->fetch_assoc($result)) {
        $r['status_info'] = $CWorks->attributes['status']['options'][$r['status']];
        $unreadProds[] = $r;
    }
}

$markedProds = array();
$uncheckedProds = array();
if (!empty($managedEvents)) {
    $query = array(
        'SELECT' => 'e.title AS event_title, c.title AS competition_title, w.id, w.status, w.title, w.author, w.posted, w.posted_username, wmi.comment AS managers_notes_comment',
        'FROM' => 'works AS w',
        'JOINS' => array(
            array('INNER JOIN' => 'competitions AS c', 'ON' => 'c.id=w.competition_id'),
            array('INNER JOIN' => 'events AS e', 'ON' => 'e.id=c.event_id'),
            array('INNER JOIN' => 'works_managers_notes AS wmi', 'ON' => 'wmi.work_id=w.id AND wmi.user_id=' . NFW::i()->user['id'])
        ),
        'WHERE' => 'e.id IN(' . implode(',', $managedEvents) . ')',
        'ORDER BY' => 'w.posted DESC',
    );
    if (!$result = NFW::i()->db->query_build($query)) {
        echo '<div class="alert alert-danger">Unable to fetch marked prods</div>';
        return false;
    }
    while ($r = NFW::i()->db->fetch_assoc($result)) {
        $r['status_info'] = $CWorks->attributes['status']['options'][$r['status']];
        $markedProds[] = $r;
    }

    $query = array(
        'SELECT' => 'e.title AS event_title, c.title AS competition_title, w.id, w.status, w.title, w.author, w.posted, w.posted_username',
        'FROM' => 'works AS w',
        'JOINS' => array(
            array('INNER JOIN' => 'competitions AS c', 'ON' => 'c.id=w.competition_id'),
            array('INNER JOIN' => 'events AS e', 'ON' => 'e.id=c.event_id'),
        ),
        'WHERE' => 'e.id IN(' . implode(',', $managedEvents) . ') AND w.status=' . WORKS_STATUS_UNCHECKED,
        'ORDER BY' => 'w.posted DESC',
    );
    if (!$result = NFW::i()->db->query_build($query)) {
        echo '<div class="alert alert-danger">Unable to fetch marked prods</div>';
        return false;
    }
    while ($r = NFW::i()->db->fetch_assoc($result)) {
        $r['status_info'] = $CWorks->attributes['status']['options'][$r['status']];
        $uncheckedProds[] = $r;
    }
}

NFW::i()->registerResource('jquery.jgrowl');

echo '<div style="display: none;">' . NFW::i()->fetch(NFW::i()->findTemplatePath('_common_status_icons.tpl')) . '</div>';
?>
<style>
    .alert-unread {
        margin-bottom: 8px;
        padding-left: 10px;
        padding-top: 10px;
        padding-bottom: 10px;
    }

    .alert-unread .inner {
        display: flex;
        gap: 0.5em;
    }

    .unread-prods .lead {
        margin-bottom: 0;
    }
</style>
<div class="row unread-prods">
    <div class="col-md-4">
        <h2>New activities</h2>
        <div id="all-works-read" class="alert alert-success"
             style="display:<?php echo empty($unreadProds) ? 'block' : 'none' ?>">No new activities</div>
        <div id="unread-works">
            <?php foreach ($unreadProds as $record): ?>
                <div
                    class="alert alert-unread alert-dismissible alert-<?php echo $record['status_info']['css-class'] ?>"
                    role="alert">
                    <button id="mark-work-read" data-id="<?php echo $record['id'] ?>"
                            type="button" class="close"
                            data-dismiss="alert" aria-label="Mark as read"><span aria-hidden="true"
                                                                                 title="Mark as read">&times;</span>
                    </button>
                    <div class="inner">
                        <div style="padding-top: 5px;" data-toggle="tooltip" data-html="true"
                             title="<?php echo '<strong>' . $record['status_info']['desc'] . '</strong><br />Voting: ' . ($record['status_info']['voting'] ? 'On' : 'Off') . '<br />Release: ' . ($record['status_info']['release'] ? 'On' : 'Off') ?>">
                            <svg width="1.5em" height="1.5em" style="fill: currentColor">
                                <use xlink:href="#<?php echo $record['status_info']['svg-icon'] ?>"/>
                            </svg>
                        </div>
                        <div>
                            <strong>
                                <a class="alert-link"
                                   href="<?php echo NFW::i()->absolute_path . '/admin/works?action=update&record_id=' . $record['id'] ?>#activity"><?php echo htmlspecialchars($record['title'] . ' by ' . $record['author']) ?></a>
                                <span class="label label-warning"><?php echo $unread[$record['id']] ?></span>
                            </strong>
                            <div class="text-muted">
                                <small><?php echo htmlspecialchars($record['event_title'] . ' / ' . $record['competition_title']) ?></small>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

    <div class="col-md-4">
        <h2>Marked prods</h2>
        <div id="no-marked-works" class="alert alert-success"
             style="display:<?php echo empty($markedProds) ? 'block' : 'none' ?>">You have no marked prods
        </div>
        <div id="marked-works">
            <?php foreach ($markedProds as $record) : ?>
                <div
                    class="alert alert-unread alert-dismissible alert-<?php echo $record['status_info']['css-class'] ?>"
                    role="alert">
                    <button id="clear-work-marked" data-id="<?php echo $record['id'] ?>"
                            type="button" class="close"
                            data-dismiss="alert" aria-label="Clear marked"><span aria-hidden="true"
                                                                                 title="Clear marked">&times;</span>
                    </button>
                    <div class="inner">
                        <div style="padding-top: 5px;" data-toggle="tooltip" data-html="true"
                             title="<?php echo '<strong>' . $record['status_info']['desc'] . '</strong><br />Voting: ' . ($record['status_info']['voting'] ? 'On' : 'Off') . '<br />Release: ' . ($record['status_info']['release'] ? 'On' : 'Off') ?>">
                            <svg width="1.5em" height="1.5em" style="fill: currentColor">
                                <use xlink:href="#<?php echo $record['status_info']['svg-icon'] ?>"/>
                            </svg>
                        </div>
                        <div>
                            <strong>
                                <a class="alert-link"
                                   href="<?php echo NFW::i()->absolute_path . '/admin/works?action=update&record_id=' . $record['id'] ?>"><?php echo htmlspecialchars($record['title'] . ' by ' . $record['author']) ?></a>
                                <?php if (isset($unread[$record['id']]) && $unread[$record['id']] > 0): ?>
                                    <span class="label label-warning"><?php echo $unread[$record['id']] ?></span>
                                <?php endif; ?>
                            </strong>
                            <div class="text-muted">
                                <small><?php echo htmlspecialchars($record['event_title'] . ' / ' . $record['competition_title']) ?></small>
                            </div>
                            <?php if ($record['managers_notes_comment']): ?>
                                <div
                                    class="lead"><?php echo htmlspecialchars(nl2br($record['managers_notes_comment'])) ?></div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

    <div class="col-md-4">
        <h2>Unchecked prods</h2>
        <?php if (empty($uncheckedProds)): ?>
            <div class="alert alert-success">You have no unchecked prods</div>
        <?php else: ?>
            <?php foreach ($uncheckedProds as $record) : ?>
                <div
                    class="alert alert-unread alert-<?php echo $record['status_info']['css-class'] ?>" role="alert">
                    <div class="inner">
                        <div>
                            <strong>
                                <a class="alert-link"
                                   href="<?php echo NFW::i()->absolute_path . '/admin/works?action=update&record_id=' . $record['id'] ?>"><?php echo htmlspecialchars($record['title'] . ' by ' . $record['author']) ?></a>
                            </strong>
                            <div class="text-muted">
                                <small><?php echo htmlspecialchars($record['event_title'] . ' / ' . $record['competition_title']) ?></small>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>
</div>
<script type="text/javascript">
    const divUnreadWorks = document.getElementById("unread-works");
    const divAllWorksRead = document.getElementById("all-works-read");

    document.querySelectorAll("#mark-work-read").forEach(btn => {
        btn.onclick = function () {
            markWorkRead(btn)
        };
    });

    async function markWorkRead(btn) {
        const response = await fetch("?action=mark_work_read", {
            method: "POST",
            body: JSON.stringify({
                workID: btn.getAttribute("data-id"),
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        const resp = await response.json();

        if (!response.ok) {
            $.jGrowl(resp['errors']['general'], {theme: 'error'});
        }

        if (divUnreadWorks.childElementCount === 0) {
            divAllWorksRead['style']['display'] = 'block';
        }

        UpdateHeaderUnread(resp['unread']);
    }

    const divMarkedWorks = document.getElementById("marked-works");
    const divNoWorksMarked = document.getElementById("no-marked-works");

    document.querySelectorAll("#clear-work-marked").forEach(btn => {
        btn.onclick = function () {
            clearWorkMarked(btn)
        };
    });

    async function clearWorkMarked(btn) {
        const response = await fetch("?action=clear_work_marked", {
            method: "POST",
            body: JSON.stringify({
                workID: btn.getAttribute("data-id"),
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        const resp = await response.json();

        if (!response.ok) {
            $.jGrowl(resp['errors']['general'], {theme: 'error'});
        }

        if (divMarkedWorks.childElementCount === 0) {
            divNoWorksMarked['style']['display'] = 'block';
        }
    }
</script>
