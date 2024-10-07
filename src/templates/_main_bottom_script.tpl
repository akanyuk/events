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
    const gSuccessToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('successToast'));
    const gAcceptedToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('acceptedToast'));
    const gCanceledToast = bootstrap.Toast.getOrCreateInstance(document.getElementById('canceledToast'));

    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
    [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));

    <?php if (NFW::i()->user['is_guest']): ?>
    $('form[id="login-form"]').activeForm({
        cleanErrors: function () {
            $(this).find('#result').text('');
        },
        error: function (response) {
            $('form[id="login-form"]').find('#result').text(response.errors['password']);
        },
        success: function (response) {
            if (response.redirect) {
                window.location.href = response.redirect;
            } else {
                window.location.reload();
            }
        }
    });
    <?php endif; ?>

    document.querySelectorAll("#work-frames-nav a").forEach((activeFrameA) => {
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

    document.querySelectorAll("#work-frames-nav").forEach((frm) => {
        frm.querySelector('a').click();
    });

    <?php echo NFWX::i()->mainBottomScript?>

    <?php /* ?>
     $('input[id="works-search"]').typeahead({
        source: function (query, process) {
            return $.get('/works?action=search&q=' + query, function (response) {
                return process(response);
            }, 'json');
        },
        displayText: function (item) {
            return item.title;
        },
        afterSelect: function (sResult) {
            $('input[id="works-search"]').val('');

            if (sResult.link) {
                window.location.href = sResult.link;
            }
        },
        fitToElement: true,
        items: 'all',
        minLength: 1
    }).attr('autocomplete', 'off');

    // Stop other audio's
    $('audio').bind('play', function () {
        for (const player of document.getElementsByTagName('audio')) {
            if (player !== this) {
                player.pause();
                player.currentTime = 0;
            }
        }
    });
<?php */ ?>
</script>