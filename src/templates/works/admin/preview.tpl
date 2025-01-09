<?php
/**
 * @var $record array
 */
NFW::i()->registerResource('main');
NFW::i()->registerFunction("display_work_media");
$theme = 'light';
?>
<!DOCTYPE html>
<html lang="<?php echo NFW::i()->lang['lang'] ?>">
<head><title>preview</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="Content-Language" content="ru"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <link href="<?php echo NFW::i()->base_path ?>vendor/bootstrap5/theme/bootstrap.min.css" rel="stylesheet"
          crossorigin="anonymous">
</head>
<body>
<svg xmlns="http://www.w3.org/2000/svg" class="d-none">
    <symbol id="icon-circle-fill" viewBox="0 0 16 16">
        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16m.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2"/>
    </symbol>
</svg>

<?php echo display_work_media($record, array('rel' => 'preview')) ?>
<script src="<?php echo NFW::i()->base_path ?>vendor/bootstrap5/js/bootstrap.bundle.js"></script>
<?php echo NFW::i()->fetch(NFW::i()->findTemplatePath('_main_bottom_script.tpl'), ['theme' => $theme]); ?>
</body>
</html>
