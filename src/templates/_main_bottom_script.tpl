<?php
/**
 * @var $theme string
 */
?>
<script>
    <?php if ($theme == 'auto'): ?>
    const theme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    document.documentElement.setAttribute('data-bs-theme', theme);
    const date = new Date();
    date.setTime(date.getTime() + (365 * 24 * 60 * 60 * 1000));
    document.cookie = "theme=" + theme + "; domain=<?php echo NFW::i()->cfg['cookie']['domain']?>; path=/; expires=" + date.toUTCString();
    <?php endif; ?>

    <?php if (NFW::i()->user['is_guest']): ?>
    $('form[id="login-form"]').activeForm({
        cleanErrors: function() {
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


        $('#work-frames-nav a').click(function (e) {
            e.preventDefault();

            const container = $(this).closest('.work-container');
            const iframeContainer = container.find('#work-iframe');
            const nav = container.find('#work-frames-nav');
            const iframeHTML = $(this).data('iframe');

            nav.find('a').removeClass('active');
            $(this).closest('a').addClass('active');

            iframeContainer.empty().html(iframeHTML);
        })
        $('[id="work-frames-nav"]').each(function(i, obj){
            $(obj).find('a:first').trigger('click');
        });

    /*
        if ($.blockUI) {
            $.blockUI.defaults.message = null;
            $.blockUI.defaults.fadeOut = 0;
            $.blockUI.defaults.fadeIn = 0;
            $.blockUI.defaults.timeout = 10000;
            $.blockUI.defaults.overlayCSS.backgroundColor = '#26f';
            $.blockUI.defaults.overlayCSS.opacity = 0.4;
            $.blockUI.defaults.baseZ = 2000;
            $(document).ajaxStart($.blockUI).ajaxStop($.unblockUI);
        }

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
*/
</script>