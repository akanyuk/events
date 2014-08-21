<?php
	$lang_main = NFW::i()->getLang('main');
	NFW::i()->assign('page_title', $lang_main['cabinet prods']);

	if (empty($records)) {
?>		
	<div class="jumbotron">
		<h1>Hey, <?php echo htmlspecialchars(NFW::i()->user['realname'])?>!</h1>
		<p><?php echo $lang_main['works empty']?></p>
		<p><a href="?action=add" class="btn btn-primary btn-lg" role="button"><?php echo $lang_main['cabinet add work']?></a></p>
	</div>
<?php
		return;
	}
?>
<script type="text/javascript">
$(document).ready(function(){
	// status hints
	$('div[rel="status-tooltip"]').tooltip({ 'animation': false });
	
	$(document).trigger('refresh');
});
</script>
<h1><?php echo $lang_main['cabinet prods']?></h1>
<table class="table table-condensed dm">
	<thead>
		<tr>
			<th><?php echo $lang_main['works title']?></th>
			<th><?php echo $lang_main['works author']?></th>
			<th><?php echo $lang_main['competions title']?></th>
			<th><?php echo $lang_main['works status']?></th>
		</tr>
	</thead>
	<tbody>
<?php
	$cur_event = false;
	foreach ($records as $record) {
		if ($cur_event != $record['event_id']) {
			echo '<tr><td colspan="4"><h2>'.$record['event_title'].'</h2></td></tr>';
			$cur_event = $record['event_id'];
		}
?>
	<tr>
		<td class="b"><a href="<?php echo NFW::i()->base_path.'cabinet/works?action=view&record_id='.$record['id']?>"><?php echo htmlspecialchars($record['title'])?></a></td>
		<td><?php echo htmlspecialchars($record['author'])?></td>
		<td><?php echo htmlspecialchars($record['competition_title'])?></td>
		<td class="nw"><div rel="status-tooltip" title="<?php echo $record['status_info']['desc_full']?>" class="label <?php echo $record['status_info']['label-class']?>"><?php echo $record['status_info']['desc']?></div></td>
	</tr>
<?php 		
	}
?>	
	</tbody>
</table>