<?php
/**
 * @var $page array
 * @var $page_title string
 */
reset($page);

NFW::i()->registerResource('main');

$langMain = NFW::i()->getLang('main');
$langUsers = NFW::i()->getLang('users');

// Selecting theme
$theme = 'auto';
if (isset($_GET['theme']) && in_array($_GET['theme'], ['light', 'dark'])) {
    $theme = $_GET['theme'];
    NFW::i()->setCookie('theme', $theme, time() + 60 * 60 * 24 * 365);
} elseif (isset($_COOKIE['theme']) && in_array($_COOKIE['theme'], ['light', 'dark'])) {
    $theme = $_COOKIE['theme'];
}
$themeLinkLight = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('theme' => 'light')));
$themeLinkDark = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('theme' => 'dark')));

// Generate change language links
$langLinks = array(
    NFW::i()->user['language'] == 'English' ? 'english' : '<a class="text-white" href="' . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('lang' => 'English'))) . '">english</a>',
    NFW::i()->user['language'] == 'Russian' ? 'русский' : '<a class="text-white" href="' . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('lang' => 'Russian'))) . '">русский</a>'
);
$langLinksXs = array(
    NFW::i()->user['language'] == 'English' ? 'en' : '<a class="text-white" href="' . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('lang' => 'English'))) . '">en</a>',
    NFW::i()->user['language'] == 'Russian' ? 'ru' : '<a class="text-white" href="' . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('lang' => 'Russian'))) . '">ru</a>'
);

// Activity state
$authorActivityCnt = NFW::i()->user['is_guest'] ? 0 : works_activity::authorUnread();
$adminActivityCnt = NFW::i()->checkPermissions('admin') ? works_activity::adminUnread() : 0;
if ($authorActivityCnt + $adminActivityCnt > 99) {
    $userBadge = '99+';
} else if ($authorActivityCnt + $adminActivityCnt > 0) {
    $userBadge = $authorActivityCnt + $adminActivityCnt;
} else {
    $userBadge = '';
}
?>
<!DOCTYPE html>
<html lang="<?php echo NFW::i()->lang['lang'] ?>" data-bs-theme="<?php echo $theme ?>">
<head>
    <title><?php echo $page_title ?? $page['title'] ?></title>
    <link href="<?php echo NFW::i()->base_path ?>vendor/bootstrap5/theme/bootstrap.min.css" rel="stylesheet"
          crossorigin="anonymous">

    <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="<?php echo NFWX::i()->project_settings['meta_description'] ?>">
    <meta name="keywords" content="<?php echo NFWX::i()->project_settings['meta_keywords'] ?>">

    <link rel="icon" type="image/png" sizes="16x16"
          href="<?php echo NFW::i()->assets('main/favicon/favicon-16x16.png') ?>">
    <link rel="icon" type="image/png" sizes="32x32"
          href="<?php echo NFW::i()->assets('main/favicon/favicon-32x32.png') ?>">
    <link rel="apple-touch-icon" sizes="144x144"
          href="<?php echo NFW::i()->assets('main/favicon/apple-touch-icon-144x144.png') ?>">
    <link rel="apple-touch-icon" sizes="180x180"
          href="<?php echo NFW::i()->assets('main/favicon/apple-touch-icon-180x180.png') ?>">
    <link rel="image_src" href="<?php echo NFW::i()->assets('main/favicon/image_src.png') ?>">
    <link rel="mask-icon"
          href="<?php echo NFW::i()->assets('main/favicon/safari-pinned-tab.svg') ?>" <?php echo 'color="#707070"' ?>>
    <link rel="manifest" href="<?php echo '/manifest.json' ?>">
    <meta name="theme-color" content="#707070">
    <meta name="msapplication-config" content="/browserconfig.xml">

    <?php
    foreach (NFWX::i()->main_og as $type => $value) {
        echo '<meta property="og:' . $type . '" content="' . htmlspecialchars($value) . '">' . "\n";
    }
    ?>
