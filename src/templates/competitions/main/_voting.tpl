<?php
/**
 * @var int $eventID
 * @var array $works
 */

$votekeyKey = 'votekey-' . $eventID;
$votekey = new votekey();
if (!NFW::i()->user['is_guest']) {
    $result = votekey::findOrCreateVotekey($eventID, NFW::i()->user['email']);
    if (!$result->error) {
        $votekey = $result;
        NFW::i()->setCookie($votekeyKey, $votekey->votekey);
    }
} else if (isset($_COOKIE['votekey-' . $eventID])) {
    $votekey = votekey::getVotekey($_COOKIE[$votekeyKey], $eventID);
    if ($votekey->error) {
        NFW::i()->setCookie($votekeyKey, null);
    }
}

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
            let votingForm = $('form[id="voting"]');

            // Applying DB state
            <?php foreach ($storedVotes as $workID=>$vote): ?>
            votingForm.find('select[id="<?php echo $workID?>"] option').removeAttr('selected');
            votingForm.find('select[id="<?php echo $workID?>"] option[value="<?php echo $vote?>"]').attr('selected', 'selected');
            <?php endforeach; ?>

            // Request votekey
            const requestVotekeyEmail = $('input[id="request-votekey-email"]');
            const successToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('successToast'));
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

            votingForm.activeForm({
                'success': function (response) {
                    alert(response.message);
                    // Save username for future use
                    localStorage.setItem('votingUsername', votingForm.find('input[name="username"]').val());
                }
            });

            // Load saved username
            const result = localStorage.getItem('votingUsername');
            if (result) {
                votingForm.find('input[name="username"]').val(result);
            }
        });
    </script>

    <div class="toast-container position-fixed top-0 end-0 p-3">
        <div id="successToast" class="toast text-bg-success"
             role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div id="successToast-text" class="toast-body"></div>
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
    <div class="mb-3">
        <label for="username"><?php echo $langMain['voting name'] ?></label>
        <input type="text" id="username" class="form-control " maxlength="64"
               value="<?php echo isset(NFW::i()->user['realname']) && NFW::i()->user['realname'] ? htmlspecialchars(NFW::i()->user['realname']) : "" ?>">
    </div>

    <div class="mb-3">
        <label for="votekey">Votekey</label>

        <div class="input-group mb-3">
            <input name="votekey" type="text" maxlength="8" class="form-control"
                   style="font-size: 120%; font-family: monospace; font-weight: bold;"
                   value="<?php echo $votekey->votekey ?>"/>
            <button class="btn btn-outline-secondary"
                    title="<?php echo $langMain['votekey-request'] ?>"
                    data-bs-toggle="offcanvas"
                    data-bs-target="#offcanvasRequestVotekey"
                    aria-controls="offcanvasRequestVotekey"><svg width="1.5em" height="1.2em">
                    <use href="#arrow-repeat"></use>
                </svg></button>
        </div>
    </div>

    <div class="mb-5">
        <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                alt="Sign in with SceneID"/></a>
    </div>
<?php endif; ?>