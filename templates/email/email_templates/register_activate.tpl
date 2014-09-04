<?php 
$lang_main = NFW::i()->getLang('main');
switch($get_variable) {
	case 'subject':
		echo $lang_main['register']['complete subject'];
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
<?php if (NFW::i()->user['language'] == 'English'): ?>
<p>Thank you for registering at «Retroscene Events» website. Your username is <?php echo htmlspecialchars($username)?>, as you requested.</p>
<br />
<p>To complete your registration, you need to set a password for your account.</p>
<p>To set your password, please visit the following page:</p>
<a href="<?php echo $activation_url?>"><?php echo $activation_url?></a>
<br />
<br />
<p>(Do not reply to this message)</p>
<?php else: ?>
<p>Спасибо за регистрацию на сайте «Retroscene Events». Ваше имя пользователя — <?php echo htmlspecialchars($username)?>, как указано при регистрации.</p>
<br />
<p>Чтобы завершить регистрацию, нужно установить пароль для вашей учётной записи.</p>
<p>Чтобы назначить пароль, посетите, пожалуйста, следующую страницу:</p>
<a href="<?php echo $activation_url?>"><?php echo $activation_url?></a>
<br />
<br />
<p>(Не отвечайте на это сообщение)</p>
<?php endif; ?>
</body></html>
<?php 		
}