</head>
<body>
<svg xmlns="http://www.w3.org/2000/svg" class="d-none">
    <symbol id="theme-icon-light" viewBox="0 0 16 16">
        <path
                d="M8 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM8 0a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 0zm0 13a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-1 0v-2A.5.5 0 0 1 8 13zm8-5a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2a.5.5 0 0 1 .5.5zM3 8a.5.5 0 0 1-.5.5h-2a.5.5 0 0 1 0-1h2A.5.5 0 0 1 3 8zm10.657-5.657a.5.5 0 0 1 0 .707l-1.414 1.415a.5.5 0 1 1-.707-.708l1.414-1.414a.5.5 0 0 1 .707 0zm-9.193 9.193a.5.5 0 0 1 0 .707L3.05 13.657a.5.5 0 0 1-.707-.707l1.414-1.414a.5.5 0 0 1 .707 0zm9.193 2.121a.5.5 0 0 1-.707 0l-1.414-1.414a.5.5 0 0 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .707zM4.464 4.465a.5.5 0 0 1-.707 0L2.343 3.05a.5.5 0 1 1 .707-.707l1.414 1.414a.5.5 0 0 1 0 .708z"/>
    </symbol>
    <symbol id="theme-icon-dark" viewBox="0 0 16 16">
        <path
                d="M6 .278a.768.768 0 0 1 .08.858 7.208 7.208 0 0 0-.878 3.46c0 4.021 3.278 7.277 7.318 7.277.527 0 1.04-.055 1.533-.16a.787.787 0 0 1 .81.316.733.733 0 0 1-.031.893A8.349 8.349 0 0 1 8.344 16C3.734 16 0 12.286 0 7.71 0 4.266 2.114 1.312 5.124.06A.752.752 0 0 1 6 .278z"/>
        <path
                d="M10.794 3.148a.217.217 0 0 1 .412 0l.387 1.162c.173.518.579.924 1.097 1.097l1.162.387a.217.217 0 0 1 0 .412l-1.162.387a1.734 1.734 0 0 0-1.097 1.097l-.387 1.162a.217.217 0 0 1-.412 0l-.387-1.162A1.734 1.734 0 0 0 9.31 6.593l-1.162-.387a.217.217 0 0 1 0-.412l1.162-.387a1.734 1.734 0 0 0 1.097-1.097l.387-1.162zM13.863.099a.145.145 0 0 1 .274 0l.258.774c.115.346.386.617.732.732l.774.258a.145.145 0 0 1 0 .274l-.774.258a1.156 1.156 0 0 0-.732.732l-.258.774a.145.145 0 0 1-.274 0l-.258-.774a1.156 1.156 0 0 0-.732-.732l-.774-.258a.145.145 0 0 1 0-.274l.774-.258c.346-.115.617-.386.732-.732L13.863.1z"/>
    </symbol>
    <symbol id="icon-user" viewBox="0 0 448 512">
        <path
                d="M224 256A128 128 0 1 0 224 0a128 128 0 1 0 0 256zm-45.7 48C79.8 304 0 383.8 0 482.3C0 498.7 13.3 512 29.7 512l388.6 0c16.4 0 29.7-13.3 29.7-29.7C448 383.8 368.2 304 269.7 304l-91.4 0z"/>
    </symbol>

    <symbol id="icon-search" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
        <path
                d="M416 208c0 45.9-14.9 88.3-40 122.7L502.6 457.4c12.5 12.5 12.5 32.8 0 45.3s-32.8 12.5-45.3 0L330.7 376c-34.4 25.2-76.8 40-122.7 40C93.1 416 0 322.9 0 208S93.1 0 208 0S416 93.1 416 208zM208 352a144 144 0 1 0 0-288 144 144 0 1 0 0 288z"/>
    </symbol>

    <symbol id="icon-chat-text" viewBox="0 0 16 16">
        <path d="M2.678 11.894a1 1 0 0 1 .287.801 11 11 0 0 1-.398 2c1.395-.323 2.247-.697 2.634-.893a1 1 0 0 1 .71-.074A8 8 0 0 0 8 14c3.996 0 7-2.807 7-6s-3.004-6-7-6-7 2.808-7 6c0 1.468.617 2.83 1.678 3.894m-.493 3.905a22 22 0 0 1-.713.129c-.2.032-.352-.176-.273-.362a10 10 0 0 0 .244-.637l.003-.01c.248-.72.45-1.548.524-2.319C.743 11.37 0 9.76 0 8c0-3.866 3.582-7 8-7s8 3.134 8 7-3.582 7-8 7a9 9 0 0 1-2.347-.306c-.52.263-1.639.742-3.468 1.105"/>
        <path d="M4 5.5a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7a.5.5 0 0 1-.5-.5M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8m0 2.5a.5.5 0 0 1 .5-.5h4a.5.5 0 0 1 0 1h-4a.5.5 0 0 1-.5-.5"/>
    </symbol>

    <symbol id="icon-chat-text-fill" viewBox="0 0 16 16">
        <path d="M16 8c0 3.866-3.582 7-8 7a9 9 0 0 1-2.347-.306c-.584.296-1.925.864-4.181 1.234-.2.032-.352-.176-.273-.362.354-.836.674-1.95.77-2.966C.744 11.37 0 9.76 0 8c0-3.866 3.582-7 8-7s8 3.134 8 7M4.5 5a.5.5 0 0 0 0 1h7a.5.5 0 0 0 0-1zm0 2.5a.5.5 0 0 0 0 1h7a.5.5 0 0 0 0-1zm0 2.5a.5.5 0 0 0 0 1h4a.5.5 0 0 0 0-1z"/>
    </symbol>

    <symbol id="icon-caret-up" viewBox="0 0 320 512">
        <path
                d="M182.6 137.4c-12.5-12.5-32.8-12.5-45.3 0l-128 128c-9.2 9.2-11.9 22.9-6.9 34.9s16.6 19.8 29.6 19.8l256 0c12.9 0 24.6-7.8 29.6-19.8s2.2-25.7-6.9-34.9l-128-128z"/>
    </symbol>

    <symbol id="icon-x" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
        <path
                d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708"/>
    </symbol>

    <symbol id="icon-plus-circle-fill" viewBox="0 0 16 16">
        <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0M8.5 4.5a.5.5 0 0 0-1 0v3h-3a.5.5 0 0 0 0 1h3v3a.5.5 0 0 0 1 0v-3h3a.5.5 0 0 0 0-1h-3z"/>
    </symbol>

    <symbol id="icon-bar-chart-line-fill" viewBox="0 0 16 16">
        <path d="M11 2a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v12h.5a.5.5 0 0 1 0 1H.5a.5.5 0 0 1 0-1H1v-3a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v3h1V7a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v7h1z"/>
    </symbol>

    <symbol id="icon-person-arms-up" viewBox="0 0 16 16">
        <path d="M8 3a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3"/>
        <path d="m5.93 6.704-.846 8.451a.768.768 0 0 0 1.523.203l.81-4.865a.59.59 0 0 1 1.165 0l.81 4.865a.768.768 0 0 0 1.523-.203l-.845-8.451A1.5 1.5 0 0 1 10.5 5.5L13 2.284a.796.796 0 0 0-1.239-.998L9.634 3.84a.7.7 0 0 1-.33.235c-.23.074-.665.176-1.304.176-.64 0-1.074-.102-1.305-.176a.7.7 0 0 1-.329-.235L4.239 1.286a.796.796 0 0 0-1.24.998l2.5 3.216c.317.316.475.758.43 1.204Z"/>
    </symbol>

    <symbol id="icon-circle-fill" viewBox="0 0 16 16">
        <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16m.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2"/>
    </symbol>

    <symbol id="icon-arrow-repeat" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
        <path
                d="M11.534 7h3.932a.25.25 0 0 1 .192.41l-1.966 2.36a.25.25 0 0 1-.384 0l-1.966-2.36a.25.25 0 0 1 .192-.41m-11 2h3.932a.25.25 0 0 0 .192-.41L2.692 6.23a.25.25 0 0 0-.384 0L.342 8.59A.25.25 0 0 0 .534 9"/>
        <path fill-rule="evenodd"
              d="M8 3c-1.552 0-2.94.707-3.857 1.818a.5.5 0 1 1-.771-.636A6.002 6.002 0 0 1 13.917 7H12.9A5 5 0 0 0 8 3M3.1 9a5.002 5.002 0 0 0 8.757 2.182.5.5 0 1 1 .771.636A6.002 6.002 0 0 1 2.083 9z"/>
    </symbol>

    <symbol id="icon-house-gear-fill" viewBox="0 0 16 16">
        <path d="M7.293 1.5a1 1 0 0 1 1.414 0L11 3.793V2.5a.5.5 0 0 1 .5-.5h1a.5.5 0 0 1 .5.5v3.293l2.354 2.353a.5.5 0 0 1-.708.708L8 2.207 1.354 8.854a.5.5 0 1 1-.708-.708z"/>
        <path d="M11.07 9.047a1.5 1.5 0 0 0-1.742.26l-.02.021a1.5 1.5 0 0 0-.261 1.742 1.5 1.5 0 0 0 0 2.86 1.5 1.5 0 0 0-.12 1.07H3.5A1.5 1.5 0 0 1 2 13.5V9.293l6-6 4.724 4.724a1.5 1.5 0 0 0-1.654 1.03"/>
        <path d="m13.158 9.608-.043-.148c-.181-.613-1.049-.613-1.23 0l-.043.148a.64.64 0 0 1-.921.382l-.136-.074c-.561-.306-1.175.308-.87.869l.075.136a.64.64 0 0 1-.382.92l-.148.045c-.613.18-.613 1.048 0 1.229l.148.043a.64.64 0 0 1 .382.921l-.074.136c-.306.561.308 1.175.869.87l.136-.075a.64.64 0 0 1 .92.382l.045.149c.18.612 1.048.612 1.229 0l.043-.15a.64.64 0 0 1 .921-.38l.136.074c.561.305 1.175-.309.87-.87l-.075-.136a.64.64 0 0 1 .382-.92l.149-.044c.612-.181.612-1.049 0-1.23l-.15-.043a.64.64 0 0 1-.38-.921l.074-.136c.305-.561-.309-1.175-.87-.87l-.136.075a.64.64 0 0 1-.92-.382ZM12.5 14a1.5 1.5 0 1 1 0-3 1.5 1.5 0 0 1 0 3"/>
    </symbol>

    <symbol id="icon-gear-fill" viewBox="0 0 16 16">
        <path
                d="M9.405 1.05c-.413-1.4-2.397-1.4-2.81 0l-.1.34a1.464 1.464 0 0 1-2.105.872l-.31-.17c-1.283-.698-2.686.705-1.987 1.987l.169.311c.446.82.023 1.841-.872 2.105l-.34.1c-1.4.413-1.4 2.397 0 2.81l.34.1a1.464 1.464 0 0 1 .872 2.105l-.17.31c-.698 1.283.705 2.686 1.987 1.987l.311-.169a1.464 1.464 0 0 1 2.105.872l.1.34c.413 1.4 2.397 1.4 2.81 0l.1-.34a1.464 1.464 0 0 1 2.105-.872l.31.17c1.283.698 2.686-.705 1.987-1.987l-.169-.311a1.464 1.464 0 0 1 .872-2.105l.34-.1c1.4-.413 1.4-2.397 0-2.81l-.34-.1a1.464 1.464 0 0 1-.872-2.105l.17-.31c.698-1.283-.705-2.686-1.987-1.987l-.311.169a1.464 1.464 0 0 1-2.105-.872zM8 10.93a2.929 2.929 0 1 1 0-5.86 2.929 2.929 0 0 1 0 5.858z"/>
    </symbol>
