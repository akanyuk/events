<?php
if (!defined('NFW_DEBUG') && defined('BROWSCAP_CACHE')) {
	require_once NFW_ROOT.'helpers/Browscap.php';
	$CBrowscap = new Browscap(BROWSCAP_CACHE);
	$b = $CBrowscap->getBrowser();

	if (isset($b->Browser) && $b->Browser == 'IE') {
		NFW::i()->registerResource('respond');
	}
}

if (NFW::i()->user['is_guest']) {
	NFW::i()->registerResource('jquery.activeForm');
}

NFW::i()->registerFunction('page_is');

$lang_main = NFW::i()->getLang('main');
?>
<!DOCTYPE html> 
<html lang="<?php echo NFW::i()->lang['lang']?>"><head><title><?php echo isset($page_title) ? $page_title : $page['title']?></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="ru" />
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<meta name="description" content="<?php echo NFW::i()->cfg['meta_description']?>" />
<meta name="keywords" content="<?php echo NFW::i()->cfg['meta_keywords']?>" />
<link rel="image_src" href="<?php echo NFW::i()->assets('main/logo64.png')?>" />
<style>
/* Main template */
.dm-nav { background-color: #707070; color: #fff; border: none; border-bottom: 1px solid #555; min-height: 40px; }
.dm-nav .navbar-header { padding-right: 20px; }
.dm-nav .navbar-nav > li > a { text-shadow: 0; color: #fff; padding-bottom: 10px; padding-top: 10px; }
.dm-nav .navbar-nav > li > a:hover, .dm-nav .navbar-nav > li > a:focus { background-color: #444; color: #fff; }
.dm-nav .navbar-nav > .active > a, .dm-nav .navbar-nav > .active > a:hover { background-color: #800; color: #fff; }

.dm-nav .lang-change { color: #fff; font-size: 80%; font-weight: bold; padding-top: 10px; }
.dm-nav .lang-change a { color: #fff; font-weight: normal; } 
.dm-nav .lang-change a:hover { color: #FFFBD7; }

#page-content { padding-top:60px; padding-bottom: 1em; }

.menu-block { 
    background-color: #F8F8F8;
    border: 1px solid #ddd;
    border-radius: 4px 4px 0 0;
    box-shadow: none;
    padding: 1em;
    margin-bottom: 20px;
}

/* Globals */
A { color: #002EB5; }
A:hover { text-decoration: none; color: #0360FF; }
A:focus { text-decoration: none; outline: none; }

H1 { font-size:200%; line-height: 28px; }
H2 { font-size:180%; line-height: 20px; }
H3 { font-size:140%; line-height: 18px; }

TABLE.dm TD.nb { border-top: none }
TABLE.dm TD.full { width: 100%; }
TABLE.dm TD.b { font-weight: bold; }
TABLE.dm TD.nw, TABLE.dm TH { white-space: nowrap; }
TABLE.dm TD.r, TABLE.dm TH.r { text-align: right; }

DIV.dm-alert-cond { padding: 10px; }
DIV.dm-alert-cond P { font-size: 12px; line-height: 13px; }
</style>
</head>

<body>
<div role="banner" class="navbar navbar-fixed-top dm-nav"><div class="container">
	<div class="lang-change pull-right">
<?php 
	$change_lang_url = ($_SERVER['REQUEST_URI'] ? $_SERVER['REQUEST_URI'] : '').(empty($_GET) ? '?lang=' : '&lang=');
	echo NFW::i()->user['language'] == 'English' ? 'english' : '<a href="'.$change_lang_url.'English">english</a>';
	echo ' / ';
	echo NFW::i()->user['language'] == 'Russian' ? 'русский' : '<a href="'.$change_lang_url.'Russian">русский</a>';
?>
	</div>
	<div class="navbar-header">
		<a href="<?php echo NFW::i()->base_path?>"><img src="<?php echo NFW::i()->assets('main/rse-logo.gif')?>" /></a>
	</div>
	<div role="navigation" class="collapse navbar-collapse">
<?php
	echo '<ul class="nav navbar-nav">';
	if (isset($page['main-menu'])) {
		preg_match_all('/<a.*<\/a>/', $page['main-menu'], $main_menu);
		foreach ($main_menu[0] as $a) {
			echo '<li'.($page['path'] && $page['path'] != '/' && strstr($a, $page['path']) ? ' class="active"' : '').'>'.$a.'</li>';
		}
	}
	echo '</ul>';
?>           		
	</div>
</div></div>
    	
<?php ob_start();
if (isset($page['breadcrumb']) && !empty($page['breadcrumb'])) {
	echo '<ul class="breadcrumb">';
	echo '<div class="pull-right">';
	echo isset($page['breadcrumb_status']) ? $page['breadcrumb_status'] : '';
	echo '</div>';

	//echo '<li><a href="/">Home</a> <span class="divider">/</span></li>';
	foreach ($page['breadcrumb'] as $b) {
		echo isset($b['url']) ? '<li><a href="'.NFW::i()->base_path.$b['url'].'">'.htmlspecialchars($b['desc']).'</a>' : '<li class="active">'.htmlspecialchars($b['desc']).'</li>';
	}

	echo '<div class="clearfix"></div>';
	echo '</ul>';
}

echo $page['content'];

$page_content = ob_get_clean();

if (isset($page['disable_right_pane']) && $page['disable_right_pane']) {
	echo '<div id="page-content" class="container">'.$page_content.'</div>';
	return;
}
?>

<div id="page-content" class="container">
	<div class="row">
		<div class="col-md-9"><?php echo $page_content?></div>
		<div class="col-md-3">
<?php
	$countdown = ceil((strtotime(NFW::i()->cfg['countdown']) - time()) / 86400);
	if ($countdown > 0): ?>
<div style="text-align: right; margin-bottom: 20px;">
	<div style="font-weight: bold; font-size: 45pt; line-height: 40pt;"><?php echo $countdown?></div>
	<div style="font-size: 18pt; line-height: 22pt;">days left</div>
	<div style="padding-top: 1em; font-size: 16pt; line-height: 22pt;"><?php echo NFW::i()->cfg['countdown_when']?></div>
	<div style="font-size: 18pt; line-height: 22pt;"><?php echo NFW::i()->cfg['countdown_where']?></div>
</div>
<?php 
	endif;

	if (isset($page['timeline'])) {
		$CTimeline = new timeline();
		$CTimeline->path_prefix = 'main';
		echo $CTimeline->renderAction(array('Module' => $CTimeline), '_timeline');		
	}
	
	if (NFW::i()->user['is_guest'] && $page['path'] != 'register.html'): ?>
<script type="text/javascript">
$(document).ready(function(){
	var f = $('form[id="login-form"]');
	f.activeForm({
 	 	error: function(response) {
			f.find('*[id="error-message"]').text(response.message);
		},
		success: function(response) {
			window.location.reload();
		}
	});
});
</script>
		
<form id="login-form" style="margin-bottom: 20px;"><fieldset>
<legend><?php echo NFW::i()->lang['Authorization']?></legend>
	<div class="form-group" style="margin-bottom: 15px;">
		<input type="text" name="username" class="form-control input-medium" placeholder="<?php echo NFW::i()->lang['Login']?>" />
	</div>
	<div class="form-group">
		<input type="password" name="password" class="form-control input-medium" placeholder="<?php echo NFW::i()->lang['Password']?>" />
	</div>
	<div id="error-message" style="height: 18px; font-size: 85%; color: #ff0000;"></div>
   	
	<div style="float: left; margin-right: 10px;">
		<button type="submit" name="login" class="btn btn-default" style="margin-top: 0;"><?php echo NFW::i()->lang['GoIn']?></button>
	</div>
	<div style="padding-top: 10px;">
		<a href="<?php echo NFW::i()->base_path?>register.html?action=restore_password"><?php echo $lang_main['register']['restore password btn']?></a>
	</div>
	<div class="clearfix"></div>
	<div style="padding-top: 20px;">
		<a class="btn btn-primary" href="<?php echo NFW::i()->base_path?>register.html"><?php echo $lang_main['register']['registration']?></a><br />
	</div>
</fieldset></form>
<?php elseif (!NFW::i()->user['is_guest']): ?>
<div class="menu-block">
	<?php if (NFW::i()->user['realname']): ?>
		<p>Welcome, <strong><?php echo htmlspecialchars(NFW::i()->user['realname'])?></strong></p>
	<?php endif;?>
	<ul class="nav nav-pills nav-stacked">
		<?php if (NFW::i()->checkPermissions('admin')): ?>
		<li><a href="/admin">Control panel</a></li>
		<?php endif; ?>
		<li<?php echo page_is('cabinet/works?action=list') ? ' class="active"' : ''?>><a href="<?php echo NFW::i()->absolute_path?>/cabinet/works?action=list"><?php echo $lang_main['cabinet prods']?></a></li>
		<li<?php echo page_is('cabinet/works?action=add') ? ' class="active"' : ''?>><a href="<?php echo NFW::i()->base_path?>cabinet/works?action=add"><?php echo $lang_main['cabinet add work']?></a></li>
		<li<?php echo page_is('register.html?action=update_profile') ? ' class="active"' : ''?>><a href="<?php echo NFW::i()->absolute_path?>/register.html?action=update_profile"><?php echo $lang_main['cabinet profile']?></a></li>
		<li><a href="?action=logout"><?php echo NFW::i()->lang['Logout']?></a></li>
	</ul>
</div>
<?php endif; ?>

<?php /*
<div style="margin-bottom: 20px;">
	<legend style="margin-bottom: 8px;">Follow us!</legend>
	<div style="padding-bottom: 0.5em;"><a href="http://vk.com/multimatograf_demoscene"><img style="position: relative; top: -3px;" src="<?php echo NFW::i()->assets('main/vkontakte.gif')?>" /> ВКонтакте</a></div>
	<div style="padding-bottom: 0.5em;"><a href="http://multimatograf.ru"><img style="position: relative; top: -3px;" src="<?php echo NFW::i()->assets('main/logo-mf.png')?>" /> Фестиваль «Мультиматограф»</a></div>
</div>
*/?>

<?php if (isset($page['latest-news'])): ?>
	<div style="margin-bottom: 20px;">
		<legend><a href="<?php echo NFW::i()->base_path?>news.html"><?php echo $lang_main['latest news']?></a></legend>
		<?php echo NFW::i()->renderNews(array('records_on_page' => 3, 'template' => 'latest'))?>
	</div>
<?php endif; ?>
	</div>
	
</div></div>

<?php if (!defined('NFW_DEBUG')): ?>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-5151104-4', 'auto');
  ga('send', 'pageview');

</script>
<?php endif;?>
</body></html>