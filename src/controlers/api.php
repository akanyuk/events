<?php

if (isset($_SERVER['HTTP_ORIGIN'])) {
    header('Access-Control-Allow-Origin: ' . $_SERVER['HTTP_ORIGIN']);
    header('Access-Control-Allow-Credentials: true');
}

switch (parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)) {
    case '/api/events/upcoming-current':
        $CEvents = new events();

        $dom = newDomDocument();
        $Events = createElement($dom,'Events');
        foreach ($CEvents->getRecords(array('filter' => array('upcoming-current' => true), 'order' => 'date_from', 'load_media' => true)) as $record) {
            $Event = createElement($dom,'Event');
            $Event->setAttribute('ID', $record['id']);
            $Event->appendChild(createElement($dom,'Title', $record['title']));
            $Event->appendChild(createElement($dom,'URL', NFW::i()->absolute_path . '/' . $record['alias']));
            $Event->appendChild(createElement($dom,'Announcement'))->appendChild($dom->createTextNode($record['announcement']));
            $Event->appendChild(createElement($dom,'DateFrom', $record['date_from']));
            $Event->appendChild(createElement($dom,'DateTo', $record['date_to']));
            $Event->appendChild(createElement($dom,'IsLogo', $record['is_preview_img']));
            $Event->appendChild(createElement($dom,'Logo', $record['preview_img']));
            $Events->appendChild($Event);
        }

        apiSuccess($dom, [$Events]);
        break;
    case '/api/events/read':
        if (!isset($_REQUEST['Alias'])) {
            apiError('wrong request');
        }

        $CEvents = new events();
        if (!$CEvents->loadByAlias($_REQUEST['Alias'])) {
            apiError('event not found');
        }

        $approved_works = 0;
        $total_works = 0;
        if (!$CEvents->record['hide_works_count']) {
            $CWorks = new works();
            $records = $CWorks->getRecords(array(
                'filter' => array(
                    'event_id' => $CEvents->record['id'],
                ),
                'skip_pagination' => true,
            ));

            $total_works = count($records);
            foreach ($records as $r) {
                if ($r['status_info']['voting'] && $r['status_info']['release']) {
                    $approved_works++;
                }
            }
        }

        $dom = newDomDocument();

        $Event = createElement($dom,'Event');
        $Event->setAttribute('ID', $CEvents->record['id']);
        $Event->appendChild(createElement($dom,'Title', $CEvents->record['title']));
        $Event->appendChild(createElement($dom,'URL', NFW::i()->absolute_path . '/' . ($CEvents->record['alias'])));
        $Event->appendChild(createElement($dom,'Announcement'))->appendChild($dom->createTextNode(($CEvents->record['announcement'])));
        $Event->appendChild(createElement($dom,'DateFrom', $CEvents->record['date_from']));
        $Event->appendChild(createElement($dom,'DateTo', $CEvents->record['date_to']));
        $Event->appendChild(createElement($dom,'IsLogo', $CEvents->record['is_preview_img']));
        $Event->appendChild(createElement($dom,'Logo', $CEvents->record['preview_img']));
        $Event->appendChild(createElement($dom,'TotalWorks', $total_works));
        $Event->appendChild(createElement($dom,'ApprovedWorks', $approved_works));
        $dom->appendChild($Event);

        apiSuccess($dom, [$Event]);
        break;
    case '/api/competitions/get53c':
        $CCompetitions = new competitions(NFWX::i()->project_settings['53c_competition_id']);
        if (!$CCompetitions->record['id']) {
            apiError('53c competition not found');
        }

        $CEvents = new events($CCompetitions->record['event_id']);
        if (!$CCompetitions->record['id']) {
            apiError('Event for 53c competition not found');
        }

        $reception_available = $CCompetitions->record['reception_from'] < NFWX::i()->actual_date && $CCompetitions->record['reception_to'] > NFWX::i()->actual_date ? 1 : 0;

        $dom = newDomDocument();
        $competition = createElement($dom,'Competition');
        $competition->appendChild(createElement($dom,'Title', $CCompetitions->record['title']));
        $competition->appendChild(createElement($dom,'EventTitle', $CEvents->record['title']));
        $competition->appendChild(createElement($dom,'ReceptionAvailable', $reception_available));
        $competition->appendChild(createElement($dom,'ReceptionFrom', $CCompetitions->record['reception_from']));
        $competition->appendChild(createElement($dom,'ReceptionTo', $CCompetitions->record['reception_to']));
        $competition->appendChild(createElement($dom,'VotingFrom', $CCompetitions->record['voting_from']));
        $competition->appendChild(createElement($dom,'VotingTo', $CCompetitions->record['voting_to']));

        apiSuccess($dom, [$competition]);
        break;
    case '/api/competitions/upload53c':
        $CWorks = new works53c();
        if (!$CWorks->loadFromUploadedFile('file53c')) {
            apiError($CWorks->last_msg);
        }

        if (!$CWorks->add53c($_POST)) {
            apiError($CWorks->last_msg);
        }

        $dom = newDomDocument();
        apiSuccess($dom);
        break;
    case '/api/works/get':
        $CWorks = new works();
        $options = array(
            'filter' => array('released_only' => true),
            'ORDER BY' => 'w.id DESC',
            'limit' => isset($_REQUEST['Limit']) && intval($_REQUEST['Limit']) > 0 && intval($_REQUEST['Limit']) < 100 ? intval($_REQUEST['Limit']) : 99,
            'offset' => $_REQUEST['Offset'] ?? null,
        );

        if (isset($_REQUEST['EventID']) && $_REQUEST['EventID']) {
            $options['filter']['event_id'] = $_REQUEST['EventID'];
        }

        if (isset($_REQUEST['CompetitionID']) && $_REQUEST['CompetitionID']) {
            $options['filter']['competition_id'] = $_REQUEST['CompetitionID'];
        }

        list($records, $foo, $num_filtered) = $CWorks->getRecords($options);

        $dom = newDomDocument();

        $Filtered = createElement($dom,'Filtered', $num_filtered);
        $Fetched = createElement($dom,'Fetched', count($records));

        $Works = createElement($dom,'Works');
        foreach ($records as $record) {
            $Work = createElement($dom,'Work');
            $Work->setAttribute('ID', $record['id']);
            $Work->appendChild(createElement($dom,'Title'))->appendChild($dom->createTextNode($record['title']));
            $Work->appendChild(createElement($dom,'Author'))->appendChild($dom->createTextNode($record['author']));
            $Work->appendChild(createElement($dom,'URL', $record['main_link']));
            $Work->appendChild(createElement($dom,'ReleaseURL', $record['release_link'] ? $record['release_link']['url'] : null));

            $Competition = createElement($dom,'Competition');
            $Competition->setAttribute('ID', $record['competition_id']);
            $Competition->appendChild(createElement($dom,'Title'))->appendChild($dom->createTextNode($record['competition_title']));
            $Competition->appendChild(createElement($dom,'WorksType', $record['works_type']));
            $Work->appendChild($Competition);

            $Event = createElement($dom, 'Event');
            $Event->setAttribute('ID', $record['event_id']);
            $Event->appendChild(createElement($dom, 'Title'))->appendChild($dom->createTextNode($record['event_title']));
            $Event->appendChild(createElement($dom, 'DateFrom', $record['event_from']));
            $Event->appendChild(createElement($dom, 'DateTo', $record['event_to']));
            $Work->appendChild($Event);

            $Works->appendChild($Work);
        }

        apiSuccess($dom, array($Filtered, $Fetched, $Works));
        break;
    default:
        apiError(NFW::i()->lang['Errors']['Bad_request']);
}

