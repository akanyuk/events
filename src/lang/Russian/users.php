<?php
/**
 * @desc Russian language file for users class
 */
$lang_users = array(
    // registration
    'Registration' => 'Зарегистрироваться',
    'Registration send' => 'Зарегистрироваться',
    'Registration complete' => 'Регистрация завершена',
    'Registration message' => 'На указанный Вами E-mail адрес выслана инструкция для продолжения регистрации.',
    'Registration subj' => 'Welcome',

    // Activation
    'Activation' => 'Активация учетной записи',
    'Activation send' => 'Активировать учетную запись',

    // Restore password
    'Restore password' => 'Восстановить пароль',
    'Restore password send' => 'Отправить запрос',
    'Restore password message' => 'Если вы правильно указали Ваш логин, то сообщение c инструкцией по активации нового пароля отправлено на Ваш E-mail адрес.',
    'Restore password subj' => 'Восстановление пароля',

    'Profile tab' => 'Профиль',
    'Password tab' => 'Пароль',

    // profile
    'My profile' => 'Мой профиль',
    'Old password' => 'Старый пароль',
    'Save password' => 'Сохранить пароль',
    'Update profile message' => 'Профиль пользователя обновлен',
    'Update password message' => 'Пароль изменен',

    'Errors' => array(
        'Not registered' => 'Страница доступна только для зарегистрированных пользователей. Пожалуйста, <a href="/users/register">зарегистрируйтесь</a>',
        'Already registered' => 'Вы уже зарегистрированы. Для регистрации другого пользователя Вам необходимо <a href="?action=logout">выйти из системы</a>',
        'Wrong old password' => 'Старый пароль указан некорректно',
        'Wrong key' => 'Указанный активационный ключ не подходит (возможно, истекло время его использования). Пожалуйста, запросите новый',
        'Passwords mismatch' => 'Пароли не совпадают',
        'Password too short' => 'Пароль не может быть менее 4-х символов',
    ),
);