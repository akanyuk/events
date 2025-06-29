<?php
// Index page

$CWorksComments = new works_comments();
list($comments, $screenshots) = $CWorksComments->latestComments();
$worksComments = $CWorksComments->renderAction([
    'comments' => $comments,
    'screenshots' => $screenshots,
], 'latest');

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
            <div class="d-grid">
                <a class="btn btn-lg btn-primary"
                   href="<?php echo NFW::i()->absolute_path ?>/events"><?php echo $langMain['all events'] ?></a>
            </div>
        </div>
        <div class="col-md-6">
            <section id="latest-comments"></section>
            <h2 class="index-head"><?php echo $langMain['latest comments'] ?></h2>
            <div class="mb-4">
                <?php echo $worksComments ?>
            </div>
            <div class="d-grid">
                <a class="btn btn-lg btn-primary"
                   href="<?php echo NFW::i()->base_path . 'comments/all' ?>"><?php echo $langMain['all comments'] ?></a>
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
            <div class="d-grid mx-auto col-xxl-10 mb-5">
                <div class="row mb-4 gy-4">
                    <div class="col-md-6 upcoming-current-cover">
                        <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>">
                            <img class="w-100" alt=""
                                 src="<?php echo $record['preview_img_large'] ?: NFW::i()->assets('main/current-event-large.png') ?>"/>
                        </a>
                    </div>
                    <div class="col-md-6">
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
                    </div>
                </div>
                <?php displayCurrenEventUploadingStatus($record); ?>
                <?php if ($layout == 'current') displayCurrenEventVotingStatus($record); ?>
            </div>
            <?php
            break;
        default:
            ?>
            <div class="table-row">
                <div class="align-top text-left" style="display: table-cell; width: 80px;"><a
                        href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><img class="media-object"
                                                                                         src="<?php echo $record['preview_img'] ?>"
                                                                                         alt=""></a>
                </div>
                <div class="align-middle text-left" style="display: table-cell;"><h4><a
                            href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                    </h4>
                    <div class="d-none d-sm-block me-1 text-muted"><?php echo $record['dates_desc'] ?></div>
                </div>
            </div>
            <div class="mb-4">
                <div class="d-block d-sm-none my-1 text-muted"><?php echo $record['dates_desc'] ?></div>
                <?php echo nl2br($record['announcement']) ?>
            </div>
        <?php
    }
}

function displayCurrenEventUploadingStatus($event): void {
    $hideWorksCount = $event['hide_works_count'];

    $CCompetitions = new competitions();
    $compos = [];
    foreach ($CCompetitions->getRecords(['filter' => [
        'open_reception' => true,
        'event_id' => $event['id']]]) as $compo) {
        $compos[] = $compo;
    }
    if (count($compos) == 0) {
        return;
    }

    $langMain = NFW::i()->getLang("main");
    ?>
    <div class="mb-3">
        <h3><?php echo $langMain['Reception opened'] ?>:</h3>
        <div class="d-grid gap-2 align-items-center" style="grid-template-columns: 100fr 1fr<?php echo $hideWorksCount?:' 1fr'?>;">
            <?php foreach ($compos as $compo):?>
                <div><a href="<?php echo NFW::i()->absolute_path . '/' . $compo['event_alias'] . '#' . $compo['alias'] ?>"><?php echo htmlspecialchars($compo['title']) ?></a></div>
                <div class="text-nowrap text-info"><?php echo $compo['reception_status']['desc'] ?></div>
                <?php
                if (!$hideWorksCount) {
                    if (!$compo['counter']) {
                        echo '<div class="badge badge-cnt text-bg-secondary" title="' . $langMain['competitions received works'] . '">' . $compo['counter'] . '</div>';
                    } elseif ($compo['counter'] < 3) {
                        echo '<div class="badge badge-cnt text-bg-warning" title="' . $langMain['competitions received works'] . '">' . $compo['counter'] . '</div>';
                    } else {
                        echo '<div class="badge badge-cnt text-bg-success" title="' . $langMain['competitions received works'] . '">' . $compo['counter'] . '</div>';
                    }
                }
                ?>
            <?php endforeach;?>
        </div>
    </div>
    <?php
}

function displayCurrenEventVotingStatus($record): void {
    $langMain = NFW::i()->getLang("main");
    ?>
    <div id="vote-now-container-<?php echo $record['id'] ?>" class="mb-3" style="display: none;">
        <h3><?php echo $langMain['Voting opened'] ?>:</h3>
        <div id="vote-now-body-<?php echo $record['id'] ?>"></div>
    </div>

    <div id="live-voting-container-<?php echo $record['id'] ?>" style="display: none;">
        <div class="d-grid d-md-block mb-3">
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
            liveVotingContainer['style'].display = state ? "block" : "none";
        }

        function updateVotingOpen(values) {
            const voteNowContainer = document.getElementById("vote-now-container-<?php echo $record['id']?>");
            const voteNowBody = document.getElementById("vote-now-body-<?php echo $record['id']?>");

            if (values.length === 0) {
                voteNowContainer['style'].display = "none";
                return
            }

            voteNowBody.innerHTML = "";
            values.forEach((compo) => {
                const title = document.createElement('a');
                title.innerText = compo['title']
                title.href = compo['url']

                const status = document.createElement('div');
                status.innerText = compo['statusText']
                status.className = "text-nowrap text-danger"

                const item = document.createElement('div');
                item.className = "d-flex flex-row mb-2 justify-content-between gap-2";
                item.appendChild(title);
                item.appendChild(status);

                voteNowBody.appendChild(item);
            })

            voteNowContainer['style'].display = "block";
        }
    </script>
    <?php
}