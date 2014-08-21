<html><head><title><?php echo NFW::i()->cfg['admin']['title']?></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<style>
BODY { margin: 1em; }
BODY, TD, TH, P { color: #000; font-family: Verdana, Arial, Helvetica, sans-serif; text-align: left; }
TD, TH, P { margin: 0; padding: 0; font-size: 0.7em; }
H1 { font: bold 1.2em Verdana, Arial, Helvetica, sans-serif; padding: 0.2em 0; }
TABLE { border: none; border-collapse: collapse; padding: 0; }
TD, TH { padding: 0.2em 0.8em; }
TD.nw { white-space: nowrap; }
TH { text-align: left; background-color: #cccccc; }
TR.odd TD { background-color:#eeeeee; }
</style>
</head>
<body>
<h1>Логи сайта <?php echo $_SERVER['HTTP_HOST']?></h1>
<p>за период с <strong><?php echo date('d.m.Y', $posted_from)?></strong> по <strong><?php echo date('d.m.Y', $posted_to)?></strong></p>
<p>отфильтровано всего: <strong><?php echo count($logs)?> записей.</strong></p>
<p>дата выгрузки: <strong><?php echo date('d.m.Y H:i:s')?></strong></p>
<p>&nbsp;</p>
<table cellpadding="6" border="0">
	<thead>
		<tr>
			<th>Дата</th>
			<th>Сообщение</th>
			<th>Login</th>
			<th>Browser</th>
			<th>IP</th>
			<th>URL</th>
		</tr>
	</thead>
	<tbody>
		<?php foreach($logs as $log) { ?>
			<tr class="{cycle values='odd,even'}">
				<td class="nw"><?php echo date('d.m.Y H:i:s', $log['posted'])?></td>
				<td><?php echo htmlspecialchars($log['message_full'])?></td>
				<td><?php echo htmlspecialchars($log['poster_username'])?></td>
				<td class=nw"><?php echo (($log['browser']) ? htmlspecialchars($log['browser']) : 'unknown')?></td>
				<td><?php echo $log['ip']?></td>
				<td><a href="<?php echo $log['url']?>">Открыть</a></td>
			</tr>
		<?php } ?>
	</tbody>
</table>
</body></html>