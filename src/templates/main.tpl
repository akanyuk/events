<?php
/**
 * @var $page array
 * @var $page_title string
 */
reset($page);

NFW::i()->registerResource('bootstrap');
NFW::i()->registerResource('main');
NFW::i()->registerFunction('page_is');

if (NFW::i()->user['is_guest']) {
    NFW::i()->registerResource('jquery.activeForm');
}

$lang_main = NFW::i()->getLang('main');
$lang_users = NFW::i()->getLang('users');

// Collecting `meta_keywords` from project and page setting
$page['meta_keywords'] = isset($page['meta_keywords']) ? $page['meta_keywords'] : '';
$page['meta_description'] = isset($page['meta_description']) ? $page['meta_description'] : '';
$meta_keywords = array();
foreach (explode(',', NFW::i()->project_settings['meta_keywords'] . ',' . $page['meta_keywords']) as $keyword) {
    $keyword = trim($keyword);
    if (!$keyword) continue;
    $meta_keywords[] = $keyword;
}
$meta_keywords = implode(',', array_unique($meta_keywords));

$is_latest_comments = !(page_is('comments.html') || NFW::i()->current_controler != 'main');

// Generate change language links
$lang_links = array(
    NFW::i()->user['language'] == 'English' ? 'english' : '<a href="' . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('lang' => 'English'))) . '">english</a>',
    NFW::i()->user['language'] == 'Russian' ? 'русский' : '<a href="' . parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) . '?' . http_build_query(array_merge($_GET, array('lang' => 'Russian'))) . '">русский</a>'
);

// Countdown and timeline
ob_start();
$countdown = ceil((strtotime(NFWX::i()->project_settings['countdown_date']) - time()) / 86400);
if ($countdown > 0) {
    echo '<div style="text-align: right; margin-bottom: 20px;">';
    echo '<div style="font-weight: bold; font-size: 45pt; line-height: 40pt;">' . $countdown . '</div>';
    echo '<div style="font-size: 18pt; line-height: 22pt;">' . $lang_main['days left'] . '<br />' . NFW::i()->project_settings['countdown_date'] . '<br />' . nl2br(NFW::i()->project_settings['countdown_desc']) . '</div>';
    echo '<div class="clearfix"></div>';
    echo '</div>';
}
$countdowns_main = ob_get_clean();

// Comments
$works_comments = false;
if ($is_latest_comments) {
    $CWorksComments = new works_comments();
    $works_comments = $CWorksComments->displayLatestComments();
}
?>
<!DOCTYPE html>
<html lang="<?php echo NFW::i()->lang['lang'] ?>">
<head><title><?php echo $page_title ?? $page['title'] ?></title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="Content-Language" content="ru"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <meta name="description"
          content="<?php echo $page['meta_description'] ?: NFWX::i()->project_settings['meta_description'] ?>"/>
    <meta name="keywords" content="<?php echo $meta_keywords ?>"/>

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
    <link rel="manifest" href="/manifest.json">
    <meta name="theme-color" content="#707070">
    <meta name="msapplication-config" content="/browserconfig.xml"/>

    <?php
    foreach (NFWX::i()->main_og as $type => $value) {
        echo '<meta property="og:' . $type . '" content="' . $value . '">' . "\n";
    }
    ?>

    <script type="text/javascript">
        $(document).ready(function () {
            <?php if (NFW::i()->user['is_guest']):    ?>
            $('form[id="mobile-login-form"]').activeForm({
                success: function (response) {
                    if (response.redirect) {
                        window.location.href = response.redirect;
                    } else {
                        window.location.reload();
                    }
                }
            });
            <?php endif; ?>

            <?php if (NFW::i()->user['is_guest'] && NFW::i()->main_login_form): ?>
            $('form[id="login-form"]').activeForm({
                success: function (response) {
                    if (response.redirect) {
                        window.location.href = response.redirect;
                    } else {
                        window.location.reload();
                    }
                }
            });
            <?php endif; ?>

            <?php if (NFWX::i()->main_search_box): # Search box ?>
            $('input[id="works-search"]').typeahead({
                source: function (query, process) {
                    return $.get('/works?action=search&q=' + query, function (response) {
                        return process(response);
                    }, 'json');
                },
                displayText: function (item) {
                    return item.title;
                },
                afterSelect: function (sResult) {
                    $('input[id="works-search"]').val('');

                    if (sResult.link) {
                        window.location.href = sResult.link;
                    }
                },
                fitToElement: true,
                items: 'all',
                minLength: 1
            }).attr('autocomplete', 'off');
            <?php endif; ?>
        });
    </script>
