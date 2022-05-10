<?php 
	NFW::i()->registerFunction('friendly_date');
	$lang_main = NFW::i()->getLang('main');
?>
<style>
	.latest-comments .posted, .latest-comments .work-title  { font-size: 85%;  white-space: nowrap; overflow: hidden; }
	.latest-comments .posted { font-weight: bold; }
	.latest-comments .work-title { font-weight: bold; }
	
	.latest-comments .message { padding-top: 10px; }
	
	.latest-comments .shadow {
		background: linear-gradient(to right, rgba(255, 255, 255, 0), rgba(255, 255, 255, 1) 60%);
		position: relative;
		top: -35px;
		float: right;
		width: 20px;
		height: 35px;
	}
	
	.latest-comments .icon {
		float: left; 
		position: relative;
		top: 2px;
		background-color: #ddd;
		border-radius: 3px;
		padding: 2px;
		margin-right: 8px;
	}
	
	.latest-comments .icon DIV {
		opacity: 0.2;
		filter: alpha(opacity=20);
	}
	
	.latest-comments HR { margin-top: 10px; margin-bottom: 10px; }
	
</style>
<div class="latest-comments">
<?php 
	$counter = 0; 
	foreach ($comments as $comment) {
		$url = NFW::i()->absolute_path.'/'.$comment['event_alias'].'/'.$comment['competition_alias'].'/'.$comment['work_id'].'#comment'.$comment['id'];
		
		echo '<a href="'.$url.'" title="'.$comment['works_type'].'">';
		echo '<div class="icon"><div class="icon-32x32 icon-32x32-'.$comment['works_type'].'"></div></div>';
		echo '</a>';

		echo '<div class="work-title"><a href="'.$url.'" title="'.htmlspecialchars($comment['work_title']).'">'.htmlspecialchars($comment['event_title'].' / '.$comment['work_title']).'</a></div>';
		echo '<div class="posted">'.friendly_date($comment['posted'], $lang_main).' '.date('H:i', $comment['posted']).' by '.htmlspecialchars($comment['posted_username']).'</div>';
		echo '<div class="shadow">&nbsp;</div>';
		echo '<div class="clearfix"></div>';
   		echo '<div class="message">'.nl2br(htmlspecialchars($comment['message'])).'</div>';
		echo $counter++ == count($comments) - 1 ? '' : '<hr />'; 
	} 
?>
</div>