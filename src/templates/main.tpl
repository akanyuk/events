<?php
/**
 * @var $page array
 * @var $page_title string
 */
reset($page);

NFW::i()->registerResource('main');
NFW::i()->registerFunction('page_is');

if (NFW::i()->user['is_guest']) {
    NFW::i()->registerResource('jquery.activeForm');
}

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
    NFW::i()->user['language'] == 'Russian' ? 'ру' : '<a class="text-white" href="' . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('lang' => 'Russian'))) . '">ру</a>'
);
?>
<!DOCTYPE html>
<html lang="<?php echo NFW::i()->lang['lang'] ?>" data-bs-theme="<?php echo $theme ?>">
<head><title><?php echo $page_title ?? $page['title'] ?></title>
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

    <link href="<?php echo NFW::i()->base_path?>vendor/bootstrap5/theme/bootstrap.min.css" rel="stylesheet">

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

        .input-search {
            padding-top: 0.2rem;
            padding-bottom: 0.2rem;
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
</svg>

<main class="fixed-top navbar-events">
    <header>
        <div class="container-fluid d-grid gap-3 align-items-center" style="grid-template-columns: 0fr 2fr 1fr;">
            <a href="/"><img src="<?php echo NFW::i()->assets('main/logo.gif') ?>" alt=""/></a>

            <div class="w-100">
                <form class="d-none d-sm-block me-3" role="search">
                    <input type="search" class="form-control input-search" aria-label="Search"
                           placeholder="<?php echo $langMain['search hint'] ?>">
                </form>
            </div>

            <div class="d-flex py-1 align-items-center">
                <div class="w-100">&nbsp;</div>

                <div class="d-block d-sm-none me-3">
                    <a href="#" class="text-white"
                       data-bs-toggle="collapse" data-bs-target="#collapseSearch"
                       aria-expanded="false" aria-controls="collapseExample">
                        <svg class="fill-white" width="1em" height="1em">
                            <use href="#icon-search"></use>
                        </svg>
                    </a>
                </div>

                <div class="d-none d-sm-block">
                    <div class="text-nowrap me-3"><?php echo implode(' • ', $langLinks) ?></div>
                </div>
                <div class="d-block d-sm-none">
                    <div class="text-nowrap me-3"><?php echo implode(' • ', $langLinksXs) ?></div>
                </div>

                <?php if ($theme == 'light'): ?>
                    <a class="text-white" href="<?php echo $themeLinkDark ?>">
                        <svg class="me-3" width="1em" height="1em">
                            <use href="#theme-icon-light"></use>
                        </svg>
                    </a>
                <?php elseif ($theme == 'dark'): ?>
                    <a class="text-white" href="<?php echo $themeLinkLight ?>">
                        <svg class="me-3" width="1em" height="1em">
                            <use href="#theme-icon-dark"></use>
                        </svg>
                    </a>
                <?php endif; ?>

                <?php if (NFW::i()->user['is_guest']): ?>
                    <a href="#" class="d-block py-2 text-white text-decoration-none"
                       data-bs-toggle="offcanvas"
                       data-bs-target="#offcanvasLogin"
                       aria-controls="offcanvasLogin">
                        <svg class="fill-white" width="1em" height="1em">
                            <use href="#icon-user"></use>
                        </svg>
                    </a>
                <?php else: ?>
                    <div class="me-3 dropdown">
                        <a href="#" class="d-block py-2 text-white text-decoration-none"
                           data-bs-toggle="dropdown" aria-expanded="false">
                            <svg class="fill-white" width="1em" height="1em">
                                <use href="#icon-user"></use>
                            </svg>
                        </a>
                        <ul class="dropdown-menu text-small shadow">
                            <li><a href="<?php echo NFW::i()->absolute_path ?>/cabinet/works?action=list"
                                   class="dropdown-item<?php echo page_is('cabinet/works?action=list') ? ' active' : '' ?>"><?php echo $langMain['cabinet prods'] ?></a>
                            </li>
                            <li><a href="<?php echo NFW::i()->absolute_path ?>/cabinet/works?action=add"
                                   class="dropdown-item<?php echo page_is('cabinet/works?action=add') ? ' active' : '' ?>"><?php echo $langMain['cabinet add work'] ?></a>
                            </li>
                            <li><a href="<?php echo NFW::i()->absolute_path ?>/users?action=update_profile"
                                   class="dropdown-item<?php echo page_is('users?action=update_profile') ? ' active' : '' ?>"><?php echo $langMain['cabinet profile'] ?></a>
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
        </div>
    </header>
    <header class="collapse m-3" id="collapseSearch">
        <form role="search">
            <input type="search" class="form-control input-search" aria-label="Search"
                   placeholder="<?php echo $langMain['search hint'] ?>">
        </form>
    </header>
</main>

<?php if (NFW::i()->user['is_guest']): ?>
    <div id="offcanvasLogin" class="offcanvas offcanvas-top" style="height: 400px;" tabindex="-1"
         aria-labelledby="offcanvasLoginLabel">
        <div class="offcanvas-header">
            <h5 class="offcanvas-title" id="offcanvasLoginLabel"><?php echo NFW::i()->lang['Authorization'] ?></h5>
            <button type="button" class="btn-close" data-bs-dismiss="offcanvas" aria-label="Close"></button>
        </div>
        <div class="offcanvas-body">
            <form id="login-form" class="mb-2">
                <div data-active-container="username" class="my-2">
                    <input type="text" class="form-control" name="username" placeholder="Username"/>
                </div>

                <div data-active-container="password" class="my-2">
                    <input type="password" class="form-control" name="password" placeholder="Password"/>
                    <div id="result" class="my-1 text-danger"></div>
                </div>

                <button type="submit" name="login" class="btn btn-primary"><?php echo NFW::i()->lang['GoIn'] ?></button>
            </form>

            <p>
                <a href="<?php echo NFW::i()->base_path ?>users?action=restore_password"><?php echo $langUsers['Restore password'] ?></a>
            </p>
            <p>
                <a href="<?php echo NFW::i()->base_path ?>users?action=register"><?php echo $langUsers['Registration'] ?></a>
            </p>
            <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                    src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                    alt="Sign in with SceneID"/></a>
        </div>
    </div>
<?php endif; ?>

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
            echo '<ol class="breadcrumb mb-1">';
            foreach (NFW::i()->breadcrumb as $b) {
                if (isset($b['url']) && $b['url']) {
                    echo '<li class="breadcrumb-item"><a href="' . NFW::i()->base_path . $b['url'] . '">' . htmlspecialchars($b['desc']) . '</a></li>';
                } else {
                    echo '<li class="breadcrumb-item active" aria-current="page">' . htmlspecialchars($b['desc']) . '</li>';
                }
            }
            echo '</ol>';
            echo '</nav>';
            echo '<div class="mb-2">'.NFW::i()->breadcrumb_status.'</div>';
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
<script src="<?php echo NFW::i()->base_path?>vendor/bootstrap5/js/bootstrap.bundle.js"></script>
<?php echo NFW::i()->fetch(NFW::i()->findTemplatePath('_main_bottom_script.tpl'), ['theme' => $theme]); ?>
</body>
</html>