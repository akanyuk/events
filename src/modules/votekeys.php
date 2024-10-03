<?php

class votekeys extends base_module {
    public function requestVotekey($eventID, $email):bool {
        $CEvents = new events($eventID);
        if (!$CEvents->record['id']) {
            $this->error('System error: wrong `event_id`');
            return false;
        }

        $CCompetitions = new competitions();
        $competitions = $CCompetitions->getRecords(array('filter' => array('event_id' => $CEvents->record['id'], 'open_voting' => true)));
        if (empty($competitions)) {
            $this->error('System error: Voting closed for this event');
            return false;
        }

        $langMain = NFW::i()->getLang('main');

        if (!$email || !$this->is_valid_email($email)) {
            $this->error($langMain['votekey-request wrong email']);
            return false;
        }

        $votekey = votekey::findOrCreateVotekey($CEvents->record['id'], $email);
        if ($votekey->error) {
            return false;
        }

        email::sendFromTemplate($email, 'votekey_request', array(
            'event' => $CEvents->record,
            'votekey' => $votekey->val,
            'language' => NFW::i()->user['language']
        ));

        return true;
    }

    public function getVotekeys($eventID, $options = array()) {
        // Generate 'WHERE' string
        $where = array(
            'event_id = ' . intval($eventID)
        );

        // Search string
        $filter = $where;
        if (isset($options['search']) && $options['search']) {
            $filter[] = '(votekey LIKE \'%' . NFW::i()->db->escape($options['search']) . '%\' OR email LIKE \'%' . NFW::i()->db->escape($options['search']) . '%\' OR poster_ip LIKE \'%' . NFW::i()->db->escape($options['search']) . '%\')';
        }

        // Count total records
        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'COUNT(*)',
            'FROM' => 'votekeys',
            'WHERE' => join(' AND ', $where),
        ))) {
            $this->error('Unable to count records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        list($totalRecords) = NFW::i()->db->fetch_row($result);

        // Count filtered values
        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => 'COUNT(*)',
            'FROM' => 'votekeys',
            'WHERE' => join(' AND ', $filter),
        ))) {
            $this->error('Unable to count filtered records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        list($numFiltered) = NFW::i()->db->fetch_row($result);
        if (!$numFiltered) {
            return array(array(), $totalRecords, 0);
        }

        if (!$result = NFW::i()->db->query_build(array(
            'SELECT' => '*',
            'FROM' => 'votekeys',
            'WHERE' => join(' AND ', $filter),
            'ORDER BY' => 'posted DESC',
            'LIMIT' => (isset($options['offset']) ? intval($options['offset']) : null) . (isset($options['limit']) ? ',' . intval($options['limit']) : null),
        ))) {
            $this->error('Unable to fetch records', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        if (!NFW::i()->db->num_rows($result)) {
            return array();
        }
        $records = array();
        while ($cur_record = NFW::i()->db->fetch_assoc($result)) {
            $records[] = $cur_record;
        }

        return array($records, $totalRecords, $numFiltered);
    }
}