</svg>

<main class="fixed-top navbar-events">
    <header>
        <div class="container-fluid py-1 px-1 px-sm-3 px-md-5 d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-start">
                <a href="/"><img src="<?php echo NFW::i()->assets('main/logo.gif') ?>" alt=""></a>
                <h1 class="d-none d-lg-block d-xl-none"><?php echo htmlspecialchars(NFWX::i()->mainHeaderTittle)?></h1>
                <h1 class="d-none d-xl-block"><?php echo htmlspecialchars(NFWX::i()->mainHeaderTittleXl ? NFWX::i()->mainHeaderTittleXl : NFWX::i()->mainHeaderTittle)?></h1>
            </div>

            <div class="d-flex align-items-center">
                <?php if (works_comments::hasNew()): ?>
                    <div class="me-3 me-md-4">
                        <a title="<?php echo $langMain['latest comments'] ?>"
                           onclick="this.remove()"
                           href="<?php echo NFW::i()->absolute_path . '#latest-comments' ?>" class="text-warning">
                            <svg width="1em" height="1em">
                                <use href="#icon-chat-text-fill"></use>
                            </svg>
                        </a>
                    </div>
                <?php endif; ?>

                <div class="me-3 me-md-4">
                    <a href="<?php echo NFW::i()->base_path ?>works/search" class="text-white">
                        <svg width="1em" height="1em">
                            <use href="#icon-search"></use>
                        </svg>
                    </a>
                </div>

                <div class="vr me-3 me-md-4 text-white"></div>

                <div class="me-3 me-md-4">
                    <div class="d-none d-sm-block text-nowrap"><?php echo implode(' • ', $langLinks) ?></div>
                    <div class="d-block d-sm-none text-nowrap"><?php echo implode(' • ', $langLinksXs) ?></div>
                </div>

                <div class="me-3 me-md-4">
                    <?php if ($theme == 'light'): ?>
                        <a class="text-white" href="<?php echo $themeLinkDark ?>">
                            <svg width="1em" height="1em">
                                <use href="#theme-icon-light"></use>
                            </svg>
                        </a>
                    <?php elseif ($theme == 'dark'): ?>
                        <a class="text-white" href="<?php echo $themeLinkLight ?>">
                            <svg width="1em" height="1em">
                                <use href="#theme-icon-dark"></use>
                            </svg>
                        </a>
                    <?php endif; ?>
                </div>

                <div class="vr text-white me-3 me-md-4"></div>

                <div class="me-3 me-md-4">
                    <?php if (NFW::i()->user['is_guest']): ?>
                        <a href="#" class="d-block text-white text-decoration-none"
                           data-bs-toggle="offcanvas"
                           data-bs-target="#offcanvasLogin"
                           aria-controls="offcanvasLogin">
                            <svg width="1em" height="1em">
                                <use href="#icon-user"></use>
                            </svg>
                        </a>
                    <?php else: ?>
                        <a href="#" class="d-block text-white text-decoration-none text-nowrap"
                           style="max-width: 240px;"
                           data-bs-toggle="offcanvas"
                           data-bs-target="#offcanvasUser"
                           aria-controls="offcanvasUser">
                            <div class="d-block d-sm-none">
                                <svg id="header-xs-icon-user" width="1em"
                                     height="1em"<?php echo $userBadge ? ' class="text-warning"' : '' ?>>
                                    <use href="#icon-user"></use>
                                </svg>
                            </div>
                            <div class="d-none d-sm-inline-block">
                                <svg width="1em" height="1em">
                                    <use href="#icon-user"></use>
                                </svg>
                            </div>
                            <span class="d-none d-sm-inline ps-1"><?php echo htmlspecialchars(NFW::i()->user['username']) ?><span
                                        id="header-sm-username-badge"
                                        class="ms-2 badge rounded-pill bg-warning"><?php echo $userBadge?></span></span>
                        </a>
                    <?php endif; ?>
                 </div>
                <?php if (NFW::i()->checkPermissions('admin')): ?>
                    <div class="vr text-white d-none d-sm-block me-3 me-md-4"></div>

                    <div class="d-none d-sm-block">
                        <a class="text-white" href="/admin" title="Control panel">
                            <svg width="1em" height="1em">
                                <use href="#icon-gear-fill"></use>
                            </svg>
                        </a>
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </header>
</main>

