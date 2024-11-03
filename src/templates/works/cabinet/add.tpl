<?php
/**
 * @var works $Module
 * @var array $event
 * @var array $competition
 */
NFW::i()->registerResource('bootstrap5.typeahead');

$langMain = NFW::i()->getLang('main');
NFW::i()->assign('page_title', $langMain['cabinet add work']);

NFW::i()->breadcrumb = array(
    array('desc' => $event['title'], 'url' => $event['alias']),
);
if ($competition) {
    NFW::i()->breadcrumb[] = array('desc' => $langMain['cabinet add work'], 'url' => 'upload/' . $event['alias']);
} else {
    NFW::i()->breadcrumb[] = array('desc' => $langMain['cabinet add work']);
}

NFWX::i()->mainContainerAdditionalClasses = 'd-grid mx-auto col-sm-10 col-md-8';
?>
<?php if ($competition): ?>
    <h3><?php echo htmlspecialchars($competition['title']) ?></h3>
    <div class="mb3"><?php echo $competition['announcement'] ?></div>
<?php endif; ?>

<form onsubmit="addWorkFormSubmit(); return false;">
    <fieldset>
        <?php if ($competition): ?>
            <input data-role="addWorkInput" id="competition_id" type="hidden"
                   value="<?php echo $competition['id'] ?>"/>
        <?php else: ?>
            <div class="mb-3">
                <label for="competition_id"><?php echo $langMain['competition'] ?></label>
                <select data-role="addWorkInput" id="competition_id" class="form-select">
                    <?php foreach ($Module->attributes['competition_id']['options'] as $i): ?>
                        <option value="<?php echo $i['id'] ?>"><?php echo $i['desc'] ?></option>
                    <?php endforeach; ?>
                </select>
                <div data-role="addWorkFeedback" id="competition_id" class="invalid-feedback"></div>
            </div>
        <?php endif; ?>

        <div class="mb-3">
            <label for="title"><?php echo $langMain['works title'] ?></label>
            <input data-role="addWorkInput" id="title" class="form-control"
                   type="text" required="required"
                   maxlength="<?php echo $Module->attributes['title']['maxlength'] ?>">
            <div data-role="addWorkFeedback" id="title" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="title"><?php echo $langMain['works author'] ?></label>
            <input data-role="addWorkInput" id="author" class="form-control"
                   type="text" required="required"
                   maxlength="<?php echo $Module->attributes['author']['maxlength'] ?>">
            <div data-role="addWorkFeedback" id="author" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="title"><?php echo $langMain['works platform'] ?></label>
            <input data-role="addWorkInput" id="platform" class="form-control"
                   type="text" required="required"
                   maxlength="<?php echo $Module->attributes['platform']['maxlength'] ?>">
            <div data-role="addWorkFeedback" id="platform" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="format"><?php echo $langMain['works format'] ?></label>
            <input data-role="addWorkInput" id="format" class="form-control"
                   type="text" maxlength="<?php echo $Module->attributes['format']['maxlength'] ?>">
            <div data-role="addWorkFeedback" id="format" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="description_public"><?php echo $langMain['works description public'] ?></label>
            <textarea data-role="addWorkInput" id="description_public" class="form-control"></textarea>
            <div data-role="addWorkFeedback" id="description_public" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <h5><?php echo $langMain['works description refs'] ?></h5>
            <?php $isFirst = true;
            foreach ($langMain['works description refs options'] as $o) { ?>
                <div class="form-check">
                    <label class="form-check-label">
                        <input type="radio" class="form-check-input" name="description_refs"
                               data-role="addWorkInput" id="description_refs"
                               value="<?php echo $o ?>" <?php echo $isFirst ? 'checked="checked"' : '' ?>/>
                        <?php echo $o ?>
                    </label>
                </div>
                <?php $isFirst = false;
            } ?>
            <div data-role="addWorkFeedback" id="description_refs" class="invalid-feedback"></div>
        </div>

        <div class="mb-3">
            <label for="description"><?php echo $langMain['works description'] ?></label>
            <textarea data-role="addWorkInput" id="description" class="form-control"></textarea>
            <div data-role="addWorkFeedback" id="description" class="invalid-feedback"></div>
        </div>

        <?php echo NFWX::i()->hook("works_add_form_append", $event['alias']) ?>

        <div class="mb-3">
            <?php
            $CMedia = new media();
            echo $CMedia->openSession(array(
                'owner_class' => get_class($Module),
                'secure_storage' => true,
                'template' => '_cabinet_add_work',
            ));
            ?>
        </div>

        <div class="alert alert-info mb-3"><?php echo $langMain['works upload info'] ?></div>

        <div class="mb-3">
            <button type="submit" class="btn btn-lg btn-success"><?php echo $langMain['works send'] ?></button>
        </div>
    </fieldset>
</form>

<div id="add-work-success-modal" class="modal fade"
     data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><?php echo $langMain['works upload success title'] ?></h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div id="add-work-success-modal-body" class="modal-body"></div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary"
                        data-bs-dismiss="modal"><?php echo NFW::i()->lang['Close'] ?></button>
            </div>
        </div>
    </div>
</div>

<script type="module">
    const platforms = [];
    <?php foreach ($Module->attributes['platform']['options'] as $platform): ?>
    platforms.push({title: '<?php echo $platform?>'});
    <?php endforeach; ?>
    Autocomplete.init("input#platform", {
        items: platforms,
        valueField: "title",
        labelField: "title",
        highlightTyped: true
    });
</script>

<script type="text/javascript">
    <?php ob_start(); ?>

    const addWorkSuccessModalBody = document.getElementById("add-work-success-modal-body");
    const addWorkSuccessModal = new bootstrap.Modal('#add-work-success-modal');
    document.getElementById("add-work-success-modal").addEventListener('hidden.bs.modal', function () {
        window.location.href = '<?php echo NFW::i()->base_path?>cabinet/works_list';
    })

    const addWorkFormSubmit = async function () {
        let post = {};
        document.querySelectorAll('[data-role="addWorkInput"]').forEach(item => {
            item.classList.remove('is-valid', 'is-invalid');
            post[item.id] = item.value;
        });

        document.querySelectorAll('[data-role="addWorkInput"]:checked').forEach(item => {
            item.classList.remove('is-valid', 'is-invalid');
            post[item.id] = item.value;
        });

        document.querySelectorAll('[data-role="addWorkFeedback"]').forEach(item => {
            item.classList.remove('d-block');
        });

        let response = await fetch("?action=upload_work", {
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

                document.querySelector('[data-role="addWorkInput"][id=' + key + ']').classList.add('is-invalid');
                document.querySelector('[data-role="addWorkFeedback"][id=' + key + ']').innerText = errors[key];
                document.querySelector('[data-role="addWorkFeedback"][id=' + key + ']').classList.add('d-block');
            });

            document.querySelectorAll('[data-role="addWorkInput"]').forEach(item => {
                if (!item.classList.contains('is-invalid')) {
                    item.classList.add('is-valid');
                }
            });

            return;
        }

        const resp = await response.json();
        addWorkSuccessModalBody.textContent = resp["message"];
        addWorkSuccessModal.show();
    }

    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>