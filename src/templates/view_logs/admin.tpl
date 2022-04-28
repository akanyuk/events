<?php 
NFW::i()->registerResource('dataTables');
NFW::i()->registerResource('dataTables/Scroller');

// Datepicker
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.min.js');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.ru.js');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.min.css');
?>
<script type="text/javascript">
$(document).ready(function(){
	var exportState = 0;

	// Action 'admin'
	var config =  dataTablesDefaultConfig;
	
	// Infinity scrolling
	config.scrollY = $(window).height() - $('table[id="logs"]').offset().top - 130;
	// Fix horizontal scroll
	//config.scrollX = '100%';
	config.deferRender = true;
	config.scroller = true;
	
	// Server-side
	config.bServerSide = true;
	config.bProcessing = false;
	config.sAjaxSource = '<?php echo $Module->formatURL('admin').'&part=list.js'?>';
	config.fnServerData = function (sSource, aoData, fnCallback) {
		aoData.push({ 'name':'posted_from','value': $('input[id="logs-filter-from"]').attr('data-timestamp') });
		aoData.push({ 'name':'posted_to','value': $('input[id="logs-filter-to"]').attr('data-timestamp') });
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

	// Create columns
	config.columns = [
		{ 'searchable': false, 'className': 'nowrap-column' },						// Дата  
		{ 'orderable': false, 'searchable': false, 'className': 'nowrap-column' },	// Сообщение
		{ 'orderable': false, 'searchable': false, 'className': 'nowrap-column' },	// Username
		{ 'orderable': false, 'searchable': false, 'className': 'nowrap-column' },	// Browser / URL
		{ 'orderable': false, 'searchable': false, 'className': 'nowrap-column' }	// IP  	
    ];

	config.order = [[0,'desc']];
	config.search = { 'search': '<?php echo (isset($_GET['filter'])) ? htmlspecialchars($_GET['filter']) : ''?>' };
	
	config.rowCallback = function(row, data, index) {
		// Dates
		$('td:eq(0)', row).html(formatDateTime(data[0], true));
		
		// Make clickable URL
		$('td:eq(3)', row).html(data[3].url == '' ? data[3].browser : '<a href="' + data[3].url + '" title="' + data[3].url + '">' + data[3].browser + '</a>');
	}
	
	// Create table
	var logsTable = $('table[id="logs"]').dataTable(config);	

	// Custom filtering function
	$('div[id="logs_length"]').closest('.row').html($('div[id="custom-filters"]').html());
	$('div[id="custom-filters"]').remove();
	
	// Datepicker
	$('input[data-datepicker]').each(function(){
		$(this).removeAttr('data-datepicker');
		$(this).attr('data-timestamp', $(this).val());
		$(this).val(formatDateTime($(this).val()));

		var dp = $(this);
		dp.datetimepicker({ 
			'autoclose': true,
			'todayBtn': true,
			'todayHighlight': true,
			'format': 'dd.mm.yyyy',
			'minView': 2,
			'weekStart': 1,
			'language': 'ru' 
		}).on('changeDate', function(e) {
			if (typeof(e.date) == 'undefined') {
				dp.val(0);
				dp.attr('data-timestamp', 0);
				return;
			}

		    var TimeZoned = new Date(e.date.setTime(e.date.getTime() + (e.date.getTimezoneOffset() * 60000)));
		    dp.datetimepicker('setDate', TimeZoned);
		    dp.attr('data-timestamp', TimeZoned.valueOf() / 1000);				

		    logsTable.fnDraw();			
		});
	});	
	
	$('select[id="logs-filter-poster"], select[id="logs-filter-kind"]').change(function(){
		logsTable.fnDraw();
	});

	
	// Action 'export'
	$('button[id="export-logs"]').click(function() {
		exportState = 1;
		logsTable.fnDraw();
		return false;
	});
});
</script>
<div id="custom-filters" style="display: none;">
	<div class="col-sm-12 col-md-12 col-xl-12">
		<div class="pull-right">
			<button id="export-logs" class="btn btn-info" title="Выгрузить выбранное в документ MS Word">Выгрузить выбранное</button>
		</div>
		с <input id="logs-filter-from" class="form-control" data-datepicker="1" readonly="readonly" placeholder="dd.mm.yyyy" style="width: 100px;" value="<?php echo  mktime (0, 0, 0, date('n'), 1, date('Y'))?>"  data-timestamp="<?php echo  mktime (0, 0, 0, date('n'), 1, date('Y'))?>" /> 
		по <input id="logs-filter-to" class="form-control" data-datepicker="1" readonly="readonly" placeholder="dd.mm.yyyy" style="width: 100px;" value="<?php echo time()?>" data-timestamp="<?php echo time()?>" />
		&nbsp;
		<select id="logs-filter-poster" class="form-control" title="Логин пользователя">
			<option value="0">--- Все ---</option>
			<?php foreach($users as $user) { ?>
				<option value="<?php echo $user['id']?>"><?php echo htmlspecialchars($user['poster_username'])?></option>
			<?php } ?>		
		</select>
		<select id="logs-filter-kind" class="form-control" title="Событие">
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
	<div class="clearfix"></div>
</div>

<table id="logs" class="table table-striped">
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
