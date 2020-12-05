<?php
/**
 * @var object $Module
 * @var integer $work_id
 * @var array $comments
 */
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerFunction('friendly_date');

$lang_main = NFW::i()->getLang('main');

$allow_delete = NFW::i()->checkPermissions('works_comments', 'delete', array('work_id' => $work_id));
?>
<script type="text/javascript">
$(document).ready(function(){
	<?php if (NFW::i()->checkPermissions('works_comments', 'add_comment')):?>
	var acF = $('form[id="works-comments-add"]');
	acF.activeForm({
		'success': function(response){
			acF.resetForm();
			$(document).trigger('works-comments-load');
		}
	});

	$(document).on('works-comments-load', function(){
		$.get('/works_comments?action=comments_list&work_id=<?php echo $work_id?>', function(response){
			if (response.result == 'success') {
				$('div[id="work-comments"]').empty();
				$.each(response.comments, function() {
					var tpl = $('div[id="works-comments-record-template"]').html();
					tpl = tpl.replace(/%ID%/g, this.id);
					tpl = tpl.replace('%POSTED_STR%', this.posted_str); 
					tpl = tpl.replace('%MESSAGE%', this.message);
					$('div[id="work-comments"]').append(tpl);
				});
			}
			
		}, 'json');
	});
	<?php endif; ?>


	<?php if ($allow_delete):?>
	$(document).on('click', '[role="delete-comment"]', function(){
		if (!confirm('Delete this comment?')) return false;

		$.post('/works_comments?action=delete', { record_id: $(this).attr('id') }, function(response){
			if (response != 'success') {
				alert(response);
				return false;
			}
			else {
				$(document).trigger('works-comments-load');
			}
		});
	});
	<?php endif; ?>
});
</script>
<style>
	.works-comments-comment .message { padding-top: 10px; overflow: auto; }
	form#works-comments-add .form-group { margin-left: 0; margin-right: 0;}
</style>

<div id="works-comments-record-template" style="display: none;">
	<div class="panel panel-default works-comments-comment">
		<div class="panel-body">
			<?php if ($allow_delete):?>
			<button role="delete-comment" id="%ID%" type="button" class="close" aria-label="Close" title="Delete comment"><span aria-hidden="true">&times;</span></button>
			<?php endif; ?>
			<code>%POSTED_STR%</code>
			<div class="message">%MESSAGE%</div>
		</div>
	</div>
</div>

<?php echo '<a name="comments"></a>'?>
<h3><?php echo $lang_main['comments']?></h3>

<div id="work-comments">
<?php foreach ($comments as $comment) {?>
	<?php echo '<a name="comment'.$comment['id'].'"></a>'?>
	
	<div class="panel panel-default works-comments-comment">
		<div class="panel-body">
			<?php if ($allow_delete):?>
			<button role="delete-comment" id="<?php echo $comment['id']?>" type="button" class="close" aria-label="Close" title="Delete comment"><span aria-hidden="true">&times;</span></button>
			<?php endif; ?>
			<code><?php echo friendly_date($comment['posted'], $lang_main).' '.date('H:i', $comment['posted']).' by '.htmlspecialchars($comment['posted_username'])?></code>
			<div class="message">
				<?php echo nl2br(htmlspecialchars($comment['message']));?>
			</div>
		</div>
	</div>
<?php } ?>
</div>

<?php if (NFW::i()->checkPermissions('works_comments', 'add_comment')):?>
	<form id="works-comments-add" action="/works_comments?action=add_comment">
		<input type="hidden" name="work_id" value="<?php echo $work_id?>" />
		<?php echo active_field(array('name' => 'message', 'attributes' => $Module->attributes['message'], 'desc' => $lang_main['works comments write'], 'vertical' => true, 'height' => '200px'))?>
		<button type="submit" class="btn btn-primary"><?php echo $lang_main['works comments send']?></button>
	</form>
<?php else:?>
	<div class="alert alert-warning"><?php echo $lang_main['works comments attention register']?></div>
<?php endif;?>