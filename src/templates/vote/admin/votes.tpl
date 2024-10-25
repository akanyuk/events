<?php
/**
 * @var object $Module
 * @var array $event
 */

NFW::i()->registerFunction('active_field');
?>
<script type="text/javascript">
    $(document).ready(function () {

        // Add vote

        const vDialog = $('div[id="vote-add-dialog"]');
        const vForm = vDialog.find('form');
        vDialog.modal({'show': false});

        $(document).off('click', 'button[id="vote-add"]').on('click', 'button[id="vote-add"]', function () {
            vForm.resetForm().trigger('cleanErrors');
            vDialog.modal('show');
        });

        vForm.activeForm({
            'success': function () {
                vDialog.modal('hide');
                oTable.fnDraw();
                return false;
            }
        });

        vDialog.find('button[id="vote-add-submit"]').click(function () {
            vForm.submit();
        });

        // Votes list
        const tableDOM = $('table[id="votes"]');
        const config = dataTablesDefaultConfig;

        // Infinity scrolling
        config.scrollY = $(window).height() - tableDOM.offset().top - 130;
        // Fix horizontal scroll
        //config.scrollX = '100%';
        config.deferRender = true;
        config.scroller = true;

        // Server-side
        config.bServerSide = true;
        config.bProcessing = false;
        config.sAjaxSource = '<?php echo $Module->formatURL('votes') . '&event_id=' . $event['id'] . '&part=list.js'?>';
        config.fnServerData = function (sSource, aoData, fnCallback) {
            $.ajax({
                'dataType': 'json',
                'type': "POST",
                'url': sSource,
                'data': aoData,
                'success': fnCallback
            });
        };

        config.aoColumns = [
            {'sortable': false },			                   // work
            {'sortable': false, 'className': 'strong center'}, // vote
            {'sortable': false, 'className': 'nowrap-column'}, // username
            {'sortable': false, 'className': 'nowrap-column'}, // posted
            {'sortable': false, 'className': 'nowrap-column'}  // IP
        ];

        config.fnRowCallback = function (nRow, aData) {
            let title = $('<span style="cursor: pointer;">' + aData[0][1] + '</span>');
            if (window.screen.width < 1000) {
                title = $('<span style="cursor: pointer;" title="' + aData[0][1] + '">' + aData[0][0] + '</span>');
            }

            title.click(function(){
                oTable.fnFilter(aData[0][1]);
            });

            const votekey = $('<span style="cursor: pointer;" title="votekey: ' + aData[3] + '; email: ' + aData[4] + '">' + aData[2] + '</span>');
            votekey.click(function(){
                oTable.fnFilter(aData[3]);
            });

            const ip = $('<span style="cursor: pointer;" title="' + aData[6][1] + '">' + aData[7] + '</span>');
            ip.click(function(){
                oTable.fnFilter(aData[7]);
            });

            $('td:eq(0)', nRow).html(title); // title
            $('td:eq(2)', nRow).html(votekey); // votekey
            $('td:eq(3)', nRow).html(formatDateTime(aData[5], true, true)); // posted
            $('td:eq(4)', nRow).html(ip); // IP
            return nRow;
        };

        const oTable = tableDOM.dataTable(config);

        // Custom filtering function
        const f = $('div[id="votes-custom-filters"]');
        $('div[id="votes_length"]').closest('div[class="col-sm-6"]').removeClass('col-sm-6').addClass('col-xs-4');
        $('div[id="votes_filter"]').closest('div[class="col-sm-6"]').removeClass('col-sm-6').addClass('col-xs-8');
        $('div[id="votes_length"]').empty().html(f.html());
        f.remove();
    });
</script>

<div id="vote-add-dialog" class="modal fade">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title"><?php echo htmlspecialchars($event['title']) ?></h4>
            </div>
            <div class="modal-body">
                <form action="<?php echo $Module->formatURL('add_vote', 'event_id=' . $event['id']) ?>">
                    <?php
                    $CWorks = new works();
                    $cur_competition = 0;
                    foreach ($CWorks->getRecords(array('skip_pagination' => true, 'filter' => array('voting_only' => true, 'event_id' => $event['id']))) as $work) {
                        if ($cur_competition != $work['competition_id']) {
                            echo '<h3>' . htmlspecialchars($work['competition_title']) . '</h3>';
                            $cur_competition = $work['competition_id'];
                        }

                        echo '<div class="row" style="padding-bottom: 2px;">';
                        echo '<div class="col-md-10"><strong>' . $work['position'] . '.</strong> ' . htmlspecialchars($work['title']) . '</div>';
                        echo '<div class="col-md-2"><input class="form-control input-sm" type="text" name="votes[' . $work['id'] . ']" /></div>';
                        echo '</div>';
                    }
                    ?>
                    <div class="row">
                        <div class="col-md-5">
                            <label for="votekey" style="display: block;">
                                <input type="text" name="votekey" class="form-control" placeholder="Votekey"
                                       maxlength="32"/>
                            </label>
                        </div>
                        <div class="col-md-7">
                            <p class="text-warning"><small>If you set non-empty votekey, all already added votes for
                                    given works will be replaced</small></p>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <label for="username" style="display: block;">
                                <input type="text" name="username" class="form-control"
                                       placeholder="Name / Nick / Comment" maxlength="200"/>
                            </label>
                        </div>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button id="vote-add-submit" type="button" class="btn btn-primary">Add vote</button>
                <button type="button" class="btn btn-default"
                        data-dismiss="modal"><?php echo NFW::i()->lang['Close'] ?></button>
            </div>
        </div>
    </div>
</div>

<div id="votes-custom-filters" style="display: none;">
    <button id="vote-add" class="btn btn-default" title="Add vote"><span class="fa fa-plus"></span></button>
</div>
<table id="votes" class="table table-striped">
    <thead>
    <tr>
        <th>Work <span
                    class="fa fa-question-circle text-muted"
                    title="Click to filter by work title"></span></th>
        <th>#</th>
        <th>Name <span
                    class="fa fa-question-circle text-muted"
                    title="Click to filter by votekey"></span></th>
        <th>Posted</th>
        <th>IP <span
                    class="fa fa-question-circle text-muted"
                    title="Click to filter by IP"></span></th>
    </tr>
    </thead>
</table>