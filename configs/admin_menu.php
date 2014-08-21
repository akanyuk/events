<?php

$admin_menu = array (
  'events' => array (
    1 => array (
      'name' => 'Events',
      'icon' => 'admin/icons/wine.png',
      'url' => 'events',
      'perm' => 'events,admin',
    ),
    2 => array (
      'name' => 'Competitions',
      'icon' => 'admin/icons/kdesvn.png',
      'url' => 'competitions',
      'perm' => 'competitions,admin',
    ),
    3 => array (
      'name' => 'Works',
      'icon' => 'admin/icons/video.png',
      'url' => 'works',
      'perm' => 'works,admin',
    ),
    4 => array (
      'name' => 'Voting',
      'icon' => 'admin/icons/votings.png',
      'url' => 'vote',
      'perm' => 'vote,admin',
    ),
  ),
  'site' => array (
    1 => array (
      'name' => 'News',
      'icon' => 'admin/icons/kword.png',
      'url' => 'news',
      'perm' => 'news,admin',
    ),
    2 => array (
      'name' => 'Pages',
      'icon' => 'admin/icons/knode.png',
      'url' => 'pages',
      'perm' => 'pages,admin',
    ),
    3 => array (
	      'name' => 'Elements',
	      'icon' => 'admin/icons/ksirtet.png',
	      'url' => 'elements',
	      'perm' => 'elements,admin',
    ),
  	4 => array (
  		'name' => 'Timeline',
  		'icon' => 'admin/icons/appointment.png',
  		'url' => 'timeline',
  		'perm' => 'timeline,admin',
  	),
  ),
  'admin' => array (
  		1 => array (
      		'name' => 'Settings',
      		'icon' => 'admin/icons/advanced.png',
      		'url' => 'settings',
      		'perm' => 'settings,admin',
    	),
  		2 => array (
      		'name' => 'Attachments',
      		'icon' => 'admin/icons/package.png',
      		'url' => 'media?action=manage',
      		'perm' => 'media,manage',
    	),
	  	3 => array (
	  		'name' => 'Users',
	  		'icon' => 'admin/icons/amsn8.png',
	  		'url' => 'users',
	  		'perm' => 'users,admin',
	  	),
    	4 => array (
      		'name' => 'Logs',
      		'icon' => 'admin/icons/my_documents2.png',
      		'url' => 'view_logs',
      		'perm' => 'view_logs,admin',
    	),
	),
);