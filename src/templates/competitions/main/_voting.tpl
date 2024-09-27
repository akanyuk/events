<?php
/**
 * @var array $event
 * @var array $competition
 * @var array $works
 */

$votekey = new votekey();
if (isset($_COOKIE['votekey'])) {
    $votekey = votekey::getVotekey($_COOKIE['votekey'], $event['id']);
    if ($votekey->error) {
        NFW::i()->setCookie('votekey', null);
    }
} else if (!NFW::i()->user['is_guest']) {
    $result = votekey::findOrCreateVotekey($event["id"], NFW::i()->user['email']);
    if (!$result->error) {
        $votekey = $result;
        NFW::i()->setCookie('votekey', $votekey->votekey);
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

$votingOptions = $langMain['voting votes'];
if (!empty($event['options'])) {
    $votingOptions = [];
    foreach ($event['options'] as $v) {
        $votingOptions[$v['value']] = $v['label_' . NFW::i()->user['language']] ? $v['label_' . NFW::i()->user['language']] : $v['value'];
    }
}

NFW::i()->registerResource('jquery.activeForm', false, true);
NFW::i()->registerResource('jquery.blockUI');
NFW::i()->registerResource('base');

NFW::i()->registerFunction('display_work_media');
NFW::i()->registerFunction('active_field');
?>
    <script type="text/javascript">
        $(document).ready(function () {
            // Load state
            let votingCache = [];
            let result;
            try {
                result = JSON.parse(localStorage.getItem('votingCache'));
                if (result) {
                    votingCache = result;
                }
            } catch (err) {
            }

            let votingForm = $('form[id="voting"]');

            // Applying storage state, removing expired
            const expire = new Date().getTime() - 60 * 60 * 24 * 14 * 1000;
            votingCache.forEach(function (record, key) {
                if (record.timestamp < expire) {
                    votingCache.splice(key, 1);
                } else {
                    votingForm.find('select[id="' + record.work_id + '"] option').removeAttr('selected');
                    votingForm.find('select[id="' + record.work_id + '"] option[value="' + record.value + '"]').attr('selected', 'selected');
                }
            });
            localStorage.setItem('votingCache', JSON.stringify(votingCache));

            // Applying DB state
            <?php foreach ($storedVotes as $workID=>$vote): ?>
            votingForm.find('select[id="<?php echo $workID?>"] option').removeAttr('selected');
            votingForm.find('select[id="<?php echo $workID?>"] option[value="<?php echo $vote?>"]').attr('selected', 'selected');
            <?php endforeach; ?>

            // Save state
            votingForm.find('select').change(function () {
                votingCache.push({
                    'work_id': $(this).attr('id'),
                    'value': $(this).val(),
                    'timestamp': new Date().getTime()
                });
                localStorage.setItem('votingCache', JSON.stringify(votingCache));
            });

            // Change votekey
            const newVotekeySelector = $('div[id="input-votekey"]');
            $('button[id="another-votekey"]').click(function () {
                newVotekeySelector.find('input[name="votekey"]').val('');
                $('div[id="saved-votekey"]').remove();
                newVotekeySelector.show();
            });

            // Request votekey
            const errorToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('errorToast'));
            const successToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('successToast'));
            const offcanvasRequestVotekey = new bootstrap.Offcanvas('#offcanvasRequestVotekey')
            $('button[id="request-votekey"]').click(function () {
                $.ajax('<?php echo NFW::i()->base_path . 'internal_api?action=requestVotekey&event_id=' . $competition['event_id']?>',
                    {
                        method: "POST",
                        dataType: "json",
                        data: {
                            'email': $('input[id="request-votekey-email"]').val()
                        },
                        error: function (response) {
                            if (response['responseJSON']['errors']['general'] === undefined) {
                                return
                            }

                            document.getElementById('errorToast-text').innerText = response['responseJSON']['errors']['general'];
                            errorToast.show();
                        },
                        success: function (response) {
                            offcanvasRequestVotekey.hide();
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
            result = localStorage.getItem('votingUsername');
            if (result) {
                votingForm.find('input[name="username"]').val(result);
            }
        });
    </script>

    <div class="toast-container position-fixed top-0 end-0 p-3">
        <div id="errorToast" class="toast text-bg-danger"
             role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
            <div class="d-flex">
                <div id="errorToast-text" class="toast-body"></div>
                <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        </div>
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
            </div>

            <button id="request-votekey" class="btn btn-primary"
                    type="button"><?php echo $langMain['votekey-request send'] ?></button>
        </div>
    </div>
<?php

ob_start();
?>
    <div class="mb-3">
        <label for="username"><?php echo $langMain['voting name'] ?></label>
        <input type="text" id="username" class="form-control " maxlength="64"
               value="<?php echo isset(NFW::i()->user['realname']) && NFW::i()->user['realname'] ? htmlspecialchars(NFW::i()->user['realname']) : "" ?>">
    </div>

    <div class="mb-3">
        <label for="votekey">Votekey</label>

        <?php if ($votekey->id): ?>
            <div id="saved-votekey" class="d-flex">
                <span style="font-size: 160%; font-family: monospace; font-weight: bold;"
                      class="text-muted me-2"><?php echo $votekey->votekey ?></span>
                <button id="another-votekey"
                        class="btn btn-sm btn-secondary"><?php echo $langMain['change-votekey'] ?></button>
            </div>
        <?php endif; ?>

        <div id="input-votekey" style="display: <?php echo $votekey->id ? 'none' : 'block' ?>;">
            <input name="votekey" type="text" maxlength="8" class="form-control"/>

            <button class="btn btn-sm btn-secondary my-2"
                    data-bs-toggle="offcanvas"
                    data-bs-target="#offcanvasRequestVotekey"
                    aria-controls="offcanvasRequestVotekey"><?php echo $langMain['votekey-request'] ?></button>
        </div>
    </div>

<?php if (NFW::i()->user['is_guest']): ?>
    <div class="mb-3">
        <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                alt="Sign in with SceneID"/></a>
    </div>
<?php endif; ?>

    <div class="mb-2">&nbsp;</div>

<?php
NFWX::i()->mainLayoutLeftContent .= ob_get_clean();


$curPos = 1;
foreach ($works as $work) {
    $work['position'] = $curPos++;
    echo display_work_media($work, [
        'rel' => 'voting',
        'single' => count($works) == 1,
        'vote_options' => $votingOptions,
        'voting_system' => $event['voting_system'],
    ]);
}
