<?php
/**
 * @var $workID integer
 */

$langMain = NFW::i()->getLang('main');
$allowComment = NFWX::i()->checkPermissions('works_comments', 'add_comment');
$allowDelete = NFWX::i()->checkPermissions('works_comments', 'delete', array('work_id' => $workID));
?>
<div id="comments" style="position: relative; top: -50px;"></div>
<div class="mb-5">
    <h2><?php echo $langMain['comments'] ?></h2>

    <div id="work-comments"></div>

    <?php if ($allowComment): ?>
        <div class="w-640 mb-3">
            <div class="mb-2">
                <label for="message"><?php echo $langMain['works comments write'] ?></label>
                <textarea id="comment-message" class="form-control" style="height: 200px"></textarea>
                <div id="comment-message-feedback" class="invalid-feedback"></div>
            </div>

            <div class="d-grid d-sm-block">
                <button id="comment-send"
                        class="btn btn-success"><?php echo $langMain['works comments send'] ?></button>
            </div>
        </div>
    <?php else: ?>
        <div class="alert alert-warning"><?php echo $langMain['works comments attention register'] ?></div>
    <?php endif; ?>
</div>

<script type="text/javascript">
    <?php ob_start(); ?>
    const commentsContainer = document.getElementById("work-comments");

    loadComments();

    <?php if ($allowComment): ?>
    const addCommentBtn = document.getElementById("comment-send");

    const messageInput = document.getElementById("comment-message");
    const messageFeedback = document.getElementById("comment-message-feedback");

    addCommentBtn.onclick = async function () {
        let response = await fetch("/internal_api?action=add_comment", {
            method: "POST",
            body: JSON.stringify({
                workID: <?php echo $workID?>,
                message: messageInput.value
            }),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        if (!response.ok) {
            const resp = await response.json();
            const errors = resp.errors;

            if (errors["general"] !== undefined && errors["general"] !== "") {
                document.getElementById('errorToast-text').innerText = errors["general"];
                gErrorToast.show();
            }

            if (errors["message"] !== undefined && errors["message"] !== "") {
                messageInput.className = 'form-control is-invalid';
                messageFeedback.innerText = errors["message"];
                messageFeedback.className = 'invalid-feedback d-block';
            }

            return;
        }

        messageInput.value = '';
        messageInput.className = 'form-control';
        messageFeedback.className = 'd-none';
        loadComments();
    }
    <?php endif;?>

    function loadComments() {
        commentsContainer.innerHTML = "";
        fetch('/internal_api?action=comments_list&work_id=<?php echo $workID?>').then(response => response.json()).then(response => {
            response['comments'].forEach((comment) => {
                const message = document.createElement('blockquote');
                message.innerText = comment['message']
                message.className = "blockquote";

                const posted = document.createElement('span');
                posted.innerText = comment['posted_str']

                const footer = document.createElement('figcaption');
                footer.className = "blockquote-footer";
                footer.appendChild(posted);

                <?php if ($allowDelete): ?>
                const deleteLink = document.createElement('a');
                deleteLink.className = "text-danger";
                deleteLink.setAttribute("href", "javascript:void(0)");
                deleteLink.setAttribute("data-role", "delete-comment");
                deleteLink.setAttribute("title", "Delete comment");
                deleteLink.setAttribute("id", comment['id']);
                deleteLink.innerHTML = '<svg width="1em" height="1em"><use href="#icon-x"></use></svg>';
                deleteLink.onclick = async function () {
                    if (!confirm('Delete this comment?')) {
                        return false;
                    }

                    let response = await fetch("/internal_api?action=delete_comment", {
                        method: "POST",
                        body: JSON.stringify({
                            commentID: comment['id']
                        }),
                        headers: {
                            "Content-type": "application/json; charset=UTF-8"
                        }
                    });

                    if (!response.ok) {
                        const resp = await response.json();
                        const errors = resp.errors;

                        if (errors["general"] !== undefined && errors["general"] !== "") {
                            document.getElementById('errorToast-text').innerText = errors["general"];
                            gErrorToast.show();
                        }

                        return;
                    }

                    loadComments();
                };

                footer.appendChild(deleteLink);
                <?php endif; ?>

                const item = document.createElement('figure');
                item.appendChild(message);
                item.appendChild(footer);

                commentsContainer.appendChild(item);
            });
        });
    }
    <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
</script>
