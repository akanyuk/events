<?php 
$lang_users = NFW::i()->getLang('users');
switch($get_variable) {
	case 'subject':
		echo $lang_users['Registration subj'];
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
<?php if (NFW::i()->user['language'] == 'Russian'): ?>
<p>Спасибо за регистрацию на сайте. Ваше имя пользователя — <?php echo htmlspecialchars($username)?>, как указано при регистрации.</p>
<br />
<p>Чтобы завершить регистрацию, нужно установить пароль для вашей учётной записи.</p>
<p>Чтобы назначить пароль, посетите, пожалуйста, следующую страницу:</p>
<a href="<?php echo $activation_url?>"><?php echo $activation_url?></a>
<br />
<br />
<p>(Не отвечайте на это сообщение)</p>
<?php else: ?>
<p>Thank you for registering at website. Your username is <?php echo htmlspecialchars($username)?>, as you requested.</p>
<br />
<p>To complete your registration, you need to set a password for your account.</p>
<p>To set your password, please visit the following page:</p>
<a href="<?php echo $activation_url?>"><?php echo $activation_url?></a>
<br />
<br />
<p>(Do not reply to this message)</p>
<?php endif; ?>
</body></html>
<?php 		
}