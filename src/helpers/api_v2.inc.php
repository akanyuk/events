<?php

class apiV2 {
    function __construct(string $path) {
        switch ($path) {
            case '/api/v2/competitions/list':
                if (!isset($_REQUEST['event'])) {
                    $this->error(400, NFW::i()->lang['Errors']['Bad_request']);
                }

                $CEvents = new events();
                if (!$CEvents->loadByAlias($_REQUEST['event'])) {
                    $this->error(400, 'event not found');
                }

                $CCompetitions = new competitions();
                $records = $CCompetitions->getRecords(['filter' => ['event_id' => $CEvents->record['id']]]);

                $result = [];
                foreach ($records as $record) {
                    $result[] = [
                        'title' => $record['title'],
                        'worksType' => $record['works_type'],
                        'receptionFrom' => intval($record['reception_from']),
                        'receptionTo' => intval($record['reception_to']),
                        'votingFrom' => intval($record['voting_from']),
                        'votingTo' => intval($record['voting_to']),
                    ];
                }

                $this->success(['competitions' => $result]);
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