<div class="container mt-3 mb-2 <?php echo NFWX::i()->mainContainerAdditionalClasses ?>">
    <?php
    if (isset($page['is_error']) && $page['is_error']) {
        echo $page['content'];
    } else if ($page['path'] == '') {
        echo NFW::i()->fetch(NFW::i()->findTemplatePath('_main_index.tpl'));
    } else {
        if (!empty(NFW::i()->breadcrumb)) {
            echo '<div class="d-flex flex-column flex-md-row justify-content-between mb-3">';
            echo '<nav aria-label="breadcrumb">';
            echo '<ol class="breadcrumb text-nowrap mb-1" style="flex-wrap: unset; overflow: auto;">';
            foreach (NFW::i()->breadcrumb as $b) {
                if (isset($b['url']) && $b['url']) {
                    echo '<li class="breadcrumb-item"><a href="' . NFW::i()->base_path . $b['url'] . '">' . htmlspecialchars($b['desc']) . '</a></li>';
                } else {
                    echo '<li class="breadcrumb-item active" aria-current="page">' . htmlspecialchars($b['desc']) . '</li>';
                }
            }
            echo '</ol>';
            echo '</nav>';
            echo '<div class="mb-2">' . NFW::i()->breadcrumb_status . '</div>';
            echo '</div>';
        }

        if (NFWX::i()->mainLayoutRightContent) {
            echo '<div class="row">';
            echo '<div class="col-md-8">' . $page['content'] . '</div>';
            echo '<div class="col-md-4">' . NFWX::i()->mainLayoutRightContent . '</div>';
            echo '</div>';
        } else {
            echo $page['content'];
        }
    } ?>
