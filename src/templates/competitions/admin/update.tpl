<?php
/**
 * @var object $Module
 */
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.jgrowl');

NFW::i()->assign('page_title', $Module->record['title'].' / edit');

// Generate breadcrumbs

NFW::i()->breadcrumb = array(
	array('url' => 'admin/events?action=update&record_id='.$Module->record['event_id'], 'desc' => $Module->record['event_title']),
	array('url' => 'admin/competitions?event_id='.$Module->record['event_id'], 'desc' => 'Competitions'),
	array('desc' => $Module->record['title']),
);

// Breadcrumbs hint
ob_start();
?>
<div class="text-muted" style="font-size: 80%;">
	<div class="pull-right">
		Posted: <?php echo date('d.m.Y H:i', $Module->record['posted']).' ('.$Module->record['posted_username'].')'?>
		<?php echo $Module->record['edited'] ? '<br />Updated: '.date('d.m.Y H:i', $Module->record['edited']).' ('.$Module->record['edited_username'].')' : ''?>
	</div>
</div>
<?php 
NFW::i()->breadcrumb_status = ob_get_clean();
?>
<script type="text/javascript">
$(document).ready(function(){
    const f = $('form[id="competitions-update"]');
    f.activeForm({
 		success: function(response) {
 	 		if (response.is_updated) {
 	 			$.jGrowl('Competition updated.');
 	 		}
 		}
 	});

    $(document).on('click', 'a[id="competitions-delete"]', function(){
        if (!confirm("Remove competition?\nCAN NOT BE UNDONE!")) {
            return false;
        }

        $.post('<?php echo $Module->formatURL('delete').'&record_id='.$Module->record['id']?>', function(response){
            response == 'success' ? window.location.href = '<?php echo $Module->formatURL().'?event_id='.$Module->record['event_id']?>' : alert(response);
        });

        return false;
    });
});
</script>

<div class="row">
	<div class="col-md-9">
		<form id="competitions-update"><fieldset>
			<legend>Edit competition</legend>
			<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title'], 'labelCols' => '2', 'inputCols' => '10'))?>
			<?php echo active_field(array('name' => 'announcement', 'value' => $Module->record['announcement'], 'attributes'=>$Module->attributes['announcement'], 'height'=>"100px;", 'labelCols' => '2', 'inputCols' => '10'))?>
			
			<?php echo active_field(array('name' => 'alias', 'value' => $Module->record['alias'], 'attributes'=>$Module->attributes['alias'], 'labelCols' => '2', 'inputCols' => '5'))?>
			<?php echo active_field(array('name' => 'works_type', 'value' => $Module->record['works_type'], 'attributes'=>$Module->attributes['works_type'], 'labelCols' => '2', 'inputCols' => '5'))?>
			
			<?php echo active_field(array('name' => 'reception_from', 'value' => $Module->record['reception_from'], 'attributes'=>$Module->attributes['reception_from'], 'labelCols' => '2'))?>
			<?php echo active_field(array('name' => 'reception_to', 'value' => $Module->record['reception_to'], 'attributes'=>$Module->attributes['reception_to'], 'labelCols' => '2'))?>
			<?php echo active_field(array('name' => 'voting_from', 'value' => $Module->record['voting_from'], 'attributes'=>$Module->attributes['voting_from'], 'labelCols' => '2'))?>
			<?php echo active_field(array('name' => 'voting_to', 'value' => $Module->record['voting_to'], 'attributes'=>$Module->attributes['voting_to'], 'labelCols' => '2'))?>

			<div class="row">
				<div class="col-md-offset-2 col-md-10">
					<div class="alert alert-warning alert-dismissible">
						<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>
						Если не указаны даты начала и окончания голосования, <br />то все принятые этого компо будут отображаться сразу же после принятия оператором!
					</div>
				</div>
			</div>
			
			<div class="row">
				<div class="col-md-offset-2 col-md-4">
					<button type="submit" class="btn btn-primary"><span class="fa fa-save"></span> <?php echo NFW::i()->lang['Save changes']?></button>
				</div>
                <div class="col-md-6 text-right" style="padding-top: 20px;">
                    <a id="competitions-delete" href="#" class="text-danger" title=""><span class="fa fa-times"></span> Delete competition</a>
                </div>
			</div>
		</fieldset></form>
	</div>
	<div class="col-md-3">
		<?php /* Right bar */ ?>
		<div class="panel panel-primary">
			<div class="panel-heading">Related links</div>
			<div class="panel-body">
				<ul class="nav nav-pills nav-stacked">
					<li role="presentation"><a href="<?php echo NFW::i()->base_path.'admin/works?event_id='.$Module->record['event_id']?>" title="Manage works of this events">Manage works</a></li>
					<li role="presentation"><a href="<?php echo NFW::i()->base_path.'admin/vote?event_id='.$Module->record['event_id']?>" title="Manage voting of this events">Manage voting</a></li>
				</ul>
<?php
	$CWorks = new works();
	$works =  $CWorks->getRecords(array('filter' => array('competition_id' => $Module->record['id'], 'allow_hidden' => true), 'skip_pagination' => true));
	if (!empty($works)) {
		echo '<hr />';
		foreach ($works as $r) { 
			echo '<p>'.$r['position'].'. <a href="'.NFW::i()->base_path.'admin/works?action=update&record_id='.$r['id'].'" title="'.htmlspecialchars($r['title'].' by '.$r['author']).'">'.htmlspecialchars($r['title']).'</a></p>';
		}
	}
?>	
			</div>
		</div>
	</div>
</div>