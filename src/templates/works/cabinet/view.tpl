<?php
/** @var works $Module */

$langMain = NFW::i()->getLang('main');
$langMedia = NFW::i()->getLang('media');

NFW::i()->assign('page_title', $Module->record['title'] . ' / ' . $langMain['cabinet prods']);
NFW::i()->breadcrumb = array(
    array('url' => 'cabinet/works_list', 'desc' => $langMain['cabinet prods']),
    array('desc' => $Module->record['title'] . ' by ' . $Module->record['author'])
);
NFW::i()->breadcrumb_status = $Module->record['event_title'] . '&nbsp;/ ' . $Module->record['competition_title'];

NFW::i()->registerResource('base');
NFW::i()->registerFunction('display_work_media');

$CCompetitions = new competitions($Module->record['competition_id']);

// Is the prod visible in public
if ($CCompetitions->record['voting_status']['available'] && $Module->record['status_info']['voting']) {
    $isPublished = true;
} else if ($CCompetitions->record['release_status']['available'] && $Module->record['status_info']['release']) {
    $isPublished = true;
} else {
    $isPublished = false;
}

// Linter related
ob_start(); ?>
    <div class="interactions">
        <div class="item">
            <div class="author"></div>
            <div class="message is-message"></div>
        </div>
    </div>
<?php ob_end_clean();

echo NFW::i()->fetch(NFW::i()->findTemplatePath('_common_status_icons.tpl'));
?>
    <style>
        .interactions .item {
            padding: 8px 10px;
        }

        .interactions .item .author {
            font-size: 90%;
            color: #c56464;
            white-space: nowrap;
        }

        .interactions .item .message {
            font-style: italic;
        }

        .interactions .item .message.is-message {
            font-style: normal !important;
        }

        @media (min-width: 769px) {
            .interactions .item {
                display: table-row;
            }

            .interactions .item .author {
                padding: 5px;
                display: table-cell;
            }

            .interactions .item .message {
                padding: 5px;
                display: table-cell;
                width: 100%;
            }
        }
    </style>

    <div class="d-md-none">
        <?php echo startBlock($Module->record, $isPublished); ?>
    </div>

    <div class="badge text-bg-danger">PREVIEW!</div>
    <hr class="mt-0"/>
<?php echo display_work_media($Module->record, array('rel' => 'preview')); ?>
    <hr class="d-md-none mt-0"/>

    <div class="w-640 mb-5">
        <section id="work-interactions-top"></section>

        <h3>Interactions</h3>
        <div class="interactions mb-2" id="work-interactions"></div>

        <div class="d-grid d-sm-block">
            <button id="show-all-interactions" class="btn btn-secondary btn-sm d-none mb-3">Show all interactions
            </button>
        </div>

        <div class="mb-2">
            <textarea id="message" class="form-control" placeholder="<?php echo $langMain['cabinet message send'] ?>"
                      style="height: 200px"></textarea>
            <div id="message-feedback" class="invalid-feedback"></div>
        </div>

        <div class="d-grid d-sm-block">
            <button id="message-send"
                    class="btn btn-success"><?php echo $langMain['cabinet send'] ?></button>
        </div>
    </div>

<?php ob_start(); ?>
    <div class="d-none d-md-block">
        <?php echo startBlock($Module->record, $isPublished); ?>
    </div>

    <h2 class="index-head mb-3"><?php echo $langMain['works files'] ?></h2>
