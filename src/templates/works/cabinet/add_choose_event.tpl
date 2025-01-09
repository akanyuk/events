<?php
/**
 * @var array $events
 */
$langMain = NFW::i()->getLang('main');
NFW::i()->assign('page_title', $langMain['cabinet add choose event']);
?>
<div class="d-grid mx-auto col-sm-10 col-md-8">
    <h2 class="index-head mb-5"><?php echo $langMain['cabinet add choose event'] ?></h2>

    <div class="row"><?php foreach ($events as $record): ?>
            <div class="col-md-6 col-sm-12 col-xs-12 gap-3">
                <div class="text-center">
                    <a href="<?php echo NFW::i()->base_path?>cabinet/works_add?event=<?php echo $record['alias'] ?>">
                        <img alt="" src="<?php echo $record['preview_img'] ?>"/>
                    </a>
                    <h3>
                        <a href="<?php echo NFW::i()->base_path?>cabinet/works_add?event=<?php echo $record['alias'] ?>"><?php echo htmlspecialchars($record['title']) ?></a>
                    </h3>
                    <p><?php echo $record['dates_desc'] ?></p>
                </div>
            </div>
        <?php endforeach; ?>
    </div>
</div>
