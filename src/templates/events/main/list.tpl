<?php
/**
 * @var array $events
 */
?>
<div class="d-grid mx-auto col-lg-8">
    <?php foreach ($events as $record): ?>
        <div class="table-row">
            <div class="align-top text-left" style="display: table-cell; width: 80px;"><a
                    href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><img class="media-object"
                                                                                     src="<?php echo $record['preview_img'] ?>"
                                                                                     alt=""/></a>
            </div>
            <div class="align-middle text-left" style="display: table-cell;"><h4><a
                        href="<?php echo NFW::i()->base_path . $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                </h4>
                <div class="text-muted"><?php echo $record['dates_desc'] ?></div>
            </div>
        </div>
        <div class="mb-5"><?php echo nl2br($record['announcement']) ?></div>
    <?php endforeach; ?>
</div>