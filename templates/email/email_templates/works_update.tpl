<?php 
switch($get_variable) {
	case 'subject':
		echo $language == 'English' ? 'DMF: your prod was updated by operator' : 'DMF: Ваша работа обновлена оператором';
		break;
	case 'from': 
		echo NFW::i()->cfg['email_from'];
		break;
	case 'from_name':
		echo 'demoscene.multimatograf.ru';
		break;
	case 'message':
?>
<html><body>
<?php if ($language == 'English'): ?>
<p>Your prod at site "Demoscene at Multimatograf" was updated by operator.</p>
<p>You can check prod status in your <a href="<?php echo NFW::i()->absolute_path?>/cabinet/works?action=list">Private Office</a>.</p>
<br />
<p>(Please do not reply)</p>
<?php else: ?>
<p>Ваша работа на сайте "Demoscene at Multimatograf" была обновлена оператором.</p>
<p>Вы можете проверить статус работы в <a href="<?php echo NFW::i()->absolute_path?>/cabinet/works?action=list">Личном Кабинете автора</a>.</p>
<br />
<p>(Не отвечайте на это сообщение)</p>
<?php endif; ?>
</body></html>
<?php 		
}