<?php
$CMedia = new media();
echo $CMedia->openSession(array(
    'owner_id' => $Module->record['id'],
    'owner_class' => get_class($Module),
    'secure_storage' => true,
    'template' => '_cabinet_add_work_media',
    'after_upload' => 'cabinet_work_media_added',
));
NFWX::i()->mainLayoutRightContent = ob_get_clean();
?>

    <script type="text/javascript">
        <?php ob_start(); ?>

        const divWorkInteractions = document.getElementById("work-interactions");
        const buttonShowAllInteractions = document.getElementById("show-all-interactions");
        const showLastInteractionsCnt = 25; // Showing last N interactions

        const buttonMessageSend = document.getElementById("message-send");
        const messageTextarea = document.getElementById("message");
        const messageFeedback = document.getElementById("message-feedback");

        buttonMessageSend.onclick = async function () {
            let response = await fetch("?action=interaction_message", {
                method: "POST",
                body: JSON.stringify({
                    workID: <?php echo $Module->record['id']; ?>,
                    message: messageTextarea.value
                }),
                headers: {
                    "Content-type": "application/json; charset=UTF-8"
                }
            });

            if (!response.ok) {
                const resp = await response.json();
                const errors = resp.errors;

                if (errors["general"] !== undefined && errors["general"] !== "") {
                    gErrorToastText.innerText = errors["general"];
                    gErrorToast.show();
                }

                if (errors["message"] !== undefined && errors["message"] !== "") {
                    messageTextarea.classList.add('is-invalid');
                    messageFeedback.innerText = errors["message"];
                    messageFeedback.className = 'invalid-feedback d-block';
                }

                return;
            }

            messageTextarea.value = '';
            messageTextarea.classList.remove('is-invalid');
            messageFeedback.className = 'd-none';

            const resp = await response.json();
            const item = interactionsItem(resp);
            divWorkInteractions.appendChild(item);
        }

        buttonShowAllInteractions.onclick = function () {
            divWorkInteractions.querySelectorAll(".item").forEach(item => {
                item.classList.remove("d-none");
            });

            setTimeout(function () {
                document.getElementById("work-interactions-top").scrollIntoView({
                    block: 'start',
                    behavior: 'smooth'
                });
            }, 100);

            buttonShowAllInteractions.classList.add("d-none");
        };

        loadInteractions();

        async function loadInteractions() {
            buttonShowAllInteractions.classList.add("d-none");

            const response = await fetch('?action=work_interaction&work_id=<?php echo $Module->record['id']; ?>');
            const resp = await response.json();

            if (!response.ok) {
                const resp = await response.json();
                alert(resp['errors']['general']);
                return;
            }

            divWorkInteractions.innerHTML = "";

            const numRecords = resp['records'].length;
            resp['records'].forEach(function (r, index) {
                let item = interactionsItem(r);
                if (numRecords - index > showLastInteractionsCnt) {
                    item.classList.add("d-none");
                }

                divWorkInteractions.appendChild(item);
            });

            if (numRecords > showLastInteractionsCnt) {
                buttonShowAllInteractions.classList.remove("d-none");
            }
        }

        function interactionsItem(r) {
            let author = document.createElement('div');
            author.className = "author";
            author.innerText = formatDateTime(r['posted'], true, true) + ' by ' + r['poster_username'];

            let message = document.createElement('div');
            message.className = "message";
            if (r['is_message']) {
                message.classList.add('is-message');
            }
            message.innerText = r['message'];

            let item = document.createElement('div');
            item.className = "item";

            item.appendChild(author);
            item.appendChild(message);

            return item;
        }

        <?php NFWX::i()->mainBottomScript .= ob_get_clean(); ?>
    </script>

<?php
function startBlock(array $record, bool $isPublished): string {
    $langMain = NFW::i()->getLang('main');
    ob_start();
    ?>
    <div class="alert alert-<?php echo $record['status_info']['css-class'] ?> d-flex align-items-center"
         role="alert">
        <svg class="flex-shrink-0 me-2" width="1em" height="1em" data-bs-toggle="tooltip"
             data-bs-title="<?php echo $record['status_info']['desc'] ?>">
            <use xlink:href="#<?php echo $record['status_info']['svg-icon'] ?>"/>
        </svg>
        <div><?php echo $record['status_reason'] ?: $record['status_info']['desc_full'] ?></div>
    </div>

    <?php if ($isPublished):
        $permalink = NFW::i()->absolute_path . '/' . $record['event_alias'] . '/' . $record['competition_alias'] . '/' . $record['id'];
        ?>
        <div class="d-grid mb-3">
            <a class="btn btn-lg btn-primary"
               href="<?php echo $permalink ?>#title"><?php echo $langMain['works permanent link'] ?></a>
        </div>
    <?php endif;

    return ob_get_clean();
}