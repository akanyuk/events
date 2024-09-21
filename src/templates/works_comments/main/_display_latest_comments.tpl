<?php
/**
 * @var $comments array
 */
NFW::i()->registerFunction('cache_media');

$noImage = NFW::i()->assets('main/current-event-large.png');
$worksID = [];
$screenshots = [];
foreach ($comments as $comment) {
    $worksID[] = $comment['work_id'];
    $screenshots[$comment['work_id']] = [
        'class' => 'no-screenshot',
        'url' => $noImage
    ];
}
$CWorks = new works();
$works = $CWorks->getRecords([
    'filter' => [
        'work_id' => array_unique($worksID)
    ],
    'skip_pagination' => true,
    'load_attachments' => true,
]);

foreach ($works as $work) {
    if ($work['screenshot']) {
        $screenshots[$work['id']] = [
            'class' => '',
            'url' => cache_media($work['screenshot'])
        ];
    }
}

NFW::i()->registerFunction('friendly_date');
$langMain = NFW::i()->getLang('main');
?>
    <style>
        @media (min-width: 576px) {
            .card {
                flex-direction: row;
            }

            .card IMG {
                width: 200px;
                margin-top: 1em;
                margin-left: 1em;
                margin-bottom: auto;
                border-radius: 0.7em;
            }

            IMG.no-screenshot {
                opacity: 20%;
            }
        }

        @media (max-width: 575px) {
            .card {
                border-top: none;
                border-left: none;
                border-right: none;
            }

            .card IMG {
                border-radius: 0;
            }

            IMG.no-screenshot {
                display: none;
            }
        }
    </style>
<?php foreach ($comments as $comment): ?>
    <div class="card mb-3">
        <img src="<?php echo $screenshots[$comment['work_id']]['url'] ?>"
             class="card-img-top <?php echo $screenshots[$comment['work_id']]['class'] ?>" alt="">
        <div class="card-body">
            <h5 class="card-title"><a
                        href="<?php echo NFW::i()->absolute_path . '/' . $comment['event_alias'] . '/' . $comment['competition_alias'] . '/' . $comment['work_id'] . '#comment' . $comment['id'] ?>"
                        title="<?php echo htmlspecialchars($comment['work_title']) ?>"><?php echo htmlspecialchars($comment['event_title'] . ' / ' . $comment['work_title']) ?></a>
            </h5>
            <h6 class="card-subtitle mb-2 text-muted"><?php echo friendly_date($comment['posted'], $langMain) . ' ' . date('H:i', $comment['posted']) . ' by ' . htmlspecialchars($comment['posted_username']) ?></h6>
            <p class="card-text"><?php echo nl2br(htmlspecialchars($comment['message'])) ?></p>
        </div>
    </div>
<?php endforeach; ?>
