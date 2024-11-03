<?php
$langUsers = NFW::i()->getLang('users');
NFW::i()->assign('page_title', $langUsers['Restore password']);
?>
<div id="restorePasswordSuccessModal" class="modal fade"
     data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><?php echo $langUsers['Restore password subj'] ?></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div id="restorePasswordSuccessModalBody" class="modal-body"></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary"
                        data-bs-dismiss="modal"><?php echo NFW::i()->lang['Close'] ?></button>
            </div>
        </div>
    </div>
</div>

<form onsubmit="restorePasswordFormSubmit(); return false;" class="d-grid mx-auto col-sm-8 col-md-6 col-lg-4">
    <fieldset>
        <legend><?php echo $langUsers['Restore password'] ?></legend>
        <div class="mb-3">
            <label for="restore-password-email">E-mail</label>
            <input type="email" required="required" id="restorePasswordEmail" class="form-control">
            <div id="restorePasswordEmailFeedback" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <button type="submit" class="btn btn-primary"><?php echo $langUsers['Restore password send'] ?></button>
        </div>

        <div class="mb-3">
            <a href="<?php echo NFW::i()->base_path ?>users/register"><?php echo $langUsers['Registration'] ?></a>
        </div>
    </fieldset>
</form>

<script type="text/javascript">
    <?php ob_start(); ?>
    const restorePasswordSuccessModalBody = document.getElementById("restorePasswordSuccessModalBody");
    const restorePasswordSuccessModal = new bootstrap.Modal('#restorePasswordSuccessModal');
    document.getElementById("restorePasswordSuccessModal").addEventListener('hidden.bs.modal', function () {
        window.location.href = '/';
    })

    const restorePasswordEmail = document.getElementById("restorePasswordEmail");
    const restorePasswordEmailFeedback = document.getElementById("restorePasswordEmailFeedback");
    restorePasswordFormSubmit = async function () {
        let response = await fetch("?action=restore_password", {
            method: "POST",
            body: JSON.stringify({
                email: restorePasswordEmail.value,
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        restorePasswordEmail.classList.remove('is-valid', 'is-invalid');
        restorePasswordEmailFeedback.classList.remove('d-block');

        if (!response.ok) {
            const resp = await response.json();
            const errors = resp.errors;

            if (errors["general"] !== undefined && errors["general"] !== "") {
                gErrorToastText.innerText = errors["general"];
                gErrorToast.show();
                return
            }

            if (errors["email"] !== undefined && errors["email"] !== "") {
                restorePasswordEmail.classList.add('is-invalid');
                restorePasswordEmailFeedback.innerText = errors["email"];
                restorePasswordEmailFeedback.classList.add('d-block');
            } else {
                restorePasswordEmail.classList.add('is-valid');
            }

            return;
        }

        const resp = await response.json();
        restorePasswordSuccessModalBody.textContent = resp["message"];
        restorePasswordSuccessModal.show();
    }
    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>