<?php
// Index page

$CWorksComments = new works_comments();
$worksComments = $CWorksComments->displayLatestComments();

$langMain = NFW::i()->getLang('main');
list($upcoming, $current, $past) = lastEvents();

foreach ($current as $record) {
    displayIndexEvent($record, 'current');
}

foreach ($upcoming as $record) {
    displayIndexEvent($record, 'upcoming');
}
?>
    <div class="row">
        <div class="col-md-6 mb-5">
            <h2 class="index-head"><?php echo $langMain['latest events'] ?></h2>
            <?php foreach ($past as $record) displayIndexEvent($record); ?>
            <div class="d-grid mx-auto col-lg-6">
                <a class="btn btn-lg btn-primary"
                   href="<?php echo NFW::i()->absolute_path ?>/events"><?php echo $langMain['all events'] ?></a>
            </div>
        </div>
        <div class="col-md-6">
            <h2 class="index-head"><?php echo $langMain['latest comments'] ?></h2>
            <div class="mb-4">
                <?php echo $worksComments ?>
            </div>
            <div class="d-grid mx-auto col-lg-6">
                <a class="btn btn-lg btn-primary"
                   href="<?php echo NFW::i()->base_path . 'comments.html' ?>"><?php echo $langMain['all comments'] ?></a>
            </div>
        </div>
    </div>
<?php

function lastEvents(): array {
    $CEvents = new events();
    $upcoming = $current = $past = array();
    $lastEvents = $CEvents->getRecords(array('limit' => 20, 'load_media' => true));
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
    return [$upcoming, $current, array_slice($past, 0, 5)];
}

function displayIndexEvent($record, $layout = ""): void {
    switch ($layout) {
        case 'upcoming':
        case 'current':
            ?>
            <div class="row mb-4 gy-4">
                <div class="col-sm-12 col-md-4">
                    <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>">
                        <img class="w-100" alt=""
                             src="<?php echo $record['preview_img_large'] ?: NFW::i()->assets('main/current-event-large.png') ?>"/>
                    </a>
                </div>
                <div class="col-sm-12 col-md-8">
                    <h2>
                        <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                    </h2>
                    <p class="h5"><?php echo $record['dates_desc'] ?>
                        <span
                            class="badge text-bg-<?php echo $layout == 'current' ? 'danger' : 'info' ?>"><?php echo $record['status_label'] ?></span>
                    </p>
                    <?php if ($record['announcement']): ?>
                        <div class="mt-3"><?php echo nl2br($record['announcement']) ?></div>
                    <?php endif; ?>
                    <?php if ($layout == 'current') displayCurrenEventStatus($record); ?>
                </div>
            </div>
            <?php
            break;
        default:
            ?>
            <div class="table-row">
                <div class="align-middle text-left" style="display: table-cell; width: 80px;"><a
                        href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><img class="media-object"
                                                                                         src="<?php echo $record['preview_img'] ?>"
                                                                                         alt=""/></a>
                </div>
                <div class="align-middle text-left" style="display: table-cell;"><h4><a
                            href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                    </h4>
                    <div class="text-muted"><?php echo $record['dates_desc'] ?></div>
                </div>
            </div>
            <div class="mb-5"><?php echo nl2br($record['announcement']) ?></div>
        <?php
    }
}

function displayCurrenEventStatus($record): void {
    $langMain = NFW::i()->getLang("main");
    ?>
    <div id="vote-now-container-<?php echo $record['id'] ?>" style="display: none;">
        <h3 class="mt-2"><?php echo $langMain['Voting is open'] ?>:</h3>
        <div id="vote-now-body-<?php echo $record['id'] ?>"></div>
    </div>

    <div id="live-voting-container-<?php echo $record['id'] ?>" style="display: none;">
        <div class="d-grid d-md-block mt-3">
            <a href="<?php echo NFW::i()->absolute_path . '/live_voting/' . $record['alias'] ?>"
               class="btn btn-success btn-lg">Live Voting</a>
        </div>
    </div>

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
                item.className = "d-flex justify-content-between";
                item.appendChild(title);
                item.appendChild(status);

                voteNowBody.appendChild(item);
            })

            voteNowContainer.style.display = "block";
        }
    </script>
    <?php
}