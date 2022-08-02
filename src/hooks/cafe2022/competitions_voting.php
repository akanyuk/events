<?php

function competitions_voting($hook_additional) {
    NFW::i()->registerResource('jquery.activeForm', false, true);
    NFW::i()->registerResource('jquery.blockUI');
    NFW::i()->registerResource('base');

    NFW::i()->registerFunction('display_work_media');
    NFW::i()->registerFunction('active_field');

    $lang_main = NFW::i()->getLang('main');

    // Finding votekey
    $CVote = new vote();

    if (isset($_GET['key']) && $CVote->checkVotekey($_GET['key'], $hook_additional['event']['id'])) {
        $votekey = $_GET['key'];
        NFW::i()->setCookie('votekey', $votekey);
    } elseif (isset($_COOKIE['votekey']) && $CVote->checkVotekey($_COOKIE['votekey'], $hook_additional['event']['id'])) {
        $votekey = $_COOKIE['votekey'];
    } else {
        $votekey = '';
    }

    if (!empty($hook_additional['event']['options'])) {
        $vote_options = array();
        foreach ($hook_additional['event']['options'] as $v) {
            $vote_options[$v['value']] = $v['label_'.NFW::i()->user['language']] ? $v['label_'.NFW::i()->user['language']] : $v['value'];
        }
    } else {
        $vote_options = $lang_main['voting votes'];
    }
?>
<script type="text/javascript">
    $(document).ready(function(){
        // Load state
        let votingCache = [];
        let result;
        try {
            result = JSON.parse(localStorage.getItem('votingCache'));
            if (result) {
                votingCache = result;
            }
        } catch (err) { }

        let votingForm = $('form[id="voting"]');

        // Apply saved values, remove expired
        const expire = new Date().getTime() - 60 * 60 * 24 * 14 * 1000;
        votingCache.forEach(function(record, key) {
            if (record.timestamp < expire) {
                votingCache.splice(key, 1);
            }
            else {
                votingForm.find('select[id="' + record.work_id+ '"] option').removeAttr('selected');
                votingForm.find('select[id="' + record.work_id+ '"] option[value="' + record.value + '"]').attr('selected', 'selected');
            }
        });
        localStorage.setItem('votingCache', JSON.stringify(votingCache));

        // Save state
        votingForm.find('select').change(function(){
            votingCache.push({ 'work_id': $(this).attr('id'), 'value': $(this).val(), 'timestamp': new Date().getTime() });
            localStorage.setItem('votingCache', JSON.stringify(votingCache));
        });

        votingForm.activeForm({
            'success': function(response){
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
<?php echo nl2br($hook_additional['competition']['announcement'])?>
<form id="voting" class="active-form" action="/vote?action=add_vote">
    <input type="hidden" name="competition_id" value="<?php echo $hook_additional['competition']['id']?>" />
<?php
    foreach ($hook_additional['voting_works'] as $work) {
        echo display_work_media($work, array('rel' => 'voting', 'single' => false, 'vote_options' => $vote_options)).'<hr />';
    }

    echo '<br />';

    echo active_field(array(
        'name' => 'username',
        'value' => NFW::i()->user['realname'] ? htmlspecialchars(NFW::i()->user['realname']) : htmlspecialchars(NFW::i()->user['username']),
        'type' => 'str',
        'desc' => $lang_main['voting name'],
        'required' => true,
        'maxlength' => 64,
        'vertical' => true,
    ));

    echo active_field(array(
        'name' => 'votekey',
        'value' => $votekey,
        'type' => 'str',
        'desc' => 'Votekey',
        'required' => true,
        'maxlength' => 8,
        'vertical' => true,
        'disable_help_block' => true,
    ));
?>
    <div class="form-group" data-active-container="general-message">
        <span class="help-block"></span>
    </div>

    <div class="form-group">
        <button type="submit" class="btn btn-lg btn-primary"><?php echo $lang_main['voting send']?></button>
    </div>
</form>
<hr />
<br />
<?php
    return "stop_execution";
}