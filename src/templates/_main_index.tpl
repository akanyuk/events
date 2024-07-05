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

        .live-voting {
            transition: opacity 1s;
            background-color: #000;
            color: #fff;
            margin-bottom: 10px;
        }

        .live-voting > .top-container {
            padding: 2px;
            display: flex;
        }

        .live-voting > .top-container DIV {
            padding: 10px 20px;
        }

        .live-voting IMG {
            max-width: 256px;
        }

        .btn-group-live-voting .btn-default {
            color: #fff;
            background-color: #1f2a20;
            border-color: #63745b;
        }

        .btn-group-live-voting .btn-primary.active {
            color: #000;
            background-color: #beeab8;
            border-color: #63745b;
        }

        @media (max-width: 768px) {
            .live-voting IMG {
                max-width: 128px;
            }

            .btn-group-live-voting A {
                padding: 3px 5px;
                font-size: 12px;
                line-height: 1.5;
            }
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
                        <div class="hidden-xs">
                            <h2>
                                <a href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                            </h2>

                            <div style="font-weight: bold;"><?php echo $record['dates_desc'] ?></div>

                            <?php if ($record['announcement']): ?>
                                <div style="padding: 10px 0;"><?php echo nl2br($record['announcement']) ?></div>
                            <?php endif; ?>
                        </div>
                        <div class="hidden-lg hidden-md hidden-sm" id="no-live-voting-<?php echo $record['id'] ?>">
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
                    <div id="live-voting-container-<?php echo $record['id'] ?>" style="display: none;">
                        <h3>Live Voting</h3>
                        <div id="body" class="live-voting">
                            <div class="top-container">
                                <img id="screenshot" src="<?php echo NFW::i()->assets('main/news-no-image.png') ?>"
                                     alt="/"/>
                                <div>
                                    <h4 id="title"></h4>
                                    <p id="compo"></p>
                                </div>
                            </div>
                            <div id="voting" class="btn-group btn-group-live-voting btn-group-justified"
                                 role="group"></div>
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
                setInterval(updateVotingState, 5000);
                updateVotingState();

                function updateVotingState() {
                    fetch('/internal_api?action=indexVotingStatus&event_id=<?php echo $record['id']?>').then(response => response.json()).then(response => {
                        updateLiveVoting(response['liveVoting']);
                        updateVotingOpen(response['votingOpen']);
                    });
                }

                let lastLiveVotingWorkID = 0;
                let isLiveVotingGoing = false;

                function updateLiveVoting(state) {
                    const noLiveVotingContainer = document.getElementById("no-live-voting-<?php echo $record['id'] ?>");
                    const liveVotingContainer = document.getElementById("live-voting-container-<?php echo $record['id']?>");
                    const liveVoting = liveVotingContainer.querySelector("#body");
                    const screenshot = liveVoting.querySelector("#screenshot");
                    const title = liveVoting.querySelector("#title");
                    const compo = liveVoting.querySelector("#compo");
                    const voting = liveVoting.querySelector("#voting");

                    if (state === null) {
                        liveVotingContainer.style.display = "none";
                        noLiveVotingContainer.style.display = "block";
                        isLiveVotingGoing = false;
                        lastLiveVotingWorkID = 0;
                        return;
                    }

                    if (state["id"] === lastLiveVotingWorkID) {
                        return;
                    }
                    lastLiveVotingWorkID = state["id"];

                    let liveVotingInTimeout = 1200;
                    if (!isLiveVotingGoing) {
                        noLiveVotingContainer.style.display = "none";
                        liveVotingInTimeout = 1;
                        isLiveVotingGoing = true;
                    }

                    liveVoting.style.opacity = "0";
                    setTimeout(function () {
                        if (state['screenshot']) {
                            screenshot.setAttribute('src', state['screenshot']);
                            screenshot.style.display = 'block';
                        } else {
                            screenshot.style.display = 'none';
                        }

                        title.innerText = state['position'] + ". " + state['title'];
                        compo.innerText = state['competition_title'];

                        voting.innerHTML = '';
                        state['voting_options'].forEach((i) => {
                            let btn = document.createElement('a');
                            btn.setAttribute("type", "button");
                            btn.className = state['voted'] === i ? "btn btn-primary active": "btn btn-default";
                            btn.innerHTML = i.toString();
                            btn.onclick = function(){
                                const isActive = btn.className === "btn btn-primary active";

                                for (const b of voting.children) {
                                    b.className = "btn btn-default";
                                }

                                let voteValue = i;
                                if (isActive) {
                                    btn.className = "btn btn-default";
                                    voteValue = 0;
                                } else {
                                    btn.className = "btn btn-primary active";
                                }

                                fetch("/internal_api?action=indexLiveVote", {
                                    method: "POST",
                                    body: JSON.stringify({
                                        workID: state["id"],
                                        vote: voteValue,
                                    }),
                                    headers: {
                                        "Content-type": "application/json; charset=UTF-8"
                                    }
                                });
                            };
                            voting.appendChild(btn);
                        });

                        liveVotingContainer.style.display = "block";
                        liveVoting.style.opacity = "1";
                    }, liveVotingInTimeout)
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
	