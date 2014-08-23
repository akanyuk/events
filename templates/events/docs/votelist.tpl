<?php
	$lang_main = NFW::i()->getLang('main');
?>
<html><head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<title>Votelist for <?php echo htmlspecialchars($Module->record['title'])?></title>
<style>
	body { margin: 0; padding: 1em; } 
	body, td, p { font: 10pt Arial; }
	h1 { font: bold 14pt Arial; margin: 0; padding: 0 0 0.2em 0; }
	h2 { font: bold 13pt Arial; margin: 0; padding: 0 0 0.2em 0; }
	h3 { font: bold 11pt Arial; margin: 0; padding: 0 0 0.2em 0; }
	h4 { font: bold 11pt Arial; margin: 0; padding: 1em 0 0 0; }
	p { margin: 0; padding: 0 0 0.5em 0; }

	.nickname { width: 200px; height: 30px; border: 1px solid black; }
	.info { background-color: #f4f4f4; margin-top: 1em; padding: 0.3em 1em; }
	.info P { font-size: 8pt; font-style: italic; padding-bottom: 0.2em; white-space: normal; }
	
	table { border: none; border-collapse: collapse; }
	td { border: none; text-align: left; white-space: nowrap; padding-top: 0.5em; vertical-align: top; }
	td.b { border-bottom: 1px solid black; }
	td.vote { border: 1px solid black; padding: 0.4em 0.8em; }
	td.right { text-align: right; }
</style>
</head>

<body>
<div style="float: right;">
	<?php echo $lang_main['votelist nickname']?>:
	<div class="nickname"></div>
</div>
<div style="float: left; margin-right: 1em;"><?php echo $Module->record['announce'] ? '<img src="'.$Module->record['announce'].'" />' : ''?></div>
<div style="float: left; margin-right: 1em;">
	<?php echo $data['header1'] ? '<h1>'.$data['header1'].'</h1>' : ''?>
	<?php echo $data['header2'] ? '<h2>'.$data['header2'].'</h2>' : ''?>
	<?php echo $data['header3'] ? '<h3>'.$data['header3'].'</h3>' : ''?>
</div>
<div style="clear: both;"></div>

<div class="info"><?php echo $lang_main['votelist note']?></div>

<table><tbody>
<?php
	$CCompetitions = new competitions();
	$CWorks = new works();
	foreach ($CCompetitions->getRecords(array('filter' => array('event_id' => $Module->record['id']))) as $c) {
		if (!in_array($c['id'], $data['competitions'])) continue;
?>
<tr><td colspan="2"><h4><?php echo htmlspecialchars($c['title'])?></h4></td></tr>
<?php
		$counter = 1;
		
		if (in_array($c['id'], $data['display_works'])) {
			list($release_works) = $CWorks->getRecords(array(
				'filter' => array('release_only' => true, 'competition_id' => $c['id']),
				'ORDER BY' => 'w.pos'
			));
			foreach ($release_works as $w) {
?>
<tr>
	<td class="b right"><?php echo $counter++?>.</td>
	<td class="b" style="width: 100%;"><?php echo htmlspecialchars($w['title'])?></td>
	<td style="padding: 0;">&nbsp;</td>
	<td class="vote">&nbsp;</td>
</tr>
<tr><td colspan="4" style="padding: 0.2em;"></td></tr>
<?php 
			}
		}
		
		while ($data['emptyrows'][$c['id']]--) {
?>
<tr>
	<td class="b right"><?php echo $counter++?>.</td>
	<td class="b" style="width: 100%;">&nbsp;</td>
	<td style="padding: 0;">&nbsp;</td>
	<td class="vote">&nbsp;</td>
</tr>
<tr><td colspan="4" style="padding: 0.2em;"></td></tr>
<?php 
		}
	}
?>
</tbody></table>
</body></html>