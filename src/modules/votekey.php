<?php

class votekey extends base_module {
    const votekeyLength = 8;

    var int $id = 0;
    var string $val = '';

    private int $eventID;
    private bool $isUsed;

    function __construct(int $eventID) {
        parent::__construct();
        $this->eventID = $eventID;
    }

    public static function generateVotekey($eventID, $email = ''): votekey {
        while (true) {
            $val = '';
            for ($i = 0; $i < self::votekeyLength; ++$i) {
                $val .= chr(mt_rand(48, 57));
            }

            $result = NFW::i()->db->query_build(array('SELECT' => 'votekey', 'FROM' => 'votekeys', 'WHERE' => '`votekey`=\'' . $val . '\' AND `event_id`=' . $eventID));
            if (!NFW::i()->db->num_rows($result)) break;
        }

        $instance = new votekey($eventID);

        $query = array(
            'INSERT' => '`event_id`, `votekey`, `email`, `useragent`, `poster_ip`, `posted`',
            'INTO' => 'votekeys',
            'VALUES' => $eventID . ', \'' . $val . '\', \'' . NFW::i()->db->escape($email) . '\', \'' . NFW::i()->db->escape($_SERVER['HTTP_USER_AGENT'] ?? '') . '\', \'' . logs::get_remote_address() . '\', ' . time()
        );
        if (!NFW::i()->db->query_build($query)) {
            $instance->error('unable to insert new votekey', __FILE__, __LINE__, NFW::i()->db->error());
            return $instance;
        }

        $instance->setID(NFW::i()->db->insert_id());
        $instance->setVal($val);

        return $instance;
    }

    public static function findOrCreateVotekey(int $eventID, string $email): votekey {
        $instance = new votekey($eventID);

        $query = array(
            'SELECT' => 'id, votekey, is_used',
            'FROM' => 'votekeys',
            'WHERE' => 'email=\'' . NFW::i()->db->escape($email) . '\' AND event_id=' . $eventID,
        );
        if (!$result = NFW::i()->db->query_build($query)) {
            $instance->error('unable to search votekey', __FILE__, __LINE__, NFW::i()->db->error());
            return $instance;
        }

        if (NFW::i()->db->num_rows($result)) {
            list($id, $val, $isUsed) = NFW::i()->db->fetch_row($result);
            $instance->setID($id);
            $instance->setVal($val);
            $instance->setIsUsed($isUsed);
            return $instance;
        }

        return self::generateVotekey($eventID, $email);
    }

    public static function getVotekey($val, $eventID): votekey {
        $instance = new votekey($eventID);
        if (!$val) {
            $instance->error('empty votekey value', __FILE__, __LINE__);
            return $instance;
        }

        $result = NFW::i()->db->query_build(array(
            'SELECT' => 'id, is_used',
            'FROM' => 'votekeys',
            'WHERE' => '`votekey`=\'' . NFW::i()->db->escape($val) . '\' AND `event_id`=' . $eventID));
        if (!NFW::i()->db->num_rows($result)) {
            $instance->error('votekey not found', __FILE__, __LINE__);
            return $instance;
        }

        list($id, $isUsed) = NFW::i()->db->fetch_row($result);
        $instance->setID($id);
        $instance->setVal($val);
        $instance->setIsUsed($isUsed);

        return $instance;
    }

    public static function cookieRestore($eventID): votekey {
        $instance = new votekey($eventID);
        if (!isset($_COOKIE['votekey-' . $eventID])) {
            $instance->error('votekey not stored', __FILE__, __LINE__);
            return $instance;
        }

        $votekey = votekey::getVotekey($_COOKIE['votekey-' . $eventID], $eventID);
        if ($votekey->error) {
            NFW::i()->setCookie('votekey-' . $eventID, null);
        }

        return $votekey;
    }

    public function setID(int $id): void {
        $this->id = $id;
    }

    public function setIsUsed(bool $isUsed): void {
        $this->isUsed = $isUsed;
    }

    public function setVal(string $val): void {
        $this->val = $val;
    }

    public function cookieStore() {
        NFW::i()->setCookie('votekey-' . $this->eventID, $this->val, time() + 60 * 60 * 24 * 7);
    }

    // Set `is_used` state and store votekey in COOKIE for future use
    public function used(): bool {
        $this->cookieStore();

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
