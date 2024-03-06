<?php
/**
 * @var array $records
 */

NFW::i()->assign('page_title', 'Timeline');

NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.min.js');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.min.css');
NFW::i()->registerResource('jquery.activeForm/bootstrap-datetimepicker.ru.js');
NFW::i()->registerResource('jquery.jgrowl');

$now =  time() - time()%3600 + 3600;
?>
<script type="text/javascript">
$(document).ready(function(){
 	// Action 'update'

    const f = $('form[id="timeline"]');
    f.activeForm({
		success: function() {
            $.jGrowl('Timeline saved');
		}
	});

 	$(document).on('click', '*[data-action="remove-values-record"]', function(){
 	 	$(this).closest('div[id="record"]').remove();
	});

 	f.find('button[id="add-values-record"]').click(function(){
 	 	f.addValue(<?php echo $now?>, '');
 	 	
 	 	return false;
	});

 	f.addValue = function(timestamp, description) {
        const record = $('<div>');
        record.append($('div[id="timeline-record-template"]').html().replace(/%description%/g, description))
        $(this).find('div[id="values-area"]').append(record);

 		// Datepicker
        const dp = record.find('input[id="datepicker"]');
        const container = dp.closest('div');
        const name = dp.attr('name');

        dp.attr({ 'readonly': '1' }).removeAttr('name role');
		container.append('<input name="' + name + '" value="' + timestamp + '" type="hidden" />');
		
		dp.datetimepicker({ 
			'autoclose': true,
			'todayBtn': true,
			'todayHighlight': true,
			'format': 'dd.mm.yyyy hh:ii',
			'minView': 0,
			'weekStart': <?php echo NFW::i()->user['language'] == 'English' ? '0' : '1'?>,
			'language': '<?php echo NFW::i()->user['language'] == 'English' ? 'en' : 'ru'?>',
			'startDate': '<?php echo date('d.m.Y H:i')?>',
			'endDate': '<?php echo date('d.m.Y H:i', time() + 86400 * 365)?>'
		}).on('changeDate', function(e) {
            const TimeZoned = new Date(e.date.setTime(e.date.getTime() + (e.date.getTimezoneOffset() * 60000)));
            dp.datetimepicker('setDate', TimeZoned);
		    container.find('input[name="' + name + '"]').val(TimeZoned.valueOf() / 1000);
		});

	 	// Initial value
		dp.datetimepicker('setDate', new Date(timestamp * 1000));
 	}

	<?php foreach ($records as $r) echo "\t\t".'f.addValue('.$r['date_from'].', '.json_encode($r['content']).');'."\n"; ?>
});
</script>

<div id="timeline-record-template" style="display: none;">
	<div id="record" class="record">
		<div class="cell">
			<div class="cell"><input name="date_from[]" id="datepicker" type="text" class="form-control" style="display: inline; width: 150px;" /></div>
			<div class="cell"><textarea name="content[]" class="form-control" style="width: 400px; height: 56px;">%description%</textarea></div>
			<div class="cell"><button data-action="remove-values-record" class="btn btn-danger btn-xs" title="<?php echo NFW::i()->lang['Remove']?>"><span class="glyphicon glyphicon-remove"></span></button></div>
		</div>
	</div>
</div>

<form id="timeline">
	<div id="values-area" class="settings"></div>
	<div style="padding-top: 20px;">
		<button id="add-values-record" class="btn btn-default">Add value</button>
		<button type="submit" name="form-send" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
	</div>
</form>