</head>
<body>
<div role="banner" class="navbar navbar-inverse navbar-fixed-top dm-nav">
    <div class="container">
        <div class="lang-change lang-change-md"><?php echo implode(' • ', $lang_links) ?></div>

        <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" style="margin: 3px 0 0 0;" data-toggle="collapse"
                    data-target="#navbar-collapse" aria-expanded="false">
                <span class="sr-only">Toggle navigation</span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
                <span class="icon-bar"></span>
            </button>

            <div class="lang-change lang-change-xs"><?php echo implode(' • ', $lang_links) ?></div>

            <a href="/" style="float: left;"><img src="<?php echo NFW::i()->assets('main/rse-logo.gif') ?>" alt=""/></a>

            <ul class="nav navbar-nav hidden-xs">
                <?php foreach (NFWX::i()->main_menu as $m) { ?>
                    <li<?php echo page_is($m['path']) ? ' class="active"' : '' ?>><a
                                href="<?php echo NFW::i()->absolute_path . '/' . $m['path'] ?>"><?php echo NFW::i()->user['language'] == 'English' ? $m['desc_en'] : $m['desc'] ?></a>
                    </li>
                <?php } ?>
            </ul>
        </div>
        <div role="navigation" class="collapse navbar-collapse" id="navbar-collapse">
            <div class="hidden-sm hidden-md hidden-lg">
                <?php if (NFW::i()->user['is_guest']): ?>
                    <form id="mobile-login-form" class="mobile-login-form">
                        <div data-active-container="username" style="padding-bottom: 5px;">
                            <input type="text" class="form-control" name="username" placeholder="Username"/>
                        </div>

                        <div data-active-container="password" style="padding-bottom: 5px;">
                            <input type="password" class="form-control" name="password" placeholder="Pasword"/>
                            <span class="help-block"></span>
                        </div>

                        <button type="submit" name="login" class="btn btn-default"
                                style="margin-top: 0;"><?php echo NFW::i()->lang['GoIn'] ?></button>
                        &nbsp;&nbsp;<a
                                href="<?php echo NFW::i()->base_path ?>users?action=restore_password"><?php echo $lang_users['Restore password'] ?></a>
                    </form>

                    <ul class="nav navbar-nav">
                        <li>
                            <a href="<?php echo NFW::i()->base_path ?>users?action=register"><?php echo $lang_users['Registration'] ?></a>
                        </li>
                        <li>
                            <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                                        src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                                        alt="Sign in with SceneID"/></a>
                        </li>
                    </ul>
                <?php else: ?>
                    <ul class="nav navbar-nav">
                        <li<?php echo page_is('cabinet/works?action=list') ? ' class="active"' : '' ?>><a
                                    href="<?php echo NFW::i()->absolute_path ?>/cabinet/works?action=list"><span
                                        class="fas fa-bug"></span> <?php echo $lang_main['cabinet prods'] ?></a></li>
                        <li<?php echo page_is('cabinet/works?action=add') ? ' class="active"' : '' ?>><a
                                    href="<?php echo NFW::i()->absolute_path ?>/cabinet/works?action=add"><span
                                        class="fas fa-upload"></span> <?php echo $lang_main['cabinet add work'] ?></a>
                        </li>
                        <li<?php echo page_is('users?action=update_profile') ? ' class="active"' : '' ?>><a
                                    href="<?php echo NFW::i()->absolute_path ?>/users?action=update_profile"><span
                                        class="fas fa-bug"></span> <?php echo $lang_main['cabinet profile'] ?></a></li>

                        <?php if (NFW::i()->checkPermissions('admin')): ?>
                            <li><a href="/admin"><span class="fa fa-cog"></span> Control panel</a></li>
                        <?php endif; ?>

                        <li><a href="?action=logout"><span
                                        class="fa fa-sign-out-alt"></span> <?php echo NFW::i()->lang['Logout'] ?></a>
                        </li>
                    </ul>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>
<?php

if (isset($page['is_error']) && $page['is_error']) {
    echo '<div id="page-content" class="container">' . $page['content'] . '</div>';
    return;
}

ob_start();
if (NFWX::i()->main_search_box) {
    echo '<div class="well well-sm">';
    echo '<input id="works-search" class="form-control" placeholder="' . $lang_main['search hint'] . '" />';
    echo '</div>';
}