</div>

<?php echo NFWX::i()->project_settings['footer'] ?>

<?php if (NFW::i()->user['is_guest']): ?>
    <div id="offcanvasLogin" class="offcanvas offcanvas-end"
         tabindex="-1" aria-labelledby="offcanvasLoginLabel">
        <div class="offcanvas-header">
            <h5 class="offcanvas-title" id="offcanvasLoginLabel"><?php echo NFW::i()->lang['Authorization'] ?></h5>
            <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
        </div>
        <div class="offcanvas-body">
            <form onsubmit="loginFormSubmit(); return false;">
                <div class="mb-3">
                    <label for="login-username"><?php echo NFW::i()->lang['Login'] ?></label>
                    <input type="text" name="username" id="login-username" required="required" maxlength="64"
                           class="form-control">
                </div>

                <div class="mb-3">
                    <label for="login-password"><?php echo NFW::i()->lang['Password'] ?></label>
                    <input type="password" name="password" id="login-password" required="required" maxlength="64"
                           class="form-control">
                    <div id="login-feedback" class="invalid-feedback"></div>
                </div>

                <div class="mb-3">
                    <button type="submit" id="login-btn"
                            class="btn btn-primary"><?php echo NFW::i()->lang['GoIn'] ?></button>
                </div>
            </form>

            <div class="mb-3">
                <a href="<?php echo NFW::i()->base_path ?>users/restore_password"><?php echo $langUsers['Restore password'] ?></a>
            </div>

            <div class="mb-3">
                <a href="<?php echo NFW::i()->base_path ?>users/register"><?php echo $langUsers['Registration'] ?></a>
            </div>

            <div class="mb-5">
                <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                            src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                            alt="Sign in with SceneID"/></a>
            </div>
        </div>
    </div>
