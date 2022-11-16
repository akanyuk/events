<?php

namespace Events\GraphQL\Util;

use Exception;

use GraphQL\Error\ClientAware;
use GraphQL\Error\Error;

class EventsError extends Exception implements ClientAware {
    public function isClientSafe(): bool {
        return true;
    }

    public function getCategory(): string {
        return "events category";
    }

    public static function throw(string $message, $file, $line, $dbError = array()) {
        if (isset($dbError['error_msg']) && $dbError['error_msg']) {
            $message .= ': '.$dbError['error_msg'];
        }

        $message .= ', called in '.$file.' on line '.$line;

        throw new Error($message);
    }
}