<?php

function place_suffix($place): string {
    switch ($place) {
        case 0:
            return '';
        case 1:
            return  'st';
        case 2:
            return  'nd';
        case 3:
            return  'rd';
        default:
            return  'th';
    }
}
