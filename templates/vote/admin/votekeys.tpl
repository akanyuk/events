<?php
/**
 * @var object $Module
 * @var array $event
 */

NFW::i()->registerFunction('active_field');
?>
<style>
	.votekey { font-family: "Lucida Console", Monaco, monospace; font-weight: bold; }
	.votekey-used { text-decoration: line-through; }
</style>
<script type="text/javascript">
$(document).ready(function(){
	
	// Add votekeys
	
	var vaDialog = $('div[id="votekeys-add-dialog"]');
	var vaForm = vaDialog.find('form');
	vaDialog.modal({ 'show': false });

	
	$(document).off('click', 'button[id="votekeys-add"]').on('click', 'button[id="votekeys-add"]', function(e, message){
		vaForm.resetForm().trigger('cleanErrors');
		vaDialog.modal('show');
	});

	vaForm.activeForm({
		'success': function(response) {
			vaDialog.modal('hide');
			oTable.fnDraw();
			return false;
		}
	});

	vaDialog.find('button[id="votekeys-add-submit"]').click(function(){
		vaForm.submit();
	});

	
	// Votekeys list
	
	var config =  dataTablesDefaultConfig;
	
	// Infinity scrolling
	config.scrollY = $(window).height() - $('table[id="votekeys"]').offset().top - 130;
	// Fix horizontal scroll
	//config.scrollX = '100%';
	config.deferRender = true;
	config.scroller = true;

	// Server-side
	config.bServerSide = true;
	config.bProcessing = false;
	config.sAjaxSource = '<?php echo $Module->formatURL('votekeys').'&event_id='.$event['id'].'&part=list.js'?>';
	config.fnServerData = function (sSource, aoData, fnCallback) {
		$.ajax( {
			'dataType': 'json', 
			'type': "POST", 
			'url': sSource, 
			'data': aoData, 
			'success': fnCallback
		});
	};
		
	config.aoColumns = [
		{ 'sortable': false, 'className': 'nowrap-column' },							// votekey
		{ 'sortable': false, 'width': '100%' },											// email
		{ 'searchable': false, 'sortable': false, 'className': 'nowrap-column' },		// posted
		{ 'searchable': false, 'sortable': false, 'className': 'nowrap-column' },		// browser
		{ 'searchable': false, 'sortable': false, 'className': 'nowrap-column' }		// IP
	];
		
	config.fnRowCallback = function(nRow, aData, iDisplayIndex) {
		var textClass = aData[0][2] ? ' votekey-used' : '';
		$('td:eq(0)', nRow).html('<span class="votekey' + textClass + '">' + aData[0][1] + '</span>');

		$('td:eq(2)', nRow).html(formatDateTime(aData[2], true));

		// browser
		$('td:eq(3)', nRow).html('<span title="' + aData[3][1] + '">' + (aData[3][0] ? aData[3][0] : 'unknown') + '</span>');
		
		return nRow;
	};
		
	var oTable = $('table[id="votekeys"]').dataTable(config);

	// Custom filtering function
	$('div[id="votekeys_length"]').empty().html($('div[id="votekeys-custom-filters"]').html());
	$('div[id="votekeys-custom-filters"]').remove();
});
</script>

<div id="votekeys-add-dialog" class="modal fade">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title"><?php echo htmlspecialchars($event['title'])?></h4>
			</div>
			<div class="modal-body">
				<form action="<?php echo $Module->formatURL('votekeys').'&event_id='.$event['id'].'&part=add-votekeys'?>">
					<?php echo active_field(array('name' => 'count', 'value' => '1', 'type' => 'int', 'desc' => 'Amount', 'value' => 1, 'inputCols' => 2, 'maxlength' => 3))?>
					<?php echo active_field(array('name' => 'email', 'type' => 'str', 'desc' => 'E-mail / comment'))?>
				</form>
			</div>
			<div class="modal-footer">
				<button id="votekeys-add-submit" type="button" class="btn btn-primary">Add votekeys</button>
				<button type="button" class="btn btn-default" data-dismiss="modal"><?php echo NFW::i()->lang['Close']?></button>
			</div>
		</div>
	</div>
</div>

<div id="votekeys-custom-filters" style="display: none;">
	<button id="votekeys-add" class="btn btn-default" title="Add votekeys"><span class="fa fa-plus"></span> Add votekeys</button>
</div>

<table id="votekeys" class="table table-striped">
	<thead>
		<tr>
			<th>Votekey</th>
			<th>E-mail</th>
			<th>Posted</th>
			<th>Browser</th>
			<th>IP</th>
		</tr>
	</thead>
</table>