<script>
    // Stop other audio's
    $('audio').bind('play', function () {
        for (const player of document.getElementsByTagName('audio')) {
            if (player !== this) {
                player.pause();
                player.currentTime = 0;
            }
        }
    });
</script>