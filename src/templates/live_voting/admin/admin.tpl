<?php
/**
 * @var live_voting $Module
 * @var array $event
 * @var array $records
 * @var int $firstCompo
 */

NFW::i()->registerFunction('cache_media');
NFW::i()->registerResource('jquery.jgrowl');
NFW::i()->assign('page_title', $event['title'] . ' / Live voting');

NFW::i()->breadcrumb = array(
    array('url' => 'admin/events?action=update&record_id=' . $event['id'], 'desc' => $event['title']),
    array('desc' => 'Live voting'),
);
ob_start();
?>
    <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapseHelp"
            aria-expanded="false" aria-controls="collapseExample"><span class="fa fa-question-circle"></span>
    </button>
<?php
NFW::i()->breadcrumb_status = ob_get_clean();
?>
    <style>
        .live-voting-menu {
            margin-bottom: 20px;
        }

        .live-voting-thumbnail {
            padding-top: 20px;
            color: #555;
            text-decoration: none;
        }

        .live-voting-thumbnail:hover {
            color: #888;
            text-decoration: none;
        }

        .live-voting-thumbnail:focus {
            color: #888;
            text-decoration: none;
        }

        .live-voting-thumbnail P {
            white-space: nowrap;
            overflow: hidden;
            margin: 0;
        }

        .live-voting-thumbnail .img-container {
            height: 128px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
        }

        .fa-live-voting {
            font-size: 500%;
        }

        .live-voting-opened {
            background-color: #66B996;
        }
    </style>

    <div class="collapse" id="collapseHelp">
        <div class="well">
            <p><span class="live-voting-opened">&nbsp;&nbsp;&nbsp;&nbsp;</span> Works that participated in the live
                voting session for the current competition. Multiply allowed.</p>
            <p>If you change the competition and start live voting, then all previously started voting in the previous
                competition stops.</p>
            <p>The "Stop live voting" button stops all running live voting.</p>
            <p>The "Open normal voting" button opens the "normal" voting for the currently open category from the
                current time.</p>
        </div>
    </div>

    <div class="live-voting-menu">
        <select id="filter-compo" class="form-control">
            <?php foreach ($records as $id => $compo) {
                echo '<option value="' . $id . '">' . $compo['title'] . '</option>';
            } ?>
        </select>
    </div>

    <div id="live-voting">
        <?php foreach ($records as $compoID => $compo): ?>
            <div class="row" data-role="competition-container" id="<?php echo $compoID ?>"
                 style="display: <?php echo $compoID == $firstCompo ? 'block' : 'none' ?>;">

                <div class="col-lg-2 col-md-3 col-sm-4 col-xs-6">
                    <a href="#" title="Announce 'COMING UP' message" class="thumbnail live-voting-thumbnail"
                       data-role="start-live-voting"
                       data-action="coming-announce"
                       data-title="Coming Up"
                       data-description="<?php echo htmlspecialchars($compo['title']) ?>">
                        <div class="img-container">
                            <div class="fa fa-live-voting fa-paper-plane"></div>
                        </div>
                        <div class="caption">
                            <p style="font-weight: bold;">COMING UP</p>
                            <p><?php echo htmlspecialchars($compo['title']) ?></p>
                        </div>
                    </a>
                </div>

                <?php foreach ($compo['works'] as $k => $r): ?>
                    <div class="col-lg-2 col-md-3 col-sm-4 col-xs-6">
                        <a href="#" title="Start live voting for this work"
                           data-role="start-live-voting"
                           data-work-id="<?php echo $r['id'] ?>"
                           data-position="<?php echo $k + 1 ?>"
                           class="thumbnail live-voting-thumbnail">
                            <div class="img-container">
                                <?php echo $r['screenshot'] ? '<img class="media-object" alt="" src="' . cache_media($r['screenshot'], 0, 128) . '" />' : previewHTML($compo['works_type']) ?>
                            </div>
                            <div class="caption">
                                <p style="font-weight: bold;"><?php echo $k + 1 . '. ' . htmlspecialchars($r['title']) ?></p>
                                <p>by <?php echo htmlspecialchars($r['author']) ?></p>
                            </div>
                        </a>
                    </div>
                <?php endforeach; ?>

                <div class="col-lg-2 col-md-3 col-sm-4 col-xs-6">
                    <a href="#" title="Announce 'COMPO END' message" class="thumbnail live-voting-thumbnail"
                       data-role="start-live-voting"
                       data-action="end-announce"
                       data-title="Compo End"
                       data-description="<?php echo htmlspecialchars($compo['title']) ?>">
                        <div class="img-container">
                            <div class="fa fa-live-voting fa-paper-plane"></div>
                        </div>
                        <div class="caption">
                            <p style="font-weight: bold;">COMPO END</p>
                            <p><?php echo htmlspecialchars($compo['title']) ?></p>
                        </div>
                    </a>
                </div>
            </div>
        <?php endforeach; ?>
    </div>

    <button id="live-voting-stop" class="btn btn-danger">Stop live voting</button>
    <button id="open-normal-voting" class="btn btn-warning">Open normal voting</button>

    <script type="text/javascript">
        $(document).ready(function () {
            const liveVotingContainer = $('div[id="live-voting"]');
            $('select[id="filter-compo"]').change(function () {
                const id = $(this).val();
                liveVotingContainer.find('div[data-role="competition-container"]').hide();
                liveVotingContainer.find('div[data-role="competition-container"][id="' + id + '"]').show();
            }).trigger('change');

            $('[data-role="start-live-voting"]').click(function (e) {
                e.preventDefault();

                if ($(this).data('action') === 'coming-announce') {
                    if ($(this).hasClass("live-voting-opened")) {
                        sendState({'comingAnnounceStop': true});
                    } else {
                        sendState({
                            'comingAnnounce': {
                                'title': $(this).data('title'),
                                'description': $(this).data('description'),
                            }
                        });
                    }
                    return;
                }

                if ($(this).data('action') === 'end-announce') {
                    if ($(this).hasClass("live-voting-opened")) {
                        sendState({'endAnnounceStop': true});
                    } else {
                        sendState({
                            'endAnnounce': {
                                'code': $(this).data('code'),
                                'title': $(this).data('title'),
                                'description': $(this).data('description'),
                            }
                        });
                    }
                    return;
                }

                // Opening/closing voting for work
                if ($(this).hasClass("live-voting-opened")) {
                    sendState({'stop': $(this).data("work-id")});
                } else {
                    sendState({
                        'start': $(this).data("work-id"),
                        'position': $(this).data("position"),
                    });
                }
            });

            $('[id="live-voting-stop"]').click(function (e) {
                e.preventDefault();

                sendState({'stopAll': true});
            });

            $('[id="open-normal-voting"]').click(function () {
                $.ajax('<?php echo $Module->formatURL('open_voting')?>',
                    {
                        method: "POST",
                        dataType: "json",
                        data: {
                            'competition_id': $('select[id="filter-compo"]').val(),
                        },
                        error: function (response) {
                            if (response['responseJSON']['errors']['general'] !== undefined) {
                                alert(response['responseJSON']['errors']['general']);
                            }
                        },
                        success: function (response) {
                            $.jGrowl(response['message']);
                        }
                    },
                );

                return false;
            });

            // Reading initial state
            $.ajax('<?php echo $Module->formatURL('read_state', 'event_id=' . $event['id'])?>',
                {
                    method: "GET",
                    dataType: "json",
                    error: function (response) {
                        if (response['responseJSON']['errors']['general'] !== undefined) {
                            alert(response['responseJSON']['errors']['general']);
                        }
                    },
                    success: function (response) {
                        updateByState(response);
                    },
                },
            );
        });

        function sendState(data) {
            $.ajax('<?php echo $Module->formatURL('update_state', 'event_id=' . $event['id'])?>',
                {
                    method: "POST",
                    dataType: "json",
                    data: data,
                    error: function (response) {
                        if (response['responseJSON']['errors']['general'] !== undefined) {
                            alert(response['responseJSON']['errors']['general']);
                        }
                    },
                    success: function (response) {
                        updateByState(response);
                    },
                },
            );
        }

        function updateByState(state) {
            $('[data-role="start-live-voting"]').removeClass('live-voting-opened');

            if (state['works'] !== undefined) {
                for (const id in state['works']) {
                    $('[data-role="start-live-voting"][data-work-id="' + id + '"]').addClass('live-voting-opened');
                }
            }

            if (state['comingAnnounce'] !== undefined) {
                $('[data-role="start-live-voting"][data-action="coming-announce"]').addClass('live-voting-opened');
            }
            if (state['endAnnounce'] !== undefined) {
                $('[data-role="start-live-voting"][data-action="end-announce"]').addClass('live-voting-opened');
            }
        }
    </script>
<?php

function previewHTML($worksType): string {
    switch ($worksType) {
        case 'picture':
            return '<div class="fa fa-live-voting fa-image"></div>';
        case 'music':
            return '<div class="fa fa-live-voting fa-music"></div>';
        case 'demo':
            return '<div class="fa fa-live-voting fa-tv"></div>';
        case 'other':
            return '<div class="fa fa-live-voting fa-film"></div>';
        default:
            return '<img class="media-object" alt="" src="' . NFW::i()->assets('main/news-no-image.png') . '"/>';
    }
}