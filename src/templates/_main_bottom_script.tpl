<?php
/**
 * @var $theme string
 */
?>
<div class="toast-container position-fixed top-0 start-50 translate-middle-x" style="top: 44px !important;">
    <div id="acceptedToast" class="toast text-bg-success"
         role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="800">
        <div class="toast-body text-center">Accepted</div>
    </div>

    <div id="canceledToast" class="toast text-bg-info"
         role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="800">
        <div class="toast-body text-center">Cancelled</div>
    </div>

    <div id="successToast" class="toast text-bg-success"
         role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="2000">
        <div class="d-flex">
            <div id="successToast-text" class="toast-body"></div>
            <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    </div>

    <div id="errorToast" class="toast text-bg-danger"
         role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="2000">
        <div class="d-flex">
            <div id="errorToast-text" class="toast-body"></div>
            <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    </div>
</div>
<script>
    <?php if ($theme == 'auto'): ?>
    const theme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    document.documentElement.setAttribute('data-bs-theme', theme);
    const date = new Date();
    date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
    document.cookie = "theme=" + theme + "; domain=<?php echo NFW::i()->cfg['cookie']['domain']?>; path=/; expires=" + date.toUTCString();
    <?php endif; ?>

    const gErrorToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('errorToast'));
    const gErrorToastText = document.getElementById('errorToast-text');

    const gSuccessToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('successToast'));
    const gSuccessToastText = document.getElementById('successToast-text');

    const gAcceptedToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('acceptedToast'));
    const gCanceledToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('canceledToast'));

    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));

    <?php if (NFW::i()->user['is_guest']): ?>
    const loginUsername = document.getElementById("login-username");
    const loginPassword = document.getElementById("login-password");
    const loginFeedback = document.getElementById("login-feedback");
    loginFormSubmit = async function () {
        let response = await fetch("?action=login", {
            method: "POST",
            body: JSON.stringify({
                username: loginUsername.value,
                password: loginPassword.value
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        if (!response.ok) {
            const resp = await response.json();
            const errors = resp.errors;

            loginUsername.classList.add('is-invalid');
            loginPassword.classList.add('is-invalid');

            if (errors["general"] !== undefined && errors["general"] !== "") {
                loginFeedback.innerText = errors["general"];
                loginFeedback.className = 'invalid-feedback d-block';
            }

            return;
        }

        window.location.reload();
    }
    <?php endif; ?>

    document.querySelectorAll("#work-frames-nav a").forEach(activeFrameA => {
        activeFrameA.onclick = function (e) {
            e.preventDefault();

            const container = activeFrameA.closest('.work-container');
            const iframeContainer = container.querySelector('#work-iframe');
            iframeContainer.innerHTML = activeFrameA.getAttribute('data-iframe');

            const nav = activeFrameA.closest('#work-frames-nav');
            nav.querySelectorAll("a").forEach((frameA) => {
                frameA.classList.remove("active");
            });
            activeFrameA.classList.add("active");
        }
    });
    document.querySelectorAll("#work-frames-nav").forEach(frm => {
        frm.querySelector('a').click();
    });

    // Stop other audio's
    for (const player of document.getElementsByTagName('audio')) {
        player.onplay = function () {
            for (const p of document.getElementsByTagName('audio')) {
                if (p !== player) {
                    p.pause();
                    p.currentTime = 0;
                }
            }
        }
    }

    <?php echo NFWX::i()->mainBottomScript?>
</script>