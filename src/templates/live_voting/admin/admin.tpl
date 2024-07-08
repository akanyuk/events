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

?>
    <style>
        .live-voting-menu {
            display: flex;
            justify-content: space-between;
            padding-bottom: 1em;
        }

        .live-voting-menu LABEL {
            display: none;
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

        .live-voting-current {
            background-color: #66B996;
            text-decoration: none;
        }

        .live-voting-all {
            background-color: #FFC881FF;
        }
    </style>
    <div class="live-voting-menu">
        <label for="filter-compo"></label>
        <select id="filter-compo" class="form-control">
            <?php foreach ($records as $id => $compo) {
                echo '<option value="' . $id . '">' . $compo['title'] . '</option>';
            } ?>
        </select>

        <button class="btn btn-link" type="button" data-toggle="collapse" data-target="#collapseHelp"
                aria-expanded="false" aria-controls="collapseExample"><span class="fa fa-question-circle"></span>
        </button>
    </div>

    <div class="collapse" id="collapseHelp">
        <div class="well">
            <p><span class="live-voting-current">&nbsp;&nbsp;&nbsp;&nbsp;</span> Live voting work on index page. Only
                one allowed.</p>
            <p><span class="live-voting-all">&nbsp;&nbsp;&nbsp;&nbsp;</span> Works that participated in the live
                voting
                session for the current competition. Multiply allowed.</p>
            <p>If you change the competition and start live voting, then all previously started voting in the previous
                competition stops.</p>
            <p>The "Stop live voting" button stops all running live voting.</p>
            <p>The "Open normal voting" button opens the "normal" voting for the currently open category from the
                current time.</p>
        </div>
    </div>

    <div id="live-voting">
        <?php foreach ($records as $compoID => $compo): ?>
            <div class="row" data-role="competition-container" id="<?php echo $compoID ?>"
                 style="display: <?php echo $compoID == $firstCompo ? 'block' : 'none' ?>;">

                <div class="col-lg-2 col-md-3 col-sm-4 col-xs-6">
                    <a href="#" title="Announce 'COMING UP' message" class="thumbnail live-voting-thumbnail"
                       data-role="start-live-voting"
                       data-action="announce"
                       data-code="coming-up-<?php echo $compoID?>"
                       data-title="Coming Up"
                       data-description="<?php echo htmlspecialchars($compo['title']) ?>">
                        <div class="img-container">
                            <div class="fa fa-live-voting fa-paper-plane"></div>
                        </div>
                        <div class="caption">
                            <p style="font-weight: bold;"><?php echo htmlspecialchars($compo['title']) ?></p>
                            <p>COMING UP</p>
                        </div>
                    </a>
                </div>

                <?php foreach ($compo['works'] as $r): ?>
                    <div class="col-lg-2 col-md-3 col-sm-4 col-xs-6">
                        <a href="#" title="Start live voting for this work"
                           data-role="start-live-voting" data-work-id="<?php echo $r['id'] ?>"
                           class="thumbnail live-voting-thumbnail">
                            <div class="img-container">
                                <?php echo $r['screenshot'] ? '<img class="media-object" alt="" src="' . cache_media($r['screenshot'], 0, 128) . '" />' : previewHTML($compo['works_type']) ?>
                            </div>
                            <div class="caption">
                                <p style="font-weight: bold;"><?php echo $r['position'] . '. ' . htmlspecialchars($r['title']) ?></p>
                                <p>by <?php echo htmlspecialchars($r['author']) ?></p>
                            </div>
                        </a>
                    </div>
                <?php endforeach; ?>
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

                if ($(this).data('action') === 'announce') {
                    if ($(this).hasClass("live-voting-current")) {
                        sendState({'liveVotingAnnounceStop': true});
                    } else {
                        sendState({
                            'liveVotingAnnounce': {
                                'code': $(this).data('code'),
                                'title': $(this).data('title'),
                                'description': $(this).data('description'),
                            }
                        });
                    }
                    return;
                }

                if ($(this).hasClass("live-voting-current") || $(this).hasClass("live-voting-all")) {
                    sendState({'stopLiveVoting': $(this).data("work-id")});
                } else {
                    sendState({'startLiveVoting': $(this).data("work-id")});
                }
            });

            $('[id="live-voting-stop"]').click(function (e) {
                e.preventDefault();

                sendState({'stopAllLiveVoting': true});
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
            $('[data-role="start-live-voting"]').removeClass('live-voting-current').removeClass('live-voting-all');

            if (state['all'] !== undefined) {
                state['all'].forEach((w) => {
                    $('[data-role="start-live-voting"][data-work-id="' + w['id'] + '"]').addClass('live-voting-all');
                });
            }

            if (state['current'] !== undefined) {
                $('[data-role="start-live-voting"][data-work-id="' + state['current']['id'] + '"]').removeClass('live-voting-all').addClass('live-voting-current');
            }

            if (state['announce'] !== undefined) {
                $('[data-role="start-live-voting"][data-code="' + state['announce']['code'] + '"]').addClass('live-voting-current');
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