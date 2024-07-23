<?php

class votekey extends base_module {
    const votekeyLength = 8;

    var int $id;
    var string $votekey;
    private bool $isUsed;

    function __construct($id = 0, $votekey = "", $isUsed = false) {
        parent::__construct();

        $this->id = $id;
        $this->votekey = $votekey;
        $this->isUsed = $isUsed;
    }

    public static function generateVotekey($eventID, $email = ''): votekey {
        while (true) {
            $votekey = '';
            for ($i = 0; $i < self::votekeyLength; ++$i) {
                $votekey .= chr(mt_rand(48, 57));
            }

            $result = NFW::i()->db->query_build(array('SELECT' => 'votekey', 'FROM' => 'votekeys', 'WHERE' => '`votekey`=\'' . $votekey . '\' AND `event_id`=' . $eventID));
            if (!NFW::i()->db->num_rows($result)) break;
        }

        $query = array(
            'INSERT' => '`event_id`, `votekey`, `email`, `useragent`, `poster_ip`, `posted`',
            'INTO' => 'votekeys',
            'VALUES' => $eventID . ', \'' . $votekey . '\', \'' . NFW::i()->db->escape($email) . '\', \'' . NFW::i()->db->escape($_SERVER['HTTP_USER_AGENT'] ?? '') . '\', \'' . logs::get_remote_address() . '\', ' . time()
        );
        if (!NFW::i()->db->query_build($query)) {
            $instance = new votekey();
            $instance->error('unable to insert new votekey', __FILE__, __LINE__, NFW::i()->db->error());
            return $instance;
        }

        return new votekey(NFW::i()->db->insert_id(), $votekey);
    }

    public static function findOrCreateVotekey(int $eventID, string $email): votekey {
        $query = array(
            'SELECT' => 'id, votekey, is_used',
            'FROM' => 'votekeys',
            'WHERE' => 'email=\'' . NFW::i()->db->escape($email) . '\' AND event_id=' . $eventID,
        );
        if (!$result = NFW::i()->db->query_build($query)) {
            $instance = new votekey();
            $instance->error('unable to search votekey', __FILE__, __LINE__, NFW::i()->db->error());
            return $instance;
        }

        if (NFW::i()->db->num_rows($result)) {
            list($id, $votekey, $is_used) = NFW::i()->db->fetch_row($result);
            return new votekey($id, $votekey, $is_used);
        }

        return self::generateVotekey($eventID, $email);
    }


    public static function getVotekey($votekey, $eventID): votekey {
        if (!$votekey) {
            $instance = new votekey();
            $instance->error('empty votekey value', __FILE__, __LINE__);
            return $instance;
        }

        $result = NFW::i()->db->query_build(array(
            'SELECT' => 'id, is_used',
            'FROM' => 'votekeys',
            'WHERE' => '`votekey`=\'' . NFW::i()->db->escape($votekey) . '\' AND `event_id`=' . $eventID));
        if (!NFW::i()->db->num_rows($result)) {
            $instance = new votekey();
            $instance->error('votekey not found', __FILE__, __LINE__);
            return $instance;
        }

        list($votekeyID, $isUsed) = NFW::i()->db->fetch_row($result);
        return new votekey($votekeyID, $votekey, $isUsed);
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

    // Set `is_used` state and store votekey in COOKIE for future use
    public function used(): bool {
        NFW::i()->setCookie('votekey', $this->votekey, time() + 60 * 60 * 24 * 7);

        if ($this->isUsed) {
            return true;
        }

        if (!NFW::i()->db->query_build(array('UPDATE' => 'votekeys', 'SET' => 'is_used=1', 'WHERE' => 'id=' . $this->id))) {
            $this->error('Unable to update votekey state', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        $this->isUsed = true;
        return true;
    }
}
