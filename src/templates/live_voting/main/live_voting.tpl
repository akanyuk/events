<?php
/**
 * @var array $event
 * @var string $title
 */
?>
<style>
    @media (max-width: 768px) {
        H1 {
            margin-top: 0;
            font-size: 16px;
        }
    }

    .live-voting {
        background-color: #000;
        color: #fff;
        margin-bottom: 10px;
    }

    .live-voting > .inner {
        padding: 2px;
        display: flex;
        align-items: center;
    }

    .live-voting > .inner DIV {
        padding: 10px 20px;
    }

    .live-voting IMG {
        max-width: 256px;
    }

    .btn-group-live-voting A.btn {
        font-size: 16px;
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
            max-width: 112px;
        }

        .btn-group-live-voting A.btn {
            padding: 1px 3px;
            font-size: 12px;
            line-height: 1.8;
        }
    }
</style>

<div style="text-align: center">
    <h1><?php echo $title ?></h1>
</div>

<div class="row">
    <div class="col-xs-12 col-sm-8 col-sm-offset-2 col-md-6 col-md-offset-3 col-lg-4 col-lg-offset-4">
        <div id="coming-announce" class="live-voting" style="display: none;">
            <div class="inner">
                <div>
                    <h4 id="title"></h4>
                    <p id="description"></p>
                </div>
            </div>
        </div>

        <div id="current-announce" class="live-voting" style="display: none;">
            <div class="inner">
                <div>
                    <h4 id="title"></h4>
                </div>
            </div>
        </div>

        <div id="live-voting-works"></div>

        <div id="end-announce" class="live-voting" style="display: none;">
            <div class="inner">
                <div>
                    <h4 id="title"></h4>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    const worksContainer = document.getElementById("live-voting-works");
    let lastState = "";
    let isSendingVote = false;

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
        state['works'].forEach((work) => {
            works.push(work["id"]);
        });

        return JSON.stringify({
            "works": works,
            "coming": state['comingAnnounce'] ? 1 : 0,
            "current": state['currentAnnounce'] ? 1 : 0,
            "end": state['endAnnounce'] ? 1 : 0
        });
    }

    function updateLiveVoting(state) {
        if (state === null) {
            comingContainer.style.display = "none";
            endContainer.style.display = "none";
            worksContainer.style.display = "none";
            currentContainer.style.display = "none";
            return;
        }

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
            return
        }

        state['works'].forEach((work) => {
            let title = document.createElement('h4');
            title.innerText = work["position"] + ". " + work["title"];

            let div = document.createElement('div');
            div.appendChild(title);

            let inner = document.createElement('div');
            inner.className = "inner";

            if (work['screenshot']) {
                let screenshot = document.createElement('img');
                screenshot.setAttribute('src', work['screenshot']);
                inner.appendChild(screenshot);
            }

            inner.appendChild(div);

            let liveVoting = document.createElement('div');
            liveVoting.className = "live-voting";
            liveVoting.appendChild(inner);

            if (work['voting_options']) {
                let btnGroup = document.createElement('div');
                btnGroup.className = "btn-group btn-group-live-voting btn-group-justified";
                btnGroup.setAttribute("role", "group");

                work['voting_options'].forEach((i) => {
                    let btn = document.createElement('a');
                    btn.setAttribute("type", "button");
                    btn.className = work['voted'] === i ? "btn btn-primary active" : "btn btn-default";
                    btn.innerHTML = i.toString();
                    btn.onclick = function () {
                        const isActive = btn.className === "btn btn-primary active";

                        for (const b of btnGroup.children) {
                            b.className = "btn btn-default";
                        }

                        let voteValue = i;
                        if (isActive) {
                            btn.className = "btn btn-default";
                            voteValue = 0;
                        } else {
                            btn.className = "btn btn-primary active";
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
                        }).then(response => {
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

    function updateVotingOpen(values) {
        const voteNowContainer = document.getElementById("vote-now-container");
        const voteNowBody = document.getElementById("vote-now-body");

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