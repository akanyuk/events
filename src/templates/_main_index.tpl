<?php
/**
 * @var $worksComments string Pre rendered works comments HTML content
 */

// Index page
$lang_main = NFW::i()->getLang('main');

$CEvents = new events();
$upcoming = $current = $past = array();
$lastEvents = $CEvents->getRecords(array('limit' => 5, 'load_media' => true));
foreach ($lastEvents as $record) {
    switch ($record['status_type']) {
        case 'upcoming':
            array_unshift($upcoming, $record);
            break;
        case 'current':
            $current[] = $record;
            break;
        default:
            $past[] = $record;
            break;
    }
}
?>
    <style>
        .vote-now-body DIV {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.2em;
        }
    </style>
<?php
if (!empty($current)) {
    foreach ($current as $record) {
        displayIndexEvent($record, 'full');
    }
}

if (!empty($upcoming)) {
    $layout = empty($current) || count($upcoming) < 2 ? 'big' : 'small';
    foreach ($upcoming as $record) {
        displayIndexEvent($record, $layout);
    }
}

echo '<div class="well well-sm">';
echo '<input id="works-search" class="form-control" placeholder="' . $lang_main['search hint'] . '" />';
echo '</div>';

if ($worksComments) {
    echo '<div class="hidden-md hidden-sm hidden-lg">';
    echo '<h2 class="index-head">' . $lang_main['latest comments'] . '</h2>';
    echo $worksComments;
    echo '<div style="margin-top: 20px; margin-bottom: 40px;">';
    echo '<a class="btn btn-lg btn-events-main" href="' . NFW::i()->base_path . 'comments.html">' . $lang_main['all comments'] . '</a>';
    echo '</div>';
    echo '</div>';
}

if (!empty($past)) {
    echo '<h2 class="index-head">' . $lang_main['latest events'] . '</h2>';
    foreach ($past as $record) {
        displayIndexEvent($record);
    }
}

if (count($lastEvents) > 0) {
    ?>
    <div style="margin-bottom: 40px; text-align: center;">
        <a class="btn btn-lg btn-primary btn-events-main"
           href="<?php echo NFW::i()->absolute_path ?>/events"><?php echo $lang_main['all events'] ?></a>
    </div>
    <?php
}

