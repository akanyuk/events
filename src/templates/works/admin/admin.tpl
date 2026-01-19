<?php
/**
 * @var works $Module
 * @var array $event
 * @var array $records
 * @var int $defaultCompetition
 */

// Create tree of works, filters selector, counters badge
$totalApproved = 0;
$recordsTree = [];
$filterOptions = [];
$filteredCompetition = 0;
$_curCompo = 0;
foreach ($records as $r) {
    if ($_curCompo != $r['competition_id']) {
        $_curCompo = $r['competition_id'];

        $selected = false;
        if (isset($_GET['filter_competition']) && $_GET['filter_competition'] == $r['competition_id']) {
            $filteredCompetition = intval($_GET['filter_competition']);
            $selected = true;
        }

        $filterOptions[] = [
            'id' => $r['competition_id'],
            'title' => htmlspecialchars($r['competition_title']),
            'selected' => $selected,
        ];

        $recordsTree[$_curCompo] = array(
            'approved' => 0,
            'title' => $r['competition_title'],
            'works' => array(),
        );
    }

    $recordsTree[$_curCompo]['works'][] = $r;

    if ($r['status_info']['voting'] && $r['status_info']['release']) {
        $recordsTree[$_curCompo]['approved']++;
        $totalApproved++;
    }
}
foreach ($recordsTree as &$_sorting) {
    usort($_sorting['works'], function ($a, $b): int {
        if ($a['status'] == $b['status']) {
            return $a['position'] < $b['position'] ? -1 : 1;
        }

        return $a['status_info']['voting'] ? -1 : 1;
    });
}

NFW::i()->assign('page_title', $event['title'] . ' / works');
NFW::i()->registerResource('jquery.activeForm');
NFW::i()->registerResource('jquery.ui.interactions');
NFW::i()->registerResource('bootstrap3.typeahead');
NFW::i()->breadcrumb = [
    ['url' => 'admin/events?action=update&record_id=' . $event['id'], 'desc' => $event['title']],
    ['desc' => 'Works'],
];

ob_start();
?>
<div class="text-muted" style="font-size: 80%;">
    Total: <span class="badge"><?php echo count($records) ?></span>&nbsp;&nbsp;
    Approved: <span class="badge"><?php echo $totalApproved ?></span>
</div>
<?php
NFW::i()->breadcrumb_status = ob_get_clean();
?>
<style>
    .works-menu {
        padding-bottom: 1em;
    }

    @media (max-width: 768px) {
        .works-menu BUTTON {
            margin-bottom: 20px;
            width: 100%;
        }
    }

    @media (min-width: 769px) {
        .works-menu SELECT {
            width: auto;
        }

        .works-menu BUTTON {
            float: right;
        }
    }

    .works-list .table > tbody > tr > td {
        vertical-align: middle;
    }

    .works-list .label-platform {
        background-color: #6e3731;
    }

    .works-list .label-format {
        background-color: #31606e;
    }

    .panel-works-sort {
        margin-bottom: 10px;
    }

    .panel-works-sort .panel-body {
        padding: 10px;
    }

    .panel-works-sort .btn-works-sort-up, .panel-works-sort .btn-works-sort-down {
        display: block;
    }

    .panel-works-sort .btn-works-sort-up {
        margin-bottom: 3px;
    }
</style>
<div class="works-menu">
    <button id="works-insert" class="btn btn-primary">Insert work</button>
    <select id="filter-compo" class="form-control">
        <option value="0" <?php echo $filteredCompetition == 0 ? 'selected="selected"' : '' ?>>
            All competitions
        </option>
        <?php foreach ($filterOptions as $opt) {
            echo '<option value="' . $opt['id'] . '" ' . ($opt['selected'] ? 'selected="selected"' : '') . '>' . $opt['title'] . '</option>';
        } ?>
    </select>
</div>

