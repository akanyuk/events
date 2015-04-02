<?php
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('ckeditor');
NFW::i()->registerResource('jquery.jgrowl');
NFW::i()->registerResource('jquery.cookie');
NFW::i()->registerFunction('ui_message');

if (isset($_COOKIE['layout_type'])) $layout_type = $_COOKIE['layout_type']; else $layout_type="";
if (isset($_COOKIE['layout_platform_show'])) $platform = json_decode($_COOKIE['layout_platform_show']); else $platform = array();

foreach ($Module->options_attributes as $key=>&$a) {
	$a['style'] = isset($a['style']) ? $a['style'] : 'width: '.(isset($a['width']) ? $a['width'] : '300px;');
}
unset($a);
?>
<script type="text/javascript">
$(document).ready(function(){
	// Votelist
	$('form[id="votelist"]').find('input[type="checkbox"], input[rel="uniform"]').uniform();
	$('input[rel="emptyrows"]').spinner({ min: 0, max: 20 });

	// Make `results.txt`, works pack
	$('form[id="make"]').activeForm({
		success: function(response) {


			if (response.reload == 'reload') { window.location.reload();; }
			else $(document).trigger('uiDialog', '<a href="' + response.url + '">' + response.url + '</a>');
		}
	});

	// Main action
 	$('form[rel="events-update"]').each(function(){
 		$(this).activeForm({
 	 		beforeSubmit: function(){
 	 			$('div[id="events-update-media"]').find('form').trigger('save-comments');
 	 	 	},
 	 		action: '<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>',
 			success: function(response) {

 	 			if (response.is_updated) {
 	 				$.jGrowl('Event profile updated.');
 	 			}
 			}
 		});
	});

	$('button[id="events-save"]').click(function(){
		$(this).closest('div[rel="tab-container"]').find('form[rel="events-update"]').submit();
	});

	// Visual edit
	$('textarea[name="content"]').CKEDIT({ 'media': 'events', 'media_owner': '<?php echo $Module->record['id']?>' });


	<?php /*$('div[id="events-update-tabs"]').tabs().show();*/ ?>

	$('div[id="events-update-tabs"]').tabs({
		active: $.cookie('events-update-activetab'),
		activate: function(event, ui){
		$.cookie('events-update-activetab', ui.newTab.index(), {
			expires : 30
		});
	}
	}).show();


    // Action 'update'
 	var f = $('form[id="eventz-update-<?php echo $Module->record['id']?>"]')
 	f.activeForm({
 	 	beforeSubmit: function() {
 	 	 	var isSuccess = true;
 	 		f.find('div[id="values-area"]').find('input').removeClass('error');
 	 	 	$.each(f.find('div[id="values-area"]').find('input[req="required"]'), function(i,o) {
 	 	 	 	if ($(this).val()) return;

 	 	 	 	$(this).addClass('error');
 	 	 	 	isSuccess = false;
 	 	 	});
 	 	 	return isSuccess;
 	 	},
 	 		action: '<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>',
 			success: function(response) {
 	 			if (response.is_updated) {
 	 				$.jGrowl('Event profile updated.');
 	 			}
 			}


	});

 	// Sortable `values`
 	f.find('div[id="values-area"]').sortable({
		items: 'div[id="record"]',
 		axis: 'y',
 	 	handle: '.icon'
	});




 	//$(document).off('click', f.find('*[rel="remove-values-record"]')).on('click', f.find('*[rel="remove-values-record"]'), function(){

 	$(document).on('click', '*[rel="remove-values-record"]', function(){

 	 	if ($(this).closest('div[id="record"]').attr('rel') == 'update') {

 	 		if (!confirm('Удалить параметр?')) return false;
 	 	}

 	 	$(this).closest('div[id="record"]').remove();
	});

 	f.find('button[id="add-values-record"]').click(function(){
 	 	var tpl = $('div[id="values-record-template-<?php echo $Module->record['id']?>"]').html();
 	 	f.find('div[id="values-area"]').append(tpl);
 	 	f.find('input, select').uniform();

 	 	return false;
	});

	$(document).trigger('refresh');

});
</script>

