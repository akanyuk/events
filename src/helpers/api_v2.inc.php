<?php

class apiV2 {
    function __construct(string $path) {
        switch ($path) {
            case '/api/v2/timeline':
                if (!isset($_REQUEST['event'])) {
                    $this->error(400, NFW::i()->lang['Errors']['Bad_request']);
                }

                $CEvents = new events();
                if (!$CEvents->loadByAlias($_REQUEST['event'])) {
                    $this->error(400, 'event not found');
                }

                $CTimeline = new timeline();
                $records = $CTimeline->getRecords($CEvents->record['id']);

                $result = [];
                foreach ($records as $record) {
                    $result[] = [
                        'begin' => $record['begin'],
                        'end' => $record['end'],
                        'title' => $record['title'] ?: $record['competition_title'],
                        'description' => $record['description'],
                        'isPublic' => (bool)$record['is_public'],
                        'type' => $record['type'],
                    ];
                }

                $this->success(['timeline' => $result]);
                break;
            default:
                $this->error(400, NFW::i()->lang['Errors']['Bad_request']);
        }
    }


    function error(int $errorCode, $message) {
        http_response_code($errorCode);
        header('Content-Type: application/json');
        NFW::i()->stop(json_encode(['message' => $message], JSON_PRETTY_PRINT));
    }

    /**
     * @param array $data
     */
    function success(array $data = array()) {
        header('Content-Type: application/json');
        NFW::i()->stop(json_encode($data, JSON_PRETTY_PRINT));
    }

}