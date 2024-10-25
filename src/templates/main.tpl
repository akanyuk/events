<?php
/**
 * @var $page array
 * @var $page_title string
 */
reset($page);

NFW::i()->registerResource('main');
NFW::i()->registerFunction('page_is');

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
?>
<!DOCTYPE html>
<html lang="<?php echo NFW::i()->lang['lang'] ?>" data-bs-theme="<?php echo $theme ?>">
<head><title><?php echo $page_title ?? $page['title'] ?></title>
    <link href="<?php echo NFW::i()->base_path ?>vendor/bootstrap5/theme/bootstrap.min.css" rel="stylesheet"
          crossorigin="anonymous">

    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="Content-Language" content="<?php echo NFW::i()->lang['lang'] ?>"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="description" content="<?php echo NFWX::i()->project_settings['meta_description'] ?>"/>
    <meta name="keywords" content="<?php echo NFWX::i()->project_settings['meta_keywords'] ?>"/>

    <link rel="icon" type="image/png" sizes="16x16"
          href="<?php echo NFW::i()->assets('main/favicon/favicon-16x16.png') ?>"/>
    <link rel="icon" type="image/png" sizes="32x32"
          href="<?php echo NFW::i()->assets('main/favicon/favicon-32x32.png') ?>"/>
    <link rel="apple-touch-icon" sizes="144x144"
          href="<?php echo NFW::i()->assets('main/favicon/apple-touch-icon-144x144.png') ?>"/>
    <link rel="apple-touch-icon" sizes="180x180"
          href="<?php echo NFW::i()->assets('main/favicon/apple-touch-icon-180x180.png') ?>"/>
    <link rel="image_src" href="<?php echo NFW::i()->assets('main/favicon/image_src.png') ?>"/>
    <link rel="mask-icon"
          href="<?php echo NFW::i()->assets('main/favicon/safari-pinned-tab.svg') ?>" <?php echo 'color="#707070"' ?> />
    <link rel="manifest" href="<?php echo '/manifest.json' ?>">
    <meta name="theme-color" content="#707070">
    <meta name="msapplication-config" content="/browserconfig.xml"/>

    <?php
    foreach (NFWX::i()->main_og as $type => $value) {
        echo '<meta property="og:' . $type . '" content="' . htmlspecialchars($value) . '">' . "\n";
    }
    ?>
    <style>
        .navbar-events {
            background-color: #303030;
            color: #fff;
            padding-top: 0;
            padding-bottom: 0;
        }

        .fill-white {
            fill: #fff;
        }

        svg {
            fill: currentColor;
        }
    </style>
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
    <symbol id="theme-icon-auto" viewBox="0 0 16 16">
        <path d="M8 15A7 7 0 1 0 8 1v14zm0 1A8 8 0 1 1 8 0a8 8 0 0 1 0 16z"></path>
    </symbol>
    <symbol id="icon-user" viewBox="0 0 448 512">
        <path
            d="M224 256A128 128 0 1 0 224 0a128 128 0 1 0 0 256zm-45.7 48C79.8 304 0 383.8 0 482.3C0 498.7 13.3 512 29.7 512l388.6 0c16.4 0 29.7-13.3 29.7-29.7C448 383.8 368.2 304 269.7 304l-91.4 0z"/>
    </symbol>
    <symbol id="icon-search" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
        <path
            d="M416 208c0 45.9-14.9 88.3-40 122.7L502.6 457.4c12.5 12.5 12.5 32.8 0 45.3s-32.8 12.5-45.3 0L330.7 376c-34.4 25.2-76.8 40-122.7 40C93.1 416 0 322.9 0 208S93.1 0 208 0S416 93.1 416 208zM208 352a144 144 0 1 0 0-288 144 144 0 1 0 0 288z"/>
    </symbol>
    <symbol id="icon-caret-up" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512">
        <path
            d="M182.6 137.4c-12.5-12.5-32.8-12.5-45.3 0l-128 128c-9.2 9.2-11.9 22.9-6.9 34.9s16.6 19.8 29.6 19.8l256 0c12.9 0 24.6-7.8 29.6-19.8s2.2-25.7-6.9-34.9l-128-128z"/>
    </symbol>

    <symbol id="icon-arrow-repeat" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
        <path
            d="M11.534 7h3.932a.25.25 0 0 1 .192.41l-1.966 2.36a.25.25 0 0 1-.384 0l-1.966-2.36a.25.25 0 0 1 .192-.41m-11 2h3.932a.25.25 0 0 0 .192-.41L2.692 6.23a.25.25 0 0 0-.384 0L.342 8.59A.25.25 0 0 0 .534 9"/>
        <path fill-rule="evenodd"
              d="M8 3c-1.552 0-2.94.707-3.857 1.818a.5.5 0 1 1-.771-.636A6.002 6.002 0 0 1 13.917 7H12.9A5 5 0 0 0 8 3M3.1 9a5.002 5.002 0 0 0 8.757 2.182.5.5 0 1 1 .771.636A6.002 6.002 0 0 1 2.083 9z"/>
    </symbol>

    <symbol id="icon-pencil-square" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
        <path
            d="M15.502 1.94a.5.5 0 0 1 0 .706L14.459 3.69l-2-2L13.502.646a.5.5 0 0 1 .707 0l1.293 1.293zm-1.75 2.456-2-2L4.939 9.21a.5.5 0 0 0-.121.196l-.805 2.414a.25.25 0 0 0 .316.316l2.414-.805a.5.5 0 0 0 .196-.12l6.813-6.814z"/>
        <path fill-rule="evenodd"
              d="M1 13.5A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-6a.5.5 0 0 0-1 0v6a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-11a.5.5 0 0 1 .5-.5H9a.5.5 0 0 0 0-1H2.5A1.5 1.5 0 0 0 1 2.5z"/>
    </symbol>

    <symbol id="icon-person-video2" viewBox="0 0 16 16">
        <path d="M10 9.05a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5"/>
        <path d="M2 1a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V3a2 2 0 0 0-2-2zM1 3a1 1 0 0 1 1-1h2v2H1zm4 10V2h9a1 1 0 0 1 1 1v9c0 .285-.12.543-.31.725C14.15 11.494 12.822 10 10 10c-3.037 0-4.345 1.73-4.798 3zm-4-2h3v2H2a1 1 0 0 1-1-1zm3-1H1V8h3zm0-3H1V5h3z"/>
    </symbol>

    <symbol id="icon-x" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
        <path
            d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708"/>
    </symbol>

    <symbol id="icon-gear-fill" viewBox="0 0 16 16">
        <path
            d="M9.405 1.05c-.413-1.4-2.397-1.4-2.81 0l-.1.34a1.464 1.464 0 0 1-2.105.872l-.31-.17c-1.283-.698-2.686.705-1.987 1.987l.169.311c.446.82.023 1.841-.872 2.105l-.34.1c-1.4.413-1.4 2.397 0 2.81l.34.1a1.464 1.464 0 0 1 .872 2.105l-.17.31c-.698 1.283.705 2.686 1.987 1.987l.311-.169a1.464 1.464 0 0 1 2.105.872l.1.34c.413 1.4 2.397 1.4 2.81 0l.1-.34a1.464 1.464 0 0 1 2.105-.872l.31.17c1.283.698 2.686-.705 1.987-1.987l-.169-.311a1.464 1.464 0 0 1 .872-2.105l.34-.1c1.4-.413 1.4-2.397 0-2.81l-.34-.1a1.464 1.464 0 0 1-.872-2.105l.17-.31c.698-1.283-.705-2.686-1.987-1.987l-.311.169a1.464 1.464 0 0 1-2.105-.872zM8 10.93a2.929 2.929 0 1 1 0-5.86 2.929 2.929 0 0 1 0 5.858z"/>
    </symbol>
