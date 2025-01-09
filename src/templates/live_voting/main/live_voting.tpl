<?php
/**
 * @var array $event
 * @var string $title
 */

$langMain = NFW::i()->getLang('main');

// linter related
ob_start();
echo '<div class="live-voting"><div class="btn-group"></div></div>';
ob_end_flush()

?>
<style>
    .live-voting .btn-group {
        grid-template-columns: auto auto auto auto auto auto auto auto auto auto;
    }

    @media (max-width: 768px) {
        .live-voting .btn-group {
            grid-template-columns: auto auto auto auto auto;
        }
    }
</style>

<div class="mx-auto w-640">
    <h1 class="fs-3 mb-4"><?php echo $title ?></h1>

    <div id="live-voting-not-running-announce" class="alert alert-info"
         style="display: none;"><?php echo $langMain['live voting not running'] ?></div>

    <div id="coming-announce" class="alert alert-info mb-4" style="display: none;">
        <h4 id="title"></h4>
        <p id="description"></p>
    </div>

    <div id="current-announce" class="alert alert-info mb-4" style="display: none;">
        <h4 id="title"></h4>
    </div>

    <div id="live-voting-works" class="mb-4"></div>

    <div id="end-announce" class="alert alert-info" style="display: none;">
        <h4 id="title"></h4>
    </div>
</div>

<script>
    const worksContainer = document.getElementById("live-voting-works");
    let lastState = "";
    let isSendingVote = false;

    const notRunningAnnounce = document.getElementById("live-voting-not-running-announce");

    const currentContainer = document.getElementById("current-announce");
    const currentTitle = currentContainer.querySelector("#title")

    const comingContainer = document.getElementById("coming-announce");
    const comingTitle = comingContainer.querySelector("#title")
    const comingDescription = comingContainer.querySelector("#description")

    const endContainer = document.getElementById("end-announce");
    const endTitle = endContainer.querySelector("#title")

    updateVotingState();
    setInterval(updateVotingState, 5000);

    function updateVotingState() {
        if (isSendingVote) {
            return;
        }

        fetch('/internal_api?action=liveVotingStatus&event_id=<?php echo $event['id']?>').then(response => response.json()).then(response => {
            updateLiveVoting(response['liveVoting']);

            const currentState = stateHash(response['liveVoting']);
            if (currentState !== lastState) {
                setTimeout(function () {
                    window.scrollTo({left: 0, top: document.body.scrollHeight + 100, behavior: "smooth"});
                }, 500);

                lastState = currentState
            }
        });
    }

    function stateHash(state) {
        let works = [];
        if (state['works'] !== undefined) {
            state['works'].forEach((work) => {
                works.push(work["id"]);
            });
        }

        return JSON.stringify({
            "works": works,
            "coming": state['comingAnnounce'] ? 1 : 0,
            "current": state['currentAnnounce'] ? 1 : 0,
            "end": state['endAnnounce'] ? 1 : 0
        });
    }

    function updateLiveVoting(state) {
        if (!isLiveVotingStarted(state)) {
            comingContainer.style.display = "none";
            endContainer.style.display = "none";
            worksContainer.style.display = "none";
            currentContainer.style.display = "none";
            notRunningAnnounce.style.display = "block";
            return;
        }

        notRunningAnnounce.style.display = "none";

        if (state['comingAnnounce']) {
            comingTitle.innerText = state['comingAnnounce']["title"];
            comingDescription.innerText = state['comingAnnounce']["description"];
            comingContainer.style.display = "block";
        } else {
            comingContainer.style.display = "none";
        }

        if (state['currentAnnounce']) {
            currentTitle.innerText = state["currentAnnounce"];
            currentContainer.style.display = "block";
        } else {
            currentContainer.style.display = "none";
        }

        if (state['endAnnounce']) {
            endTitle.innerText = state['endAnnounce']["title"];
            endContainer.style.display = "block";
        } else {
            endContainer.style.display = "none";
        }

        worksContainer.innerHTML = "";

        if (state['works'] === undefined) {
            return;
        }

        state['works'].forEach(work => {
            let liveVoting = document.createElement('div');
            liveVoting.className = "live-voting mb-5";

            let title = document.createElement('h2');
            title.className = "mb-3";
            title.innerText = work["position"] + ". " + work["title"];
            liveVoting.appendChild(title);

            if (work['screenshot']) {
                let screenshot = document.createElement('img');
                screenshot.setAttribute('src', work['screenshot']);
                screenshot.className = "mb-3 w-100";
                liveVoting.appendChild(screenshot);
            }

            if (work['voting_options']) {
                let btnGroup = document.createElement('div');
                btnGroup.className = "d-grid btn-group gap-1";
                btnGroup.setAttribute("role", "group");

                work['voting_options'].forEach(i => {
                    let btn = document.createElement('a');
                    btn.setAttribute("type", "button");

                    btn.className = "btn btn-outline-success btn-vote";
                    if (work['voted'] === i) {
                        btn.classList.add("active");
                    }

                    btn.innerHTML = i.toString();
                    btn.onclick = function () {
                        const isActive = btn.classList.contains("active");

                        for (const b of btnGroup.children) {
                            b.classList.remove("active");
                        }

                        let voteValue = i;
                        if (isActive) {
                            btn.classList.remove("active");
                            voteValue = 0;
                        } else {
                            btn.classList.add("active");
                        }

                        isSendingVote = true;
                        fetch("/internal_api?action=liveVote", {
                            method: "POST",
                            body: JSON.stringify({
                                workID: work["id"],
                                vote: voteValue,
                            }),
                            headers: {
                                "Content-type": "application/json; charset=UTF-8"
                            }
                        }).then(function () {
                            isSendingVote = false;
                        });
                    };
                    btnGroup.appendChild(btn);
                });

                liveVoting.appendChild(btnGroup);
            }

            worksContainer.appendChild(liveVoting);
        });

        worksContainer.style.display = "block";
    }

    function isLiveVotingStarted(state) {
        if (state === null) {
            return false;
        }

        if (state['comingAnnounce'] || state['currentAnnounce'] || state['endAnnounce']) {
            return true;
        }

        return state['works'] !== undefined && state['works'].length > 0;
    }
</script>