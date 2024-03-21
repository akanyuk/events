<?php
/**
 * @var $record array
 */

NFW::i()->registerResource('bootstrap');
NFW::i()->registerResource('main');
NFW::i()->registerFunction("display_work_media");
?>
<!DOCTYPE html>
<html lang="<?php echo NFW::i()->lang['lang'] ?>">
<head><title>preview</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<meta http-equiv="Content-Language" content="ru"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
</head>
<body><?php echo display_work_media($record, array('rel' => 'preview'))?></body>
</html>