</svg>

<main class="fixed-top navbar-events">
    <header>
        <div class="container-fluid py-1 px-1 px-sm-3 px-md-5 d-flex justify-content-between align-items-center">
            <a href="/"><img src="<?php echo NFW::i()->assets('main/logo.gif') ?>" alt=""/></a>

            <div class="d-flex align-items-center">
                <div class="me-2 me-sm-3 me-md-4">
                    <a href="<?php echo NFW::i()->base_path ?>works/search" class="text-white">
                        <svg class="fill-white" width="1em" height="1em">
                            <use href="#icon-search"></use>
                        </svg>
                    </a>
                </div>

                <div class="vr me-2 me-sm-3 me-md-4 text-white"></div>

                <div class="me-2 me-sm-3 me-md-4">
                    <div class="d-none d-sm-block text-nowrap"><?php echo implode(' • ', $langLinks) ?></div>
                    <div class="d-block d-sm-none text-nowrap small"><?php echo implode(' ', $langLinksXs) ?></div>
                </div>

                <div class="me-2 me-sm-3 me-md-4">
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

                <div class="vr text-white me-2 me-sm-3 me-md-4"></div>

                <div class="me-2 me-sm-3 me-md-4">
                    <?php if (NFW::i()->user['is_guest']): ?>
                        <a href="#" class="d-block text-white text-decoration-none"
                           data-bs-toggle="offcanvas"
                           data-bs-target="#offcanvasLogin"
                           aria-controls="offcanvasLogin">
                            <svg class="fill-white" width="1em" height="1em">
                                <use href="#icon-user"></use>
                            </svg>
                        </a>
                    <?php else: ?>
                        <div class="dropdown">
                            <a href="#" class="d-block text-white text-decoration-none text-nowrap"
                               style="max-width: 240px;"
                               data-bs-toggle="dropdown" aria-expanded="false">
                                <svg class="fill-white" width="1em" height="1em">
                                    <use href="#icon-user"></use>
                                </svg>
                                <span
                                    class="d-none d-sm-inline ps-1"><?php echo htmlspecialchars(NFW::i()->user['username']) ?></span>
                            </a>
                            <ul class="dropdown-menu text-small shadow">
                                <li><a href="<?php echo NFW::i()->absolute_path ?>/cabinet/works?action=list"
                                       class="dropdown-item<?php echo page_is('cabinet/works?action=list') ? ' active' : '' ?>"><?php echo $langMain['cabinet prods'] ?></a>
                                </li>
                                <li><a href="<?php echo NFW::i()->absolute_path ?>/cabinet/works?action=add"
                                       class="dropdown-item<?php echo page_is('cabinet/works?action=add') ? ' active' : '' ?>"><?php echo $langMain['cabinet add work'] ?></a>
                                </li>
                                <li><a href="<?php echo NFW::i()->absolute_path ?>/users/update_profile"
                                       class="dropdown-item<?php echo page_is('users/update_profile') ? ' active' : '' ?>"><?php echo $langMain['cabinet profile'] ?></a>
                                </li>

                                <?php if (NFW::i()->checkPermissions('admin')): ?>
                                    <li><a href="/admin" class="dropdown-item">Control panel</a></li>
                                <?php endif; ?>

                                <li>
                                    <hr class="dropdown-divider">
                                </li>

                                <li><a class="dropdown-item"
                                       href="?action=logout"><?php echo NFW::i()->lang['Logout'] ?></a></li>
                            </ul>
                        </div>
                    <?php endif; ?>
                </div>
                <?php if (NFW::i()->checkPermissions('admin')): ?>
                    <div class="vr text-white d-none d-sm-block me-sm-3 me-md-4"></div>

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

