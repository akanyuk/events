<?php
/**
 * @var string $session_id
 * @var integer $owner_id
 * @var string $owner_class
 * @var integer $MAX_FILE_SIZE
 * @var integer $MAX_SESSION_SIZE
 */
$langMedia = NFW::i()->getLang('media');
$langMain = NFW::i()->getLang('main');
?>
<div id="add-work-files-container"></div>

<div class="mb-3">
    <input type="file" id="add-work-files" multiple/>
</div>

<div class="mb-3 alert alert-warning">
    <div class="mb-1"><?php echo $langMedia['MaxFileSize'] ?>:
        <strong><?php echo number_format($MAX_FILE_SIZE / 1048576, 2, '.', ' ') ?>Mb</strong></div>
    <div class="mb-1"><?php echo $langMedia['MaxSessionSize'] ?>:
        <strong><?php echo number_format($MAX_SESSION_SIZE / 1048576, 2, '.', ' ') ?>Mb</strong></div>
    <div class="mb-1"><?php echo $langMedia['CurrentSessionSize'] ?>: <strong><span
                    id="add-work-session-size">0</span>Mb</strong></div>
</div>

<script type="text/javascript"><?php ob_start();?>
    const addWorkFilesContainer = document.getElementById("add-work-files-container");
    const addWorkFilesBtn = document.getElementById("add-work-files");
    const addWorkSessionSize = document.getElementById("add-work-session-size");

    addWorkFilesBtn.addEventListener('change', function () {
        if (this.files.length === 0) {
            return;
        }

        addWorkFilesBtn.setAttribute("disabled", "disabled");

        let waitResponses = this.files.length;
        let needReload = false;
        for (const file of this.files) {
            uploadFile(file).then(function () {
                needReload = true;

                waitResponses--;
                if (waitResponses === 0) {
                    afterUpload(true);
                }
            }).catch(err => {
                gErrorToastText.innerText = err;
                gErrorToast.show();

                waitResponses--;
                if (waitResponses === 0) {
                    afterUpload(needReload);
                }
            });
        }

        const afterUpload = function (needReload) {
            if (needReload) {
                loadWorkMedia();
            }
            addWorkFilesBtn.value = "";
            addWorkFilesBtn.removeAttribute("disabled");
        };
    });

    async function uploadFile(file) {
        let formData = new FormData();
        formData.append("local_file", file);
        formData.append("owner_class", "works");

        const response = await fetch('<?php echo NFW::i()->base_path . 'media.php?action=upload&session_id=' . $session_id?>', {
            method: "POST",
            body: formData
        });
        const resp = await response.text()
        const result = JSON.parse(resp.replace(/<textarea>/g, '').replace(/<\/textarea>/g, ''));

        if (result.result === 'error') {
            throw new Error(result.errors["local_file"]);
        }
    }

    async function loadWorkMedia() {
        const response = await fetch('<?php echo NFW::i()->base_path . 'media.php?action=list&session_id=' . $session_id . '&ts='?>' + new Date().getTime());
        const resp = await response.text()
        const result = JSON.parse(resp.replace(/<textarea>/g, '').replace(/<\/textarea>/g, ''));

        addWorkSessionSize.innerText = result['iSessionSize_str'];

        addWorkFilesContainer.innerHTML = "";
        result['aaData'].forEach(f => {
            let file = document.createElement('div');
            file.className = "d-flex gap-2 mb-3";

            let iconImg = document.createElement('img');
            if (f['type'] === "image") {
                iconImg.setAttribute("src", f['tmb_prefix'] + '64');
            } else {
                iconImg.setAttribute("src", f['icon_large']);
            }
            iconImg.setAttribute("alt", "");
            iconImg.style['min-width'] = '64px';
            file.appendChild(iconImg);

            let desc = document.createElement('div');
            desc.className = "w-100";

            let title = document.createElement('div');
            title.innerHTML = f.basename;
            desc.appendChild(title);

            let descSm = document.createElement('div');
            descSm.className = "text-muted small";

            let descSm1 = document.createElement('div');
            descSm1.innerHTML = "<?php echo $langMain['works filesize'] . ': '?>" + f['filesize_str'];
            descSm.appendChild(descSm1);

            desc.appendChild(descSm);
            file.appendChild(desc);

            const deleteLink = document.createElement('a');
            deleteLink.className = "text-danger";
            deleteLink.setAttribute("href", "javascript:void(0)");
            deleteLink.setAttribute("title", "Remove from uploads");
            deleteLink.innerHTML = '<svg width="1em" height="1em"><use href="#icon-x"></use></svg>';
            deleteLink.onclick = async function () {
                await fetch('<?php echo NFW::i()->base_path?>media.php?action=remove', {
                    method: "POST",
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'file_id=' + f['id']
                });

                await loadWorkMedia();
            };
            file.appendChild(deleteLink);

            addWorkFilesContainer.appendChild(file);
        });
    }
    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>

