<?php
NFW::i()->registerFunction('cache_media');
NFW::i()->registerFunction('active_field');
$lang_main = NFW::i()->getLang('main');

// Load saved votekey
$votekey = false;
if (isset($_COOKIE['votekey'])) {
	$CVote = new vote();
	if ($CVote->checkVotekey($_COOKIE['votekey'], $competition['event_id'])) {
		$votekey = $_COOKIE['votekey'];
	}
}
else
{
	if ($competition['event_id'] && NFW::i()->user["email"] && NFW::i()->user["username"])
	{

		$CVote = new vote();
		$result = $CVote->requestVotekey(array("event_id"=>$competition['event_id'],"email"=>NFW::i()->user["email"]), false);

		if ($result["votekey"]) {
			NFW::i()->setCookie('votekey', $result["votekey"]);
			$votekey = $result["votekey"];
		}

	}

}


// Load saved votes
$cookie = array();
if (isset($_COOKIE['votes'])) {
	foreach (json_decode($_COOKIE['votes']) as $key=>$val) {
		$cookie[$key] = $val;
	}
};

	$CEvents = new events($competition['event_id']);
	$vote_values = $CEvents->record['options'];

	$vals = array();
	foreach ($vote_values as $val) $vals[] = $val["value"];
	$max_val = empty($vals) ? 0 : max($vals);
	unset($vals);

if ($vote_values)
{

	foreach ($vote_values as $k=>$v)
	{
		if (!$v["value"]) $value = $v["label_".NFW::i()->user['language']];
		else
		{
			if (!$v["label_".NFW::i()->user['language']]) $value = $v["value"];
			else {
				$value = $v["label_".NFW::i()->user['language']];
				}
			}

		$vote_options[$v["value"]]=$value;

		}

}
else $vote_options = $lang_main['voting votes'];

	/*ShM*/

// Get voting works
$CWorks = new works();
list($voting_works) = $CWorks->getRecords(array(
	'filter' => array('voting_only' => true, 'competition_id' => $competition['id']),
	'ORDER BY' => 'w.pos'
));
?>
<script type="text/javascript">
$(document).ready(function(){
	// Save state
	$.cookie.json = true;

	$('form[id="voting"]').find('select').change(function(){
		var curVotes = $.cookie('votes');
		if (typeof(curVotes) != "object") {
			curVotes = new Object();
		}
		curVotes[$(this).attr('id')] = $(this).val();
		$.cookie('votes', curVotes, { expires: 7 });
	});


	// Request votekey
	var dr = $('div[id="request-votekey-dialog"]');
	dr.modal({ 'show': false });

	$('button[id="request-votekey"]').click(function(){
		dr.find('div[id="response-message"]').hide();
		fr.show();
		dr.find('button[id="request-votekey-submit"]').show();
		dr.modal('show');
		return false;
	});

	var fr = dr.find('form');
	fr.activeForm({
		'success': function(response){
			fr.hide();
			dr.find('button[id="request-votekey-submit"]').hide();
			dr.find('div[id="response-message"]').html(response.message).show();
		}
	});

	dr.find('button[id="request-votekey-submit"]').click(function(){
		fr.submit();
	});

	// Change votekey
	$('button[id="another-votekey"]').click(function(){
		$('div[id="new-votekey"]').find('input[name="votekey"]').val('');
		$('div[id="saved-votekey"]').remove();
		$('div[id="new-votekey"]').show();
	});

	// Voting
	var vf = $('form[id="voting"]');
	vf.activeForm({
		'success': function(response){
			alert(response.message);
			//vf.resetForm();
		}
	});

});
</script>
<style>
	FORM#voting H2 { margin: 0 !important; border-bottom: 1px solid #777; }
	FORM#voting H3 { margin: 0 0 10px 0 !important; }
	FORM#voting LABEL { font-weight: normal !important; }

	FORM#request-votekey .help-block { color: #800; }
</style>

<div id="request-votekey-dialog" class="modal fade">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title"><?php echo $lang_main['votekey-request long']?></h4>
			</div>
			<div class="modal-body">
				<form id="request-votekey" action="<?php echo NFW::i()->base_path?>events" class="form-horizontal">
					<input type="hidden" name="event_id" value="<?php echo $competition['event_id']?>" />
					<input type="hidden" name="action" value="request_votekey" />
					<div class="alert alert-warning"><?php echo $lang_main['votekey-request note']?></div>
					<?php echo active_field(array('name' => 'email', 'type' => 'email', 'desc' => $lang_main['votekey-request email label'], 'inputCols' => '8'))?>
				</form>
				<div id="response-message" class="alert alert-success" style="display: none;"></div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal"><?php echo $lang_main['close button']?></button>
				<button id="request-votekey-submit" type="button" class="btn btn-primary"><?php echo $lang_main['votekey-request send']?></button>
			</div>
		</div>
	</div>
</div>

<div><span class="label label-danger"><?php echo $lang_main['voting to']?>: <?php echo date('d.m.Y H:i', $competition['voting_to'])?></span></div>
<?php echo nl2br($competition['announcement'])?>
<hr />

