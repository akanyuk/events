<?php
// Russian language file for main template
$lang_main = array(
	'set language' => 'Установить язык',

	'news' => 'Новости',
	'latest news' => 'Новости',
	
	'days' 				=> 'дней',
	'hours'				=> 'часов',
	'minutes'			=> 'минут',
	'unavailable' 		=> 'недоступно',
	'event closed' 		=> 'закончено',
	'reception closed' 	=> 'завершено',
	'voting closed' 	=> 'закончено',

	'close button' => 'Закрыть',
	
	// register.html
	'register' => array(
		// email
		'complete subject'			=> 'Retroscene Events: Welcome',
		'restore password subject' 	=> 'Retroscene Events: восстановление пароля',
		
		// controler
		'already registered'=> 'Вы уже зарегистрированы. Для регистрации другого пользователя Вам необходимо <a href="?action=logout">выйти из системы</a>.',
		'complete desc' 	=> 'На указанный Вами E-mail адрес выслана инструкция для продолжения регистрации.',
		'wrong key'			=> 'Указанный активационный ключ не подходит (возможно, истекло время его использования). Пожалуйста, запросите новый.',
		
		// template
		'registration'		=> 'Зарегистрироваться',
		'label info'		=> 'Данные учетной записи',
		'username'			=> 'Логин',
		'realname'			=> 'Полное имя',
		'language'			=> 'Язык',
		'country'			=> 'Страна',
		'city'			=> 'Город',

		'send'				=> 'Зарегистрироваться',
		'captcha'			=> 'Защитный код',
		'captcha info'		=> 'Для того, чтобы доказать, что вы не спам-бот, введите изображенные цифры.',
		'label success'		=> 'Регистрация завершена',
		
		'activation'		=> 'Активация учетной записи',
		'password'			=> 'Ваш новый пароль',
		're-password'		=> 'Повторите ввод',
		'activate'			=> 'Активировать учетную запись',
		
		'restore password' 			=> 'Восстановить пароль',
		'restore password btn'		=> 'Забыли пароль?',
		'restore password label' 	=> 'Запросить восстановление пароля',
		'restore password info' 	=> 'После отправки данных новый пароль со ссылкой на его активацию будет выслан на&nbsp;Ваш e-mail адрес.',
		'restore send'				=> 'Отправить запрос',
		'restore complete caption'	=> 'Операция завершена',
		'restore message'			=> 'Если вы правильно указали Ваш логин, то сообщение c инструкцией по активации нового пароля отправлено на Ваш E-mail адрес.',
	),
	
	'cabinet prods' 	=> 'Мои работы',
	'cabinet profile' 	=> 'Мой профиль',
	'cabinet add work' 	=> 'Загрузить работу',
	'cabinet' => array(
		// Profile edit
		'edit profile' => 'Профиль пользователя',
		'save profile' => 'Сохранить изменения',
		'edit password' => 'Смена пароля',
		'old-password' => 'Старый пароль',
		'do not change password' => 'Если Вы не хотите менять пароль – оставьте все три поля пустыми.',
	),
	
	'events' 			=> 'События',
	'event' 			=> 'Событие',
	'events no open' 	=> 'В настоящее время нет мероприятий с открытым приемом работ.',
	
	'competition' 				=> 'Номинация',
	'competions title' 			=> 'Номинация',
	'competions type'			=> 'Тип работ',
	'competions reception'		=> 'Прием работ',
	'competions voting' 		=> 'Голосование',
	'competions approved works-short'	=> 'Работ',
	'competions approved works'			=> 'Прислано работ',

	'works empty'	=> 'У Вас не загружено ни одной работы',
	'works send' 	=> 'Отправить работу',
	'works title' 	=> 'Название',
	'works author' 	=> 'Автор',
	'works platform'	=> 'Платформа',
	'works format'		=> 'Формат',
	'works description'	=> 'Описание',
	'works voting' 	=> 'Голосование',
	'works status' 	=> 'Статус',
	'works posted' 	=> 'Добавлена',
	
	'works files'	=> 'Файлы',
	'works filesize' => 'Размер',
	'works uploaded' => 'Загружен',
	'filestatus voting' => 'Файл будет доступен для скачивания во время голосования',
	'filestatus image' => 'Файл будет отображаться в качестве изображения во время голосования и в публичном профиле работы',
	'filestatus audio' => 'Файл будет использоваться в audio-плеере во время голосования и в публичном профиле работы',
	'filestatus release' => 'Файл будет доступен для скачивания в публичном профиле работы, а так же будет добавлен в пак работ',
	
	'works upload info' => '<p>Загруженные файлы будут сохранены на сервере только после нажатия кнопки «Отправить работу».</p><p>Вы можете загрузить несколько файлов (скриншот, файл для голосования, архив для релиза), указав описания файлов в поле «Комментарий».</p><p>После проверки оргкомитетом на Ваш e-mail адрес будет выслано оповещение о&nbsp;текущем статусе работы.</p>',
	'works upload success label' => 'Отправка работы завершена',
	'works upload success message' => 'Работа успешно сохранена. После проверки оргкомитетом Вы получите e-mail оповещение о&nbsp;текущем статусе работы.',
	'works status desc' => array(
		0 => 'Не проверена',
		1 => 'Проверена',
		2 => 'Дисквалифицирована',
		3 => 'Ожидание ответа',
		4 => 'Вне конкурса'
	),
	'works status desc full' => array(
		0 => 'Работа пока не проверена оргкомитетом.',
		1 => 'Работа принята.',
		2 => 'Работа дисквалифицирована.',
		3 => 'Ожидание ответа автора.',
		4 => 'Работа не будет показана на фестиваля, но будет включена в финальный пак работ.'
	),
	
	'works details' => 'Работы',
	'works place' => 'Место',
	'works average_vote' => 'Средний балл',
	'works num_votes' => 'Всего голосов',
	'works total_scores' => 'Всего баллов',
	
	'voting to' => 'Голосование до',
	'voting download' => 'Скачать',
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
	'voting note' => '<strong>Внимание!</strong> Ваши оценки и ник могут быть опубликованы организаторами демопати.',
	'voting send' => 'Проголосовать!',
	'voting error empty votelist' => 'Пожалуйста заполните оценки.',
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
	'votekey-request success note' => 'Новый ключ голосования успешно сгенерирован и отправлен на указанный e-mail адрес.',
	'votekey-request success note2' => 'Ключ голосования повторно отправлен на указанный e-mail адрес.',

	'votelist nickname' => 'Ваше имя или ник',	
	'votelist note' => '<p>В поле «Vote» напротив работы поставьте оценку от <strong>1 до 10</strong>, которой на Ваш взгляд заслуживает работа.</p><p>Если Вы затрудняетесь с оценкой работы, или просто не хотите голосовать - оставьте поле пустым.</p><p>В свободном месте после названия работы Вы можете оставить свой комментарий.</p>',
	
	'53c reception form' => 'Прием работ на конкурс откроется',
);