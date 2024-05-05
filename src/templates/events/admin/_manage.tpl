<?php
/**
 * @var $Module events
 */

NFW::i()->registerResource('bootstrap3.typeahead');
NFW::i()->registerFunction('active_field');

// Fetch all users
$users_search = array();
$CUsers = new users();
foreach ($CUsers->getRecords(array('filter' => array('is_group' => false))) as $u) {
	$users_search[] = '{ "id": '.$u['id'].', "name": "'.str_replace('"', '\"', htmlspecialchars($u['username'])).'"}';
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
    const emF = $('form[id="events-manage"]');
    emF.activeForm({
		success: function() {
			$.jGrowl('Event updated.');
		}
	});

	emF.find('input[id="search-user"]').typeahead({ 
		source: [<?php echo $users_search?>],
		updater: function(item){
            const mList = $('ul[id="managers-list"]');

			if (mList.find('li[id=' + item.id + ']').length) {
				return '';
			}

            let tpl = $('[id="managers-record-template"]').html();
            tpl = tpl.replace(/%ID%/g, item.id);
			tpl = tpl.replace('%NAME%', item.name);

            mList.append(tpl);
			
			return '';
		} 
	}).attr('autocomplete', 'off');

	$(document).on('click', '[data-action="events-managers-remove"]', function(){
		$(this).closest('li').remove();
		return false;
	});

});
</script>

<ul id="managers-record-template" style="display: none;">
	<li id="%ID%" class="list-group-item">
		<input type="hidden" name="managers[]" value="%ID%" />
		<div class="pull-right"><button data-action="events-managers-remove" class="btn btn-danger btn-xs" title="<?php echo NFW::i()->lang['Remove']?>"><span class="glyphicon glyphicon-remove"></span></button></div>
		<strong><a href="<?php echo NFW::i()->base_path?>admin/users?action=update&record_id=%ID%">%NAME%</a></strong>					
		<div class="clearfix"></div>			
	</li>
</ul>

<form id="events-manage" action="<?php echo $Module->formatURL('manage').'&record_id='.$Module->record['id']?>">
	<div class="form-group">
		<label class="col-md-2 control-label">Managers</label>
		<div class="col-md-8">
			<div style="padding-bottom: 10px;">
				<input class="form-control" type="text" id="search-user" placeholder="Search user" />
			</div>
			<ul id="managers-list" class="list-group"><?php foreach ($managers as $m) { ?>
				<li id="<?php echo $m['id']?>" class="list-group-item">
					<input type="hidden" name="managers[]" value="<?php echo $m['id']?>" />
					<div class="pull-right"><button data-action="events-managers-remove" class="btn btn-danger btn-xs" title="<?php echo NFW::i()->lang['Remove']?>"><span class="glyphicon glyphicon-remove"></span></button></div>
					<strong><a href="<?php echo NFW::i()->base_path?>admin/users?action=update&record_id=<?php echo $m['id']?>"><?php echo htmlspecialchars($m['username'])?></a></strong>					
					<div class="clearfix"></div>			
				</li>
			<?php } ?></ul>
		</div>
	</div>
		
	<hr />
	<?php echo active_field(array('name' => 'alias', 'value' => $Module->record['alias'], 'attributes'=>$Module->attributes['alias'], 'labelCols' => '2', 'inputCols' => '8'))?>
    <?php echo active_field(array('name' => 'alias_group', 'value' => $Module->record['alias_group'], 'attributes'=>$Module->attributes['alias_group'], 'labelCols' => '2', 'inputCols' => '8'))?>
	<?php echo active_field(array('name' => 'is_hidden', 'value' => $Module->record['is_hidden'], 'attributes'=>$Module->attributes['is_hidden'], 'labelCols' => '2', 'inputCols' => '8'))?>
	
	<div class="form-group">
		<div class="col-md-6 col-md-offset-2">
			<button type="submit" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
		</div>
	</div>			
</form>