<style>
	.eventz {	display: table;	}
	.eventz .record, .eventz .header { display:table-row; }
	.eventz .record:nth-child(even) { background-color: #E2E4FF; }
	.eventz .cell { display:table-cell; padding: 5px 2px; }
	.eventz .cell:nth-child(1) { padding-left: 5px; }
	.eventz .header .cell { font-size: 90%; font-weight: bold; }
</style>


<div id="events-update-tabs" style="display: none;">
	<div style="float: right; padding-right: 1em; padding-top: 0.2em;">
		<p style="font-size: 85%; text-align: right;">Posted: <?php echo date('d.m.Y H:i:s', $Module->record['posted']).' ('.$Module->record['posted_username'].')'?></p>
		<?php if ($Module->record['edited']): ?>
			<p style="font-size: 85%; text-align: right;">Updated: <?php echo date('d.m.Y H:i:s', $Module->record['edited']).' ('.$Module->record['edited_username'].')'?></p>
		<?php endif; ?>
	</div>

	<ul>
		<li><a href="#tabs-1">Settings</a></li>
		<li><a href="#tabs-2">Description</a></li>
  	    <li><a href="#tabs-5">Vote Options</a></li>
		<li><a href="#tabs-4">Votelist</a></li>
		<li><a href="#tabs-3">Builders</a></li>

		<?php if (NFW::i()->checkPermissions('events', 'update_managers')): ?>
			<li><a href="<?php echo $Module->formatURL('update_managers').'&record_id='.$Module->record['id']?>">Managers</a></li>
		<?php endif; ?>
	</ul>


    <div id="tabs-5" rel="tab-container">

<div id="values-record-template-<?php echo $Module->record['id']?>" style="display: none;">
	<div id="record" class="record" rel="insert">
		<?php


		foreach ($Module->options_attributes as $key=>$a) { ?>
			<div class="cell"><input type="text" name="options[<?php echo $key?>][]" style="<?php echo $a['style']?>" placeholder="<?php echo $a['desc']?>" <?php echo isset($a['required']) && $a['required'] ? 'req="required"' : ''?> /></div>
		<?php } ?>
		<div class="cell"><span class="icon ui-icon ui-icon-arrowthick-2-n-s ui-state-disabled" title="Переместить"></span></div>
		<div class="cell"><span rel="remove-values-record" class="ui-icon ui-icon-closethick ui-state-disabled" title="Удалить"></span></div>
	</div>
</div>

<form id="eventz-update-<?php echo $Module->record['id']?>" action="<?php echo $Module->formatURL('update').'&record='.$Module->record['id']?>">
	<input type="hidden" name="update_record_options" value="1" />
	<div id="values-area" class="eventz">
		<div class="header">
			<?php foreach ($Module->options_attributes as $key=>$a) { ?>
				<div class="cell"><?php echo $a['desc']?></div>
			<?php } ?>
		</div>
		<?php foreach ($Module->record['options'] as $v) { ?>
			<div id="record" class="record myClass" rel="update">
				<?php foreach ($Module->options_attributes as $key=>$a) { ?>
					<div class="cell"><input type="text" name="options[<?php echo $key?>][]" value="<?php echo $v[$key]?>" style="<?php echo $a['style']?>" placeholder="<?php echo $a['desc']?>" <?php echo isset($a['required']) && $a['required'] ? 'req="required"' : ''?> /></div>
				<?php } ?>
				<div class="cell"><span class="icon ui-icon ui-icon-arrowthick-2-n-s ui-state-disabled" title="Переместить"></span></div>
				<div class="cell"><span rel="remove-values-record" class="ui-icon ui-icon-closethick ui-state-disabled" title="Удалить"></span></div>
			</div>
		<?php } ?>
	</div>

	<div style="padding-top: 0.5em;">
		<button type="submit" name="form-send" class="nfw-button" icon="ui-icon-disk">Сохранить изменения</button>
		<button id="add-values-record" class="nfw-button" icon="ui-icon-plus">Добавить параметр</button>
	</div>
</form>


    </div>

    <div id="tabs-1" rel="tab-container">
		<form rel="events-update">
			<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
			<?php echo active_field(array('name' => 'alias', 'value' => $Module->record['alias'], 'attributes'=>$Module->attributes['alias'], 'width'=>"200px;"))?>
			<?php echo active_field(array('name' => 'date_from', 'value' => $Module->record['date_from'], 'attributes'=>$Module->attributes['date_from']))?>
			<?php echo active_field(array('name' => 'date_to', 'value' => $Module->record['date_to'], 'attributes'=>$Module->attributes['date_to']))?>
			<?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes'=>$Module->attributes['announcement'], 'width'=>"500px;", 'height'=>"50px;"))?>
			<?php echo active_field(array('name' => 'is_hidden', 'value' => $Module->record['is_hidden'], 'attributes'=>$Module->attributes['is_hidden']))?>
		</form>
		<div id="events-update-media" style="padding-top: 1em; padding-left: 105px;">
<?php
	$CMedia = new media();
	echo $CMedia->openSession(array('owner_class' => get_class($Module), 'owner_id' => $Module->record['id'], 'safe_filenames' => true, 'force_rename' => true));
?>

			<div style="width: 400px; padding: 1em;">
			<?php echo ui_message(array('text' => '	&#8226; Use comment <strong>announce</strong> for <strong>64x64pix</strong> logo in events list.'));?>
			</div>

			<button id="events-save" class="nfw-button" icon="ui-icon-disk">Save changes</button>
		</div>
    </div>
    <div id="tabs-2" rel="tab-container">
		<form rel="events-update">
			<textarea name="content"><?php echo htmlspecialchars($Module->record['content'])?></textarea>
		</form>
    </div>
    <div id="tabs-3">
		<style>
			FORM#make LABEL { text-align: left; width: auto; padding-right: 2px; padding-top: 7px; font-weight: bold; }
			FORM#make .input-row { padding-left: 0; }
			FORM#make TEXTAREA { font-family: Consolas, Lucida Console, Courier New, monospace; font-size: 10.5px; color: #444; margin-bottom: 1em; width: 500px; height: 400px; }
			FORM#make .checker { padding-bottom: 0.5em; }
			#results_filename .selector { top: 0px; }
		</style>
		<form id="make">
			<input type="hidden" name="part" value="make" />

			<fieldset class="section" style="float: left; margin-right: 1em;">
				<legend>results.txt</legend>
				<textarea name="results_txt">
<?php

//  ["num_votes"]=>
//  string(2) "41"
//  ["total_scores"]=>
//  string(3) "346"
//  ["average_vote"]=>
//  string(4) "8.44"


	// Get release works
	$CWorks = new works();
	list($release_works) = $CWorks->getRecords(array(
		'filter' => array('release_only' => true, 'event_id' => $Module->record['id']),
		'ORDER BY' => 'c.pos, w.status, w.place'
	));


	if ($result = NFW::i()->db->query_build(array('SELECT'	=> 'count(distinct(`votekey_id`)) as `total`,`event_id` ', 'FROM' => 'votes', 'GROUP BY' => 'event_id', 'WHERE' => '`votekey_id`> 0 and `event_id` = '.$Module->record['id']))) {
		while ($record = NFW::i()->db->fetch_assoc($result)) {
			$totalvotes = $record["total"];
		}
	}
	else $totalvotes = 0;


	if ($result = NFW::i()->db->query_build(array('SELECT'	=> 'count(distinct(`username`)) as `total`,`event_id` ', 'FROM' => 'votes', 'GROUP BY' => 'event_id', 'WHERE' => '`votekey_id` = 0 and `event_id` = '.$Module->record['id']))) {
		while ($record = NFW::i()->db->fetch_assoc($result)) {
			$offline = $record["total"];
		}
	}
	else $offline = 0;



	if ($layout_type=="diver")
	{

		echo '   '.htmlspecialchars($Module->record['title'])."\n";
		echo '   '.date('d.m.Y', $Module->record['date_from']).'-'.date('d.m.Y', $Module->record['date_to'])."\n";
		echo "\n";
		echo '   '.'Official results'."\n";
		echo "\n";

		$header =  " # title                                                      vts pts  avg";
		$cur_competition = false;
		foreach ($release_works as $w) {
			if ($cur_competition != $w['competition_id']) {
				$cur_competition = $w['competition_id'];
				echo "\n";
				echo '   '.($w['competition_title']).str_repeat(' ',80-3 - mb_strlen(($w['competition_title']),'UTF-8'))."\n";
				echo "\n";
				echo $header."\n"."\n";
			}

			$desc = $w['title'].($w['author'] ? ' by '.$w['author'] : '');
			if (in_array($w['competition_id'],$platform)) $desc .= " [".($w["platform"])."]";

			echo ($w['place'] ? sprintf("%2s", $w['place']).' ' : ' - ');
			if (in_array($w['competition_id'],$platform)) $w['title'] = $w['title']." [".($w["platform"])."]";
			echo ($w['title']).str_repeat(' ',35 - mb_strlen(($w['title']),'UTF-8'));

			if (mb_strlen(($w['title']),'UTF-8')>35) echo "\n".str_repeat(' ',35+3);

			echo ($w['author']).str_repeat(' ',30 - mb_strlen(($w['author']),'UTF-8'));

			if (mb_strlen(($w['author']),'UTF-8')>30) echo "\n".str_repeat(' ',35+3+30);

			echo str_pad(($w['num_votes']),3," ",STR_PAD_LEFT)." ";
			echo str_pad(($w['total_scores']),3," ",STR_PAD_LEFT)." ";

			echo str_replace(".",",",$w['average_vote'])."\n";
		}

			echo "\n";
			echo ($totalvotes+$offline)." voters: ";
			if ($totalvotes) echo $totalvotes." online";
			if ($totalvotes && $offline) echo  " + ";
			if ($offline) echo $offline." at partyplace";
			echo "\n";
			echo "online party management system provided by nyuk";
		}
	else
	{

		echo htmlspecialchars($Module->record['title'])."\n";
		echo date('d.m.Y', $Module->record['date_from']).'-'.date('d.m.Y', $Module->record['date_to'])."\n";
		echo "\n";
		echo 'Official results'."\n";
		echo "\n";

		$cur_competition = false;
		foreach ($release_works as $w) {
			if ($cur_competition != $w['competition_id']) {
				$cur_competition = $w['competition_id'];
				echo "\n";
				echo '________'.htmlspecialchars($w['competition_title']).str_repeat('_',72 - mb_strlen(htmlspecialchars($w['competition_title']),'UTF-8'))."\n";
				echo "\n";
			}

			$desc = $w['title'].($w['author'] ? ' by '.$w['author'] : '');
			if (in_array($w['competition_id'],$platform)) $desc .= " [".($w["platform"])."]";

			echo ($w['place'] ? sprintf("%2s", $w['place']).'. ' : ' - ').$desc.str_repeat(' ', 66 - mb_strlen($desc,'UTF-8')).str_pad(($w['total_scores']),3," ",STR_PAD_LEFT)." ".$w['average_vote']."\n";
		}
	}

?>
				</textarea>



				<div id="results_filename" class="active-field">
					<label for="results_filename"><strong>files/<?php echo $Module->record['alias']?>/</strong></label>
					<div class="input-row">
						<input type="text" value="results.txt" name="results_filename" maxlength="64" style="width: 120px" />
						<button name="save_results" value="1" type="submit" class="nfw-button" icon="ui-icon-disk">Save</button>
						<div id="filename" class="error-info" rel="error-info"></div>
					</div>
				</div>
			</fieldset>

			<fieldset class="section">
				<legend>Results settings</legend>

				<div id="results_filename" class="active-field">
                <div>Выберите, для каких компо добавлять платформу:<br/><br/></div>
<?php
	$cur_competition = false;
	foreach ($release_works as $w) {
		if ($cur_competition != $w['competition_id']) {
			$cur_competition = $w['competition_id'];
			echo '<div><input name="layout_platform_show[]" value="'.$cur_competition.'" type="checkbox" ';
			if (in_array($w['competition_id'],$platform)) echo 'checked="checked" ';
			echo '/> '.htmlspecialchars($w['competition_title']).'</div>';
		}
	}

?>
					<label for="layout_type">Type of layout</label>
					<div class="input-row">
						<select name="layout_type" id="layout_type" class="form-control" style="width: 90px; top:0px;">
							<?php
							$layout_types = array("nyuk"=>"nyuk","diver"=>"diver");

							 foreach ($layout_types as $i=>$d) echo '<option value="'.$i.'"'.($layout_type == $i ? ' selected="selected"' : '').'>'.$d.'</option>'; ?>
						</select>
						<button name="refresh_results" value="1" type="submit" class="nfw-button" icon="ui-icon-disk">Refresh</button>
					</div>

				</div>


			</fieldset>

              <br/>
			<fieldset class="section">
				<legend>Make works pack (zip-archive)</legend>

<?php
	$cur_competition = false;
	foreach ($release_works as $w) {
		if ($cur_competition != $w['competition_id']) {
			$cur_competition = $w['competition_id'];
			echo '<div><input name="competitions[]" value="'.$cur_competition.'" type="checkbox" checked="checked" /> '.htmlspecialchars($w['competition_title']).'</div>';
		}
	}
?>
				<hr />
				<div><input name="attach_results_txt" type="checkbox" checked="checked" /> Attach `results.txt` into archive</div>
				<div><input name="attach_media" type="checkbox" /> Attach Event's media files</div>
	
				<div id="pack_filename" class="active-field">
					<label for="pack_filename"><strong>files/<?php echo $Module->record['alias']?>/</strong></label>
					<div class="input-row">
						<input type="text" value="<?php echo $Module->record['alias'].'-pack.zip'?>" name="pack_filename" maxlength="64" style="width: 120px" />
						<button name="save_pack" value="1" type="submit" class="nfw-button" icon="ui-icon-disk">Save</button>
						<div id="filename" class="error-info" rel="error-info"></div>
					</div>
				</div>
			</fieldset>
			<div style="clear: both;"></div>
		</form>
    </div>

    <div id="tabs-4">
		<form id="votelist" method="POST" class="active-form" target="_blank">
			<input type="hidden" name="part" value="votelist" />
<?php
	echo active_field(array('name' => 'header1', 'desc' => 'Header 1', 'rel' => 'uniform', 'value' => $Module->record['title']));
	echo active_field(array('name' => 'header2', 'desc' => 'Header 2', 'rel' => 'uniform', 'value' => date('d.m.Y', $Module->record['date_from']).'-'.date('d.m.Y', $Module->record['date_to'])));
	echo active_field(array('name' => 'header3', 'desc' => 'Header 3', 'rel' => 'uniform', 'value' => 'Main compo votelist'));
?>
			<div class="input-row"><table class="main-table">
				<tr>
					<th>Include</th>
					<th style="width: 280px;">Competition</th>
					<th>Display works</th>
					<th>Empty rows</th>
				</tr>
<?php
	$CCompetitions = new competitions();
	foreach ($CCompetitions->getRecords(array('filter' => array('event_id' => $Module->record['id']))) as $c) {
		//echo active_field(array('name' => 'competitions['.$c['id'].']', 'value' => true, 'type' => 'checkbox', 'desc' => $c['title']));
?>
			<tr class="zebra">
				<td><input type="checkbox" checked="CHECKED" name="competitions[]" value="<?php echo $c['id']?>" /></td>
				<td><?php echo htmlspecialchars($c['title'])?></td>
				<td><input type="checkbox" checked="CHECKED" name="display_works[]" value="<?php echo $c['id']?>" /></td>
				<td><input rel="emptyrows" name="emptyrows[<?php echo $c['id']?>]" value="0" type="text" style="width: 15px;" maxlength="2" /></td>
			</tr>
<?php
	}
?>
			</table></div>

			<div class="input-row" style="padding-top: 1em;">
				<button type="submit" class="nfw-button" icon="ui-icon-document">Generate votelist</button>
			</div>
		</form>
    </div>
</div>
