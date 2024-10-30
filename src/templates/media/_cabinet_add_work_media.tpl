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
<div id="work-files-container"></div>
<h3><?php echo $langMain['works add files'] ?></h3>

<div class="mb-3">
    <input type="file" id="add-files-file" multiple/>
</div>

<div class="mb-3">
    <div class="alert alert-warning">
        <div><?php echo $langMedia['MaxFileSize'] ?>:
            <strong><?php echo number_format(NFW::i()->cfg['media']['MAX_FILE_SIZE'] / 1048576, 2, '.', ' ') ?>
                Mb</strong></div>
    </div>
</div>

<script type="text/javascript"><?php ob_start();?>

    const workFilesContainer = document.getElementById("work-files-container");

    loadWorkMedia();

    function loadWorkMedia() {
        fetch('<?php echo NFW::i()->base_path . 'cabinet/works_media?action=list&work_id=' . $owner_id?>').then(response => response.json()).then(response => {
            workFilesContainer.innerHTML = "";

            response['files'].forEach(f => {
                let file = document.createElement('div');
                file.className = "d-flex gap-3 mb-3";

                let iconContainer = document.createElement('div');
                iconContainer.className = "text-center";

                let iconA = document.createElement('a');
                iconA.setAttribute("href", f.url);

                let iconImg = document.createElement('img');
                iconImg.setAttribute("src", f.icon);
                iconImg.setAttribute("alt", "");
                iconA.appendChild(iconImg);

                iconContainer.appendChild(iconA);

                let status = document.createElement('div');
                status.className = "d-flex justify-content-center gap-1";
                status.appendChild(statusIcon('<?php echo $langMain['filestatus screenshot'] ?>', f['isScreenshot'], 'media-screenshot'));
                status.appendChild(statusIcon('<?php echo $langMain['filestatus image'] ?>', f['isImage'], 'media-image'));
                status.appendChild(statusIcon('<?php echo $langMain['filestatus audio'] ?>', f['isAudio'], 'media-audio'));
                status.appendChild(statusIcon('<?php echo $langMain['filestatus voting'] ?>', f['isVoting'], 'media-voting'));
                status.appendChild(statusIcon('<?php echo $langMain['filestatus release'] ?>', f['isRelease'], 'media-release'));
                iconContainer.appendChild(status);

                file.appendChild(iconContainer);

                let desc = document.createElement('div');
                desc.className = "w-100";

                let descA = document.createElement('a');
                descA.setAttribute("href", f.url);
                descA.innerText = f.basename;
                desc.appendChild(descA);

                let descSm = document.createElement('div');
                descSm.className = "text-muted small";

                let descSm1 = document.createElement('div');
                descSm1.innerText = "<?php echo $langMain['works uploaded'] . ': '?>" + f['postedBy'];
                descSm.appendChild(descSm1);

                let descSm2 = document.createElement('div');
                descSm2.innerText = "<?php echo $langMain['works filesize'] . ': '?>" + f['filesize'];
                descSm.appendChild(descSm2);

                desc.appendChild(descSm);

                file.appendChild(desc);

                workFilesContainer.appendChild(file);
            });
        });
    }

    function statusIcon(title, isActive, icon) {
        let st = document.createElement('div');
        st.setAttribute("title", title);

        let svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
        svg.classList.add(isActive ? 'text-success' : 'text-muted');
        svg.style.width = '1em';
        svg.style.height = '1em';

        let use = document.createElementNS('http://www.w3.org/2000/svg', 'use');
        use.setAttribute("href", "#" + icon);
        svg.appendChild(use);

        st.appendChild(svg);
        return st;
    }

    document.getElementById("add-files-file").addEventListener('change', function () {
        for (const file of this.files) {
            let formData = new FormData();
            formData.append("file", file);

            fetch('<?php echo NFW::i()->base_path . 'cabinet/works_media?action=add&work_id=' . $owner_id?>', {
                method: "POST",
                body: formData
            }).then(response => response.json()).then(response => {
                console.log('response', response);
            });
        }
    });

    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>
