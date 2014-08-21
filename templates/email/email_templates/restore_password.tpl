<?php
$lang_main = NFW::i()->getLang('main'); 
switch($get_variable) {
	case 'subject':
		echo $lang_main['register']['restore password subject'];
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
<?php if (NFW::i()->user['language'] == 'English'): ?>
<p>To change your password, please visit the following page:</p>
<a href="<?php echo $activation_url?>"><?php echo $activation_url?></a>
<br />
<br />
<p>(Do not reply to this message)</p>
<?php else: ?>
<p>Вы запросили новый пароль для учётной записи на сайте «Demoscene at Multimatograf»</p>
<p>Если вы не запрашивали этого или передумали менять свой пароль, просто проигнорируйте это письмо.</p> 
<p>Если же вы посетите страницу активации ниже, пароль будет изменён.</p>
<br />
<p>Чтобы сменить пароль, посетите, пожалуйста, следующую страницу:</p>
<p><a href="<?php echo $activation_url?>"><?php echo $activation_url?></a></p>
<br />
<p>(Не отвечайте на это сообщение)</p>
<?php endif; ?>
</body></html>
<?php 		
}