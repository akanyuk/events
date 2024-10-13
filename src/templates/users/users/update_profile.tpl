<?php
/**
 * @var users_ext $CUsers
 */

$langUsers = NFW::i()->getLang('users');
NFW::i()->assign('page_title', $langUsers['My profile']);

$attrs = $CUsers->attributes;
?>
<ul class="nav nav-underline ps-sm-5" role="tablist">
    <li class="nav-item" role="presentation">
        <button class="nav-link active" id="profile-tab" type="button" role="tab"
                data-bs-toggle="tab" data-bs-target="#profile"
                aria-controls="profile" aria-selected="true"><?php echo $langUsers['Profile tab'] ?></button>
    </li>
    <li class="nav-item" role="presentation">
        <button class="nav-link" id="password-tab" type="button" role="tab"
                data-bs-toggle="tab" data-bs-target="#password"
                aria-controls="password" aria-selected="true"><?php echo $langUsers['Password tab'] ?></button>
    </li>
</ul>

<div class="tab-content pt-4 ps-sm-5 d-grid mx-left col-sm-8 col-md-6 col-lg-4">
    <div class="tab-pane active" id="profile" role="tabpanel" aria-labelledby="home-tab" tabindex="0">
        <form>
            <fieldset>
                <dl>
                    <dt><?php echo $langUsers['Username'] ?></dt>
                    <dd><?php echo htmlspecialchars(NFW::i()->user['username']) ?></dd>

                    <dt>E-mail</dt>
                    <dd><?php echo htmlspecialchars(NFW::i()->user['email']) ?></dd>
                </dl>

                <div class="mb-3">
                    <label for="realname"><?php echo $attrs['realname']['desc'] ?></label>
                    <input data-role="updateProfileInput" id="realname" class="form-control"
                           type="text" required="required" maxlength="<?php echo $attrs['realname']['maxlength'] ?>"
                           value="<?php echo NFW::i()->user['realname'] ?>">
                    <div data-role="updateProfileFeedback" id="realname" class="invalid-feedback"></div>
                </div>

                <div class="mb-3">
                    <label for="language"><?php echo $attrs['language']['desc'] ?></label>
                    <select data-role="updateProfileInput" id="language" class="form-select">
                        <?php foreach ($attrs['language']['options'] as $lang): ?>
                            <option <?php echo NFW::i()->user['language'] == $lang ? 'selected="selected"' : '' ?>
                                    value="<?php echo $lang ?>"><?php echo $lang ?></option>
                        <?php endforeach; ?>
                    </select>
                    <div data-role="updateProfileFeedback" id="language" class="invalid-feedback"></div>
                </div>

                <div class="mb-3">
                    <label for="country"><?php echo $attrs['country']['desc'] ?></label>
                    <select data-role="updateProfileInput" id="country" class="form-select">
                        <option value=""></option>
                        <?php foreach ($attrs['country']['options'] as $country): ?>
                            <option <?php echo $country['id'] == NFW::i()->user['country'] ? 'selected="selected"' : '' ?>
                                    value="<?php echo $country['desc'] ?>"><?php echo $country['desc'] ?></option>
                        <?php endforeach; ?>
                    </select>
                    <div data-role="updateProfileFeedback" id="country" class="invalid-feedback"></div>
                </div>

                <div class="mb-3">
                    <label for="city"><?php echo $attrs['city']['desc'] ?></label>
                    <input data-role="updateProfileInput" id="city" class="form-control"
                           type="text" value="<?php echo NFW::i()->user['city'] ?>" maxlength="<?php echo $attrs['city']['maxlength'] ?>">
                    <div data-role="updateProfileFeedback" id="city" class="invalid-feedback"></div>
                </div>

                <div class="mb-3">
                    <button type="submit" class="btn btn-primary"><?php echo NFW::i()->lang['Save changes'] ?></button>
                </div>
            </fieldset>
        </form>
    </div>

    <div class="tab-pane" id="password" role="tabpanel" aria-labelledby="profile-tab" tabindex="0">
        <form>
            <fieldset>
                <div class="mb-3">
                    <label for="old_password"><?php echo $langUsers['Old password'] ?></label>
                    <input data-role="activateAccountInput" id="old_password" required="required" maxlength="64"
                           class="form-control" type="password">
                    <div data-role="activateAccountFeedback" id="password" class="invalid-feedback"></div>
                </div>

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
                    <button type="submit" class="btn btn-primary"><?php echo $langUsers['Save password'] ?></button>
                </div>
            </fieldset>
        </form>
    </div>
</div>

<script type="text/javascript">
    <?php ob_start(); ?>

    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>