if (!empty(NFW::i()->breadcrumb)) {
    echo '<ul class="breadcrumb">';
    echo '<div class="breadcrumb-status pull-right">';
    echo NFW::i()->breadcrumb_status;
    echo '</div>';

    foreach (NFW::i()->breadcrumb as $b) {
        echo isset($b['url']) ? '<li><a href="' . NFW::i()->base_path . $b['url'] . '">' . htmlspecialchars($b['desc']) . '</a></li>' : '<li class="active">' . htmlspecialchars($b['desc']) . '</li>';
    }

    echo '<div class="clearfix"></div>';
    echo '</ul>';

    echo '<div class="breadcrumb-status-mobile">' . NFW::i()->breadcrumb_status . '</div>';
}

echo $page['content'];
$page_content = ob_get_clean();

if (!NFWX::i()->main_right_pane) {
    echo '<div id="page-content" class="container">' . $page_content . '</div>';
    return;
}
?>
<div id="page-content" class="container">
    <div class="row">
        <div class="col-md-9 col-sm-9 col-xs-12">
            <?php
            if ($page['path'] == '') {
                echo NFW::i()->fetch(
                    NFW::i()->findTemplatePath('pages/main/_index.tpl'),
                    array(
                        'worksComments' => $works_comments,
                    )
                );
            } else {
                echo $page_content;
            }
            ?>
        </div>
        <div class="col-md-3 col-sm-3 hidden-xs">
            <div class="hidden-xs hidden-sm"><?php echo $countdowns_main ?></div>

            <div id="block-before-menu"></div>

            <?php if (NFW::i()->user['is_guest'] && NFWX::i()->main_login_form): ?>
                <form id="login-form">
                    <fieldset>
                        <legend><?php echo NFW::i()->lang['Authorization'] ?></legend>

                        <div data-active-container="username">
                            <input type="text" class="form-control" name="username" placeholder="Username"/>
                            <span class="help-block"></span>
                        </div>

                        <div data-active-container="password">
                            <input type="password" class="form-control" name="password" placeholder="Password"/>
                            <span class="help-block"></span>
                        </div>

                        <div style="float: left; margin-right: 10px;">
                            <button type="submit" name="login" class="btn btn-default"
                                    style="margin-top: 0;"><?php echo NFW::i()->lang['GoIn'] ?></button>
                        </div>
                        <div style="padding-top: 10px;">
                            <a href="<?php echo NFW::i()->base_path ?>users?action=restore_password"><?php echo $lang_users['Restore password'] ?></a>
                        </div>
                        <div class="clearfix"></div>
                        <div style="padding-top: 20px;">
                            <a class="btn btn-primary"
                               href="<?php echo NFW::i()->base_path ?>users?action=register"><?php echo $lang_users['Registration'] ?></a>
                        </div>

                        <div style="padding-top: 20px;">
                            <a href="<?php echo NFW::i()->base_path ?>sceneid?action=performAuth"><img
                                        src="<?php echo NFW::i()->assets("main/SceneID_Icon_200x32.png") ?>"
                                        alt="Sign in with SceneID"/></a>
                        </div>
                    </fieldset>
                </form>

            <?php elseif (!NFW::i()->user['is_guest']): ?>
                <div class="menu-block">
                    <p>Welcome, <strong><?php echo htmlspecialchars(NFW::i()->user['realname']) ?></strong></p>
                    <ul class="nav nav-pills nav-stacked">
                        <?php if (NFW::i()->checkPermissions('admin')): ?>
                            <li><a href="/admin">Control panel</a></li>
                        <?php endif; ?>
                        <li<?php echo page_is('cabinet/works?action=list') ? ' class="active"' : '' ?>><a
                                    href="<?php echo NFW::i()->absolute_path ?>/cabinet/works?action=list"><?php echo $lang_main['cabinet prods'] ?></a>
                        </li>
                        <li<?php echo page_is('cabinet/works?action=add') ? ' class="active"' : '' ?>><a
                                    href="<?php echo NFW::i()->base_path ?>cabinet/works?action=add"><?php echo $lang_main['cabinet add work'] ?></a>
                        </li>
                        <li<?php echo page_is('users?action=update_profile') ? ' class="active"' : '' ?>><a
                                    href="<?php echo NFW::i()->absolute_path ?>/users?action=update_profile"><?php echo $lang_main['cabinet profile'] ?></a>
                        </li>
                        <li><a href="?action=logout"><?php echo NFW::i()->lang['Logout'] ?></a></li>
                    </ul>
                </div>
            <?php endif; ?>

            <?php echo $is_latest_comments && $works_comments !== false ? '<div style="margin-bottom: 40px;"><h3><a href="' . NFW::i()->base_path . 'comments.html">' . $lang_main['latest comments'] . '</a></h3>' . $works_comments . '</div>' : '' ?>
        </div>
    </div>
</div>

<?php echo NFW::i()->fetch(NFW::i()->findTemplatePath('_main_bottom_script.tpl')); ?>
</body>
</html>