<?php

// Determine event, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));

if (count($pathParts) > 2) {
    NFW::i()->stop(404);
}

$event = count($pathParts) == 2 ? eventFromAlias($pathParts[1]) : false;

if (NFW::i()->user['is_guest']) {
    $lang_main = NFW::i()->getLang("main");

    NFWX::i()->main_search_box = false;
    NFWX::i()->main_right_pane = false;

    $pageTitle = $lang_main['cabinet add work'];
    $uploadLegend = $lang_main['cabinet add work'];
    $path = "upload";

    if ($event !== false) {
        $pageTitle = htmlspecialchars($event['title'])." / ".$pageTitle;
        $uploadLegend = htmlspecialchars($event['title'])." / ".$uploadLegend;
        $path .= "/".$event['alias'];

        NFWX::i()->main_og['title'] = $pageTitle;
        NFWX::i()->main_og['description'] = $event['announcement_og'] ? $event['announcement_og'] : strip_tags($event['announcement']);
        if ($event['preview_img_large']) {
            NFWX::i()->main_og['image'] = tmb($event['preview_large'], 500, 500, array('complementary' => true));
        }
    }

    NFW::i()->assign('page', array(
        'title' => $pageTitle,
        'path' => implode("/", $pathParts),
        'content' => renderLoginRequired($uploadLegend),
    ));
    NFW::i()->display('main.tpl');
}

header("Location:/cabinet/works?action=add".($event === false) ? "" : "&event_id=".$event['id']);

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

/**
 * @param $uploadLegend string
 * @return string
 */
function renderLoginRequired($uploadLegend) {
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
            <legend><?php echo $uploadLegend ?></legend>

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