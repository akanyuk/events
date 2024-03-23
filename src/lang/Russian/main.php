<?php
/**
 * @desc Russian language file for main template
 */
$lang_main = array(
    'days suffix' => array('день', 'дня', 'дней'),
    'hours suffix' => array('час', 'часа', 'часов'),
    'minutes suffix' => array('минута', 'минуты', 'минут'),
    'today' => 'Сегодня',
    'yesterday' => 'Вчера',

    'news' => 'Новости',
    'latest news' => 'Новости',
    'all news' => 'Все новости',
    'comments' => 'Комментарии',
    'latest comments' => 'Комментарии',
    'all comments' => 'Все комментарии',
    'days left' => 'дней осталось',
    'unavailable' => 'недоступно',
    'reception closed' => 'завершено',
    'voting closed' => 'закончено',
    'choose button' => 'Выбрать',
    'search hint' => 'Поиск по названию или автору',

    'download' => 'скачать',

    'cabinet prods' => 'Мои работы',
    'cabinet profile' => 'Мой профиль',
    'cabinet add work' => 'Загрузить работу',
    'cabinet add work at' => 'Загрузить работу для',
    'cabinet add choose event' => 'Выберите событие',
    'cabinet add choose event desc' => 'Выберите событие для загрузки работы',

    'latest events' => 'Последние события',
    'all events' => 'Все события',
    'events' => 'События',
    'event' => 'Событие',
    'events no open' => 'В настоящее время нет событий с открытым приемом работ.',
    'events not found' => 'Событие не найдено.',

    'competition' => 'Номинация',
    'competitions type' => 'Тип работ',
    'competitions reception' => 'Прием работ',
    'competitions voting' => 'Голосование',
    'competitions approved works-short' => 'Работ',
    'competitions received works' => 'Прислано работ',
    'competitions approved works' => 'Принято работ',

    'works empty' => 'У Вас не загружено ни одной работы',
    'works send' => 'Отправить работу',
    'works title' => 'Название',
    'works author' => 'Автор',
    'works author note' => 'Комментарий автора',
    'works platform' => 'Платформа',
    'works format' => 'Формат',
    'works description' => 'Комментарий для организаторов',
    'works description public' => 'Комментарий для зрителей',
    'works description refs' => 'Отображать при голосовании дополнительные материалы (фазы, референсы и т.п.)',
    'works description refs options' => array('Да', 'Нет', 'На усмотрение организаторов', 'Другое (в комментарии)'),

    'works voting' => 'Голосование',
    'works status' => 'Статус',
    'works release' => 'Публикация',
    'works reason' => 'Причина',

    'works tab main' => 'Информация',
    'works tab preview' => 'Превью',

    'works permanent link' => 'Постоянная ссылка',

    'works files' => 'Файлы',
    'works add files' => 'Дозагрузить файлы',
    'works add files submit' => 'Отправить',
    'works add file comment' => 'Комментарий',
    'works filesize' => 'Размер',
    'works uploaded' => 'Загружен',
    'filestatus voting' => 'Файл будет доступен для скачивания во время голосования',
    'filestatus image' => 'Файл будет отображаться в качестве изображения во время голосования и в публичном профиле работы',
    'filestatus audio' => 'Файл будет использоваться в audio-плеере во время голосования и в публичном профиле работы',
    'filestatus release' => 'Файл будет доступен для скачивания в публичном профиле работы, а так же будет добавлен в пак работ',

    'works upload no file error' => 'Вы не добавили ни одного файла для загрузки.',

    'works upload info' => '<p>Загруженные файлы будут сохранены на сервере только после нажатия кнопки «Отправить работу».</p><p>Вы можете загрузить несколько файлов (скриншот, файл для голосования, архив для релиза).</p><p>После проверки оргкомитетом на Ваш e-mail адрес будет выслано оповещение о&nbsp;текущем статусе работы.</p>',
    'works upload agree warning' => 'Вы должны согласиться с правилами загрузки работы.',
    'works upload success message' => 'Работа успешно сохранена. После проверки оргкомитетом Вы получите e-mail оповещение о&nbsp;текущем статусе работы.',
    'works added files success message' => 'Новые файлы добавлены в профиль работы.',
    'works status desc' => array(
        0 => 'Not checked yet',
        1 => 'Verified',
        2 => 'Disqualified',
        3 => 'Feedback needed',
        4 => 'Out of compo',
        5 => 'Wait preselection',
    ),
    'works status desc full' => array(
        0 => 'Работа пока не проверена организаторами',
        1 => 'Работа принята',
        2 => 'Работа дисквалифицирована',
        3 => 'Ожидание ответа автора',
        4 => 'Работа не будет показана на фестиваля, но будет включена в финальный пак работ',
        5 => 'Работа принята, ожидает преселект'
    ),

    'works details' => 'Работы',
    'works place' => 'Место',
    'works average_vote' => 'Средний балл',
    'works num_votes' => 'Всего голосов',
    'works total_scores' => 'Всего баллов',

    'works your comment' => 'Ваш комментарии. Будет виден всем посетителям сайта',
    'works comments count' => 'Обсудить',
    'works comments write' => 'Написать комментарий',
    'works comments send' => 'Отправить',
    'works comments attention register' => 'Только зарегистрированные пользователи могут оставлять комментарии.',

    'voting to' => 'Голосование до',
    'voting audio not support' => 'Your browser does not support the audio element.<br />Please download file from link bellow.',
    'voting votes' => array(
        0 => 'Не Голосовать',
        1 => '1: Ужасно',
        2 => '2',
        3 => '3',
        4 => '4',
        5 => '5',
        6 => '6',
        7 => '7',
        8 => '8',
        9 => '9',
        10 => '10: Отлично'
    ),
    'voting name' => 'Ваше имя или ник',
    'voting vote' => 'Ваша оценка',
    'voting note' => '<strong>Внимание!</strong> Ваши оценки и ник могут быть опубликованы организаторами демопати.',
    'voting send' => 'Проголосовать!',
    'voting error wrong username' => 'Пожалуйста укажите имя.',
    'voting error wrong votekey' => 'Ключ голосования не найден.',
    'voting success note' => 'Ваш голос принят.',

    'votekey-request note' => 'Ключ для голосования будет выслан на указанный e-mail адрес. <br />Адрес опубликован не будет.',
    'votekey-request email label' => 'E-mail адрес',
    'votekey-request' => 'Запросить ключ',
    'votekey-another' => 'Другой ключ',
    'votekey-request long' => 'Запросить ключ голосования',
    'votekey-request send' => 'Отправить запрос',
    'votekey-request wrong email' => 'Некорректный e-mail адрес',
    'votekey-request success note' => 'Ключ голосования отправлен на указанный e-mail адрес.',

    'votelist nickname' => 'Ваше имя или ник',
    'votelist note' => '<p>В поле «Vote» напротив работы поставьте оценку от <strong>1 до 10</strong>, которой на Ваш взгляд заслуживает работа.</p><p>Если Вы затрудняетесь с оценкой работы, или просто не хотите голосовать - оставьте поле пустым.</p><p>В свободном месте после названия работы Вы можете оставить свой комментарий.</p>',

    // /upload link
    'upload info' => 'Для загрузки работы Вам необходимо авторизоваться или пройти <a href="/users?action=register">регистрацию</a>.'
);