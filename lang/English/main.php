<?php
//English language file for main template
$lang_main = array(
	'set language' => 'Set language',
	
	'latest news' => 'Latest news',
	'all news' => 'All news',

	'days' 				=> 'days',
	'hours'				=> 'hours',
	'minutes'			=> 'minutes',
	'unavailable' 		=> 'unavailable',
	'event closed' 		=> 'closed',
	'reception closed' 	=> 'closed',
	'voting closed' 	=> 'closed',
	
	'close button' => 'Close',
	
	'register' => array(
		// email
		'complete subject'	=> 'Demoscene at Multimatograf: Welcome',
		'restore password subject' => 'Demoscene at Multimatograf: password recovery',
		
		// controler
		'already registered'=> 'You are already registered. Please <a href="?action=logout">log out</a> to register another account.',
		'complete desc' 	=> 'A message with the further instructions has been sent to your e-mail address.',
		'wrong key'			=> 'The password activation key was incorrect or has expired. Please request a new password.',
				
		// template
		'registration'		=> 'Registration',
		'label info'		=> 'Account information',
		'username'			=> 'User name',
		'realname'			=> 'Full name',
		'country'			=> 'Country',
		'city'			=> 'City',
		'language'			=> 'Language',
		'captcha'			=> 'Protective code',
		'captcha info'		=> 'Enter the protective code from image nearby.',
		'send'				=> 'Register',
		'label success'		=> 'Registration complete',
		
		'activation'		=> 'Account activation',
		'password'			=> 'New password',
		're-password'		=> 'Retype password',
		'activate'			=> 'Activate account',
		
		'restore password' 			=> 'Restore password',
		'restore password btn' 		=> 'Restore password',
		'restore password label' 	=> 'Restore password request',
		'restore password info'		=> 'Your new password will be sent on your e-mail address.',
		'restore send'				=> 'Send request',
		'restore complete caption'	=> 'Operation complete',
		'restore message'			=> 'If you have specified your login correctly, a message with the further instruction on the password recovery will be sent to you.',		
	),
	
	'cabinet prods' 	=> 'My Prods',
	'cabinet profile' 	=> 'Profile',
	'cabinet add work'	=> 'Upload prod',
	'cabinet' => array(
		// Profile edit
		'edit profile' => 'Edit profile',
		'save profile' => 'Save profile',
		'edit password' => 'Edit password',
		'old-password' => 'Old password',
		'do not change password' => 'If you don\'t want to change your password, leave all the fields blank.',
	),

	'events' 			=> 'Events',
	'event' 			=> 'Event',
	'events no open' 	=> 'Opened events not found.',
	
	'competition' 				=> 'Сompetition',
	'competions title' 			=> 'Сompetition title',
	'competions type'			=> 'Works type',
	'competions reception'		=> 'Reception',
	'competions voting' 		=> 'Voting',
	'competions approved works-short'	=> 'Prods',
	'competions approved works'			=> 'Prods approved',
		
	'works empty'	=> 'You have not uploaded any prods yet',
	'works send' 	=> 'Send prod',
	'works title' 	=> 'Title',
	'works author' 	=> 'Author',
	'works platform'	=> 'Platform',
	'works format'		=> 'Format',
	'works description'	=> 'Description',
	'works voting' 	=> 'Voting',
	'works status' 	=> 'Status',
	'works posted' 	=> 'Posted',
	
	'works files'	=> 'Files',
	'works filesize' => 'Filesize',
	'works uploaded' => 'Uploaded',
	'filestatus voting' => 'File can be downloaded at online voting',
	'filestatus image' => 'File used as image at online voting and in public prod profile',
	'filestatus audio' => 'File used in audio-player at online voting and in public prod profile',
	'filestatus release' => 'File will be added in prods pack and can be downloaded from public prod profile',
	
	'works upload info' => '<p>The uploaded files will be stored on the server only after you press the "Send prod" button.</p><p>You can also include extra files (like screenshots, file for voting and nfo file) by describing them in the comments field.</p><p>You will receive an e-mail confirmation of your prod\'s approval after it is verified by the organizers.</p>',
	'works upload success label' => 'Prod uploaded successfully.',
	'works upload success message' => 'Prod stored successfully. You will receive an e-mail confirmation of your prod\'s approval status after it is verified by the organizers.',
	'works status desc' => array(
		0 => 'Not checked yet',
		1 => 'Verified',
		2 => 'Disqualified',
		3 => 'Feedback needed',
		4 => 'Out of compo'
	),
	'works status desc full' => array(
		0 => 'The work is being processed by the organizing committee.',
		1 => 'The work is accepted.',
		2 => 'Work is disqualified.',
		3 => 'Awaiting author\'s feedback.',
		4 => 'Prod will not be shown on the demoparty, but will be included in the release pack.'
	),

	'works details' => 'Prods',
	'works place' => 'Place',
	'works average_vote' => 'Average vote',
	'works num_votes' => 'Number of votes',
	'works total_scores' => 'Total scores',
	
	'voting to' => 'Voting ends on',
	'voting download' => 'Download',
	'voting audio not support' => 'Ваш браузер не поддерживает воспроизведение аудио.<br />Вы можете скачать данный аудиофайл по ссылке ниже.',
	'voting votes' => array(
		0 => 'Skip voting',
		1 => '1: Very bad',
		2 => '2',
		3 => '3',
		4 => '4',
		5 => '5',
		6 => '6',
		7 => '7',
		8 => '8',
		9 => '9',
		10 => '10: Best'
	),
	'voting name' => 'Your name or nick',
	'voting note' => '<strong>Attention!</strong> Your votes and your name may be published by demoparty orgs.',
	'voting send' => 'Send!',
	'voting error empty votelist' => 'Please fill votes',
	'voting error wrong username' => 'Please fill your name.',
	'voting error wrong votekey' => 'Wrong votekey.',
	'voting success note' => 'Your vote accepted.',
	
	'votekey-request note' => 'Votekey will be send to given e-mail address. <br />E-mail address never be published by demoparty orgs.',
	'votekey-request email label' => 'E-mail address',
	'votekey-request' => 'Request votekey',
	'votekey-another' => 'Another votekey',
	'votekey-request long' => 'Request votekey',
	'votekey-request send' => 'Send request',
	'votekey-request wrong email' => 'Incorrect e-mail address',
	'votekey-request success note' => 'New votekey succesfully generated and sended to given e-mail address.',
	'votekey-request success note2' => 'Votekey succesfully sended to given e-mail address.',

	'votelist nickname' => 'Your nickname / realname',
	'votelist note' => '<p>В поле «Vote» напротив работы поставьте оценку от <strong>1 до 10</strong>, которой на Ваш взгляд заслуживает работа.</p><p>Если Вы затрудняетесь с оценкой, или просто не хотите голосовать - оставьте соответствующее поле пустым.</p><p>В свободном месте после названия работы Вы можете оставить свой комментарий.</p>',
	
	'53c reception form' => 'Prod submission begins at',
);