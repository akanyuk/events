<?php
/**
 * @var $workID integer
 */

NFW::i()->registerResource('jquery.activeForm');
NFWX::i()->disableBlockUI = true;

$langMain = NFW::i()->getLang('main');
$allowDelete = NFW::i()->checkPermissions('works_comments', 'delete', array('work_id' => $workID));
?>
<script type="text/javascript">
    $(document).ready(function () {
        <?php if (NFW::i()->checkPermissions('works_comments', 'add_comment')):?>
        const acF = $('form[id="works-comments-add"]');
        acF.activeForm({
            'success': function () {
                acF.resetForm();
                $(document).trigger('works-comments-load');
            }
        });
        <?php endif; ?>

        $(document).on('works-comments-load', function () {
            $.get('/works_comments?action=comments_list&work_id=<?php echo $workID?>', function (response) {
                if (response.result === 'success') {
                    $('div[id="work-comments"]').empty();
                    $.each(response.comments, function () {
                        let tpl = $('div[id="works-comments-record-template"]').html();
                        tpl = tpl.replace(/%ID%/g, this.id);
                        tpl = tpl.replace('%POSTED_STR%', this.posted_str);
                        tpl = tpl.replace('%MESSAGE%', this.message);
                        $('div[id="work-comments"]').append(tpl);
                    });
                }

            }, 'json');
        });

        $(document).trigger('works-comments-load');

        <?php if ($allowDelete):?>
        $(document).on('click', '[data-role="delete-comment"]', function (e) {
            if (!confirm('Delete this comment?')) {
                return false;
            }

            e.preventDefault();

            $.post('/works_comments?action=delete', {record_id: $(this).attr('id')}, function (response) {
                if (response !== 'success') {
                    alert(response);
                    return false;
                } else {
                    $(document).trigger('works-comments-load');
                }
            });
        });
        <?php endif; ?>
    });
</script>

<div id="works-comments-record-template" style="display: none;">
    <figure>
        <blockquote class="blockquote">%MESSAGE%</blockquote>
        <figcaption class="blockquote-footer">
            %POSTED_STR%
            <?php if ($allowDelete): ?>
                <a data-role="delete-comment" href="#" title="Delete comment" id="%ID%"
                   class="text-danger">
                    <svg width="1em" height="1em">
                        <use href="#icon-x"></use>
                    </svg>
                </a>
            <?php endif; ?>
        </figcaption>
    </figure>
</div>

<div id="comments" style="position: relative; top: -50px;"></div>
<div class="mb-5">
    <h2><?php echo $langMain['comments'] ?></h2>

    <div id="work-comments"></div>

    <?php if (NFW::i()->checkPermissions('works_comments', 'add_comment')): ?>
        <form id="works-comments-add" action="/works_comments?action=add_comment">
            <input type="hidden" name="work_id" value="<?php echo $workID ?>"/>

            <div class="mb-2">
                <label for="message"><?php echo $langMain['works comments write'] ?></label>
                <textarea name="message" class="form-control" style="height: 200px"></textarea>
            </div>

            <div class="d-grid d-sm-block">
                <button type="submit" class="btn btn-success"><?php echo $langMain['works comments send'] ?></button>
            </div>
        </form>
    <?php else: ?>
        <div class="alert alert-warning"><?php echo $langMain['works comments attention register'] ?></div>
    <?php endif; ?>
</div>
