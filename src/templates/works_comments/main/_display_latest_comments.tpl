<?php
/**
 * @var $gComments array
 * @var $screenshots array
 */

NFW::i()->registerFunction('cache_media');
NFW::i()->registerFunction('friendly_date');

$noImage = NFW::i()->assets('main/current-event-large.png');
$langMain = NFW::i()->getLang('main');
?>
    <style>
        .card .blockquote {
            font-size: 1rem;
        }

        @media (min-width: 576px) {
            .card {
                flex-direction: row;
            }

            .card IMG {
                width: 200px;
                margin-top: 1em;
                margin-left: 1em;
                margin-bottom: auto;
                padding-bottom: 1em;
                border-radius: 0;
            }

            IMG.no-screenshot {
                opacity: 20%;
            }

            HR.comment-delimiter {
                display: none;
            }
        }

        @media (max-width: 575px) {
            .card {
                border: none;
            }

            IMG.no-screenshot {
                display: none;
            }
        }
    </style>
<?php foreach ($gComments as $workID => $w): ?>
    <div class="card mb-3">
        <img src="<?php echo isset($screenshots[$workID]) ? cache_media($screenshots[$workID]) : $noImage ?>"
             class="card-img-top <?php echo isset($screenshots[$workID]) ? '' : 'no-screenshot' ?>" alt="">
        <div class="card-body">
            <h5 class="card-title"><a
                        href="<?php echo $w['work_url'] ?>"><?php echo htmlspecialchars($w['title']) ?></a>
            </h5>

            <?php foreach ($w['items'] as $comment): ?>
                <figure>
                    <blockquote class="blockquote">
                        <?php echo nl2br(htmlspecialchars($comment['message'])) ?>
                    </blockquote>
                    <figcaption class="blockquote-footer">
                        <?php echo friendly_date($comment['posted'], $langMain) . ' ' . date('H:i', $comment['posted']) . ' ' . htmlspecialchars($comment['posted_username']) ?>
                    </figcaption>
                </figure>
            <?php endforeach; ?>
        </div>
    </div>
    <?php

    next($gComments);
    if (key($gComments) !== null && !isset($screenshots[key($gComments)])) {
        echo '<hr class="comment-delimiter"/>';
    }

endforeach;
