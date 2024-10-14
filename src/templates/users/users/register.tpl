<?php
/**
 * @var users_ext $CUsers
 * @var string $defaultCountry
 * @var string $defaultCity
 */
$langUsers = NFW::i()->getLang('users');
NFW::i()->assign('page_title', $langUsers['Registration']);

$attrs = $CUsers->attributes;
?>
<form onsubmit="registerFormSubmit(); return false;" class="d-grid mx-auto col-sm-8 col-md-6 col-lg-4">
    <fieldset>
        <legend><?php echo $langUsers['Registration'] ?></legend>

        <div class="mb-3">
            <label for="username"><?php echo NFW::i()->lang['Login'] ?></label>
            <input data-role="registerInput" id="username" class="form-control"
                   type="text" required="required" maxlength="<?php echo $attrs['username']['maxlength'] ?>">
            <div data-role="registerFeedback" id="username" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="email">E-mail</label>
            <input data-role="registerInput" id="email" class="form-control"
                   type="email" required="required">
            <div data-role="registerFeedback" id="email" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="realname"><?php echo $attrs['realname']['desc'] ?></label>
            <input data-role="registerInput" id="realname" class="form-control"
                   type="text" required="required" maxlength="<?php echo $attrs['realname']['maxlength'] ?>">
            <div data-role="registerFeedback" id="realname" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="language"><?php echo $attrs['language']['desc'] ?></label>
            <select data-role="registerInput" id="language" class="form-select">
                <?php foreach ($attrs['language']['options'] as $lang): ?>
                    <option <?php echo NFW::i()->user['language'] == $lang ? 'selected="selected"' : '' ?>
                            value="<?php echo $lang ?>"><?php echo $lang ?></option>
                <?php endforeach; ?>
            </select>
            <div data-role="registerFeedback" id="language" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="country"><?php echo $attrs['country']['desc'] ?></label>
            <select data-role="registerInput" id="country" class="form-select">
                <option value=""></option>
                <?php foreach ($attrs['country']['options'] as $country): ?>
                    <option <?php echo $country['id'] == $defaultCountry ? 'selected="selected"' : '' ?>
                            value="<?php echo $country['desc'] ?>"><?php echo $country['desc'] ?></option>
                <?php endforeach; ?>
            </select>
            <div data-role="registerFeedback" id="country" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="city"><?php echo $attrs['city']['desc'] ?></label>
            <input data-role="registerInput" id="city" class="form-control"
                   type="text" value="<?php echo $defaultCity ?>" maxlength="<?php echo $attrs['city']['maxlength'] ?>">
            <div data-role="registerFeedback" id="city" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <button type="submit" class="btn btn-primary"><?php echo $langUsers['Registration send'] ?></button>
        </div>
    </fieldset>
</form>

<div id="registerSuccessModal" class="modal fade"
     data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><?php echo $langUsers['Registration complete'] ?></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div id="registerSuccessModalBody" class="modal-body"></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary"
                        data-bs-dismiss="modal"><?php echo NFW::i()->lang['Close'] ?></button>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    <?php ob_start(); ?>
    const registerSuccessModalBody = document.getElementById("registerSuccessModalBody");
    const registerSuccessModal = new bootstrap.Modal('#registerSuccessModal');
    document.getElementById("registerSuccessModal").addEventListener('hidden.bs.modal', function () {
        window.location.href = '/';
    })

    registerFormSubmit = async function () {
        let post = {};
        document.querySelectorAll('[data-role="registerInput"]').forEach(item => {
            item.classList.remove('is-valid', 'is-invalid');
            post[item.id] = item.value;
        });

        document.querySelectorAll('[data-role="registerFeedback"]').forEach(item => {
            item.classList.remove('d-block');
        });

        let response = await fetch("?action=register", {
            method: "POST",
            body: JSON.stringify(post),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        if (!response.ok) {
            const resp = await response.json();
            const errors = resp.errors;

            Object.keys(errors).forEach(function (key) {
                if (key === 'general') {
                    gErrorToastText.innerText = errors["general"];
                    gErrorToast.show();
                    return;
                }

                document.querySelector('[data-role="registerInput"][id=' + key + ']').classList.add('is-invalid');
                document.querySelector('[data-role="registerFeedback"][id=' + key + ']').innerText = errors[key];
                document.querySelector('[data-role="registerFeedback"][id=' + key + ']').classList.add('d-block');
            });

            document.querySelectorAll('[data-role="registerInput"]').forEach(item => {
                if (!item.classList.contains('is-invalid')) {
                    item.classList.add('is-valid');
                }
            });

            return;
        }

        const resp = await response.json();
        registerSuccessModalBody.textContent = resp["message"];
        registerSuccessModal.show();
    }

    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>