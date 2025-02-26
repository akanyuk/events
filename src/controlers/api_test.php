<?php
	NFW::i()->registerResource('jquery.activeForm');
    active_field('set_defaults', array('labelCols' => 2, 'inputCols' => 10));
	
	ob_start();
?>
    <style>
        FORM {
            margin: 20px 0;
        }

        #response {
            background-color: #eee;
            font-family: monospace;
            margin-top: 20px;
            padding: 10px;
            white-space: pre;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            let actionSelectOptions = '';

            $('form[data-rel="api-test"]').each(function () {
                const f = $(this);
                f.prepend('<legend>Current action: ' + f.attr('action') + '</legend>');

                actionSelectOptions = actionSelectOptions + '<option id="' + f.attr('action') + '">' + f.attr('action') + '</option>';
                f.activeForm({
                    dataType: 'text',
                    success: function (response) {
                        $('div[id="response"]').text(response);
                    },
                    error: function (response) {
                        console.log(response);
                        $('div[id="response"]').text(response['responseText']);
                        return false;
                    }
                });

                f.append($('div[id="form-append"]').html());
            });

            $('select[id="actionSelect"]').append(actionSelectOptions).change(function () {
                $('form[data-rel="api-test"]').hide();
                $('form[data-rel="api-test"][action="' + $(this).val() + '"').show();

                if ($(this).val().includes("api/v2/")) {
                    $('div[data-active-container="ResponseType"]').hide();
                } else {
                    $('div[data-active-container="ResponseType"]').show();
                }
            }).trigger('change');
        });
    </script>

    <div id="form-append" style="display: none;">
        <?php echo active_field(array('name' => 'ResponseType', 'desc' => 'ResponseType', 'type' => 'select', 'options' => array('xml', 'json'))) ?>

        <div class="form-group">
            <div class="col-md-offset-4 col-md-8">
                <button type="submit" class="btn btn-lg btn-primary">Send request</button>
            </div>
        </div>
    </div>

    <h1>Events API tests</h1>
    <br/>
    <div class="row">
        <label for="actionSelect" class="col-md-4 control-label" style="text-align: right; padding-top: 3px;">Choose
            action</label>
        <div class="col-md-8">
            <select id="actionSelect" class="form-control"></select>
        </div>
    </div>

    <form data-rel="api-test" action="/api/v2/works/get">
        <fieldset>
            <?php echo active_field(array('name' => 'event', 'desc' => '<code>event</code><br ><small>Event alias. Leave the field empty if you don\'t need event filtering. </small>')) ?>
            <?php echo active_field(array('name' => 'competition', 'desc' => '<code>competition</code><br ><small>Competition alias. Leave the field empty if you don\'t need competition filtering. </small>')) ?>
            <?php echo active_field(array('name' => 'limit', 'value' => 30, 'desc' => '<code>limit</code><br ><small>Max value: <strong>999</strong><br /></small><small>Default value: <strong>30</strong></small>', 'type' => 'int', 'min' => 1, 'max' => 999)) ?>
            <?php echo active_field(array('name' => 'offset', 'value' => 0, 'desc' => '<code>offset</code>', 'type' => 'int', 'min' => 0)) ?>
        </fieldset>
    </form>

    <form data-rel="api-test" action="/api/v2/timeline">
        <fieldset>
            <?php echo active_field(array('name' => 'event', 'desc' => 'event')) ?>
        </fieldset>
    </form>

    <form data-rel="api-test" action="/api/events/upcoming-current">
        <fieldset></fieldset>
    </form>

    <form data-rel="api-test" action="/api/events/read">
        <fieldset>
            <?php echo active_field(array('name' => 'Alias', 'desc' => 'Alias')) ?>
        </fieldset>
    </form>

    <form data-rel="api-test" action="/api/competitions/get53c">
        <fieldset></fieldset>
    </form>

    <form data-rel="api-test" action="/api/competitions/upload53c" enctype="multipart/form-data">
        <fieldset>
            <?php echo active_field(array('name' => 'Title', 'desc' => 'Title')) ?>
            <?php echo active_field(array('name' => 'Author', 'desc' => 'Author')) ?>

            <div id="FileATR" class="form-group">
                <label for="FileATR" class="col-md-2 control-label">FileATR (768 bytes)</label>
                <div class="col-md-10">
                    <input type="file" name="FileATR"/>
                    <span class="help-block"></span>
                </div>
            </div>
        </fieldset>
    </form>

    <form data-rel="api-test" action="/api/works/get">
        <fieldset>
            <div class="alert alert-warning col-md-offset-4">Deprecated. Use <code>/api/v2/works/get</code> instead</div>
            <?php echo active_field(array('name' => 'EventID', 'value' => 0, 'desc' => 'EventID', 'type' => 'int', 'min' => 0)) ?>
            <?php echo active_field(array('name' => 'CompetitionID', 'value' => 0, 'desc' => 'CompetitionID', 'type' => 'int', 'min' => 0)) ?>
            <?php echo active_field(array('name' => 'Limit', 'value' => 15, 'desc' => 'Limit', 'type' => 'int', 'min' => 1, 'max' => 99)) ?>
            <?php echo active_field(array('name' => 'Offset', 'value' => 0, 'desc' => 'Offset', 'type' => 'int', 'min' => 0)) ?>
        </fieldset>
    </form>

    <div style="clear: both;"></div>

    <div id="response"></div>

<?php
NFW::i()->breadcrumb = array(array('desc' => 'Events API tests'));

NFW::i()->assign('page', array(
    'title' => 'Events API tests',
    'path' => 'api_test',
    'content' => ob_get_clean()
));
NFW::i()->display('main.tpl');