<div id="page-content" class="container">
    <?php
    if (isset($page['is_error']) && $page['is_error']) {
        echo $page['content'];
    } else if ($page['path'] == '') {
        echo NFW::i()->fetch(NFW::i()->findTemplatePath('_main_index.tpl'));
    } else {
        if (!empty(NFW::i()->breadcrumb)) {
            echo '<div class="d-flex flex-column flex-md-row justify-content-between mb-3">';
            echo '<nav aria-label="breadcrumb">';
            echo '<ol class="breadcrumb  text-nowrap mb-1" style="flex-wrap: unset; overflow: scroll;">';
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
    <div id="offcanvasLogin" class="offcanvas offcanvas-top" style="height: fit-content;" tabindex="-1"
         aria-labelledby="offcanvasLoginLabel">
        <div class="offcanvas-header">
            <h5 class="offcanvas-title" id="offcanvasLoginLabel"><?php echo NFW::i()->lang['Authorization'] ?></h5>
            <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
        </div>
        <div class="offcanvas-body">
            <form onsubmit="loginFormSubmit(); return false;">
                <div class="mx-left col-sm-6 col-md-4 col-lg-3 mb-3">
                    <label for="login-username"><?php echo NFW::i()->lang['Login'] ?></label>
                    <input type="text" name="username" id="login-username" required="required" maxlength="64"
                           class="form-control">
                </div>

                <div class="mx-left col-sm-6 col-md-4 col-lg-3 mb-3">
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
<?php endif; ?>

<script src="<?php echo NFW::i()->base_path ?>vendor/bootstrap5/js/bootstrap.bundle.js"></script>
<?php echo NFW::i()->fetch(NFW::i()->findTemplatePath('_main_bottom_script.tpl'), ['theme' => $theme]); ?>
</body>
</html>