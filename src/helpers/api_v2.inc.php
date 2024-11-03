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
            case '/api/v2/works/get':
                $options = array(
                    'filter' => array('released_only' => true),
                    'ORDER BY' => 'w.id DESC',
                    'limit' => isset($_REQUEST['limit']) && intval($_REQUEST['limit']) > 0 && intval($_REQUEST['limit']) <= 999 ? intval($_REQUEST['limit']) : 30,
                    'offset' => $_REQUEST['offset'] ?? null,
                );

                if (isset($_REQUEST['event']) && $_REQUEST['event']) {
                    $CEvents = new events();
                    if (!$CEvents->loadByAlias($_REQUEST['event'])) {
                        $this->error(400, 'event not found');
                    }
                    $options['filter']['event_id'] = $CEvents->record['id'];
                }

                if (isset($_REQUEST['competition']) && $_REQUEST['competition'] && $options['filter']['event_id']) {
                    $CCompetitions = new competitions();
                    if (!$CCompetitions->loadByAlias($_REQUEST['competition'], $options['filter']['event_id'])) {
                        $this->error(400, 'competition not found');
                    }
                    $options['filter']['competition_id'] = $CCompetitions->record['id'];
                }

                $CWorks = new works();
                list($records, $total, $numFiltered) = $CWorks->getRecords($options);
                $works = [];
                foreach ($records as $record) {
                    $works[] = [
                        'id' => $record['id'],
                        'title' => $record['title'],
                        'author' => $record['author'],
                        'platform' => $record['platform'],
                        'format' => $record['format'],
                        'link' => $record['main_link'],
                        'downloadLink' => $record['release_link'] ? $record['release_link']['url'] : null,
                        'event' => $record['event_alias'],
                        'competition' => $record['competition_alias'],
                    ];
                }
                $this->success([
                    'total' => $total,
                    'filtered' => $numFiltered,
                    'works' => $works,
                ]);
                break;
            default:
                $this->error(400, NFW::i()->lang['Errors']['Bad_request']);
        }
    }


    function error(int $errorCode, $message) {
        http_response_code($errorCode);
        header('Content-Type: application/json');
        NFW::i()->stop(json_encode(['message' => $message], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
    }

    /**
     * @param array $data
     */
    function success(array $data = array()) {
        header('Content-Type: application/json');
        NFW::i()->stop(json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
    }

}