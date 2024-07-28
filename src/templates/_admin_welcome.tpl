<?php 

$managed_events = events::get_managed();

// local actions

if (isset($_GET['action']) && $_GET['action'] =='works_set_checked_all') {
	if (empty($managed_events)) {
		NFW::i()->stop('Wrong request.');
	}
	
	$query = array(
		'SELECT'	=> 'w.id',
		'FROM'		=> 'works AS w',
		'JOINS'		=> array(
			array('INNER JOIN' => 'competitions AS c', 'ON' => 'c.id=w.competition_id'),
			array('LEFT JOIN'=> 'works_managers_notes AS wmi', 'ON'	=> 'wmi.work_id=w.id AND wmi.user_id='.NFW::i()->user['id'])
		),
		'WHERE'		=> '(wmi.is_checked IS NULL OR wmi.is_checked=0) AND c.event_id IN('.implode(',', $managed_events).')',
	);
	if (!$result = NFW::i()->db->query_build($query)) {
		NFW::i()->stop('Unable to fetch unchecked prods.');
	}
	while($r = NFW::i()->db->fetch_assoc($result)) {
		list($is_success, $msg) = markWorkChecked($r['id']);
		if (!$is_success) {
			NFW::i()->stop($msg);
		}
	}
	
	NFW::i()->stop('success');
}


// Unchecked and marked prods

$CWorks = new works();

$unchecked_prods = $marked_prods = array();
$unchecked_prods_count = 0;
if (!empty($managed_events)) {
	$query = array(
		'SELECT'	=> 'COUNT(*)',
		'FROM'		=> 'works AS w',
		'JOINS'		=> array(
			array('INNER JOIN' => 'competitions AS c', 'ON' => 'c.id=w.competition_id'),
			array('INNER JOIN' => 'events AS e', 'ON' => 'e.id=c.event_id'),
			array('LEFT JOIN'=> 'works_managers_notes AS wmi', 'ON'	=> 'wmi.work_id=w.id AND wmi.user_id='.NFW::i()->user['id'])
		),
		'WHERE'		=> '(wmi.is_checked IS NULL OR wmi.is_checked=0) AND e.id IN('.implode(',', $managed_events).')',
		'ORDER BY'	=> 'w.posted DESC',
	);
	if (!$result = NFW::i()->db->query_build($query)) {
		echo '<div class="alert alert-danger">Unable to count unchecked prods.</div>';
		return false;
	}
	list($unchecked_prods_count) = NFW::i()->db->fetch_row($result);
		
	$query['SELECT'] = 'e.title AS event_title, c.title AS competition_title, w.id, w.status, w.title, w.author, w.posted, w.posted_username, wmi.comment AS managers_notes_comment';
	$query['LIMIT'] = 20;
	
	if (!$result = NFW::i()->db->query_build($query)) {
		echo '<div class="alert alert-danger">Unable to fetch unchecked prods.</div>';
		return false;
	}
	while($r = NFW::i()->db->fetch_assoc($result)) {
		$r['status_info'] = $CWorks->attributes['status']['options'][$r['status']];
		$unchecked_prods[] = $r;
	}
	
	// Marked prods
	
	$query['WHERE']	= 'wmi.is_marked=1 AND e.id IN('.implode(',', $managed_events).')';
	$query['LIMIT'] = null;
	
	if (!$result = NFW::i()->db->query_build($query)) {
		echo '<div class="alert alert-danger">Unable to fetch unchecked prods.</div>';
		return false;
	}
	while($r = NFW::i()->db->fetch_assoc($result)) {
        $r['status_info'] = $CWorks->attributes['status']['options'][$r['status']];
		$marked_prods[] = $r;
	}
}
?>
<script type="text/javascript">
$(document).ready(function(){
	$('[id="works-set-checked-all"]').click(function(){
		$.post('?action=works_set_checked_all', function(response){
			response === 'success' ? window.location.reload() : alert(response);
		});
	});
});
</script>
<style>
	.table > tbody > tr > td { vertical-align: middle; }
	
	@media (min-width: 769px) {
		.marked-prods H2 { margin-top: 0; }
		.marked-prods .alert { margin-top: 40px; }
	}

    .marked-prods .alert-note { margin-top: 3px; margin-bottom: 3px; padding: 3px 10px; }