<form id="voting" action="<?php echo NFW::i()->base_path?>events" class="form-horizontal">
	<input type="hidden" name="competition_id" value="<?php echo $competition['id']?>" />
	<input type="hidden" name="action" value="vote" />
<?php $counter = 0; foreach ($voting_works as $w) { ?>
	<h3><?php echo $w['pos'].'. '.htmlspecialchars($w['title'])?></h3>

<?php
	// Display content (image, audio, video
	foreach ($w['image_files'] as $f) echo '<p><img src="'.cache_media($f).'" /></p>';

	if (!empty($w['audio_files'])) {
		echo '<audio controls="controls" loop="loop" preload="false">';
		foreach ($w['audio_files'] as $f) echo '<source src="'.cache_media($f).'" type="'.$f['mime_type'].'" />';
		echo $lang_main['voting audio not support'].'</audio>';
	}

	echo '<div>'.$w['external_html'].'</div>';
?>
	<div class="row">
		<div class="col-md-8">
			<?php echo $lang_main['works platform']?> / <?php echo $lang_main['works format']?>:
			<strong><?php echo htmlspecialchars($w['platform']).($w['format'] ? ' / '.htmlspecialchars($w['format']) : '')?></strong>
			<?php if ($w['permanent_file'] || !empty($w['voting_files'])):?>
				<div>
					<div class="pull-left"><?php echo $lang_main['voting download']?>:</div>
					<div class="pull-left" style="padding-left: 5px;">
						<?php
							if ($w['permanent_file']) {
								echo '<div><strong><a href="'.$w['permanent_file']['url'].'">'.htmlspecialchars($w['permanent_file']['basename']).'</a></strong></div>';
							}
							else {
								foreach ($w['voting_files'] as $f) { 
									echo '<div><strong><a href="'.cache_media($f).'">'.htmlspecialchars($f['basename']).'</a></strong></div>';
								}
							} 
						?>
					</div>
					<div class="clearfix"></div>
				</div>
			<?php endif; ?>
		</div>
		<div class="col-md-3">
			<select name="votes[<?php echo $w['id']?>]" id="<?php echo $w['id']?>" class="form-control" style="width: auto;">
				<?php foreach ($vote_options as $i=>$d) echo '<option value="'.$i.'"'.(isset($cookie[$w['id']]) && $cookie[$w['id']] == $i ? ' selected="selected"' : '').'>'.$d.'</option>'; ?>
			</select>
		</div>
	</div>
<?php
		echo $counter++ == count($voting_works) - 1 ? '' : '<hr />';
	}
?>
	<br />
	<?php

	$name = array(
		'name' => 'username',
		'value' => isset($_COOKIE['voting_username']) ? $_COOKIE['voting_username'] : '',
		'type' => 'str',
		'desc' => $lang_main['voting name'],
		'required' => true,
		'maxlength' => 64,
		'inputCols' => '8'
	);

	if (!$name["value"] && NFW::i()->user["username"])
	{
		$name["value"] = (NFW::i()->user["realname"]) ? htmlspecialchars(NFW::i()->user["realname"]) : htmlspecialchars(NFW::i()->user["username"]);

		}

	 echo active_field($name);

	 ?>
	<div class="form-group">
		<div class="col-md-offset-3 col-md-8">
			<div class="alert alert-warning"><?php echo $lang_main['voting note']?></div>
		</div>
	</div>


	<div class="form-group" id="votekey">
		<label class="col-md-3 control-label" for="votekey"><strong>Votekey</strong></label>

		<?php if ($votekey): ?>
			<div id="saved-votekey">
				<div class="col-md-4 text-muted" style="padding-top: 4px; font-size: 140%;"><?php echo $votekey?></div>
				<div class="col-md-4">
					<button id="another-votekey" class="btn btn-default btn-sm"><?php echo $lang_main['votekey-another']?></button>
				</div>
			</div>

			<div id="new-votekey" style="display: none;">
				<div class="col-md-4">
					<input name="votekey" type="text" maxlength="8" class="form-control" value="<?php echo $votekey?>" />
				</div>
				<div class="col-md-4">
					<button id="request-votekey" class="btn btn-default btn-sm"><?php echo $lang_main['votekey-request']?></button>
				</div>
			</div>
		<?php else: ?>
			<div class="col-md-4">
				<input name="votekey" type="text" maxlength="8" class="form-control" />
			</div>
			<div class="col-md-4">
				<button id="request-votekey" class="btn btn-default btn-sm"><?php echo $lang_main['votekey-request']?></button>
			</div>
		<?php endif; ?>
	</div>

	<div class="form-group" id="general">
		<div class="col-md-offset-3 col-md-8">
			<span class="help-block"></span>
		</div>
	</div>

	<div class="form-group">
		<div class="col-md-offset-3 col-md-8">
			<button type="submit" class="btn btn-lg btn-primary"><?php echo $lang_main['voting send']?></button>
		</div>
	</div>
</form>
<hr />
<br />