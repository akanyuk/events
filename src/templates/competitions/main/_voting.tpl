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
        NFW::i()->setCookie('votekey', $votekey);
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

        // Request votekey
        const dr = $('div[id="request-votekey-dialog"]');
        const fr = dr.find('form');
        dr.modal({'show': false});

        $('button[id="request-votekey"]').click(function () {
            dr.find('div[id="response-message"]').hide();
            fr.show();
            dr.find('button[id="request-votekey-submit"]').show();
            dr.modal('show');
            return false;
        });

        fr.activeForm({
            'success': function (response) {
                fr.hide();
                dr.find('button[id="request-votekey-submit"]').hide();
                dr.find('div[id="response-message"]').html(response.message).show();
            }
        });

        dr.find('button[id="request-votekey-submit"]').click(function () {
            fr.submit();
        });

        // Change votekey
        const newVotekeySelector = $('div[id="input-votekey"]');
        $('button[id="another-votekey"]').click(function () {
            newVotekeySelector.find('input[name="votekey"]').val('');
            $('div[id="saved-votekey"]').remove();
            newVotekeySelector.show();
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

<div id="request-votekey-dialog" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title"><?php echo $langMain['votekey-request long'] ?></h4>
            </div>
            <div class="modal-body">
                <form id="request-votekey" action="/vote?action=request_votekey" class="form-horizontal">
                    <input type="hidden" name="event_id" value="<?php echo $competition['event_id'] ?>"/>
                    <input type="hidden" name="action" value="request_votekey"/>
                    <div class="alert alert-warning"><?php echo $langMain['votekey-request note'] ?></div>
                    <?php echo active_field(array('name' => 'email', 'type' => 'email', 'desc' => $langMain['votekey-request email label'], 'inputCols' => '8')) ?>
                </form>
                <div id="response-message" class="alert alert-success" style="display: none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default"
                        data-dismiss="modal"><?php echo NFW::i()->lang['Close'] ?></button>
                <button id="request-votekey-submit" type="button"
                        class="btn btn-primary"><?php echo $langMain['votekey-request send'] ?></button>
            </div>
        </div>
    </div>
</div>

<?php echo count($works) == 1 ? '' : $competition['announcement'] ?>

<form id="voting" class="active-form" action="/vote?action=add_vote">
    <input type="hidden" name="competition_id" value="<?php echo $competition['id'] ?>"/>
    <?php
    $curPos = 1;
    foreach ($works as $work) {
        $work['position'] = $curPos++;
        echo display_work_media($work, [
                'rel' => 'voting',
                'single' => count($works) == 1,
                'vote_options' => $votingOptions,
                'voting_system' => $event['voting_system'],
            ]) . '<hr />';
    }

    echo '<br />';

    echo active_field(array(
        'name' => 'username',
        'value' => isset(NFW::i()->user['realname']) && NFW::i()->user['realname'] ? htmlspecialchars(NFW::i()->user['realname']) : "",
        'type' => 'str',
        'desc' => $langMain['voting name'],
        'required' => true,
        'maxlength' => 64,
        'vertical' => true,
        'width' => '640px',
    ));
    ?>
    <div class="form-group" data-active-container="votekey">
        <label class="control-label" for="votekey"><strong>Votekey</strong></label>
        <?php if ($votekey->id): ?>
            <div id="saved-votekey">
                <span class="text-muted"
                      style="display: inline-block; position: relative; top: 4px; font-size: 160%; font-family: monospace; font-weight: bold; width: 120px;"><?php echo $votekey->votekey ?></span>
                <button id="another-votekey"
                        class="btn btn-default"><?php echo $langMain['change-votekey'] ?></button>
            </div>
        <?php endif; ?>

        <div id="input-votekey" style="display: <?php echo $votekey->id ? 'none' : 'block' ?>;">
            <input name="votekey" type="text" maxlength="8" class="form-control"
                   style="max-width: 640px;"/>
            <div style="padding-top: 20px;">
                <button id="request-votekey"
                        class="btn btn-default"><?php echo $langMain['votekey-request'] ?></button>
            </div>
        </div>
    </div>

    <div class="form-group" data-active-container="general-message">
        <span class="help-block"></span>
    </div>

    <div class="form-group">
        <button type="submit" class="btn btn-lg btn-primary"><?php echo $langMain['voting send'] ?></button>
    </div>
</form>
<hr/>
