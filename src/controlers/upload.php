<?php

// Determine event, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));

if (count($pathParts) > 2) {
    NFW::i()->stop(404);
}

$lang_main = NFW::i()->getLang("main");

$title = $lang_main['cabinet add work'];
$path = "upload";
$redirectSuffix = "";

$event = false;
if (count($pathParts) == 2) {
    $event = eventFromAlias($pathParts[1]);
    if ($event !== false) {
        $title = $event['title']." / ".$title;
        $path .= "/".$event['alias'];
        $redirectSuffix = "&event_id=".$event['id'];
    }
}

if (NFW::i()->user['is_guest']) {
    NFWX::i()->main_search_box = false;
    NFWX::i()->main_right_pane = false;

    NFW::i()->assign('page', array(
        'title' => $title,
        'path' => implode("/", $pathParts),
        'content' => renderLoginRequired($event),
    ));
    NFW::i()->display('main.tpl');
}

header("Location:/cabinet/works?action=add".$redirectSuffix);

/**
 * @param string $path
 * @return bool|array
 */
function eventFromAlias($path = "") {
    $CEvents = new events();
    if (!$CEvents->loadByAlias($path)) {
        return false;
    }

    $CCompetitions = new competitions();
    foreach ($CCompetitions->getRecords(array('filter' => array('open_reception' => true))) as $c) {
        if ($c['event_id'] == $CEvents->record['id']) {
            return $CEvents->record;
        }
    }

    return false;
}

function renderLoginRequired($event) {
    NFW::i()->registerResource('jquery.activeForm');
    $lang_users = NFW::i()->getLang('users');
    $lang_main = NFW::i()->getLang("main");

    ob_start();
    ?>
    <script type="text/javascript">
        $(document).ready(function () {
            $('form[id="login"]').activeForm({
                success: function () {
                    window.location.reload();
                }
            });
        });
    </script>
    <form id="login" class="form-horizontal">
        <fieldset>
            <legend><?php echo ($event === false ? "" : htmlspecialchars($event['title'])." / ").$lang_main['cabinet add work'] ?></legend>

            <div class="alert alert-info"><?php echo $lang_main['upload info'] ?></div>

            <?php echo active_field(array('name' => 'username', 'desc' => NFW::i()->lang['Login'], 'labelCols' => 1, 'inputCols' => 3)) ?>
            <?php echo active_field(array('name' => 'password', 'type' => 'password', 'desc' => NFW::i()->lang['Password'], 'labelCols' => 1, 'inputCols' => 3)) ?>

            <div class="form-group">
                <div class="col-md-7 col-md-offset-1">
                    <button name="login" class="btn btn-primary"
                            type="submit"><?php echo NFW::i()->lang['GoIn'] ?></button>
                    &nbsp;<a
                            href="<?php echo NFW::i()->base_path ?>users?action=restore_password"><?php echo $lang_users['Restore password'] ?></a><br/>
                </div>
            </div>
            <br/>
            <div class="form-group">
                <div class="col-md-7 col-md-offset-1">
                    <a class="btn btn-default"
                       href="<?php echo NFW::i()->base_path ?>users?action=register"><?php echo $lang_users['Registration'] ?></a>
                </div>
            </div>
        </fieldset>
    </form>
    <?php
    return ob_get_clean();
}