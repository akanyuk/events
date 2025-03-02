<?php
/**
 * @var $comments array
 * @var $screenshots array
 */

NFW::i()->registerFunction('cache_media');
NFW::i()->registerFunction('friendly_date');

$noImage = NFW::i()->assets('main/current-event-large.png');
$langMain = NFW::i()->getLang('main');
foreach ($comments as $workID => $w): ?>
    <div class="card card-comment mb-3">
        <a href="<?php echo $w['work_url'] ?>"><img src="<?php echo isset($screenshots[$workID]) ? cache_media($screenshots[$workID]) : $noImage ?>"
                                                    class="card-img-top mt-0 mt-md-2 pe-md-3 <?php echo isset($screenshots[$workID]) ? '' : 'no-screenshot' ?>" alt=""></a>
        <div class="card-body px-0 pt-md-0">
            <p class="lead"><a
                        href="<?php echo $w['work_url'] ?>"><?php echo htmlspecialchars($w['display_title']) ?></a>
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
