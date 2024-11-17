<?php
/**
 * @var $comments array
 */

NFW::i()->registerFunction('friendly_date');
$lang_main = NFW::i()->getLang('main');
?>
<style>
    .latest-comments .work-title {
        font-weight: bold;
        white-space: nowrap;
        overflow: hidden;
    }

    .latest-comments .posted {
        white-space: nowrap;
        overflow: hidden;
    }

    .latest-comments .shadow {
        background: linear-gradient(to right, rgba(255, 255, 255, 0), rgba(255, 255, 255, 1) 60%);
        position: relative;
        top: -35px;
        float: right;
        width: 20px;
        height: 35px;
    }

    .latest-comments .message {
        padding-top: 5px;
        text-wrap: balance !important;
    }

    .latest-comments HR {
        margin-top: 10px;
        margin-bottom: 10px;
    }
</style>
<div class="latest-comments">
    <?php
    $counter = 0;
    foreach ($comments as $comment) {
        $url = NFW::i()->absolute_path . '/' . $comment['event_alias'] . '/' . $comment['competition_alias'] . '/' . $comment['work_id'] . '#comment' . $comment['id'];

        echo '<div class="work-title"><a href="' . $url . '" title="' . htmlspecialchars($comment['work_title']) . '">' . htmlspecialchars($comment['event_title'] . ' / ' . $comment['work_title']) . '</a></div>';
        echo '<div class="posted"><code>' . friendly_date($comment['posted'], $lang_main) . ' ' . date('H:i', $comment['posted']) . ' by ' . htmlspecialchars($comment['posted_username']) . '</code></div>';
        echo '<div class="shadow">&nbsp;</div>';
        echo '<div class="message">' . nl2br(htmlspecialchars($comment['message'])) . '</div>';
        echo $counter++ == count($comments) - 1 ? '' : '<hr />';
    }
    ?>
</div>