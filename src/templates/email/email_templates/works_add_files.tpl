<?php 
switch($get_variable) {
	case 'subject':
		echo '['.$data['work']['event_alias'].']['.$data['work']['competition_alias'].'] files added';
		break;
	case 'from': 
		echo NFW::i()->project_settings['email_from'];
		break;
	case 'from_name':
		echo NFW::i()->project_settings['email_from_name'];
		break;
	case 'message':
?>
<html>
<style>
BODY { background: none; font-size: 10pt; font-family: Tahoma, Verdana, Arial, Helvetica, SunSans-Regular, Sans-Serif; background-color: #ffffff; color: #000000; padding: 1em; }
H1 { font: bold 15pt Arial,sans-serif; margin: 1em 0; }
H2 { font: bold 13pt Arial,sans-serif; margin: 1em 0 0 0; }
P { margin: 0; padding: 0.5em 0 0 0; }
HR { 
	-moz-border-bottom-colors: none; -moz-border-left-colors: none; -moz-border-right-colors: none; -moz-border-top-colors: none;
    border-color: #EEEEEE -moz-use-text-color -moz-use-text-color; border-image: none; border-style: solid none none; border-width: 1px 0 0;
    margin-bottom: 0.5em; margin-top: 0.5em;
}

dl { margin: 0; display: block; }
dt, dd { line-height: 1.3; }
dt { margin-bottom: 0.5em; }
dl, dl::before, dl:after { box-sizing: border-box; }
dt { font-weight: normal; }
dd { font-weight: bold; margin-left: 0; }
</style>
<body>
<h1>New files added in prod at events.retroscene.org</h1>
<dl>
	<dt>Event:</dt><dd><?php echo htmlspecialchars($data['work']['event_title'])?></dd>
	<dt>Competition:</dt><dd><?php echo htmlspecialchars($data['work']['competition_title'])?></dd>
	<dt>Title:</dt><dd><?php echo htmlspecialchars($data['work']['title'])?></dd>
	<dt>Author:</dt><dd><?php echo htmlspecialchars($data['work']['author'])?></dd>
	<dt>Files added:</dt><dd><?php echo $data['media_added']?></dd>
</dl>
<br />
<p><?php echo '<a href="'.NFW::i()->absolute_path.'/admin/works?action=update&record_id='.$data['work']['id'].'">'.NFW::i()->absolute_path.'/admin/works?action=update&record_id='.$data['work']['id'].'</a>'?></p>
<hr />
<p>(Please do not reply)</p>
</body></html>
<?php 		
}