</style>
<div class="row marked-prods">
	<div class="col-md-6">
		<?php if (empty($unchecked_prods)): ?>
		<h2>Unchecked prods</h2>
		<div class="alert alert-success">You checked all prods.</div>
		<?php else: ?>
		<div class="hidden-xs">
			<div class="pull-right">
				<button id="works-set-checked-all" class="btn btn-success"><span class="fa fa-check"></span> Set all prods checked <span class="badge"><?php echo $unchecked_prods_count?></span></button>
			</div>
			<h2>Unchecked prods</h2>
			<table class="table table-condensed table-striped">
				<thead>
					<tr>
						<th></th>
						<th>Prod</th>
						<th>Posted</th>
					</tr>
				</thead>
				<tbody>
<?php foreach ($unchecked_prods as $record) { ?>
<tr>
	<td>
		<div data-toggle="tooltip" data-html="true" title="<?php echo '<strong>'.$record['status_info']['desc'].'</strong><br />Voting: '.($record['status_info']['voting'] ? 'On' : 'Off').'<br />Release: '.($record['status_info']['release'] ? 'On' : 'Off')?>" class="text text-<?php echo $record['status_info']['css-class']?>"><span class="<?php echo $record['status_info']['icon']?>"></span></div>
	</td>
	<td>
		<strong>
			<a href="<?php echo NFW::i()->absolute_path.'/admin/works?action=update&record_id='.$record['id']?>"><?php echo htmlspecialchars($record['title'].' by '.$record['author'])?></a>
		</strong>
		<div class="text-muted">
			<small><?php echo htmlspecialchars($record['event_title'].' / '.$record['competition_title'])?></small>
		</div>		
	</td>
	<td class="nowrap"><?php echo date('d.m.Y H:i', $record['posted']).' by '.htmlspecialchars($record['posted_username'])?></td>
</tr>
<?php } ?>
				</tbody>
				<?php if (count($unchecked_prods) < $unchecked_prods_count):?>
				<tfoot>
					<tr>
						<td colspan="3">Skipped <span class="badge"><?php echo $unchecked_prods_count - count($unchecked_prods)?></span> next prods</td>
					</tr>
				</tfoot>
				<?php endif; ?>
			</table>
		</div>
		
		<div class="hidden-sm hidden-md hidden-lg">
			<h2>Unchecked prods</h2>
			<table class="table table-condensed table-striped">
				<tbody>
<?php foreach ($unchecked_prods as $record) { ?>
<tr>
	<td>
		<div class="pull-right">
			<div data-toggle="tooltip" data-html="true" title="<?php echo '<strong>'.$record['status_info']['desc'].'</strong><br />Voting: '.($record['status_info']['voting'] ? 'On' : 'Off').'<br />Release: '.($record['status_info']['release'] ? 'On' : 'Off')?>" class="text text-<?php echo $record['status_info']['css-class']?>"><span class="<?php echo $record['status_info']['icon']?>"></span></div>
		</div>
		<strong>
			<a href="<?php echo NFW::i()->absolute_path.'/admin/works?action=update&record_id='.$record['id']?>"><?php echo htmlspecialchars($record['title'].' by '.$record['author'])?></a>
		</strong>
		<div class="text-muted">
			<small><?php echo htmlspecialchars($record['event_title'].' / '.$record['competition_title'])?></small>
		</div>		
		<div>Posted <?php echo date('d.m.Y H:i', $record['posted']).' by '.htmlspecialchars($record['posted_username'])?></div>
	</td>
</tr>
<?php } ?>
				</tbody>
				<?php if (count($unchecked_prods) < $unchecked_prods_count):?>
				<tfoot>
					<tr>
						<td>Skipped <span class="badge"><?php echo $unchecked_prods_count - count($unchecked_prods)?></span> next prods</td>
					</tr>
				</tfoot>
				<?php endif; ?>
			</table>

            <div style="text-align: center">
                <button id="works-set-checked-all" class="btn btn-lg btn-success"><span class="fa fa-check"></span> Set all prods checked <span class="badge"><?php echo $unchecked_prods_count?></span></button>
            </div>
		</div>
		<?php endif;?>
	</div>
	
	<div class="col-md-6">
		<h2>Marked prods</h2>
		<?php if (empty($marked_prods)): ?>
		<div class="alert alert-success">You have no marked prods.</div>
		<?php else: ?>
		
		<div class="hidden-xs">
			<table class="table table-condensed table-striped">
				<thead>
					<tr>
						<th></th>
						<th>Prod</th>
						<th>Posted</th>
					</tr>
				</thead>
				<tbody>
