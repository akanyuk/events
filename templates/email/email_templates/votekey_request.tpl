<?php 
switch($get_variable) {
	case 'subject':
		echo $language == 'English' ? 'Retroscene Events: votekey generated' : 'Retroscene Events: ключ голосования';
		break;
	case 'from': 
		echo NFW::i()->cfg['email_from'];
		break;
	case 'from_name':
		echo 'Retroscene Events';
		break;
	case 'message':
?>
<html><body>
<?php if ($language == 'English'): ?>
<p>Your votekey for «<?php echo htmlspecialchars($event['title'])?>»:</p>
<br />
<strong><?php echo $votekey?></strong>
<p>(Please do not reply)</p>
<?php else: ?>
<p>Ваш ключ голосования для «<?php echo htmlspecialchars($event['title'])?>»:</p>
<br />
<strong><?php echo $votekey?></strong>
<p>(Не отвечайте на это сообщение)</p>
<?php endif; ?>
</body></html>
<?php 		
}