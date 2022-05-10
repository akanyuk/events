<?php

function limit_text($text, $limit = 20, $postfix = '...') {
	if (mb_strlen($text) <= $limit) return $text;
	 
	if (!mb_strstr($text, ' ')) return mb_substr($text, 0, $limit).$postfix;
	
	$string = '';
	foreach (explode(' ', $text) as $word) {
		if (mb_strlen($string) + mb_strlen($word) + 1 > $limit) {
			return $string.$postfix;
		}			
		
		$string .= ' '.$word;
	}
	
	// Newer used, but...
	return $string;
}