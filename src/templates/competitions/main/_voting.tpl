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

NFW::i()->registerResource('jquery.activeForm', false, true);
NFW::i()->registerResource('jquery.blockUI');
?>
    <script type="text/javascript">
        $(document).ready(function () {
            const errorToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('errorToast'));
            const successToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('successToast'));
            const acceptedToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('acceptedToast'));
            const canceledToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('canceledToast'));

            const scrollToError = document.getElementById('username').offsetTop - 80;
            const inputUsername = $('input[id="username"]');
            const usernameFeedback = $('#username-feedback');
            const inputVotekey = $('input[id="votekey"]');
            const votekeyFeedback = $('#votekey-feedback');

            // Load saved username
            const result = localStorage.getItem('votingUsername');
            if (result) {
                inputUsername.val(result);
            }

            // Applying DB state
            <?php foreach ($storedVotes as $workID=>$vote): ?>
            $('button[data-role="vote"][data-work-id="<?php echo $workID?>"][data-vote-value="<?php echo $vote?>"]').addClass('active');
            <?php endforeach; ?>

            $('button[data-role="vote"]').click(async function () {
                const workID = $(this).data('work-id');
                const username = inputUsername.val();
                const votekey = $('input[id="votekey"]').val();

                let voteValue = parseInt($(this).data('vote-value'));
                if ($(this).hasClass('active')) {
                    voteValue = 0;
                }

                inputUsername.removeClass('is-valid is-invalid');
                usernameFeedback.text('').hide();
                inputVotekey.removeClass('is-valid is-invalid');
                votekeyFeedback.text('').hide();

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
                        document.getElementById('errorToast-text').innerText = errors["general"];
                        errorToast.show();
                    }

                    if (errors["username"] !== undefined && errors["username"] !== "") {
                        inputUsername.addClass('is-invalid');
                        usernameFeedback.text(errors["username"]).show();
                        isScroll = true;
                    } else {
                        inputUsername.addClass('is-valid');
                    }

                    if (errors["votekey"] !== undefined && errors["votekey"] !== "") {
                        inputVotekey.addClass('is-invalid');
                        votekeyFeedback.text(errors["votekey"]).show();
                        isScroll = true;
                    } else {
                        inputVotekey.addClass('is-valid');
                    }

                    if (isScroll) {
                        window.scrollTo({top: scrollToError, behavior: "smooth"});
                    }

                    return;
                }

                $('button[data-role="vote"][data-work-id="' + workID + '"]').removeClass('active');

                if (voteValue === 0) {
                    acceptedToast.hide();
                    canceledToast.show();
                } else {
                    $(this).addClass('active');
                    canceledToast.hide();
                    acceptedToast.show();
                }

                // Save username for future use
                localStorage.setItem('votingUsername', username);
            });

            // Request votekey
            const requestVotekeyEmail = $('input[id="request-votekey-email"]');
            const offcanvasRequestVotekey = new bootstrap.Offcanvas('#offcanvasRequestVotekey')
            $('button[id="request-votekey"]').click(function () {
                requestVotekeyEmail.removeClass('is-invalid');
                $('#request-votekey-email-feedback').text('').hide();

                $.ajax('<?php echo NFW::i()->base_path . 'internal_api?action=requestVotekey&event_id=' . $eventID?>',
                    {
                        method: "POST",
                        dataType: "json",
                        data: {
                            'email': requestVotekeyEmail.val()
                        },
                        error: function (response) {
                            if (response['responseJSON']['errors']['general'] === undefined) {
                                return
                            }

                            requestVotekeyEmail.addClass('is-invalid');
                            $('#request-votekey-email-feedback').text(response['responseJSON']['errors']['general']).show();
                        },
                        success: function (response) {
                            offcanvasRequestVotekey.hide();

                            requestVotekeyEmail.val('');
                            requestVotekeyEmail.removeClass('is-invalid');
                            $('#request-votekey-email-feedback').text('').hide();

                            document.getElementById('successToast-text').innerText = response['message'];
                            successToast.show();
                        }
                    }
                );
            });
        });
    </script>
    <div class="toast-container position-fixed top-0 start-50 translate-middle-x" style="top: 44px !important;">
        <div id="acceptedToast" class="toast text-bg-success"
             role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="800">
            <div class="toast-body text-center">Accepted</div>
        </div>

        <div id="canceledToast" class="toast text-bg-info"
             role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="800">
            <div class="toast-body text-center">Cancelled</div>
        </div>

        <div id="successToast" class="toast text-bg-success"
             role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="2000">
            <div class="d-flex">
                <div id="successToast-text" class="toast-body"></div>
                <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>

        <div id="errorToast" class="toast text-bg-danger"
             role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="2000">
            <div class="d-flex">
                <div id="errorToast-text" class="toast-body"></div>
                <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
    </div>

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
            <label for="username"><?php echo $langMain['voting name'] ?></label>
            <input type="text" id="username" class="form-control " maxlength="64"
                   value="<?php echo isset(NFW::i()->user['realname']) && NFW::i()->user['realname'] ? htmlspecialchars(NFW::i()->user['realname']) : "" ?>">
            <div id="username-feedback" class="invalid-feedback"></div>
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
                        <use href="#arrow-repeat"></use>
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
    <input type="hidden" id="username"/>
    <input type="hidden" id="votekey"/>
<?php endif; ?>