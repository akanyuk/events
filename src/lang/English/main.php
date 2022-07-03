<?php
/**
 * @desc English language file for main template
 */
$lang_main = array(
    'days suffix' => array('day', 'days', 'days'),
    'hours suffix' => array('hour', 'hours', 'hours'),
    'minutes suffix' => array('minute', 'minutes', 'minutes'),
    'today' => 'Today',
    'yesterday' => 'Yesterday',

    'news' => 'News',
    'latest news' => 'Latest news',
    'all news' => 'Show all news',
    'comments' => 'Comments',
    'latest comments' => 'Latest comments',
    'all comments' => 'Show all comments',
    'days left' => 'days left',
    'unavailable' => 'unavailable',
    'reception closed' => 'closed',
    'voting closed' => 'closed',
    'choose button' => 'Choose',
    'download' => 'download',
    'search hint' => 'Search by title or author',

    'cabinet prods' => 'My Prods',
    'cabinet profile' => 'Profile',
    'cabinet add work' => 'Upload prod',
    'cabinet add work at' => 'Upload prod at',
    'cabinet add choose event' => 'Choose event',
    'cabinet add choose event desc' => 'Choose event for prod uploading',

    'latest events' => 'Latest events',
    'all events' => 'Show all events',
    'events' => 'Events',
    'event' => 'Event',
    'events no open' => 'Opened events not found.',
    'events not found' => 'Events not found.',

    'competition' => 'Сompetition',
    'competitions type' => 'Works type',
    'competitions reception' => 'Reception',
    'competitions voting' => 'Voting',
    'competitions approved works-short' => 'Prods',
    'competitions received works' => 'Prods received',
    'competitions approved works' => 'Prods approved',

    'works empty' => 'You have not uploaded any prods yet',
    'works send' => 'Send prod',
    'works title' => 'Title',
    'works author' => 'Author',
    'works author note' => 'Author\'s note',
    'works platform' => 'Platform',
    'works format' => 'Format',
    'works description' => 'Comment for organizers',
    'works description public' => 'Comment for visitors',
    'works description refs' => 'Display additional materials during voting (phases, references, etc)',
    'works description refs options' => array('Yes', 'No', 'At the discretion of the organizers', 'Another (in comment)'),

    'works voting' => 'Voting',
    'works status' => 'Status',

    'works tab main' => 'Main',
    'works tab preview' => 'Preview',

    'works permanent link' => 'Permanent link',

    'works files' => 'Files',
    'works add files' => 'Add more files',
    'works add files submit' => 'Send files',
    'works add file comment' => 'Comment',
    'works filesize' => 'Filesize',
    'works uploaded' => 'Uploaded',
    'filestatus voting' => 'File can be downloaded at online voting',
    'filestatus image' => 'File used as image at online voting and in public prod profile',
    'filestatus audio' => 'File used in audio-player at online voting and in public prod profile',
    'filestatus release' => 'File will be added in prods pack and can be downloaded from public prod profile',

    'works upload no file error' => 'No files for uploading!.',

    'works upload info' => '<p>The uploaded files will be stored on the server only after you press the "Send prod" button.</p><p>You can also include extra files (like screenshots, file for voting and nfo file).</p><p>You will receive an e-mail confirmation of your prod\'s approval after it is verified by the organizers.</p>',
    'works upload agree warning' => 'You must agree to the rules of uploading work.',
    'works upload success message' => 'Prod stored successfully. You will receive an e-mail confirmation of your prod`s approval status after it is verified by the organizers.',
    'works added files success message' => 'New files in prod profile stored successfully.',
    'works status desc' => array(
        0 => 'Not checked yet',
        1 => 'Verified',
        2 => 'Disqualified',
        3 => 'Feedback needed',
        4 => 'Out of compo',
        5 => 'Wait preselection',
    ),
    'works status desc full' => array(
        0 => 'The prod is being processed by the organizing committee.',
        1 => 'The prod is accepted.',
        2 => 'Work is disqualified.',
        3 => 'Awaiting author\'s feedback.',
        4 => 'Prod will not be shown on the demoparty, but will be included in the release pack.',
        5 => 'Prod wait to preselect.'
    ),

    'works details' => 'Prods',
    'works place' => 'Place',
    'works average_vote' => 'Average vote',
    'works num_votes' => 'Number of votes',
    'works total_scores' => 'Total scores',

    'works comments count' => 'Comments',
    'works comments write' => 'Write comment',
    'works comments send' => 'Send comment',
    'works comments attention register' => 'Only registered users can write comments.',

    'voting to' => 'Voting ends on',
    'voting audio not support' => 'Ваш браузер не поддерживает воспроизведение аудио.<br />Вы можете скачать данный аудиофайл по ссылке ниже.',
    'voting votes' => array(
        0 => 'Skip voting',
        1 => '1: Very bad',
        2 => '2',
        3 => '3',
        4 => '4',
        5 => '5',
        6 => '6',
        7 => '7',
        8 => '8',
        9 => '9',
        10 => '10: Best'
    ),
    'voting name' => 'Your name or nick',
    'voting vote' => 'Your vote',
    'voting note' => '<strong>Attention!</strong> Your votes and your name may be published by demoparty orgs.',
    'voting send' => 'Do vote!',
    'voting error empty votelist' => 'Please fill votes',
    'voting error wrong username' => 'Please fill your name.',
    'voting error wrong votekey' => 'Wrong votekey.',
    'voting success note' => 'Your vote accepted.',

    'votekey-request note' => 'Votekey will be send to given e-mail address. <br />E-mail address never be published by demoparty orgs.',
    'votekey-request email label' => 'E-mail address',
    'votekey-request' => 'Request votekey',
    'votekey-another' => 'Another votekey',
    'votekey-request long' => 'Request votekey',
    'votekey-request send' => 'Send request',
    'votekey-request wrong email' => 'Incorrect e-mail address',
    'votekey-request success note' => 'New votekey succesfully generated and sended to given e-mail address.',
    'votekey-request success note2' => 'Votekey succesfully sended to given e-mail address.',

    'votelist nickname' => 'Your nickname / realname',
    'votelist note' => '<p>В поле «Vote» напротив работы поставьте оценку от <strong>1 до 10</strong>, которой на Ваш взгляд заслуживает работа.</p><p>Если Вы затрудняетесь с оценкой, или просто не хотите голосовать - оставьте соответствующее поле пустым.</p><p>В свободном месте после названия работы Вы можете оставить свой комментарий.</p>',

    '53c reception form' => 'Prod submission begins at',

    // /upload link
    'upload info' => 'To upload the prof, you need to log in or <a href="/users?action=register">register</a>.',
);