<?php else: ?>
    <div id="offcanvasUser" class="offcanvas offcanvas-end"
         tabindex="-1" aria-labelledby="offcanvasUserLabel">
        <div class="offcanvas-header">
            <h5 class="offcanvas-title" id="offcanvasUserLabel">Welcome, <?php echo htmlspecialchars(NFW::i()->user['realname']) ?></h5>
            <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
        </div>
        <div class="offcanvas-body">
            <div class="mb-3">
                <a href="<?php echo NFW::i()->absolute_path ?>/cabinet/works_list"><?php echo $langMain['cabinet prods'] ?>
                    <span id="header-sm-menu-prods-badge"
                          class="ms-2 badge rounded-pill bg-warning"><?php echo $authorActivityCnt > 0 ? ($authorActivityCnt > 99 ? "99+" : $authorActivityCnt) : '' ?></span>
                </a>
            </div>

            <div class="mb-3">
                <a href="<?php echo NFW::i()->absolute_path ?>/cabinet/works_add"><?php echo $langMain['cabinet add work'] ?></a>
            </div>

            <div class="mb-3">
                <a href="<?php echo NFW::i()->absolute_path ?>/users/update_profile"><?php echo $langMain['cabinet profile'] ?></a>
            </div>

            <?php if (NFW::i()->checkPermissions('admin')): ?>
                <div class="mb-3">
                    <a href="/admin">Control panel<?php if ($adminActivityCnt > 0): ?><span
                                class="ms-2 badge rounded-pill bg-warning"><?php echo $adminActivityCnt > 99 ? "99+" : $adminActivityCnt ?></span><?php endif; ?>
                    </a>
                </div>
            <?php endif; ?>

            <div class="mb-5">
                <a href="?action=logout"><?php echo NFW::i()->lang['Logout'] ?></a>
            </div>
        </div>
    </div>
<?php endif; ?>

<script src="<?php echo NFW::i()->base_path ?>vendor/bootstrap5/js/bootstrap.bundle.js"></script>
<?php echo NFW::i()->fetch(NFW::i()->findTemplatePath('_main_bottom_script.tpl'), ['theme' => $theme]); ?>
</body>
</html>
