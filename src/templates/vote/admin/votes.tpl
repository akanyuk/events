<?php
/**
 * @var object $Module
 * @var array $event
 */

NFW::i()->registerFunction('active_field');
?>
<script type="text/javascript">
$(document).ready(function(){

	// Add vote

    const vDialog = $('div[id="vote-add-dialog"]');
    const vForm = vDialog.find('form');
    vDialog.modal({ 'show': false });
	
	$(document).off('click', 'button[id="vote-add"]').on('click', 'button[id="vote-add"]', function(){
		vForm.resetForm().trigger('cleanErrors');
		vDialog.modal('show');
	});

	vForm.activeForm({
		'success': function() {
			vDialog.modal('hide');
			oTable.fnDraw();
			return false;
		}
	});

	vDialog.find('button[id="vote-add-submit"]').click(function(){
		vForm.submit();
	});

	// Votes list
    const tableDOM = $('table[id="votes"]');
    const config = dataTablesDefaultConfig;

    // Infinity scrolling
	config.scrollY = $(window).height() - tableDOM.offset().top - 130;
	// Fix horizontal scroll
	//config.scrollX = '100%';
	config.deferRender = true;
	config.scroller = true;

	// Server-side
	config.bServerSide = true;
	config.bProcessing = false;
	config.sAjaxSource = '<?php echo $Module->formatURL('votes').'&event_id='.$event['id'].'&part=list.js'?>';
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
		{ 'sortable': false, 'width': '100%' },							// work 
		{ 'sortable': false, 'className': 'strong center' },			// vote
		{ 'sortable': false, 'className': 'nowrap-column' },			// username  
		{ 'sortable': false, 'className': 'nowrap-column' },			// votekey
		{ 'sortable': false, 'className': 'nowrap-column' },			// votekey email
		{ 'sortable': false, 'className': 'nowrap-column' },			// posted
		{ 'sortable': false, 'className': 'nowrap-column' },			// browser
		{ 'sortable': false, 'className': 'nowrap-column' }				// IP
	];
	
	config.fnRowCallback = function(nRow, aData) {
		$('td:eq(5)', nRow).html(formatDateTime(aData[5], true));

		// browser
		$('td:eq(6)', nRow).html('<span title="' +  aData[6][1] + '">' + (aData[6][0] ? aData[6][0] : 'unknown') + '</span>');
		
		return nRow;
	};

	const oTable = tableDOM.dataTable(config);

	// Custom filtering function
    const f = $('div[id="votes-custom-filters"]');
    $('div[id="votes_length"]').closest('div[class="col-sm-6"]').removeClass('col-sm-6').addClass('col-xs-4');
    $('div[id="votes_filter"]').closest('div[class="col-sm-6"]').removeClass('col-sm-6').addClass('col-xs-8');
	$('div[id="votes_length"]').empty().html(f.html());
	f.remove();
});
</script>

<div id="vote-add-dialog" class="modal fade">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title"><?php echo htmlspecialchars($event['title'])?></h4>
			</div>
			<div class="modal-body">
				<form action="<?php echo $Module->formatURL('add_vote', 'event_id='.$event['id'])?>">
<?php 
	$CWorks = new works();
	$cur_competition = 0;
	foreach ($CWorks->getRecords(array('skip_pagination' => true, 'filter' => array('voting_only' => true, 'event_id' => $event['id']))) as $work) {
		if ($cur_competition != $work['competition_id']) {
			echo '<h3>'.htmlspecialchars($work['competition_title']).'</h3>';
			$cur_competition = $work['competition_id'];
		}
		 
		echo '<div class="row" style="padding-bottom: 2px;">';
		echo '<div class="col-md-10"><strong>'.$work['position'].'.</strong> '.htmlspecialchars($work['title']).'</div>';
		echo '<div class="col-md-2"><input class="form-control input-sm" type="text" name="votes['.$work['id'].']" /></div>';
		echo '</div>';
	}	
?>
                    <div class="row">
                        <div class="col-md-5">
                            <label for="votekey" style="display: block;">
                                <input type="text" name="votekey" class="form-control" placeholder="Votekey" maxlength="32" />
                            </label>
                        </div>
                        <div class="col-md-7">
                            <p class="text-warning"><small>If you set non empty votekey, all already added votes for given works will be replaced.</small></p>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <label for="username" style="display: block;">
                                <input type="text" name="username" class="form-control" placeholder="Name / Nick / Comment" maxlength="200" />
                            </label>
                        </div>
                    </div>
				</form>
			</div>
			<div class="modal-footer">
				<button id="vote-add-submit" type="button" class="btn btn-primary">Add vote</button>
				<button type="button" class="btn btn-default" data-dismiss="modal"><?php echo NFW::i()->lang['Close']?></button>
			</div>
		</div>
	</div>
</div>

<div id="votes-custom-filters" style="display: none;">
	<button id="vote-add" class="btn btn-default" title="Add vote"><span class="fa fa-plus"></span></button>
</div>
<table id="votes" class="table table-striped">
	<thead>
		<tr>
			<th>Work</th>
			<th>Vote</th>
			<th>Name</th>
			<th>Key</th>
			<th>E-mail</th>
			<th>Posted</th>
			<th>Browser</th>
			<th>IP</th>
		</tr>
	</thead>
</table>