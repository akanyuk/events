<?php
/**
 * @var string $searchString
 * @var string $pagingLinks
 * @var array $works
 */

NFW::i()->registerFunction('cache_media');

$langMain = NFW::i()->getLang('main');
NFW::i()->assign('page_title', $langMain['Search']);
$noImage = NFW::i()->assets('main/current-event-large.png');
?>
<div class="d-grid mx-auto col-sm-10 col-md-8">
    <form class="mb-3" action="<?php echo NFW::i()->base_path ?>works/search">
        <div class="input-group">
            <input type="search" name="q" value="<?php echo $searchString ?>"
                   class="form-control" placeholder="<?php echo $langMain['search hint'] ?>">
            <button type="submit" class="btn btn-secondary">
                <svg width="1.5em" height="1.2em">
                    <use href="#icon-search"></use>
                </svg>
            </button>
        </div>
    </form>

    <?php if ($searchString && empty($works)): ?>
        <div class="alert alert-info"><?php echo $langMain['Search nothing found'] ?></div>
    <?php elseif ($searchString): ?>
        <?php foreach ($works as $work):
            $url = NFW::i()->absolute_path . '/' . $work['event_alias'] . '/' . $work['competition_alias'] . '/' . $work['id'];
            $title = $work['title'] . ' by ' . $work['author'];

            $platformFormat = '<div class="badge badge-platform me-1 mb-2" title="' . $langMain['works platform'] . '">' . htmlspecialchars($work['platform']) . '</div>';
            if ($work['format']) {
                $platformFormat .= '<div class="badge badge-format" title="' . $langMain['works format'] . '">' . htmlspecialchars($work['format']) . '</div>';
            }

            switch ($work['place']) {
                case 0:
                    $ePrefix = '';
                    break;
                case 1:
                    $ePrefix = '<strong>'.$work['place'] . 'st</strong>&nbsp;at ';
                    break;
                case 2:
                    $ePrefix = '<strong>'.$work['place'] . 'nd</strong>&nbsp;at ';
                    break;
                case 3:
                    $ePrefix = '<strong>'.$work['place'] . 'rd</strong>&nbsp;at ';
                    break;
                default:
                    $ePrefix = '<strong>'.$work['place'] . 'th</strong>&nbsp;at ';
                    break;
            }

            ?>
            <div class="card card-comment mb-3">
                <a href="<?php echo $url ?>"><img
                            src="<?php echo $work['screenshot'] ? cache_media($work['screenshot']) : $noImage ?>"
                            class="card-img-top mt-0 mt-md-2 pe-md-3 <?php echo $work['screenshot'] ? '' : 'no-screenshot' ?>"
                            alt=""></a>
                <div class="card-body px-0 pt-md-0">
                    <p class="lead"><a
                                href="<?php echo $url ?>"><?php echo htmlspecialchars($title) ?></a>
                    </p>
                    <?php echo $platformFormat ?>
                    <p><?php echo $ePrefix . $work['event_title'] ?> /
                        <?php echo $work['competition_title'] ?></p>
                </div>
            </div>
            <?php

            next($works);
            if (key($works) !== null && !$works[key($works)]['screenshot']) {
                echo '<hr class="comment-delimiter"/>';
            }
        endforeach;
        ?>
        <?php echo $pagingLinks ?>
    <?php endif; ?>
</div>
