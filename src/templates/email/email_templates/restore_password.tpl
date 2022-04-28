<?php
$lang_users = NFW::i()->getLang('users'); 
switch($get_variable) {
	case 'subject':
		echo $lang_users['Restore password subj'];
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
<p>Вы запросили новый пароль для учётной записи на сайте</p>
<p>Если вы не запрашивали этого или передумали менять свой пароль, просто проигнорируйте это письмо.</p> 
<p>Если же вы посетите страницу активации ниже, пароль будет изменён.</p>
<br />
<p>Чтобы сменить пароль, посетите, пожалуйста, следующую страницу:</p>
<p><a href="<?php echo $activation_url?>"><?php echo $activation_url?></a></p>
<br />
<p>(Не отвечайте на это сообщение)</p>
<?php else: ?>
<p>To change your password, please visit the following page:</p>
<a href="<?php echo $activation_url?>"><?php echo $activation_url?></a>
<br />
<p>(Do not reply to this message)</p>
<?php endif; ?>
</body></html>
<?php 		
}