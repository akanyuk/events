<script type="text/javascript">
$(document).ready(function(){
	$('span[rel="competition-details"]').click(function(){
		$('tr[rel="competition-header"]').removeClass('bg-info');
		$('tr[rel="competition-details"]').hide();
		$(this).closest('tr').addClass('bg-info');
		$('tr[rel="competition-details"][id="' + $(this).attr('id') + '"]').closest('tr').show();
		return false;
	});	
});

</script>
<style>
	.competition-details P { font-size: 85% !important; }
</style>

<h1 style="margin-top: 0px;"><?php echo htmlspecialchars($title)?></h1>

<?php echo $content?>

<table class="table table-condensed dm">
	<thead>
		<tr>
			<th></th>
			<th><?php echo $lang_main['competions title']?></th>
			<th><?php echo $lang_main['competions type']?></th>
			<th class="r"><?php echo $lang_main['competions reception']?></th>
			<th class="r"><?php echo $lang_main['competions voting']?></th>
			<th class="r"><?php echo $lang_main['competions approved works-short']?></th>
		</tr>
	</thead>
	<tbody>

<?php 
	foreach ($competitions as $c) {
		if ($c['release_status']['available'] && $c['release_works']) {
			$is_link = true;
			$count = $c['release_works'];
		}
		elseif($c['voting_status']['available'] && $c['voting_works']) {
			$is_link = true;
			$count = $c['voting_works'];
		}
		else {
			$is_link = false;
			$count = $c['voting_works'];
		}

		if (!$count) {
			$label = '<span class="label label-default">'.$count.'</span>';
		}
		elseif ($count < 3) {
			$label = '<span class="label label-warning">'.$count.'</span>';
		}
		else {
			$label = '<span class="label label-success">'.$count.'</span>';
		}
		
?>
	<tr rel="competition-header" id="<?php echo $c['id']?>" name="<?php echo $c['id']?>">
		<td class="b r"><?php echo $c['pos']?></td>
		<td class="nw">
			<?php if ($is_link): ?>
				<a href="<?php echo  NFW::i()->absolute_path.'/'.$c['event_alias'].'/'.$c['alias']?>"><?php echo htmlspecialchars($c['title'])?></a>
			<?php else: ?>
				<span rel="competition-details" id="<?php echo $c['id']?>" style="cursor: pointer;"><?php echo htmlspecialchars($c['title'])?></span>
			<?php endif; ?>
		</td>
		<td class="nw"><em><?php echo $c['works_type']?></em></td>
		<td class="nw r <?php echo $c['reception_status']['text-class']?>"><?php echo $c['reception_status']['desc']?></td>
		<td class="nw r <?php echo $c['voting_status']['text-class']?>"><?php echo $c['voting_status']['desc']?></td>
		<td class="nw r"><?php echo $label?></td>
	</tr>
	<tr rel="competition-details" id="<?php echo $c['id']?>" style="display: none;">
		<td>&nbsp;</td><td colspan="5" class="competition-details">
			<p><?php echo nl2br($c['announcement'])?></p>
			<?php if ($c['reception_from']): ?>
				<p>
					<strong><?php echo $lang_main['competions reception']?>:</strong>
					<?php echo date('d.m.Y H:i', $c['reception_from']).' - '.date('d.m.Y H:i', $c['reception_to'])?>
				</p>
			<?php endif; ?>
				
			<?php if ($c['voting_from']): ?>
				<p>
					<strong><?php echo $lang_main['competions voting']?>:</strong>
					<?php echo date('d.m.Y H:i', $c['voting_from']).' - '.date('d.m.Y H:i', $c['voting_to'])?>
				</p>
			<?php endif; ?>
			</dl>
		</td>
	</tr>
<?php } ?>
</table>