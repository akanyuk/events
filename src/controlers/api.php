<?php

if (isset($_SERVER['HTTP_ORIGIN'])) {
	header('Access-Control-Allow-Origin: '.$_SERVER['HTTP_ORIGIN']);
	header('Access-Control-Allow-Credentials: true');
}

switch (parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)) {
    case '/api/events/upcoming-current':
        $CEvents = new events();

        $dom = startXML();
        $Events = $dom->createElement('Events');
        foreach ($CEvents->getRecords(array('filter' => array('upcoming-current' => true), 'order' => 'date_from', 'load_media' => true)) as $record) {
            $Event = $dom->createElement('Event');
            $Event->setAttribute('ID', $record['id']);
            $Event->appendChild($dom->createElement('Title', $record['title']));
            $Event->appendChild($dom->createElement('URL', NFW::i()->absolute_path.'/'.$record['alias']));
            $Event->appendChild($dom->createElement('Announcement'))->appendChild($dom->createTextNode($record['announcement']));
            $Event->appendChild($dom->createElement('DateFrom', $record['date_from']));
            $Event->appendChild($dom->createElement('DateTo', $record['date_to']));
            $Event->appendChild($dom->createElement('IsLogo', $record['is_preview_img']));
            $Event->appendChild($dom->createElement('Logo', $record['preview_img']));
            $Events->appendChild($Event);
        }

        apiSuccess($dom, $Events);
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

        $dom = startXML();

        $Event = $dom->createElement('Event');
        $Event->setAttribute('ID', $CEvents->record['id']);
        $Event->appendChild($dom->createElement('Title', $CEvents->record['title']));
        $Event->appendChild($dom->createElement('URL', NFW::i()->absolute_path.'/'.($CEvents->record['alias'])));
        $Event->appendChild($dom->createElement('Announcement'))->appendChild($dom->createTextNode(($CEvents->record['announcement'])));
        $Event->appendChild($dom->createElement('DateFrom', $CEvents->record['date_from']));
        $Event->appendChild($dom->createElement('DateTo', $CEvents->record['date_to']));
        $Event->appendChild($dom->createElement('IsLogo', $CEvents->record['is_preview_img']));
        $Event->appendChild($dom->createElement('Logo', $CEvents->record['preview_img']));
        $Event->appendChild($dom->createElement('TotalWorks', $total_works));
        $Event->appendChild($dom->createElement('ApprovedWorks', $approved_works));
        $dom->appendChild($Event);

        apiSuccess($dom, $Event);
        break;
	case '/api/competitions/get53c':
		$CCompetitions = new competitions(NFW::i()->project_settings['53c_competition_id']);
		if (!$CCompetitions->record['id']) {
			apiError('53c competition not found');
		}

		$CEvents = new events($CCompetitions->record['event_id']);
		if (!$CCompetitions->record['id']) {
			apiError('Event for 53c competition not found');
		}
		
		$reception_available = $CCompetitions->record['reception_from'] < NFW::i()->actual_date && $CCompetitions->record['reception_to'] > NFW::i()->actual_date ? 1 : 0;
		
		$dom = startXML();
		$competition = $dom->createElement('Competition');
		$competition->appendChild($dom->createElement('Title', $CCompetitions->record['title']));
		$competition->appendChild($dom->createElement('EventTitle', $CEvents->record['title']));
		$competition->appendChild($dom->createElement('ReceptionAvailable', $reception_available));
		$competition->appendChild($dom->createElement('ReceptionFrom', $CCompetitions->record['reception_from']));
		$competition->appendChild($dom->createElement('ReceptionTo', $CCompetitions->record['reception_to']));
		$competition->appendChild($dom->createElement('VotingFrom', $CCompetitions->record['voting_from']));
		$competition->appendChild($dom->createElement('VotingTo', $CCompetitions->record['voting_to']));

		apiSuccess($dom, $competition);
	    break;
	case '/api/competitions/upload53c':
		$CWorks = new works53c();
		if (!$CWorks->loadFromUploadedFile('file53c')) {
			apiError($CWorks->last_msg);
		}
		
		if (!$CWorks->add53c($_POST)) {
			apiError($CWorks->last_msg);
		}
		
		$dom = startXML();
		apiSuccess($dom);
		break;
	case '/api/works/get':
		$CWorks = new works();
		$options = array(
			'filter' => array('released_only' => true),
			'ORDER BY' => 'w.id DESC',
			'limit'	=> isset($_REQUEST['Limit']) && intval($_REQUEST['Limit']) > 0 && intval($_REQUEST['Limit']) < 100 ? intval($_REQUEST['Limit']) : 99,
			'offset'=> isset($_REQUEST['Offset']) ? $_REQUEST['Offset'] : null,
		);
		
		if (isset($_REQUEST['EventID']) && $_REQUEST['EventID']) {
			$options['filter']['event_id'] = $_REQUEST['EventID'];
		}

		if (isset($_REQUEST['CompetitionID']) && $_REQUEST['CompetitionID']) {
			$options['filter']['competition_id'] = $_REQUEST['CompetitionID'];
		}
		
		list($records, $foo, $num_filtered) = $CWorks->getRecords($options);
		
		$dom = startXML();
		
		$Filtered = $dom->createElement('Filtered', $num_filtered);
		$Fetched = $dom->createElement('Fetched', count($records));
		
		$Works = $dom->createElement('Works');
		foreach ($records as $record) {
			$Work = $dom->createElement('Work');
			$Work->setAttribute ('ID', $record['id']);
			$Work->appendChild($dom->createElement('Title'))->appendChild($dom->createTextNode($record['title']));
			$Work->appendChild($dom->createElement('Author'))->appendChild($dom->createTextNode($record['author']));
			$Work->appendChild($dom->createElement('URL', $record['main_link']));
			$Work->appendChild($dom->createElement('ReleaseURL', $record['release_link'] ? $record['release_link']['url'] : null));
			
			$Competition = $dom->createElement('Competition');
			$Competition->setAttribute('ID', $record['competition_id']);
			$Competition->appendChild($dom->createElement('Title'))->appendChild($dom->createTextNode($record['competition_title']));
			$Competition->appendChild($dom->createElement('WorksType', $record['works_type']));
			$Work->appendChild($Competition);
			
			$Event = $dom->createElement('Event');
			$Event->setAttribute('ID', $record['event_id']);
			$Event->appendChild($dom->createElement('Title'))->appendChild($dom->createTextNode($record['event_title']));
			$Event->appendChild($dom->createElement('DateFrom', $record['event_from']));
			$Event->appendChild($dom->createElement('DateTo', $record['event_to']));
			$Work->appendChild($Event);
			
			$Works->appendChild($Work);
		}
		
		apiSuccess($dom, array($Filtered, $Fetched, $Works));
		break;
	default:
		apiError(NFW::i()->lang['Errors']['Bad_request']);
}

