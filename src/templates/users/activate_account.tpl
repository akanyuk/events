<?php
/**
 * @var array $account
 * @var string $key
 */
$langUsers = NFW::i()->getLang('users');
NFW::i()->assign('page_title', $langUsers['Activation']);
?>
<form onsubmit="activateAccountFormSubmit(); return false;" class="d-grid mx-auto col-sm-8 col-md-6 col-lg-4">
    <fieldset>
        <legend><?php echo $langUsers['Activation'] ?></legend>

        <dl>
            <dt><?php echo $langUsers['Username'] ?></dt>
            <dd><?php echo htmlspecialchars($account['username']) ?></dd>

            <dt>E-mail</dt>
            <dd><?php echo htmlspecialchars($account['email']) ?></dd>
        </dl>

        <div class="mb-3">
            <label for="password"><?php echo $langUsers['New_password'] ?></label>
            <input data-role="activateAccountInput" id="password" required="required" maxlength="64"
                   class="form-control" type="password">
            <div data-role="activateAccountFeedback" id="password" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="password2"><?php echo $langUsers['Retype_password'] ?></label>
            <input data-role="activateAccountInput" required="required" id="password2" maxlength="64"
                   class="form-control" type="password">
            <div data-role="activateAccountFeedback" id="password2" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <button type="submit" class="btn btn-primary"><?php echo $langUsers['Activation send'] ?></button>
        </div>
    </fieldset>
</form>

<script type="text/javascript">
    <?php ob_start(); ?>
    activateAccountFormSubmit = async function () {
        let post = {'key': '<?php echo $key?>'};
        document.querySelectorAll('[data-role="activateAccountInput"]').forEach(item => {
            item.classList.remove('is-valid', 'is-invalid');
            post[item.id] = item.value;
        });

        document.querySelectorAll('[data-role="activateAccountFeedback"]').forEach(item => {
            item.classList.remove('d-block');
        });

        let response = await fetch("?action=activate_account", {
            method: "POST",
            body: JSON.stringify(post),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        if (!response.ok) {
            const resp = await response.json();
            const errors = resp.errors;

            if (errors["general"] !== undefined && errors["general"] !== "") {
                gErrorToastText.innerText = errors["general"];
                gErrorToast.show();
                return
            }

            Object.keys(errors).forEach(function (key) {
                document.querySelector('[data-role="activateAccountInput"][id=' + key + ']').classList.add('is-invalid');
                document.querySelector('[data-role="activateAccountFeedback"][id=' + key + ']').innerText = errors[key];
                document.querySelector('[data-role="activateAccountFeedback"][id=' + key + ']').classList.add('d-block');
            });

            return;
        }

        window.location.href = '/';
    }

    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>