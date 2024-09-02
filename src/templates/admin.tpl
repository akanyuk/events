<?php
/**
 * @var array $page
 * @var string $page_title
 * @var array $top_menu
 * @var array $sidebar_right
 */
reset($page);

NFW::i()->registerResource('bootstrap');
NFW::i()->registerFunction('page_is');

$sidebar = NFW::i()->fetch(NFW::i()->findTemplatePath('_admin_sidebar.tpl'));
if ($sidebar) {
    NFW::i()->registerResource('bootstrap.sidebar');
}

// Generate `content` replacement - help
if ($page['is_welcome']) {
    $page['content'] = NFW::i()->fetch(NFW::i()->findTemplatePath('_admin_welcome.tpl'));
}

if (!empty(NFW::i()->breadcrumb)) {
    ob_start();
    ?>
    <ul class="breadcrumb">
        <?php foreach (NFW::i()->breadcrumb as $b) {
            if (!isset($b['url']) || !$b['url']) {
                echo '<li class="active">' . $b['desc'] . '</li>';
                continue;
            }
            $url = strstr($b['url'], 'https://') ? $b['url'] : NFW::i()->base_path . $b['url'];
            echo '<li><a href="' . $url . '">' . $b['desc'] . '</a></li>';
        }
        ?>
    </ul>
    <?php
    $breadcrumb = ob_get_clean();

    ob_start();
    ?>
    <div class="hidden-xs">
        <div class="breadcrumb-container">
            <?php echo $breadcrumb ?>
            <?php echo NFW::i()->breadcrumb_status ? '<div class="breadcrumb-status">' . NFW::i()->breadcrumb_status . '</div>' : '' ?>
        </div>
    </div>
    <div class="hidden-sm hidden-md hidden-lg">
        <?php echo $breadcrumb ?>
        <?php echo NFW::i()->breadcrumb_status ? '<div class="breadcrumb-status">' . NFW::i()->breadcrumb_status . '</div>' : '' ?>
    </div>
    <?php
    $page['content'] = ob_get_clean() . $page['content'];
}
?>
<!DOCTYPE html>
<html lang="<?php echo NFW::i()->lang['lang'] ?>">
<head><title><?php echo $page_title ?? $page['title'] ?></title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <?php echo isset(NFW::i()->cfg['admin']['head_content']) ? NFW::i()->cfg['admin']['head_content'] : '' ?>
    <style>
        body {
            padding-top: 60px;
        }

        .breadcrumb {
            overflow: auto;
        }

        @media screen and (max-width: 992px) {
            .sidebar {
                width: 100%;
            }

            .breadcrumb {
                margin: 0 0 5px 0;
            }

            .breadcrumb-status {
                margin: 0 0 10px 0;
            }
        }

        .breadcrumb-status {
            margin-top: 0;
            font-size: 12px;
            color: #777;
        }
    </style>
</head>
<body>
<nav class="navbar navbar-default navbar-fixed-top navbar-inverse">
    <div class="container-fluid">
        <div class="hidden-md hidden-lg">
            <div class="pull-right">
                <a class="navbar-brand" href="/admin" title="Control panel"><span class="fas fa-cog"></span></a>
                <a class="navbar-brand"
                   title="<?php echo NFW::i()->lang['LoggedAs'] . ' ' . htmlspecialchars(NFW::i()->user['username']) ?>"
                   href="<?php echo NFW::i()->base_path ?>admin/profile"><span class="fas fa-user"></span></a>
                <a class="navbar-brand" href="/" title="Main page"><span class="fas fa-home"></span></a>
            </div>
        </div>

        <div class="navbar-header">
            <?php if ($sidebar): ?>
                <button type="button" class="navbar-toggle toggle-left hidden-lg" data-toggle="sidebar"
                        data-target=".sidebar-left">
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
            <?php endif; ?>
        </div>

        <div class="hidden-xs hidden-sm">
            <ul class="nav navbar-nav">
                <?php $hasActive = false;
                foreach ($top_menu as $m) {
                    if ($m['url'] == "") {
                        continue;
                    }

                    if (!$hasActive && page_is($m['url'])) {
                        $hasActive = true;
                        $isActive = true;
                    } else {
                        $isActive = false;
                    }

                    echo '<li' . ($isActive ? ' class="active"' : '') . '><a href="' . NFW::i()->absolute_path . '/admin/' . $m['url'] . '">' . $m['name'] . '</a></li>';
                } ?>
            </ul>
        </div>

        <div class="hidden-xs hidden-sm">
            <div class="navbar-right">
                <a class="navbar-brand" href="/admin" title="Control panel"><span class="fas fa-cog"></span></a>
                <a class="navbar-brand"
                   title="<?php echo NFW::i()->lang['LoggedAs'] . ' ' . htmlspecialchars(NFW::i()->user['username']) ?>"
                   href="<?php echo NFW::i()->base_path ?>admin/profile"><span class="fas fa-user"></span></a>
                <a class="navbar-brand" href="/" title="Main page"><span class="fas fa-home"></span></a>
            </div>
        </div>
    </div>
</nav>

<div id="global-modal-container"></div>

<div class="container-fluid" style="padding-top: 20px; padding-bottom: 20px;">
    <?php if ($sidebar): ?>
        <div class="row">
            <div class="col xs-12 col-sm-6 col-md-3 col-lg-2 sidebar sidebar-left sidebar-animate sidebar-lg-show hidden-print"><?php echo $sidebar ?></div>
            <div class="col-lg-10 col-lg-offset-2"><?php echo $page['content']; ?></div>
        </div>
    <?php else: echo $page['content']; endif; ?>
</div>
</body>
</html>