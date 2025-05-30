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

    'comments' => 'Комментарии',
    'latest comments' => 'Комментарии',
    'all comments' => 'Все комментарии',
    'days left' => 'дней осталось',
    'unavailable' => 'недоступно',
    'reception closed' => 'завершено',
    'voting closed' => 'закончено',
    'choose button' => 'Выбрать',
    'download' => 'скачать',
    'Search' => 'Поиск',
    'search hint' => 'Поиск по названию или автору',
    'Search nothing found' => 'По вашему запросу ничего не найдено',
    'Reception opened' => 'Прием работ',

    'cabinet prods' => 'Мои работы',
    'cabinet profile' => 'Мой профиль',
    'cabinet add work' => 'Загрузить работу',
    'cabinet add choose event' => 'Выберите событие',
    'cabinet add choose event desc' => 'Выберите событие для загрузки работы',
    'Activity' => 'Activity', // TODO: translate
    'Show early activity' => 'Show early activity', // TODO: translate
    'New activity' => 'New activity', // TODO: translate
    'cabinet message send' => 'Написать сообщение организаторам',
    'cabinet send' => 'Отправить',
    'cabinet message required' => 'Необходимо написать текст сообщения',

    'latest events' => 'Последние события',
    'all events' => 'Все события',
    'events' => 'События',
    'event' => 'Событие',
    'events no open' => 'В настоящее время нет событий с открытым приемом работ',
    'events not found' => 'Событие не найдено.',

    'competition' => 'Номинация',
    'competitions type' => 'Тип работ',
    'competitions reception' => 'Прием работ',
    'competitions voting' => 'Голосование',
    'competitions approved works-short' => 'Работ',
    'competitions received works' => 'Прислано работ',
    'competitions approved works' => 'Принято работ',

    'works attributes' => [
        'author' => 'Автор',
        'title' => 'Название',
        'platform' => 'Платформа',
        'format' => 'Формат',
        'competition_id' => 'Номинация',
        'author_note' => 'Комментарий автора',
        'external_html' => 'Дополнительно',
    ],
    'works empty' => 'У Вас не загружено ни одной работы',
    'works send' => 'Отправить работу',
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
    'works filesize' => 'Размер',
    'works uploaded' => 'Загружен',
    'filestatus screenshot' => 'Скриншот для ссылок в социальных сетях и для показа работы на экране во время фестиваля (пати)',
    'filestatus voting' => 'Файл будет доступен для скачивания во время онлайн голосования',
    'filestatus image' => 'Файл будет отображаться в качестве изображения в публичном профиле работы',
    'filestatus audio' => 'Файл будет использоваться в audio-плеере во время голосования и в публичном профиле работы',
    'filestatus release' => 'Файл будет доступен для скачивания в публичном профиле работы',

    'work uploaded' => 'Работа загружена',
    'works upload no file error' => 'Вы не добавили ни одного файла для загрузки',
    'works upload info' => '<div class="mb1">Загруженные файлы будут сохранены на сервере только после нажатия кнопки «Отправить работу».</div><div class="mb1">Вы можете загрузить несколько файлов (скриншот, файл для голосования, архив для релиза).</div>',
    'works upload success message' => 'Работа успешно загружена. Изменение статуса отображается в разделе «Мои работы»',
    'works status desc' => array(
        0 => 'Not checked yet',
        1 => 'Verified',
        2 => 'Disqualified',
        3 => 'Feedback needed',
        4 => 'Out of compo',
        5 => 'Wait preselection',
        6 => 'Canceled',
    ),
    'works status desc full' => array(
        0 => 'Работа пока не проверена организаторами',
        1 => 'Работа принята',
        2 => 'Работа дисквалифицирована',
        3 => 'Ожидание ответа автора',
        4 => 'Работа не будет участвовать в голосовании, но будет показана вне конкурса',
        5 => 'Работа принята, ожидает преселект',
        6 => 'Конкурс отменен',
    ),

    'works details' => 'Работы',
    'works place' => 'Место',
    'works average_vote' => 'Средний балл',
    'works num_votes' => 'Всего голосов',
    'works total_scores' => 'Всего баллов',

    'works your comment' => 'Ваш комментарии. Будет виден всем посетителям сайта',
    'works comments count' => 'Обсудить',
    'works comments write' => 'Текст сообщения',
    'works comments send' => 'Отправить комментарий',
    'works comments attention register' => 'Только зарегистрированные пользователи могут оставлять комментарии.',

    'voting to' => 'Голосование до',
    'voting audio not support' => 'Your browser does not support the audio element.<br />Please download file from link bellow.',
    'voting votes' => array(
        0 => 'Не Голосовать',
        1 => '',
        2 => '2',
        3 => '3',
        4 => '4',
        5 => '5',
        6 => '6',
        7 => '7',
        8 => '8',
        9 => '9',
        10 => 'Отлично'
    ),
    'voting name' => 'Ваше имя или ник',
    'voting vote' => 'Ваша оценка',
    'voting note' => '<strong>Внимание!</strong> Ваши оценки и ник могут быть опубликованы организаторами пати.',
    'voting send' => 'Проголосовать!',
    'voting error wrong username' => 'Пожалуйста укажите имя.',
    'voting error wrong votekey' => 'Ключ голосования не найден.',
    'voting success note' => 'Ваш голос принят.',
    'Voting opened' => 'Голосование',

    'votekey-request note' => 'Ключ для голосования будет выслан на указанный e-mail адрес. <br />Адрес опубликован не будет.',
    'votekey-request email label' => 'E-mail адрес',
    'votekey-request' => 'Запросить НОВЫЙ ключ',
    'votekey-request long' => 'Запрос ключа голосования',
    'votekey-request send' => 'Отправить запрос',
    'votekey-request wrong email' => 'Некорректный e-mail адрес',
    'votekey-request success note' => 'Ключ голосования отправлен на указанный e-mail адрес.',

    'votelist nickname' => 'Ваше имя или ник',
    'votelist note' => '<p>В поле «Vote» напротив работы поставьте оценку от <strong>1 до 10</strong>, которой на Ваш взгляд заслуживает работа.</p><p>Если Вы затрудняетесь с оценкой работы, или просто не хотите голосовать - оставьте поле пустым.</p><p>В свободном месте после названия работы Вы можете оставить свой комментарий.</p>',

    // `/upload/%alias%` link
    'upload info' => 'Для загрузки работы Вам необходимо авторизоваться или пройти <a href="/users/register">регистрацию</a>.',

    // Live voting related
    'live voting info' => 'Для использования живого голосования Вам необходимо авторизоваться или пройти <a href="/users/register">регистрацию</a>.',
    'live voting not running' => 'В настоящее время живое голосование не запущено. Следите за обновлениями новостных каналов',
);