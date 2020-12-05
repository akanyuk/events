<?php
// Multilanguage version

function friendly_date($date, $lang = array()) {
	if (!$date) return '';
	
	if (date('Ymd', $date) == date('Ymd')) return isset($lang['today']) ? $lang['today'] : 'Сегодня';
	
	$yesterday = mktime(0,0,0,date('m'),date('d')-1,date('Y'));
	if (mktime(0,0,0,date('m', $date),date('d', $date),date('Y', $date)) == $yesterday) return isset($lang['yesterday']) ? $lang['yesterday'] : 'Вчера';
	
    return date('d.m.Y', $date);
}