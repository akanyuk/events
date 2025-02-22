<?php
/**
 * @var int $eventID
 * @var array $works
 * @var votekey $votekey
 */

$storedVotes = [];
if ($votekey->id) {
    $req = [];
    foreach ($works as $work) {
        $req[] = $work['id'];
    }

    $CVote = new vote();
    $storedVotes = $CVote->getWorksVotes($req, $votekey);
}

$langMain = NFW::i()->getLang('main');
?>
<div id="offcanvasRequestVotekey" class="offcanvas offcanvas-start" data-bs-backdrop="static" tabindex="-1"
     aria-labelledby="offcanvasRequestVotekeyLabel">
    <div class="offcanvas-header">
        <h5 class="offcanvas-title"
            id="offcanvasRequestVotekeyLabel"><?php echo $langMain['votekey-request long'] ?></h5>
        <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
    </div>

    <div class="offcanvas-body">
        <div class="alert alert-warning"><?php echo $langMain['votekey-request note'] ?></div>

        <div class="mb-3">
            <label for="email">E-mail address</label>
            <input id="request-votekey-email" type="text" class="form-control"/>
            <div id="request-votekey-email-feedback" class="invalid-feedback"></div>
        </div>

        <button id="request-votekey" class="btn btn-primary"
                type="button"><?php echo $langMain['votekey-request send'] ?></button>
    </div>
</div>

<?php if (NFW::i()->user['is_guest']): ?>
    <div class="w-640">
        <div class="mb-3">
            <label for="voting-username"><?php echo $langMain['voting name'] ?></label>
            <input type="text" id="voting-username" class="form-control " maxlength="64">
            <div id="voting-username-feedback" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="votekey">Votekey</label>

            <div class="input-group">
                <input id="votekey" type="text" maxlength="8" class="form-control"
                       style="font-size: 120%; font-family: monospace; font-weight: bold;"
                       value="<?php echo $votekey->val ?>"/>
                <button class="btn btn-outline-secondary"
                        title="<?php echo $langMain['votekey-request'] ?>"
                        data-bs-toggle="offcanvas"
                        data-bs-target="#offcanvasRequestVotekey"
                        aria-controls="offcanvasRequestVotekey">
                    <svg width="1.5em" height="1.2em">
                        <use href="#icon-arrow-repeat"></use>
                    </svg>
                </button>
            </div>
            <div id="votekey-feedback" class="invalid-feedback"></div>
        </div>

        <div class="mb-5">
            <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                    src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                    alt="Sign in with SceneID"/></a>
        </div>
    </div>
<?php else: ?>
    <div class="d-none">
        <input type="hidden" id="voting-username"/>
        <div id="voting-username-feedback"></div>
        <input type="hidden" id="votekey"/>
        <div id="votekey-feedback" class="invalid-feedback"></div>
    </div>
<?php endif; ?>

<script type="text/javascript">
    <?php ob_start(); ?>
    const inputVotingUsername = document.getElementById('voting-username')
    const votingUsernameFeedback = document.getElementById('voting-username-feedback');
    const inputVotekey = document.getElementById('votekey');
    const votekeyFeedback = document.getElementById('votekey-feedback');
    const scrollToError = inputVotingUsername['offsetTop'] - 80;

    // Load saved username
    const result = localStorage.getItem('votingUsername');
    if (result) {
        inputVotingUsername.value = result;
    }

    // Applying DB state
    <?php foreach ($storedVotes as $workID=>$vote): ?>
    document.querySelector('button[data-role="vote"][data-work-id="<?php echo $workID?>"][data-vote-value="<?php echo $vote?>"]').classList.add("active");
    <?php endforeach; ?>

    document.querySelectorAll('button[data-role="vote"]').forEach((btn) => {
        btn.onclick = async function () {
            const workID = btn.getAttribute('data-work-id');
            const username = inputVotingUsername.value;
            const votekey = inputVotekey['value'];

            let voteValue = parseInt(btn.getAttribute('data-vote-value'));
            if (btn.classList.contains('active')) {
                voteValue = 0;
            }

            inputVotingUsername.classList.remove('is-valid', 'is-invalid');
            votingUsernameFeedback.className = 'd-none';
            inputVotekey.classList.remove('is-valid', 'is-invalid');
            votekeyFeedback.className = 'd-none';

            let response = await fetch("/internal_api?action=vote", {
                method: "POST",
                body: JSON.stringify({
                    workID: workID,
                    vote: voteValue,
                    username: username,
                    votekey: votekey,
                }),
                headers: {
                    "Content-type": "application/json; charset=UTF-8"
                }
            });

            if (!response.ok) {
                const resp = await response.json();
                const errors = resp.errors;
                let isScroll = false;

                if (errors["general"] !== undefined && errors["general"] !== "") {
                    gErrorToastText.innerText = errors["general"];
                    gErrorToast.show();
                }

                if (errors["username"] !== undefined && errors["username"] !== "") {
                    inputVotingUsername.classList.add('is-invalid');
                    votingUsernameFeedback.innerText = errors["username"];
                    votingUsernameFeedback.className = 'invalid-feedback d-block';
                    isScroll = true;
                } else {
                    inputVotingUsername.classList.add('is-valid');
                }

                if (errors["votekey"] !== undefined && errors["votekey"] !== "") {
                    inputVotekey.classList.add('is-invalid');
                    votekeyFeedback.innerText = errors["votekey"];
                    votekeyFeedback.className = 'invalid-feedback d-block';
                    isScroll = true;
                } else {
                    inputVotekey.classList.add('is-valid');
                }

                if (isScroll) {
                    window.scrollTo({top: scrollToError, behavior: "smooth"});
                }

                return;
            }

            document.querySelectorAll('button[data-role="vote"][data-work-id="' + workID + '"]').forEach((btn) => {
                btn.classList.remove("active");
            });

            if (voteValue === 0) {
                gAcceptedToast.hide();
                gCanceledToast.show();
            } else {
                btn.classList.add("active");
                gCanceledToast.hide();
                gAcceptedToast.show();
            }

            // Save username for future use
            localStorage.setItem('votingUsername', username);
        };
    });

    <?php if (NFW::i()->user['is_guest']): ?>
    // Requesting votekey
    const requestVotekeyEmail = document.getElementById('request-votekey-email');
    const requestVotekeyEmailFeedback = document.getElementById('request-votekey-email-feedback');
    const offcanvasRequestVotekey = new bootstrap.Offcanvas('#offcanvasRequestVotekey');
    document.getElementById('request-votekey').onclick = async function () {
        requestVotekeyEmail.classList.remove('is-invalid');
        requestVotekeyEmailFeedback.className = 'd-none';

        let response = await fetch("/internal_api?action=requestVotekey&event_id=<?php echo $eventID?>", {
            method: "POST",
            body: JSON.stringify({
                'email': requestVotekeyEmail.value
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        if (!response.ok) {
            const resp = await response.json();
            const errors = resp.errors;

            if (errors["general"] !== undefined && errors["general"] !== "") {
                requestVotekeyEmail.classList.add('is-invalid');
                requestVotekeyEmailFeedback.innerText = errors["general"];
                requestVotekeyEmailFeedback.className = 'invalid-feedback d-block';
            }

            return;
        }

        offcanvasRequestVotekey.hide();

        requestVotekeyEmail.value = "";
        requestVotekeyEmail.classList.remove('is-invalid');
        requestVotekeyEmailFeedback.className = 'd-none';

        const resp = await response.json();
        gSuccessToastText.innerText = resp['message'];
        gSuccessToast.show();
    };
    <?php endif; ?>
    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>
