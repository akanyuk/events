<?php
/**
 * @var users_ext $CUsers
 * @var string $defaultCountry
 * @var string $defaultCity
 */
$langUsers = NFW::i()->getLang('users');
NFW::i()->assign('page_title', $langUsers['Registration']);

$attrs = $CUsers->attributes;
//$successDialog->render(array('title' => $langUsers['Registration complete']));

/*<script type="text/javascript">
    $(document).ready(function () {
        var f = $('form[id="register"]');
        f.activeForm({
            'beforeSubmit': function (d, f, o) {
                // Reload captcha
                f.find('img[id="captcha"]').attr('src', '<?php echo NFW::i()->base_path?>captcha.png?' + +Math.floor(Math.random() * 10000000));
            },
            'error': function (response) {
                f.find('input[name="captcha"]').val('');
            },
            'success': function (response) {
                $(document).trigger('show-<?php echo $successDialog->getID()?>', [response.message]);
            }
        });

        $(document).on('hide-<?php echo $successDialog->getID()?>', function () {
            window.location.href = '/';
        });
    });
</script>
*/
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
            <select class="form-select">
                <?php foreach ($attrs['language']['options'] as $lang): ?>
                    <option <?php echo NFW::i()->user['language'] == $lang ? 'selected="selected"' : '' ?>
                            value="<?php echo $lang ?>"><?php echo $lang ?></option>
                <?php endforeach; ?>
            </select>
        </div>

        <div class="mb-3">
            <label for="country"><?php echo $attrs['country']['desc'] ?></label>
            <select class="form-select">
                <option value=""></option>
                <?php foreach ($attrs['country']['options'] as $country): ?>
                    <option <?php echo $country['id'] == $defaultCountry ? 'selected="selected"' : '' ?>
                            value="<?php echo $country['desc'] ?>"><?php echo $country['desc'] ?></option>
                <?php endforeach; ?>
            </select>
        </div>

        <div class="mb-3">
            <label for="city"><?php echo $attrs['city']['desc'] ?></label>
            <input data-role="registerInput" id="city" class="form-control"
                   type="text" value="<?php echo $defaultCity ?>" maxlength="<?php echo $attrs['city']['maxlength'] ?>">
            <div data-role="registerFeedback" id="city" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="captcha"><?php echo NFW::i()->lang['Captcha'] ?></label>
            <div class="input-group">
                <input id="restorePasswordCaptcha" type="text" required="required" maxlength="6"
                       class="form-control" style="font-family: monospace; font-weight: bold;"/>
                <img id="restorePasswordCaptchaImg" src="<?php echo NFW::i()->base_path ?>captcha.png" alt=""/>
            </div>
            <div data-role="registerFeedback" id="captcha" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <button type="submit" class="btn btn-primary"><?php echo $langUsers['Registration send'] ?></button>
        </div>
    </fieldset>
</form>

<script type="text/javascript">
    <?php ob_start(); ?>
    registerFormSubmit = async function () {
        // TODO: add realization
        window.location.href = '/';
    }

    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>