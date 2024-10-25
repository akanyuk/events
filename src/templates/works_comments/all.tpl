<?php
/**
 * @var $comments array
 * @var $screenshots array
 * @var $pagingLinks string
 */
$langMain = NFW::i()->getLang('main');
NFW::i()->assign('page_title', $langMain['comments']);

NFW::i()->registerFunction('cache_media');
NFW::i()->registerFunction('friendly_date');
$noImage = NFW::i()->assets('main/current-event-large.png');
?>
<div class="d-grid mx-auto col-sm-10 col-md-8 col-lg-6">
    <h1 class="px-3 mb-3"><?php echo $langMain['comments'] ?></h1>
    <?php foreach ($comments as $workID => $w): ?>
        <div class="card card-comment mb-3">
            <a href="<?php echo $w['work_url'] ?>"><img
                        src="<?php echo isset($screenshots[$workID]) ? cache_media($screenshots[$workID]) : $noImage ?>"
                        class="card-img-top px-3 <?php echo isset($screenshots[$workID]) ? '' : 'no-screenshot' ?>"
                        alt=""></a>
            <div class="card-body pt-md-0">
                <p class="lead"><a
                            href="<?php echo $w['work_url'] ?>"><?php echo htmlspecialchars($w['title']) ?></a>
                </p>

                <?php foreach ($w['items'] as $comment): ?>
                    <figure>
                        <blockquote class="blockquote">
                            <?php echo nl2br(htmlspecialchars($comment['message'])) ?>
                        </blockquote>
                        <figcaption class="blockquote-footer">
                            <?php echo friendly_date($comment['posted'], $langMain) . ' by ' . date('H:i', $comment['posted']) . ' ' . htmlspecialchars($comment['posted_username']) ?>
                        </figcaption>
                    </figure>
                <?php endforeach; ?>
            </div>
        </div>
        <?php

        next($comments);
        if (key($comments) !== null && !isset($screenshots[key($comments)])) {
            echo '<hr class="comment-delimiter"/>';
        }

    endforeach;

    echo $pagingLinks;
    ?>
</div>