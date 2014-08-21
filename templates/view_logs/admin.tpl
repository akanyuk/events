<?php 
NFW::i()->registerResource('dataTables');
NFW::i()->registerResource('jquery.activeForm');
?>
<script type="text/javascript">
$(document).ready(function(){
	var exportState = 0;
	
	var config = dataTablesDefaultConfig;

	// Infinity scrolling
	config.iDisplayLength = 100;	
	config.bScrollInfinite = true;
	config.bScrollCollapse = true;
	config.sScrollY = $(window).height() - $('table[id="logs"]').offset().top - 102;

	// Fix horizontal scroll
	config.sScrollX = '100%';
	
	// Server-side
	config.bServerSide = true;
	config.bProcessing = false;
	config.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';
	config.fnServerData = function (sSource, aoData, fnCallback) {
		aoData.push({ 'name':'posted_from','value': $('input[id="logs-filter-from"]').val() });
		aoData.push({ 'name':'posted_to','value': $('input[id="logs-filter-to"]').val() });
		aoData.push({ 'name':'poster','value': $('select[id="logs-filter-poster"] option:selected').val() });
		aoData.push({ 'name':'kind','value': $('select[id="logs-filter-kind"] option:selected').val() });

		// Экспорт вместо обновления
		if (exportState) {
			exportState = 0;
			
			//split params into form inputs
			var inputs = '';
			$.each(aoData, function(){
				if (this.name != 'iDisplayLength' && this.name != 'iDisplayStart') { 
					inputs+='<input type="hidden" name="'+ this.name +'" value="'+ this.value +'" />';
				}
			});
			$('<form action="?action=export" method="POST">'+inputs+'</form>')
			.appendTo('body').submit().remove();
		}
		else {		
			$.ajax( {
				'dataType': 'json', 
				'type': "POST", 
				'url': sSource, 
				'data': aoData, 
				'success': fnCallback
			});
		}
	};
	config.fnRowCallback = function( nRow, aData, iDisplayIndex ) {
		// Dates
		$('td:eq(0)', nRow).html(formatDateTime(aData[0], true));
		
		// Make clickable URL
		$('td:eq(3)', nRow).html('<a href="' + aData[3].url + '" title="' + aData[3].url + '">' + aData[3].browser + '</a>');
		return nRow;
	};
	 
	// Columns setup
	config.aoColumns = [
   		{ 'bSearchable': false, 'sClass': 'nowrap-column' },						// Дата  
  		{ 'bSortable': false, 'bSearchable': false, 'sClass': 'nowrap-column' },	// Сообщение
  		{ 'bSortable': false, 'bSearchable': false,  'sClass': 'nowrap-column' },	// Username
  		{ 'bSortable': false, 'bSearchable': false,  'sClass': 'nowrap-column' },	// Browser / URL
  		{ 'bSortable': false, 'bSearchable': false,  'sClass': 'nowrap-column' }	// IP  	
  	];
	config.aaSorting = [[0,'desc']];

	// Create table
	var logsTable = $('table[id="logs"]').dataTable(config);	
	
	// Custom filtering function 
	$('.dataTables_filter').html($('div[id="custom-filters"]').html()).width('100%').css({ 'float' : 'left', 'text-align' : 'left' });
	$('div[id="custom-filters"]').remove();

	// Convert dates
	$('input[rel="datepicker"]').each(function(){
		var fieldID = this.id;
		var fieldValue = $(this).val();
		var dt = new Date(fieldValue * 1000);
		
		$(this).removeAttr('id').attr('disabled', 'disabled').after('<input type="hidden" id="' + fieldID + '" value="' + fieldValue + '" />').datepicker({ 
			'altField': '#' + fieldID, 
			'altFormat' : '@',
			'onSelect' : function(dateText, inst) {
				$('#' + fieldID).val($.datepicker.formatDate('@', $(this).datepicker('getDate')) / 1000);
				logsTable.fnDraw();
			}
		}).val($.datepicker.formatDate('dd.mm.yy', dt));

		$(this).uniform();
	});
	
	$('select[id="logs-filter-poster"], select[id="logs-filter-kind"]').change(function(){
		logsTable.fnDraw();
	}).uniform();

	
	// Action 'export'
	$('button[id="export-logs"]').click(function() {
		exportState = 1;
		logsTable.fnDraw();
		return false;
	});
	
	$(document).trigger('refresh');
});
</script>
<style>
	/* Fix uniform */
	.selector { top: -3px; }
</style>
<div id="custom-filters" style="display: none;">	
	<div style="float: right;">
		<button id="export-logs" class="nfw-button" title="Выгрузить выбранное в документ MS Word">Выгрузить выбранное</button>
	</div>
	<div>		    
		с <input id="logs-filter-from" rel="datepicker" style="width: 65px;" value="<?php echo  mktime (0, 0, 0, date('n'), 1, date('Y'))?>" maxlength="8" /> 
		по <input id="logs-filter-to" rel="datepicker" style="width: 65px;" value="<?php echo time()?>" maxlength="8" />
		&nbsp;
		<select id="logs-filter-poster" title="Логин пользователя">
			<option value="0">--- Все ---</option>
			<?php foreach($users as $user) { ?>
				<option value="<?php echo $user['id']?>"><?php echo htmlspecialchars($user['poster_username'])?></option>
			<?php } ?>		
		</select>
		<select id="logs-filter-kind" title="Событие">
			<option value="0">--- Все ---</option>
			<?php foreach($Module->kinds as $label=>$groups) { ?>
				<optgroup label="<?php echo $label?>">
					<?php foreach($groups as $id=>$kind) { ?>
						<option value="<?php echo $id?>"><?php echo htmlspecialchars($kind)?></option>
					<?php } ?>
				</optgroup>			
			<?php } ?>		
		</select>
	</div>
	<div style="clear: both;"></div>
</div>

<table id="logs" class="dataTables">
	<thead>
		<tr>
			<th>Дата</th>
			<th>Сообщение</th>
			<th>Login</th>
			<th>Browser / URL</th>
			<th>IP</th>
		</tr>
	</thead>
</table>
