<?php

function page_is($has = null, $not = null) {
	if ($has && !strstr($_SERVER['REQUEST_URI'], $has)) {
		return false;
	}
	
	if ($not && strstr($_SERVER['REQUEST_URI'], $not)) {
		return false;
	}
	
    return true;
}