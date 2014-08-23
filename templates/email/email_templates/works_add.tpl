<?php 
switch($get_variable) {
	case 'subject':
		echo 'DMF: автор добавил работу';
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
<p>На сайт Demoscene at Multimatograf была добавлена новая работа.</p>
<p><?php echo '<a href="'.NFW::i()->absolute_path?>/admin/works?action=update&record_id=<?php echo $data['work']['id'].'">'.NFW::i()->absolute_path.'/admin/works?action=update&work_id='.$data['work']['id'].'</a>'?></p>
<br />
<p>(Не отвечайте на это сообщение)</p>
</body></html>
<?php 		
}