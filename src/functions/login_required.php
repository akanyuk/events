<?php

function login_required($title, $info) {
    NFW::i()->registerResource('jquery.activeForm');
    $lang_users = NFW::i()->getLang('users');

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
            <legend><?php echo $title ?></legend>
            <div class="alert alert-info"><?php echo $info ?></div>

            <?php echo active_field(array('name' => 'username', 'desc' => NFW::i()->lang['Login'], 'labelCols' => 1, 'inputCols' => 3)) ?>
            <?php echo active_field(array('name' => 'password', 'type' => 'password', 'desc' => NFW::i()->lang['Password'], 'labelCols' => 1, 'inputCols' => 3)) ?>

            <div class="form-group">
                <div class="col-md-7 col-md-offset-1">
                    <button name="login" class="btn btn-default"
                            type="submit"><?php echo NFW::i()->lang['GoIn'] ?></button>
                    &nbsp;<a
                            href="<?php echo NFW::i()->base_path ?>users?action=restore_password"><?php echo $lang_users['Restore password'] ?></a><br/>
                </div>
            </div>
            <br/>
            <div class="form-group">
                <div class="col-md-7 col-md-offset-1">
                    <a class="btn btn-primary"
                       href="<?php echo NFW::i()->base_path ?>users?action=register"><?php echo $lang_users['Registration'] ?></a>
                </div>
            </div>
            <div class="form-group">
                <div class="col-md-7 col-md-offset-1">
                    <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                                src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                                alt="Sign in with SceneID"/></a>
                </div>
            </div>
        </fieldset>
    </form>
    <?php
    NFW::i()->assign('page', array(
        'title' => $title,
        'content' => ob_get_clean(),
    ));
    NFW::i()->display('main.tpl');
}