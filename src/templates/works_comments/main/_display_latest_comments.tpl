<?php
/**
 * @var $comments array
 */
NFW::i()->registerFunction('cache_media');

$noImage = NFW::i()->assets('main/current-event-large.png');
//$noImage = NFW::i()->assets('main/news-no-image.png');
$worksID = [];
$screenshots = [];
foreach ($comments as $comment) {
    $worksID[] = $comment['work_id'];
    $screenshots[$comment['work_id']] = $noImage;
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
        $screenshots[$work['id']] = cache_media($work['screenshot']);
    }
}

NFW::i()->registerFunction('friendly_date');
$langMain = NFW::i()->getLang('main');
?>
    <style>
        .card {
            flex-direction: row;
        }

        .card IMG {
            max-width: 25%;
            margin-top: 1em;
            margin-left: 1em;
            margin-bottom: auto;
            border-radius: 0.7em;
        }
    </style>
<?php foreach ($comments as $comment): ?>
    <div class="card mb-3">
        <img src="<?php echo $screenshots[$comment['work_id']] ?>" class="card-img-top" alt="...">
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

<?php foreach ($comments as $comment): ?>
    <div class="card mb-3">
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