function newDomDocument(): DomDocument {
    $dom = new DomDocument;
    $dom->preserveWhiteSpace = false;
    $dom->formatOutput = true;
    $dom->encoding = 'UTF-8';
    return $dom;
}

function createElement(DomDocument $dom, $localName, $value = ""): DOMElement {
    try {
        $element = $dom->createElement($localName, $value);
    } catch (DOMException $e) {
        NFW::i()->stop($e->getMessage());
    }

    return $element;
}

function apiError($message) {
    $dom = newDomDocument();
    $document = createElement($dom,'Document');
    $document->appendChild(createElement($dom, 'Status', 'error'));
    $document->appendChild(createElement($dom, 'Message', $message));

    writeResponse($dom, $document);
}

/**
 * @param $dom DomDocument
 * @param $children array
 */
function apiSuccess(DomDocument $dom, array $children = array()) {
    $document = createElement($dom, 'Document');
    $document->appendChild(createElement($dom, 'Status', 'success'));

    foreach ($children as $child) {
        $document->appendChild($child);
    }

    writeResponse($dom, $document);
}

/**
 * @param $dom DomDocument
 * @param $document DOMElement
 */
function writeResponse(DomDocument $dom, DOMElement $document) {
    $document->appendChild(createElement($dom, 'Username', NFW::i()->user['username']));
    $document->appendChild(createElement($dom, 'IsGuest', NFW::i()->user['is_guest'] ? '1' : '0'));

    $dom->appendChild($document);

    $r = $dom->saveXML();

    if (isset($_REQUEST['ResponseType']) && $_REQUEST['ResponseType'] == 'json') {
        header('Content-Type: application/json');
        NFW::i()->stop(json_encode(simplexml_load_string($r, 'SimpleXMLElement', LIBXML_NOCDATA), JSON_PRETTY_PRINT));
    } else {
        header("Content-Type: text/xml");
        NFW::i()->stop($r);
    }
}
