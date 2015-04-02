<?php
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.jgrowl');

// Fetch all users
$users_search = array();
$CUsers = new users();
foreach ($CUsers->getUsers() as $u) {
	$users_search[] = '{ "id": '.$u['id'].', "value": "'.str_replace('"', '\"', htmlspecialchars($u['username'])).'"}';
}
$users_search = implode(',', $users_search);

// Fetch current managers list
$query = array(
	'SELECT'	=> 'u.id, u.username',
	'FROM'		=> 'events_managers AS e',
	'JOINS'		=> array(
		array(
			'INNER JOIN'=> 'users AS u',
			'ON'		=> 'u.id=e.user_id'
		),
	),
	'WHERE'		=> 'e.event_id='.$Module->record['id'],
);
if (!$result = NFW::i()->db->query_build($query)) {
	NFW::i()->stop('Unable to fetch managers');
}
$managers = array();
while($cur_record = NFW::i()->db->fetch_assoc($result)) {
	$managers[] = $cur_record;
}

?>
<script type="text/javascript">
$(document).ready(function(){
	var emF = $('form[id="event-managers"]');
	emF.activeForm({
		success: function(response) {
			$.jGrowl('Event managers updated.');
		}
	});

	var usersList = [<?php echo $users_search?>];
	emF.find('input[id="name"]').autocomplete({
		source: usersList,
		select: function(event, ui) {
			if (emF.find('div[class="managers-item"][id="' + ui.item.id + '"]').length) return;

			emF.find('div[id="managers-list"]').append('<div id="' + ui.item.id + '" class="managers-item"><div class="icon"><a id="' + ui.item.id + '" rel="managers-delete" class="ui-icon ui-icon-trash" title="Удалить из списка"></a></div><div class="name"><a href="<?php echo NFW::i()->base_path?>admin/users?action=update&record_id=' + ui.item.id + '">' + ui.item.value + '</a></div><div style="clear: both;"></div><input type="hidden" name="managers[]" value="' + ui.item.id + '" /></div>');
		},
		close: function(event, ui) {
			emF.find('input[id="name"]').val(''); 
		}
	});

	$(document).on('click', 'a[rel="managers-delete"]', function(){
		emF.find('div[class="managers-item"][id="' + this.id + '"]').remove();
		return false;
	});

	$(document).trigger('refresh');
});
</script>
<style>
	.managers-item { background-color: #D7D6FC; border: 1px dotted #888888; margin-bottom: 5px; padding: 2px 5px 2px 10px; width: 300px; }
	.managers-item .name { font-weight: bold; overflow: hidden; }
	.managers-item .icon { float: right; }
	.managers-item .icon A { cursor: pointer; }
</style>
<form id="event-managers" action="<?php echo $Module->formatURL('update_managers')?>&record_id=<?php echo $Module->record['id']?>">
	<label for="name" class="required">Search:</label>
	<div class="input-row">
		<input type="text" id="name" />
	</div>
	<div class="delimiter"></div>

	<div class="input-row" id="managers-list">
		<?php foreach ($managers as $m) { ?>
			<div id="<?php echo $m['id']?>" class="managers-item">
				<div class="icon"><a rel="managers-delete" id="<?php echo $m['id']?>" class="ui-icon ui-icon-trash" title="Удалить из списка"></a></div>
				<div class="name"><a href="<?php echo NFW::i()->base_path?>admin/users?action=update&record_id=<?php echo $m['id']?>"><?php echo htmlspecialchars($m['username'])?></a></div>
				<div style="clear: both;"></div>
				<input type="hidden" name="managers[]" value="<?php echo $m['id']?>" />
			</div>
		<?php } //foreach?>
	</div>
	
	<div class="input-row">
		<button type="submit" name="form_sent" class="nfw-button" icon="ui-icon-disk">Save changes</button>
    </div>
</form>