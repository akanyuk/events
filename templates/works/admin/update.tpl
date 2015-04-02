<?php
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.cookie');
NFW::i()->registerResource('colorbox');
NFW::i()->registerResource('jquery.jgrowl');
?>
<script type="text/javascript">
$(document).ready(function(){
	// Action 'delete'
	$('a[id="works-delete"]').click(function(){
		if (!confirm('Удалить запись?')) return false;

		$.post('<?php echo $Module->formatURL('delete')?>', { record_id: '<?php echo $Module->record['id']?>' }, function(response){
			if (response != 'success') {
				alert(response);
				return false;
			}
			else {
				window.location.href = '<?php echo $Module->formatURL()?>';
			}
		});
	});

	var wuF = $('form[id="works-update"]');
	wuF.activeForm({
		success: function(response) {
 			if (response.is_updated) {
 				$.jGrowl('Work profile updated.');
 			}
		}
	});

	// Platform
	var aPlatforms = [];
<?php foreach ($Module->attributes['platform']['options'] as $p) echo 'aPlatforms.push(\''.htmlspecialchars($p).'\');'."\n"; ?>	
	$('input[name="platform"]').autocomplete({
		source: aPlatforms,
		minLength: 0
	}).click(function(){
		$(this).autocomplete('search', '');
	});


	// Release archive
	$('button[id="media-release"]').click(function(){
		$.post('<?php echo $Module->formatURL('media_manage').'&record_id='.$Module->record['id']?>', {
			'media_release': 1,
			'attach_file_id': $('input[id="attach-file_id"]').prop('checked') ? 1 : 0 
		}, function(response) {
			if (response.result == 'success') {
				$('span[id="permanent-link"]').html('<a href="' + response.url + '">' + response.url + '</a>');
				$(document).trigger('uiDialog', '<a href="' + response.url + '">' + response.url + '</a>');
			}
			else {
				alert(response.errors.general);
			}
		},'json');
	});
	$('input[id="attach-file_id"]').uniform();
		
	$('div[id="works-insert-tabs"]').tabs().show();
	
	$(document).trigger('refresh');
});
</script>
<style>
	/* combobox */
	.custom-combobox { position: relative; display: inline-block; }
	.custom-combobox-toggle { 
		position: absolute; top: 0; bottom: 0; margin-left: -1px; padding: 0;
		/* support: IE7 */
		*height: 1.7em;
		*top: 0.1em;
	}
	.custom-combobox-input { margin: 0;	padding: 0.3em;	}
</style>

<div id="works-insert-tabs" style="display: none;">
	<?php if (NFW::i()->checkPermissions('works', 'delete')): ?>
		<div class="ui-state-error ui-corner-all" style="float: right; margin-right: 0.5em; margin-top: 0.2em; padding-right: 1px;"> 
			<a id="works-delete" href="#" class="ui-icon ui-icon-trash" title="Delete record"></a>
		</div>
	<?php endif; ?>
	<div style="float: right; padding-right: 1em; padding-top: 0.2em;">
		<p style="font-size: 85%; text-align: right;">Posted: <?php echo date('d.m.Y H:i:s', $Module->record['posted']).' ('.$Module->record['posted_username'].')'?></p>
		<?php if ($Module->record['edited']): ?>
			<p style="font-size: 85%; text-align: right;">Updated: <?php echo date('d.m.Y H:i:s', $Module->record['edited']).' ('.$Module->record['edited_username'].')'?></p>
		<?php endif; ?>
	</div>
	
	<ul>
		<li><a href="#tabs-1">Main</a></li>
		<li><a href="#tabs-2">Manage files</a></li>
	</ul>
    
    <div id="tabs-1" rel="tab-container">
		<form id="works-update" action="<?php echo $Module->formatURL('update').'&record_id='.$Module->record['id']?>">
			<input name="send_notify" type="hidden" />
			
			<div style="float: right; width: 230px; padding-left: 10px;">
		   		<fieldset>
		   			<legend>Poster info</legend>
	<?php
		ob_start();
		echo '<strong>e-mail:</strong> '.$Module->record['poster_email'].'<br />';
		echo '<strong>realname:</strong> '.htmlspecialchars($Module->record['poster_realname']).'<br />';
		echo '<strong>country:</strong> '.($Module->record['poster_country'] ? htmlspecialchars($Module->record['poster_country']) : '-').'<br />';
		echo '<strong>city:</strong> '.($Module->record['poster_city'] ? htmlspecialchars($Module->record['poster_city']) : '-').'<br />';
		echo $Module->record['description'] ? '<br /><strong>Author\'s comment:</strong><br />'.htmlspecialchars($Module->record['description']) : '';
		echo ob_get_clean();
	?>
				</fieldset>
			</div>
			
			<div style="padding-top: 10px;"></div>
			
			<?php echo active_field(array('name' => 'title', 'value' => $Module->record['title'], 'attributes'=>$Module->attributes['title'], 'width'=>"500px;"))?>
			<?php echo active_field(array('name' => 'author', 'value' => $Module->record['author'], 'attributes'=>$Module->attributes['author'], 'width'=>"500px;"))?>
			<?php echo active_field(array('name' => 'competition_id', 'value' => $Module->record['competition_id'], 'attributes'=>$Module->attributes['competition_id']))?>
			<?php echo active_field(array('name' => 'status', 'value' => $Module->record['status'], 'attributes'=>$Module->attributes['status']))?>
			<?php echo active_field(array('name' => 'platform', 'value' => $Module->record['platform'], 'attributes'=>$Module->attributes['platform'], 'width'=>"210px;"))?>
			<?php echo active_field(array('name' => 'format', 'value' => $Module->record['format'], 'attributes'=>$Module->attributes['format'], 'width'=>"210px;"))?>
			<?php echo active_field(array('name' => 'external_html', 'value' => $Module->record['external_html'], 'attributes'=>$Module->attributes['external_html'], 'width'=>"750px;", 'height'=>"150px;"))?>
						
			<div style="padding-top: 1em; padding-left: 105px;">
				<button id="works-save" class="nfw-button" icon="ui-icon-disk">Save changes</button>
				<input type="hidden" name="checkboxes_presents[send_notify]" value="1" />
				<input name="send_notify" type="checkbox" /> Send notify to author
			</div>
		</form>
    </div>
    <div id="tabs-2">
    	<?php 
    		$CMedia = new media();
    		echo $CMedia->openSession(array(
				'owner_class' => get_class($Module), 
				'owner_id' => $Module->record['id'], 
				'secure_storage' => true,
				'path_prefix' => 'works',
				'template' => 'media_manage',
    		))?> 
    		
    	 <hr />
    	 <div style="padding-bottom: 1em;">
    	 	<strong>Current permanent archive link: </strong>
    	 	<span id="permanent-link"><?php echo $Module->record['permanent_file'] ? '<a href="'.$Module->record['permanent_file']['url'].'">'.$Module->record['permanent_file']['url'].'</a>' : 'none'?></span>
    	 </div>
    	 <button id="media-release" class="nfw-button" icon="ui-icon-disk">Generate permanent archive with `release` files</button>
    	 <input id="attach-file_id" type="checkbox" checked="checked" />Attach `file_id.diz` into archive (only if not exist).
    </div>
</div>