<div id="event-works" class="works-list">
    <?php foreach ($recordsTree as $compoID => $c): ?>
        <div data-role="competition-container" id="<?php echo $compoID ?>"
             style="display: <?php echo $filteredCompetition == 0 || $filteredCompetition == $compoID ? 'block' : 'none' ?>;">
            <div class="row">
                <div class="col-xs-9">
                    <h4><?php echo htmlspecialchars($c['title']) . ' ' . $c['approved'] . ' [' . count($c['works']) . ']' ?></h4>
                </div>
                <div class="col-xs-3" style="text-align: right;">
                    <button id="works-sort" type="button" class="btn btn-link"
                            data-competition-id="<?php echo $compoID ?>"
                            data-title="<?php echo $c['title'] ?>">Sort
                    </button>
                </div>
            </div>
            <table class="table table-condensed">
                <?php foreach ($c['works'] as $r): ?>
                    <tr class="<?php echo $r['status_info']['css-class'] == "success" ? "" : $r['status_info']['css-class'] ?>"
                        title="<?php echo $r['status_info']['desc'] ?>">
                        <td>
                            <a href="<?php echo $Module->formatURL('update') . '&record_id=' . $r['id'] ?>">
                                <img class="media-object" alt=""
                                     src="<?php echo $r['screenshot'] ? $r['screenshot']['tmb_prefix'] . '64' : NFW::i()->assets('main/news-no-image.png') ?>"/>
                            </a>
                        </td>
                        <td style="width:100%;">
                            <a href="<?php echo $Module->formatURL('update') . '&record_id=' . $r['id'] ?>">
                                <?php echo htmlspecialchars($r['title']) ?>
                                by <?php echo htmlspecialchars($r['author']) ?>
                            </a>
                        </td>
                        <td style="text-align: center;">
                            <div class="label label-platform"><?php echo htmlspecialchars($r['platform']) ?></div>
                            <?php if ($r['format']): ?>
                                <div class="label label-format"><?php echo htmlspecialchars($r['format']) ?></div>
                            <?php endif; ?>
                        </td>
                        <td>
                            <?php if ($r['release_link']): ?>
                                <a href="<?php echo $r['release_link']['url'] ?>" class="btn btn-sm btn-success"
                                   title="Permanent archive link"><span class="fa fa-download"
                                                                        aria-hidden="true"></span></a>
                            <?php else: ?>
                                <a id="make-release-link" data-id="<?php echo $r['id'] ?>" href="#"
                                   class="btn btn-sm btn-default"
                                   title="Create permanent archive link"><span class="fa fa-download"
                                                                               aria-hidden="true"></span></a>
                            <?php endif; ?>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </table>
        </div>
    <?php endforeach; ?>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        // Filtering
        const eventWorks = $('div[id="event-works"]');
        $('select[id="filter-compo"]').change(function () {
            const id = $(this).val();
            if (id === '0') {
                eventWorks.find('div[data-role="competition-container"]').show();
                const nextTitle = '<?php echo $event['title']?>' + ' / works';
                window.history.replaceState(id, nextTitle, '/admin/works?event_id=<?php echo $event['id']?>');
                return;
            }

            eventWorks.find('div[data-role="competition-container"]').hide();
            eventWorks.find('div[data-role="competition-container"][id="' + id + '"]').show();

            const nextTitle = '<?php echo $event['title']?>' + ' / ' + $(this).val();
            window.history.replaceState(id, nextTitle, '/admin/works?event_id=<?php echo $event['id']?>&filter_competition=' + id);
        }).trigger('change');

        // Sorting work
        const sortDialog = $('div[id="works-sort-dialog"]');
        const worksSortContainer = sortDialog.find('[id="works"]');
        sortDialog.modal({'show': false});

        $(document).on('click', 'button[id="works-sort"]', function () {
            const competitionID = $(this).data('competition-id');

            sortDialog.find('#title').text($(this).data('title'));
            sortDialog.find('input[name=competition_id]').val(competitionID);

            worksSortContainer.empty();
            $.ajax(
                '<?php echo $Module->formatURL('get_pos')?>',
                {
                    method: "post",
                    dataType: "json",
                    data: {'competition_id': competitionID},
                    success: function (response) {
                        response.forEach(function (item) {
                            let tpl = $('#sort-record-template').html();
                            tpl = tpl.replace(/%id%/g, item['id']);
                            tpl = tpl.replace(/%icon%/g, '<img class="media-object" src="' + item['icon'] + '" alt="" /> ');
                            tpl = tpl.replace(/%title%/g, item['title']);
                            tpl = tpl.replace(/%author%/g, item['author']);
                            worksSortContainer.append(tpl);
                        });
                    },
                    error: function () {
                        alert("Get works positions unexpected error");
                    }
                }
            );

            worksSortContainer.sortable({
                items: 'div[id="record"]',
                axis: "y"
            });
            sortDialog.modal('show');
        });

        $(document).on('click', 'button[id="works-sort-up"]', function (e) {
            e.preventDefault();

            const me = $(this).closest('div[id="record"]');
            const prev = me.prev('div[id="record"]');
            if (prev.length === 0) {
                return;
            }

            me.insertBefore(prev);
        })

        $(document).on('click', 'button[id="works-sort-down"]', function (e) {
            e.preventDefault();

            const me = $(this).closest('div[id="record"]');
            const next = me.next('div[id="record"]');
            if (next.length === 0) {
                return;
            }

            me.insertAfter(next);
        })

        sortDialog.find('form').activeForm({
            error: function () {
                if (response['responseJSON']['errors']['general'] === undefined) {
                    return;
                }
                alert(response['responseJSON']['errors']['general']);
            },
            success: function () {
                sortDialog.modal('hide');
                window.location.reload();
            }
        });

        // Insert work
        const insertDialog = $('div[id="works-insert-dialog"]');
        insertDialog.modal({'show': false});

        $(document).on('click', 'button[id="works-insert"]', function () {
            // Set default compo
            const curFilteredCompo = $('select[id="filter-compo"]').val();
            if (curFilteredCompo !== '0') {
                $('select[name="competition_id"] option').removeAttr('selected');
                $('select[name="competition_id"] option[value="' + curFilteredCompo + '"]').attr('selected', 'selected');
            }

            insertDialog.find('form').resetForm().trigger('cleanErrors');
            insertDialog.modal('show');
        });

        insertDialog.find('form').activeForm({
            success: function (response) {
                insertDialog.modal('hide');
                window.location.href = '<?php echo $Module->formatURL('update')?>&record_id=' + response.record_id;
                return false;
            }
        });

        // Platform typeahead
        let aPlatforms = [];
        <?php foreach ($Module->attributes['platform']['options'] as $p) echo 'aPlatforms.push(' . json_encode($p) . ');' . "\n"; ?>
        $('input[name="platform"]').typeahead({
            source: aPlatforms,
            minLength: 0
        }).attr('autocomplete', 'off');

        $('button[id="works-insert-submit"]').click(function () {
            insertDialog.find('form').submit();
        });

        // Make release button
        $(document).on('click', '#make-release-link', function (e) {
            e.preventDefault();

            const obj = $(this);
            const recordID = obj.data('id');

            $.ajax(
                '<?php echo NFW::i()->base_path?>admin/works_media?action=make_release&record_id=' + recordID,
                {
                    dataType: "json",
                    success: function (response) {
                        obj.removeAttr('id');
                        obj.removeAttr('title');
                        obj.attr('href', decodeURIComponent(response['url']));
                        obj.addClass('btn-success').removeClass('btn-default');
                    },
                    error: function (response) {
                        if (response['responseJSON']['errors']['general'] === undefined) {
                            return
                        }
                        alert(response['responseJSON']['errors']['general']);
                    }
                }
            );
        });
    });
