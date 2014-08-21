<?php

if (isset($_GET['type']) && $_GET['type'] == 'image') {
	foreach ($records as $key=>$r) {
		if ($r['type'] != 'image') {
			unset($records[$key]);
		}
	}
	
	// generate thumbnails array
	$thumbs = array();
	if (isset($_GET['t']) && !empty($_GET['t'])) foreach ($_GET['t'] as $t) {
		$x = $y = false;
		$postfix = '';
			
		if (isset($t['x'])) {
			$x = intval($t['x']);
			if ($x < 8 || $x > 640) continue;
	
			$title[0] = 'Ширина: <strong>'.$x.'px</strong>;';
			$postfix = $x;
		}
		else {
			$title[0] = 'Ширина: <strong>пропорционально</strong>;';
		}
	
		if (isset($t['y'])) {
			$y = intval($t['y']);
			if ($y < 8 || $y > 640) continue;
	
			$title[1] = 'Высота: <strong>'.$y.'px</strong>;';
			$postfix .= 'x'.$y;
		}
		else {
			$title[1] = 'Высота: <strong>пропорционально</strong>;';
		}
			
		if (!$x && !$y) continue;
			
		$thumbs[] = array('title' => implode('<br />', $title), 'postfix' => $postfix);
	}
}

if (empty($records)) {
	echo '<html><body><script type="text/javascript">alert("На сервер не загружено ни одного файла!"); window.close();</script></body></html>';
}
else {
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" " http://www.w3.org/TR/html4/strict.dtd"> 
<html><head><title>Выбор файла</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<script type="text/javascript">
function selectFilename(filename) {
	window.opener.CKEDITOR.tools.callFunction(<?php echo $_GET['CKEditorFuncNum']?>, filename, '');
	window.close();
}
</script>
</head>
<body style="padding: 1em;">
<?php if (isset($_GET['type']) && $_GET['type'] == 'image'): ?>
	<style>
		TABLE { width: 100%; }
		TD, TH { border-left: 1px dotted #aaa; white-space: nowrap; text-align: center; vertical-align: center; }
		TD.first, TH.first { border-left: none; }
	</style>
	<table class="main-table">
		<thead>
			<tr>
				<th class="first">Полный размер</th>
				<?php foreach ($thumbs as $t) { ?>
					<th><?php echo $t['title']?></th>
				<?php } ?>					
			</tr>
		</thead>
		<tbody>
			<?php foreach ($records as $a) { ?>
				<tr class="zebra">
					<td class="first"><a onclick="selectFilename('<?php echo $a['url']?>');" title="Полный размер" href="#"><strong><?php echo $a['basename']?></strong><br />(полный размер)</a></td>
					<?php foreach ($thumbs as $t) {
						$filename = $a['tmb_prefix'].$t['postfix'].'.'.$a['extension'];
					?>
						<td><a onclick="selectFilename('<?php echo $filename?>');" title="Выбрать" href="#"><img src="<?php echo $filename?>" /></a></td>
					<?php } ?>
				</tr>
			<?php } // foreach ?>
		</tbody>
	</table>
<?php else: ?>
	<style>
		TABLE { border:0; padding:0; border-collapse:collapse; }
		TH, TD { padding: 2px 5px; }
		TH { font-weight: normal; background-color: #cccccc; }
	</style>
	<table class="main-table" style="width: 100%;">
		<thead>
			<tr>
				<th>&nbsp;</th>
				<th>Имя файла</th>
				<th>Загружен</th>
				<th>Размер</th>
			</tr>
		</thead>
		<tbody>
			<?php foreach ($records as $a) { ?>
				<tr>
					<td style="padding-right: 0px;"><img src="<?php echo $a['icons']['16x16']?>" /></td>
					<td style="width: 100%;"><a onclick="selectFilename('<?php echo $a['url']?>');" href="#"><?php echo htmlspecialchars($a['basename'])?></a></td>
					<td style="white-space: nowrap"><?php echo date('d.m.Y H:i:s', $a['posted'])?></td>
					<td style="white-space: nowrap"><?php echo $a['filesize_str']?></td>
				</tr>
			<?php } ?>
		</tbody>
	</table>
<?php endif; ?>
<?php } // endif; ?>