<?php 
switch($get_variable) {
	case 'subject':
		echo $language == 'English' ? 'Retroscene Events: your prod was updated by operator' : 'Retroscene Events: Ваша работа обновлена оператором';
		break;
	case 'from': 
		echo NFW::i()->project_settings['email_from'];
		break;
	case 'from_name':
		echo NFW::i()->project_settings['email_from_name'];
		break;
	case 'message':
?>
<html><body>
<?php if ($language == 'English'): ?>
<p>Your prod at site "Retroscene Events" was updated by operator.</p>
<p>You can check prod status in your <a href="<?php echo NFW::i()->absolute_path?>/cabinet/works?action=list">Private Office</a>.</p>
<br />
<p>(Please do not reply)</p>
<?php else: ?>
<p>Ваша работа на сайте "Retroscene Events" была обновлена оператором.</p>
<p>Вы можете проверить статус работы в <a href="<?php echo NFW::i()->absolute_path?>/cabinet/works?action=list">Личном Кабинете автора</a>.</p>
<br />
<p>(Не отвечайте на это сообщение)</p>
<?php endif; ?>
</body></html>
<?php 		
}