<?php
/**
 * @var array $event
 * @var array $competition
 * @var array $works
 * @var array $votekey Preloaded from request or user profile votekey
 */

$result = NFWX::i()->hook("competitions_voting", $event['alias'], array('event' => $event, 'competition' => $competition, 'voting_works' => $works));
if ($result === "stop_execution") {
    return;
}

NFW::i()->registerResource('jquery.activeForm', false, true);
NFW::i()->registerResource('jquery.blockUI');
NFW::i()->registerResource('base');

NFW::i()->registerFunction('display_work_media');
NFW::i()->registerFunction('active_field');

$lang_main = NFW::i()->getLang('main');

$votingOptions = array();
if (!empty($hook_additional['event']['options'])) {
    foreach ($hook_additional['event']['options'] as $v) {
        $votingOptions[$v['value']] = $v['label_' . NFW::i()->user['language']] ? $v['label_' . NFW::i()->user['language']] : $v['value'];
    }
} else if (!empty($event['options'])) {
    foreach ($event['options'] as $v) {
        $votingOptions[$v['value']] = $v['label_' . NFW::i()->user['language']] ? $v['label_' . NFW::i()->user['language']] : $v['value'];
    }
} else {
    $votingOptions = $lang_main['voting votes'];
}
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

        // Apply saved values, remove expired
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
        const newVotekeySelector = $('div[id="new-votekey"]');
        $('button[id="another-votekey"]').click(function () {
            newVotekeySelector.find('input[name="votekey"]').val('');
            $('div[id="saved-votekey"]').remove();
            newVotekeySelector.show();
        });

        votingForm.activeForm({
            'success': function (response) {
                alert(response.message);
                //vf.resetForm();

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
                <h4 class="modal-title"><?php echo $lang_main['votekey-request long'] ?></h4>
            </div>
            <div class="modal-body">
                <form id="request-votekey" action="/vote?action=request_votekey" class="form-horizontal">
                    <input type="hidden" name="event_id" value="<?php echo $competition['event_id'] ?>"/>
                    <input type="hidden" name="action" value="request_votekey"/>
                    <div class="alert alert-warning"><?php echo $lang_main['votekey-request note'] ?></div>
                    <?php echo active_field(array('name' => 'email', 'type' => 'email', 'desc' => $lang_main['votekey-request email label'], 'inputCols' => '8')) ?>
                </form>
                <div id="response-message" class="alert alert-success" style="display: none;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default"
                        data-dismiss="modal"><?php echo NFW::i()->lang['Close'] ?></button>
                <button id="request-votekey-submit" type="button"
                        class="btn btn-primary"><?php echo $lang_main['votekey-request send'] ?></button>
            </div>
        </div>
    </div>
</div>

<?php echo count($works) == 1 ? '' : nl2br($competition['announcement']) ?>

<form id="voting" class="active-form" action="/vote?action=add_vote">
    <input type="hidden" name="competition_id" value="<?php echo $competition['id'] ?>"/>
    <?php
    $curPos = 1;
    foreach ($works as $work) {
        $work['position'] = $curPos++;
        echo display_work_media($work, array('rel' => 'voting', 'single' => count($works) == 1, 'vote_options' => $votingOptions)) . '<hr />';
    }

    echo '<br />';

    echo active_field(array(
        'name' => 'username',
        'value' => isset(NFW::i()->user['realname']) && NFW::i()->user['realname'] ? htmlspecialchars(NFW::i()->user['realname']) : "",
        'type' => 'str',
        'desc' => $lang_main['voting name'],
        'required' => true,
        'maxlength' => 64,
        'vertical' => true,
        'width' => '640px',
    ));
    ?>
    <div class="form-group" data-active-container="votekey">
        <label class="control-label" for="votekey"><strong>Votekey</strong></label>
        <?php if ($votekey): ?>
            <div id="saved-votekey">
                <span class="text-muted"
                      style="display: inline-block; position: relative; top: 4px; font-size: 160%; font-family: monospace; font-weight: bold; width: 120px;"><?php echo $votekey ?></span>
                <button id="another-votekey"
                        class="btn btn-default"><?php echo $lang_main['votekey-another'] ?></button>
            </div>

            <div id="new-votekey" style="display: none;">
                <input name="votekey" type="text" maxlength="8" class="form-control"
                       style="display: inline-block; width: 120px; vertical-align: middle;"
                       value="<?php echo $votekey ?>"/>
                <button id="request-votekey"
                        class="btn btn-default"><?php echo $lang_main['votekey-request'] ?></button>
            </div>
        <?php else: ?>
            <div>
                <input name="votekey" type="text" maxlength="8" class="form-control"
                       style="display: inline-block; width: 120px; vertical-align: middle;"/>
                <button id="request-votekey"
                        class="btn btn-default"><?php echo $lang_main['votekey-request'] ?></button>
            </div>
        <?php endif; ?>
    </div>

    <div class="form-group" data-active-container="general-message">
        <span class="help-block"></span>
    </div>

    <div class="form-group">
        <button type="submit" class="btn btn-lg btn-primary"><?php echo $lang_main['voting send'] ?></button>
    </div>
</form>
<hr/>
