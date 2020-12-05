<?php 
	NFW::i()->registerFunction('active_field');
?>
<script type="text/javascript">
$(document).ready(function(){
 	// Action 'update'
 	var f = $('form[id="settings-update-<?php echo $Module->record['varname']?>"]')
 	f.activeForm({
		success: function(response) {
			if (response.is_updated) {
				$.jGrowl('<?php echo $Module->lang['Settings saved']?>');
			}
		}
	});
});
</script>
<br />
<form id="settings-update-<?php echo $Module->record['varname']?>" action="<?php echo NFW::i()->base_path.'admin/settings?action=update&varname='.$Module->record['varname']?>">
<?php 
	foreach ($Module->record['attributes'] as $key=>$a) {
		echo active_field(array(
			'name' => 'values['.$key.'][0]', 'attributes'=>$a, 'value' => isset($Module->record['values'][0][$key]) ? $Module->record['values'][0][$key] : null)); 
	}
	 
	if (NFW::i()->checkPermissions('settings', 'update')): ?>
		<div class="form-group">
			<div class="col-md-9 col-md-offset-3">
				<button type="submit" class="btn btn-primary"><span class="glyphicon glyphicon-floppy-disk"></span> <?php echo NFW::i()->lang['Save changes']?></button>
			</div>
		</div>
	<?php endif; ?>
</form>