</script>

<div id="works-insert-dialog" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Insert work</h4>
            </div>
            <div class="modal-body">
                <form action="<?php echo $Module->formatURL('insert') . '&event_id=' . $event['id'] ?>">
                    <?php echo active_field(array('name' => 'competition_id', 'attributes' => $Module->attributes['competition_id'], 'labelCols' => '2')) ?>
                    <?php echo active_field(array('name' => 'title', 'attributes' => $Module->attributes['title'], 'labelCols' => '2')) ?>
                    <?php echo active_field(array('name' => 'author', 'attributes' => $Module->attributes['author'], 'labelCols' => '2')) ?>
                    <?php echo active_field(array('name' => 'platform', 'attributes' => $Module->attributes['platform'], 'labelCols' => '2')) ?>
                </form>
            </div>
            <div class="modal-footer">
                <button id="works-insert-submit" type="button"
                        class="btn btn-primary"><?php echo NFW::i()->lang['Save changes'] ?></button>
            </div>
        </div>
    </div>
</div>

<div id="works-sort-dialog" class="modal fade">
    <form id="works-sort"
          method="post"
          action="<?php echo $Module->formatURL('set_pos') ?>">
        <input name="competition_id" type="hidden"/>
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title">Sorting: <span id="title"></span></h4>
                </div>
                <div class="modal-body">
                    <div id="works"></div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Save sorting</button>
                </div>
            </div>
        </div>
    </form>
</div>

<div id="sort-record-template" style="display: none;">
    <div id="record" class="panel panel-default panel-works-sort">
        <input type="hidden" name="work[]" value="%id%"/>
        <div class="panel-body">
            <div class="media">
                <div class="media-left">%icon%</div>
                <div class="media-body">
                    <div class="row">
                        <div class="col-xs-9">
                            <h4 class="works-sort-title media-heading">%title%</h4>
                            <div class="works-sort-author text-muted">%author%</div>
                        </div>
                        <div class="col-xs-3">
                            <div class="pull-right">
                                <button id="works-sort-up"
                                        class="btn btn-default btn-works-sort-up"><span
                                            class="fa fa-sort-up" title="Move up"></span>
                                </button>
                                <button id="works-sort-down"
                                        class="btn btn-default btn-works-sort-down"><span
                                            class="fa fa-sort-down" title="Move down"></span></button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>