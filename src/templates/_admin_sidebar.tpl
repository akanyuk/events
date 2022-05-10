<?php
/**
 * @var $top_menu array
 */
NFW::i()->registerFunction('limit_text');
?>
<script type="text/javascript">
$(document).ready(function(){
	$('#sidebar-menu').metisMenu();
});
</script>
<style>
	LI.nw { white-space: nowrap; }
	LI.hidden-event { display: none !important; }
</style>
<nav class="sidebar-nav">
	<ul class="metismenu" id="sidebar-menu">
<?php
echo '<li class="active hidden-sm hidden-md hidden-lg"><a href="#"><span class="sidebar-nav-item">Main menu</span><span class="fa arrow"></span></a><ul>';
foreach ($top_menu as $m) {
	echo '<li><a href="'.NFW::i()->absolute_path.'/admin/'.$m['url'].'">'.$m['name'].'</a></li>';
}
echo '</ul></li>';

foreach (adminSidebarEvents() as $event) {
?>
		<li>
			<a href="#" title="<?php echo htmlspecialchars($event['title'])?>"><span class="sidebar-nav-item"><?php echo htmlspecialchars(limit_text($event['title'], 24))?></span><span class="fa arrow"></span></a>
			<ul>
				<?php foreach ($event['competitions'] as $competition) { ?>
				<li>
					<a href="#" title="<?php echo htmlspecialchars($competition['title'])?>">
						<span class="fa arrow"></span>
						<span class="sidebar-nav-item"><?php echo htmlspecialchars(limit_text($competition['title'], 32))?></span>
					</a>
					<ul>
						<?php foreach ($competition['works'] as $work) { ?>
						<li class="nw"><strong><a href="<?php echo NFW::i()->base_path.'admin/works?action=update&record_id='.$work['id']?>" title="<?php echo htmlspecialchars($work['title'].' by '.$work['author'])?>"><?php echo htmlspecialchars($work['position'].'. '.$work['title'])?></a></strong></li>
						<?php } ?>
					</ul>
				</li>
				<?php } ?>
				<li><a href="<?php echo NFW::i()->base_path.'admin/events?action=update&record_id='.$event['id']?>"><span class="sidebar-nav-item-icon fa fa-wine-glass-alt"></span> Manage event</a></li>
				<li><a href="<?php echo NFW::i()->base_path.'admin/competitions?event_id='.$event['id']?>"><span class="sidebar-nav-item-icon fa fa-truck-monster"></span> Competitions</a></li>
				<li><a href="<?php echo NFW::i()->base_path.'admin/works?event_id='.$event['id']?>"><span class="sidebar-nav-item-icon fas fa-bug"></span> Works</a></li>
				<li><a href="<?php echo NFW::i()->base_path.'admin/vote?event_id='.$event['id']?>"><span class="sidebar-nav-item-icon fa fa-poll"></span> Voting</a></li>
			</ul>
		</li>
<?php
}
?>
	</ul>
</nav>

<?php
function adminSidebarEvents() {
	$managed_events = events::get_managed();
	if (empty($managed_events)) return array();

	$query = array(
		'SELECT'	=> 'e.id AS event_id, e.title AS event_title, c.id AS competition_id, c.title AS competition_title, w.id AS work_id, w.title AS work_title, w.position AS work_pos, w.author',
		'FROM'		=> 'works AS w',
		'JOINS'		=> array(
			array('INNER JOIN' => 'competitions AS c', 'ON' => 'c.id=w.competition_id'),
			array('INNER JOIN' => 'events AS e', 'ON' => 'e.id=c.event_id'),
		),
		'WHERE'		=> 'e.id IN('.implode(',', array_splice($managed_events, 0, 5)).')',
		'ORDER BY'	=> 'e.date_from DESC, c.position, w.position'
	);
	if (!$result = NFW::i()->db->query_build($query)) {
		$this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
		return false;
	}
	if (!NFW::i()->db->num_rows($result)) {
		return array();
	}

	$events = $competitions = array();
	while($r = NFW::i()->db->fetch_assoc($result)) {
		$event_key = false;
		foreach ($events as $eKey=>$e) {
			if ($e['id'] == $r['event_id']) {
				$event_key = $eKey;
				break;
			}
		}

		if ($event_key !== false) {
			$competition_found = false;
			foreach ($events[$event_key]['competitions'] as $cKey=>$c) {
				if ($c['id'] == $r['competition_id']) {
					$events[$event_key]['competitions'][$cKey]['works'][] = array('id' => $r['work_id'], 'title' => $r['work_title'], 'position' => $r['work_pos'], 'author' => $r['author']);
					$competition_found = true;
					break;
				}
			}

			if (!$competition_found) {
				$events[$event_key]['competitions'][] = array('id' => $r['competition_id'], 'title' => $r['competition_title'], 'works' => array(
					array('id' => $r['work_id'], 'title' => $r['work_title'], 'position' => $r['work_pos'], 'author' => $r['author'])
				));
			}
		} else {
			// New record
			$events[] = array('id' => $r['event_id'], 'title' => $r['event_title'], 'competitions' => array(
				array('id' => $r['competition_id'], 'title' => $r['competition_title'], 'works' => array(
					array('id' => $r['work_id'], 'title' => $r['work_title'], 'position' => $r['work_pos'], 'author' => $r['author'])
				))
			));
		}
	}

	return $events;
}