<?php
header ("Content-Type:text/xml");

$content = file_get_contents($_GET['u']);
if (!simplexml_load_string($content)) {
	NFW::i()->stop('<error>Wrong xml file</error>');
}

if (isset($_GET['encoding'])) {
	$content = str_replace('encoding="'.$_GET['encoding'].'"', 'encoding="utf-8"', $content);
	$content = iconv($_GET['encoding'], 'utf-8', $content);	
}

NFW::i()->stop($content);