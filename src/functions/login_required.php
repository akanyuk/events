<?php

function login_required($title, $info) {
    $langUsers = NFW::i()->getLang('users');
    ob_start();
    ?>
    <form onsubmit="loginRequiredFormSubmit(); return false;" class="d-grid mx-auto col-sm-8 col-md-6 col-lg-4">
        <fieldset>
            <legend><?php echo $title ?></legend>
            <div class="alert alert-info"><?php echo $info ?></div>

            <div class="mb-3">
                <label for="login-required-username"><?php echo NFW::i()->lang['Login'] ?></label>
                <input type="text" name="username" required="required" maxlength="64"
                       id="login-required-username" class="form-control">
            </div>

            <div class="mb-3">
                <label for="login-required-password"><?php echo NFW::i()->lang['Password'] ?></label>
                <input type="password" name="password" required="required" maxlength="64"
                       id="login-required-password" class="form-control">
                <div id="login-required-feedback" class="invalid-feedback"></div>
            </div>

            <div class="mb-3">
                <button type="submit" id="login-required-btn"
                        class="btn btn-primary"><?php echo NFW::i()->lang['GoIn'] ?></button>
            </div>

            <div class="mb-3">
                <a href="<?php echo NFW::i()->base_path ?>users/restore_password"><?php echo $langUsers['Restore password'] ?></a>
            </div>

            <div class="mb-3">
                <a href="<?php echo NFW::i()->base_path ?>users/register"><?php echo $langUsers['Registration'] ?></a>
            </div>

            <div class="mb-5">
                <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                            src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                            alt="Sign in with SceneID"/></a>
            </div>
        </fieldset>
    </form>

    <script type="text/javascript">
        const loginRequiredUsername = document.getElementById("login-required-username");
        const loginRequiredPassword = document.getElementById("login-required-password");
        const loginRequiredFeedback = document.getElementById("login-required-feedback");
        loginRequiredFormSubmit = async function () {
            let response = await fetch("?action=login", {
                method: "POST",
                body: JSON.stringify({
                    username: loginRequiredUsername.value,
                    password: loginRequiredPassword.value
                }),
                headers: {
                    "Content-type": "application/json; charset=UTF-8"
                }
            });

            if (!response.ok) {
                const resp = await response.json();
                const errors = resp.errors;

                loginRequiredUsername.classList.add('is-invalid');
                loginRequiredPassword.classList.add('is-invalid');

                if (errors["general"] !== undefined && errors["general"] !== "") {
                    loginRequiredFeedback.innerText = errors["general"];
                    loginRequiredFeedback.className = 'invalid-feedback d-block';
                }

                return;
            }

            window.location.reload();
        }
    </script>
    <?php
    NFW::i()->assign('page', array(
        'path' => '/', // Preventing `index` page
        'title' => $title,
        'content' => ob_get_clean(),
    ));
    NFW::i()->display('main.tpl');
}