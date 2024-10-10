<?php
if (!NFW::i()->user['is_guest']) {
    header('Location: '.NFW::i()->absolute_path);
}

$langUsers = NFW::i()->getLang('users');
NFW::i()->assign('page_title', $langUsers['Restore password']);
?>
<form onsubmit="restorePasswordFormSubmit(); return false;">
    <fieldset>
        <legend><?php echo $langUsers['Restore password'] ?></legend>
        <div class="mx-left col-sm-6 col-md-4 col-lg-3 mb-3">
            <label for="restore-password-email">E-mail</label>
            <input type="text" id="restore-password-email" class="form-control " maxlength="64">
            <div id="restore-password-email-feedback" class="invalid-feedback"></div>
        </div>

        <div class="mx-left col-sm-6 col-md-4 col-lg-3 mb-3">
            <label for="captcha"><?php echo NFW::i()->lang['Captcha'] ?></label>

            <div class="input-group">
                <input id="restore-password-captcha" type="text" maxlength="6" class="form-control"
                       style="font-family: monospace; font-weight: bold;"/>
                <img id="restore-password-captcha-img" src="<?php echo NFW::i()->base_path ?>captcha.png" alt=""/>
            </div>

            <div id="restore-password-captcha-feedback" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <button type="submit" id="login-btn"
                    class="btn btn-primary"><?php echo $langUsers['Restore password send'] ?></button>
        </div>
    </fieldset>
</form>

<div class="mb-3">
    <a href="<?php echo NFW::i()->base_path ?>users?action=register"><?php echo $langUsers['Registration'] ?></a>
</div>
<script type="text/javascript">
    const restorePasswordEmail = document.getElementById("restore-password-email");
    const restorePasswordEmailFeedback = document.getElementById("restore-password-email-feedback");
    const restorePasswordCaptcha = document.getElementById("restore-password-captcha");
    const restorePasswordCaptchaFeedback = document.getElementById("restore-password-captcha-feedback");
    const restorePasswordCaptchaImg = document.getElementById("restore-password-captcha-img");
    restorePasswordFormSubmit = async function () {
        restorePasswordCaptchaImg.setAttribute('src', '<?php echo NFW::i()->base_path?>captcha.png?' + +Math.floor(Math.random() * 10000000));

        let response = await fetch("?action=restore_password", {
            method: "POST",
            body: JSON.stringify({
                request_email: restorePasswordEmail.value,
                captcha: restorePasswordCaptcha.value
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        restorePasswordEmail.classList.remove('is-valid', 'is-invalid');
        restorePasswordEmailFeedback.classList.remove('d-block');
        restorePasswordCaptchaFeedback.classList.remove('d-block');

        if (!response.ok) {
            const resp = await response.json();
            const errors = resp.errors;

            if (errors["general"] !== undefined && errors["general"] !== "") {
                gErrorToastText.innerText = errors["general"];
                gErrorToast.show();
                return
            }

            if (errors["request_email"] !== undefined && errors["request_email"] !== "") {
                restorePasswordEmail.classList.add('is-invalid');
                restorePasswordEmailFeedback.innerText = errors["request_email"];
                restorePasswordEmailFeedback.classList.add('d-block');
            } else {
                restorePasswordEmail.classList.add('is-valid');
            }

            if (errors["captcha"] !== undefined && errors["captcha"] !== "") {
                restorePasswordCaptcha.classList.add('is-invalid');
                restorePasswordCaptchaFeedback.innerText = errors["captcha"];
                restorePasswordCaptchaFeedback.classList.add('d-block');
            }

            return;
        }

        window.location.href = '/';
    }
</script>