function apiError($message) {
	$dom = startXML();
	$document = $dom->createElement('Document');
    $document->appendChild($dom->createElement('Status', 'success'));
    $document->appendChild($dom->createElement('Message', $message));

    writeResponse($dom, $document);
}

/**
 * @param $dom DomDocument
 * @param $childs array
  */
function apiSuccess($dom, $childs = array()) {
	$document = $dom->createElement('Document');
    $document->appendChild($dom->createElement('Status', 'success'));

	foreach (is_array($childs) ? $childs : array($childs) as $child) {
		$document->appendChild($child);
	}

    writeResponse($dom, $document);
}

function startXML() {
    $dom = new DomDocument;
    $dom->preserveWhiteSpace = false;
    $dom->formatOutput = true;
    $dom->encoding = 'UTF-8';
    return $dom;
}

/**
 * @param $dom DomDocument
 * @param $document DOMElement
 */
function writeResponse($dom, $document) {
    $document->appendChild($dom->createElement('Username', NFW::i()->user['username']));
    $document->appendChild($dom->createElement('IsGuest', NFW::i()->user['is_guest'] ? '1' : '0'));

    $dom->appendChild($document);

    $r = $dom->saveXML();

    if (isset($_REQUEST['ResponseType']) && $_REQUEST['ResponseType'] == 'json') {
        header('Content-Type: application/json');
        NFW::i()->stop(json_encode(simplexml_load_string($r, 'SimpleXMLElement', LIBXML_NOCDATA)));
    }
    else {
        header("Content-Type: text/xml");
        NFW::i()->stop($r);
    }
}