function displayIndexEvent($record, $layout = 'small'): void {
    switch ($layout) {
        case 'small':
            ?>
            <div style="padding-bottom: 20px;">
                <div style="display: table-row;">
                    <div style="display: table-cell; width: 80px; vertical-align: middle; text-align: left;">
                        <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><img class="media-object"
                                                                                            src="<?php echo $record['preview_img'] ?>"
                                                                                            alt=""/></a>
                    </div>
                    <div style="display: table-cell; vertical-align: middle;">
                        <h4 style="margin-bottom: 0;"><a
                                    href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                        </h4>
                        <div class="text-muted"><?php echo $record['dates_desc'] ?></div>
                        <div><?php echo $record['status_label'] ?></div>
                    </div>
                </div>
                <?php if ($record['announcement']): ?>
                    <p style="padding-top: 0.5em;"><?php echo nl2br($record['announcement']) ?></p>
                <?php endif; ?>
            </div>
            <?php
            break;
        case 'big':
            ?>
            <div style="padding-bottom: 50px;">
                <div class="row">
                    <div class="col-sm-12 col-md-5">
                        <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>">
                            <img src="<?php echo $record['preview_img_large'] ?: NFW::i()->assets('main/current-event-large.png') ?>"
                                 style="width: 100%; margin-top: 20px;" alt=""/>
                        </a>
                    </div>
                    <div class="col-sm-12 col-md-7">
                        <h2>
                            <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                        </h2>
                        <div style="font-weight: bold;"><?php echo $record['dates_desc'] ?></div>
                        <div style="font-size: 200%"><?php echo $record['status_label'] ?></div>
                        <?php if ($record['announcement']): ?>
                            <div style="padding-top: 20px;"><?php echo nl2br($record['announcement']) ?></div>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
            <?php
            break;
        case 'full':
            $langMain = NFW::i()->getLang("main");
            ?>
            <div class="index-current-event">
                <div class="row">
                    <div class="col-sm-12 col-md-5">
                        <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>">
                            <img src="<?php echo $record['preview_img_large'] ?: NFW::i()->assets('main/current-event-large.png') ?>"
                                 style="width: 100%; margin-top: 20px;" alt=""/>
                        </a>
                    </div>
                    <div class="col-sm-12 col-md-7">
                        <div class="hidden-sm hidden-xs">
                            <h2>
                                <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                            </h2>

                            <div style="font-weight: bold;"><?php echo $record['dates_desc'] ?></div>

                            <?php if ($record['announcement']): ?>
                                <div style="padding: 10px 0;"><?php echo nl2br($record['announcement']) ?></div>
                            <?php endif; ?>
                        </div>
                        <div class="hidden-lg hidden-md" id="no-live-voting-<?php echo $record['id'] ?>">
                            <h2>
                                <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                            </h2>

                            <div style="font-weight: bold;"><?php echo $record['dates_desc'] ?></div>

                            <?php if ($record['announcement']): ?>
                                <div style="padding: 10px 0;"><?php echo nl2br($record['announcement']) ?></div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>

                <?php if (!NFW::i()->user['is_guest']): ?>
                    <div id="live-voting-container-<?php echo $record['id'] ?>" style="display: block;">
                        <div class="hidden-xs" style="text-align: center">
                            <a href="<?php echo NFW::i()->absolute_path . '/live_voting/' . $record['alias'] ?>"
                               class="btn btn-success btn-lg">Live Voting</a>
                        </div>
                        <div class="hidden-lg hidden-md hidden-sm">
                            <a href="<?php echo NFW::i()->absolute_path . '/live_voting/' . $record['alias'] ?>"
                               class="btn btn-success btn-lg" style="display: flow-root;">Live Voting</a>
                        </div>
                    </div>
                <?php endif; ?>

                <?php if (!NFW::i()->user['is_guest']): ?>
                    <div id="vote-now-container-<?php echo $record['id'] ?>" style="display: none;">
                        <h3><?php echo $langMain['Voting is open'] ?>:</h3>
                        <div id="vote-now-body-<?php echo $record['id'] ?>" class="vote-now-body"></div>
                    </div>
                <?php endif; ?>

                <hr/>
            </div>

            <?php if (!NFW::i()->user['is_guest']): ?>
            <script>
                const liveVotingContainer = document.getElementById("live-voting-container-<?php echo $record['id']?>");

                setInterval(updateVotingState, 5000);
                updateVotingState();

                function updateVotingState() {
                    fetch('/internal_api?action=votingStatus&event_id=<?php echo $record['id']?>').then(response => response.json()).then(response => {
                        updateLiveVoting(response['liveVotingOpen']);
                        updateVotingOpen(response['votingOpen']);
                    });
                }

                function updateLiveVoting(state) {
                    liveVotingContainer.style.display = state ? "block" : "none";
                }

                function updateVotingOpen(values) {
                    const voteNowContainer = document.getElementById("vote-now-container-<?php echo $record['id']?>");
                    const voteNowBody = document.getElementById("vote-now-body-<?php echo $record['id']?>");

                    if (values.length === 0) {
                        voteNowContainer.style.display = "none";
                        return
                    }

                    voteNowBody.innerHTML = "";
                    values.forEach((compo) => {
                        const title = document.createElement('a');
                        title.innerText = compo['title']
                        title.href = compo['url']

                        const status = document.createElement('div');
                        status.innerText = compo['statusText']
                        status.className = "text-danger"

                        const item = document.createElement('div');
                        item.appendChild(title);
                        item.appendChild(status);

                        voteNowBody.appendChild(item);
                    })

                    voteNowContainer.style.display = "block";
                }
            </script>
        <?php endif;
            break;
    }
}
	