<?php foreach ($marked_prods as $record) { ?>
<tr>
	<td>
        <div data-toggle="tooltip" data-html="true" title="<?php echo '<strong>'.$record['status_info']['desc'].'</strong><br />Voting: '.($record['status_info']['voting'] ? 'On' : 'Off').'<br />Release: '.($record['status_info']['release'] ? 'On' : 'Off')?>" class="text text-<?php echo $record['status_info']['css-class']?>"><span class="<?php echo $record['status_info']['icon']?>"></span></div>
	</td>
	<td>
		<strong>
			<a href="<?php echo NFW::i()->absolute_path.'/admin/works?action=update&record_id='.$record['id']?>"><?php echo htmlspecialchars($record['title'].' by '.$record['author'])?></a>
		</strong>
		<div class="text-muted">
			<small><?php echo htmlspecialchars($record['event_title'].' / '.$record['competition_title'])?></small>
		</div>
        <?php if ($record['managers_notes_comment']): ?>
            <div class="alert alert-warning alert-note"><?php echo htmlspecialchars(nl2br($record['managers_notes_comment']))?></div>
        <?php endif; ?>
	</td>
	<td class="nowrap"><?php echo date('d.m.Y H:i', $record['posted']).' by '.htmlspecialchars($record['posted_username'])?></td>
</tr>
<?php } ?>
				</tbody>
			</table>
		</div>
		
		<div class="hidden-sm hidden-md hidden-lg">
			<table class="table table-condensed table-striped">
				<tbody>
<?php foreach ($marked_prods as $record) { ?>
<tr>
	<td>
		<div class="pull-right" style="margin-left: 10px;">
            <div data-toggle="tooltip" data-html="true" title="<?php echo '<strong>'.$record['status_info']['desc'].'</strong><br />Voting: '.($record['status_info']['voting'] ? 'On' : 'Off').'<br />Release: '.($record['status_info']['release'] ? 'On' : 'Off')?>" class="text text-<?php echo $record['status_info']['css-class']?>"><span class="<?php echo $record['status_info']['icon']?>"></span></div>
		</div>			
		<strong>
			<a href="<?php echo NFW::i()->absolute_path.'/admin/works?action=update&record_id='.$record['id']?>"><?php echo htmlspecialchars($record['title'].' by '.$record['author'])?></a>
		</strong>
		<div class="text-muted">
			<small><?php echo htmlspecialchars($record['event_title'].' / '.$record['competition_title'])?></small>
		</div>		
		<div>Posted: <?php echo date('d.m.Y H:i', $record['posted']).' by '.htmlspecialchars($record['posted_username'])?></div>
        <?php if ($record['managers_notes_comment']): ?>
            <div class="alert alert-warning alert-note"><?php echo htmlspecialchars(nl2br($record['managers_notes_comment']))?></div>
        <?php endif; ?>
	</td>
</tr>
<?php } ?>
				</tbody>
			</table>
		</div>
		<?php endif;?>		
	</div>
</div>

<?php 
function markWorkChecked($work_id): array {
	if (!$result = NFW::i()->db->query_build(array('SELECT' => 'comment, is_marked, 1 AS is_checked', 'FROM' => 'works_managers_notes', 'WHERE' => 'work_id='.$work_id.' AND user_id='.NFW::i()->user['id']))) {
		return array(false, 'Unable to fetch personal info');
	}
	if (NFW::i()->db->num_rows($result)) {
		$manager_note = NFW::i()->db->fetch_assoc($result);
		
		if (!NFW::i()->db->query_build(array('DELETE' => 'works_managers_notes', 'WHERE' => 'work_id='.$work_id.' AND user_id='.NFW::i()->user['id']))) {
			return array(false, 'Unable to delete old personal info');
		}
	}
	else {
		$manager_note = array(
			'comment' => '', 
			'is_marked' => 0, 
			'is_checked' => 1
		);
	}
	if (!NFW::i()->db->query_build(array(
		'INSERT' => 'work_id, user_id, comment, is_checked, is_marked',
		'INTO' => 'works_managers_notes',
		'VALUES' => $work_id.','.NFW::i()->user['id'].', \''.NFW::i()->db->escape($manager_note['comment']).'\', '.$manager_note['is_checked'].', '.$manager_note['is_marked']
	))) {
		return array(false, 'Unable to insert personal info');
	}
	
	return array(true, null);
}