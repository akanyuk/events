<?php
/*
 * 'word_suffix' function plugin
 *
 * Purpose: returns count with suffix for given count (товар, товаров, товара)
 */
function word_suffix($number, $pre = array()) {
	if (empty($pre)) {
		$pre = array('товар', 'товара', 'товаров');
	}
	
	$ne = substr((string)$number, -2);
	$ne2 = 0;
	
	if (strlen($ne) == 2){
		$ne2 = $ne[0];
		$ne = $ne[1];
	}
	
	if ($ne2 == 1) {
		return $pre[2];
	}
	else if ($ne == 1) {
		return $pre[0];
	}
	else if ($ne > 1 && $ne < 5) {
		return $pre[1];
	}
	else {
		return $pre[2];
	}
}