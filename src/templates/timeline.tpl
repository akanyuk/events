<?php
NFW::i()->registerResource('jquery.countdown');
?>
<html lang="<?php echo NFW::i()->lang['lang'] ?>">
<head>
    <meta http-equiv=Content-Type content="text/html; charset=utf-8">
    <title>Timeline</title>
    <style>
        body {
            overflow: hidden;
            margin: 0;
            padding: 1em;
            background-color: #000000;
            color: #ffffff;
        }

        body, p {
            font: 18pt Arial;
        }

        .timeline-record {
            margin-bottom: 2.5em;
            padding-left: 1em;
            clear: both;
        }

        .timeline-record .countdown {
            float: right;
            text-align: right;
            font-family: Consolas, Lucida Console, Courier New, monospace;
            font-size: 50pt;
            font-weight: bold;
            color: #080;
            text-shadow: 1px 0 10px #080;
        }

        .timeline-record .date {
            margin-bottom: 0.2em;
            padding: 0.2em 0.5em;
            width: 150pt;
            background: #4A0505;
            background: linear-gradient(to right, #800A0A, #000000);
            color: #fff;
            font-size: 85%;
            font-weight: bold;
        }

        .timeline-record hr {
            margin: 0 0 0 -0.3em;
            width: 300pt;
            height: 1px;
            border: none;
            background: linear-gradient(to right, #C95B1C, #000000);
        }

        .timeline-record .description {
            font-weight: bold;
        }
    </style>
    <script type="text/javascript">
        const urlParams = new URLSearchParams(window.location.search);
        let numRows = parseInt(urlParams.get('count'));
        if (isNaN(numRows)) {
            numRows = 5;
        }

        $(document).ready(function () {
            setInterval(updateTimeline, 10000);
            updateTimeline();
        });

        function updateTimeline() {
            const timelineContainer = $('div[id="timeline-container"]');

            $.ajax("?action=data", {
                "dataType": "json"
            }).done(function (response) {
                timelineContainer.empty();

                response.slice(0, numRows).forEach(record => {
                    const countdownRecord = $('<div>', {class: 'timeline-record'});

                    $('<div>', {
                        class: 'countdown',
                    }).countdown({
                        until: new Date(record['countdown']),
                        compact: true,
                        format: 'HMS',
                        onExpiry: function () {
                            $(this).closest('div').remove();
                        }
                    }).appendTo(countdownRecord);

                    $('<div>', {
                        class: 'date',
                        html: record['date'],
                    }).appendTo(countdownRecord);

                    $('<div>', {
                        class: 'description',
                        html: record['html'],
                    }).appendTo(countdownRecord);

                    timelineContainer.append(countdownRecord);
                });
            });
        }
    </script>
</head>
<body>
<div id="timeline-container"></div>

<div id="record-template" style="display: none">
    <div class="timeline-record">
        <div id="countdown" class="countdown">%countdown%</div>
        <div class="date">%date%</div>
        <div class="description">%html%</div>
    </div>
</div>

</body>
</html>