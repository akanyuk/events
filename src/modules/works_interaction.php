<?php

/**
 * @desc Interactions between work author and organizers
 */
class works_interaction extends base_module {
    const MESSAGE = 1;

    const AUTHOR_ADD_FILE = 100;
    const ADMIN_ADD_FILE = 101;
    const ADMIN_DELETE_FILE = 102;
    const ADMIN_UPDATE_FILE_PROPS = 103;
    const ADMIN_RENAME_FILE = 104;
    const ADMIN_CONVERT_ZX = 105;
    const ADMIN_FILE_ID_DIZ = 106;
    const ADMIN_MAKE_RELEASE = 107;
    const ADMIN_REMOVE_RELEASE = 108;
    const ADMIN_UPDATE_STATUS = 109;
    const ADMIN_UPDATE = 110;
    const ADMIN_LINK_ADDED = 111;
    const ADMIN_LINK_REMOVED = 112;

    public static function authorAddFile(int $workID, string $basename) {
        self::saveNoMessage(self::AUTHOR_ADD_FILE, $workID, json_encode([
            'basename' => $basename,
        ]));
    }

    public static function adminAddFile(int $workID, string $basename) {
        self::saveNoMessage(self::ADMIN_ADD_FILE, $workID, json_encode([
            'basename' => $basename,
        ]));
    }

    public static function adminDeleteFile(int $workID, string $basename) {
        self::saveNoMessage(self::ADMIN_DELETE_FILE, $workID, json_encode([
            'basename' => $basename,
        ]));
    }

    public static function adminUpdateFileProps(int $workID, string $basename, array $props) {
        self::saveNoMessage(self::ADMIN_UPDATE_FILE_PROPS, $workID, json_encode([
            'basename' => $basename,
            'props' => array_filter([
                isset($props['screenshot']) && $props['screenshot'] ? 'screenshot' : null,
                isset($props['audio']) && $props['audio'] ? 'audio' : null,
                isset($props['image']) && $props['image'] ? 'image' : null,
                isset($props['voting']) && $props['voting'] ? 'voting' : null,
                isset($props['release']) && $props['release'] ? 'release' : null,
            ]),
        ]));
    }

    public static function adminRenameFile(int $workID, string $oldName, string $basename) {
        self::saveNoMessage(self::ADMIN_RENAME_FILE, $workID, json_encode([
            'oldName' => $oldName,
            'basename' => $basename,
        ]));
    }

    public static function adminConvertZX(int $workID, string $basename1, string $basename2, string $origName) {
        self::saveNoMessage(self::ADMIN_CONVERT_ZX, $workID, json_encode([
            'basename1' => $basename1,
            'basename2' => $basename2,
            'origName' => $origName,
        ]));
    }

    public static function adminFileIdDiz(int $workID) {
        self::saveNoMessage(self::ADMIN_FILE_ID_DIZ, $workID);
    }

    public static function adminMakeRelease(int $workID, string $basename) {
        self::saveNoMessage(self::ADMIN_MAKE_RELEASE, $workID, json_encode([
            'basename' => $basename,
        ]));
    }

    public static function adminRemoveRelease(int $workID) {
        self::saveNoMessage(self::ADMIN_REMOVE_RELEASE, $workID);
    }

    public static function adminUpdateStatus(int $workID, int $status, string $reason) {
        self::saveNoMessage(self::ADMIN_UPDATE_STATUS, $workID, json_encode([
            'status' => $status,
            'reason' => $reason,
        ]));
    }

    public static function adminUpdate(int $workID, string $field, string $value) {
        self::saveNoMessage(self::ADMIN_UPDATE, $workID, json_encode([
            'field' => $field,
            'value' => $value,
        ]));
    }

    public static function adminLinkAdded(int $workID, string $url) {
        self::saveNoMessage(self::ADMIN_LINK_ADDED, $workID, json_encode([
            'url' => $url,
        ]));
    }

    public static function adminLinkRemoved(int $workID, string $url) {
        self::saveNoMessage(self::ADMIN_LINK_REMOVED, $workID, json_encode([
            'url' => $url,
        ]));
    }

    public static function addMessage(int $workID, string $message): bool {
        $query = array(
            'INSERT' => '`type`, work_id, message, posted, posted_by',
            'INTO' => 'works_interaction',
            'VALUES' => self::MESSAGE . ', ' . $workID . ', \'' . NFW::i()->db->escape($message) . '\', ' . time() . ',' . NFW::i()->user['id']
        );
        if (!NFW::i()->db->query_build($query)) {
            NFW::i()->errorHandler(null, 'Unable to insert new interaction', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        $id = NFW::i()->db->insert_id();
        self::updateUnreadState($workID);
        self::updateLastReadState($id, $workID);
        return true;
    }

    private static function saveNoMessage(int $type, int $workID, string $metadata = "") {
        $query = array(
            'INSERT' => '`type`, work_id, metadata, posted, posted_by',
            'INTO' => 'works_interaction',
            'VALUES' => $type . ', ' . $workID . ', \'' . NFW::i()->db->escape($metadata) . '\', ' . time() . ',' . NFW::i()->user['id']
        );
        if (!NFW::i()->db->query_build($query)) {
            NFW::i()->errorHandler(null, 'Unable to insert new interaction', __FILE__, __LINE__, NFW::i()->db->error());
            return;
        }

        $id = NFW::i()->db->insert_id();
        self::updateUnreadState($workID);
        self::updateLastReadState($id, $workID);
    }

    private static function updateUnreadState(int $workID) {
        $CWorks = new works($workID);
        if (!$CWorks->record['id']) {
            NFW::i()->errorHandler(null, 'Unable to find work', __FILE__, __LINE__, NFW::i()->db->error());
            return;
        }

        // Prune old interactions unread with same `work_id`
        if (!NFW::i()->db->query_build(array('DELETE' => 'works_interaction_unread', 'WHERE' => 'work_id=' . $workID))) {
            NFW::i()->errorHandler(null, 'Unable to delete old interaction unread states', __FILE__, __LINE__, NFW::i()->db->error());
            return;
        }

        $users = events::getManagers($CWorks->record['event_id']);
        $users[] = $CWorks->record['posted_by'];
        foreach (array_unique($users) as $userID) {
            if ($userID == NFW::i()->user['id']) {
                continue;
            }

            if (!NFW::i()->db->query_build(array(
                'INSERT' => '`work_id`, `user_id`',
                'INTO' => 'works_interaction_unread',
                'VALUES' => $workID . ', ' . $userID
            ))) {
                NFW::i()->errorHandler(null, 'Unable to insert works interaction state', __FILE__, __LINE__, NFW::i()->db->error());
            }
        }
    }

    private static function updateLastReadState(int $id, $workID) {
        if ($id <= 0) {
            return;
        }

        if (!NFW::i()->db->query_build(array('DELETE' => 'works_interaction_last_read', 'WHERE' => 'work_id=' . $workID . ' AND user_id=' . NFW::i()->user['id']))) {
            NFW::i()->errorHandler(null, 'Unable to delete old interaction last read', __FILE__, __LINE__, NFW::i()->db->error());
        }

        if (!NFW::i()->db->query_build([
            'INSERT' => 'interaction_id, work_id,user_id',
            'INTO' => 'works_interaction_last_read',
            'VALUES' => $id . ',' . $workID . ',' . NFW::i()->user['id'],
        ])) {
            NFW::i()->errorHandler(null, 'Unable to update work interaction last read', __FILE__, __LINE__, NFW::i()->db->error());
        }
    }

    private function format(array $lang, $langMain, int $lastReadID, array $record): array {
        $dupeCheck = '';
        $isMessage = false;
        switch ($record['type']) {
            case self::MESSAGE:
                $message = $record['message'];
                $isMessage = true;
                break;
            case self::ADMIN_FILE_ID_DIZ:
            case self::ADMIN_REMOVE_RELEASE:
                $message = $lang[$record['type']];
                break;
            case self::AUTHOR_ADD_FILE;
            case self::ADMIN_ADD_FILE;
            case self::ADMIN_DELETE_FILE:
            case self::ADMIN_MAKE_RELEASE:
                $metadata = json_decode($record['metadata'], true);
                $message = sprintf($lang[$record['type']], $metadata['basename']);
                break;
            case self::ADMIN_UPDATE_FILE_PROPS:
                $metadata = json_decode($record['metadata'], true);
                $props = empty($metadata['props']) ? '-' : implode(", ", $metadata['props']);
                $message = sprintf($lang[$record['type']], $metadata['basename'], $props);
                $dupeCheck = sprintf($lang[$record['type']], $metadata['basename'], '');
                break;
            case self::ADMIN_RENAME_FILE:
                $metadata = json_decode($record['metadata'], true);
                $message = sprintf($lang[$record['type']], $metadata['oldName'], $metadata['basename']);
                break;
            case self::ADMIN_CONVERT_ZX:
                $metadata = json_decode($record['metadata'], true);
                $message = sprintf($lang[$record['type']], $metadata['basename1'], $metadata['basename2'], $metadata['origName']);
                break;
            case self::ADMIN_UPDATE_STATUS:
                $metadata = json_decode($record['metadata'], true);
                $status = $langMain['works status desc'][$metadata['status']] ?: 'unknown';
                $reason = $metadata['reason'] ?: $langMain['works status desc full'][$metadata['status']];
                $message = sprintf($lang[$record['type']], $status, $reason);
                break;
            case self::ADMIN_UPDATE:
                $metadata = json_decode($record['metadata'], true);
                $field = $langMain['works attributes'][$metadata['field']] ?: 'unknown';
                $message = sprintf($lang[$record['type']], $field, $metadata['value']);
                break;
            case self::ADMIN_LINK_ADDED:
            case self::ADMIN_LINK_REMOVED:
                $metadata = json_decode($record['metadata'], true);
                $message = sprintf($lang[$record['type']], $metadata['url']);
                break;

            default:
                $message = $record['message'];
        }

        return [
            'dupe_check' => $dupeCheck,
            'message' => $message,
            'is_message' => $isMessage,
            'posted' => $record['posted'],
            'posted_by' => intval($record['posted_by']),
            'poster_username' => $record['poster_username'],
            'is_new' => $lastReadID < $record['id'],
        ];
    }

    private function removeDupes(array $records): array {
        $result = [];
        $lastDupe = '';
        foreach (array_reverse($records) as $record) {
            if ($record['dupe_check'] == '' || $record['dupe_check'] != $lastDupe) {
                $result[] = $record;
                unset($result[array_key_last($result)]['dupe_check']);
            }
            $lastDupe = $record['dupe_check'];
        }
        return array_reverse($result);
    }

    public function records(array $work) {
        if (!$result = NFW::i()->db->query_build([
            'SELECT' => 'interaction_id',
            'FROM' => 'works_interaction_last_read',
            'WHERE' => 'work_id=' . $work['id'] . ' AND user_id=' . NFW::i()->user['id'],
        ])) {
            $this->error('Unable to load work interaction last read', __FILE__, __LINE__, NFW::i()->db->error);
            return false;
        }
        $lastReadID = 0;
        if (NFW::i()->db->num_rows($result)) {
            list($lastReadID) = NFW::i()->db->fetch_row($result);
        }

        $query = array(
            'SELECT' => 'wi.*, u.username AS poster_username',
            'FROM' => 'works_interaction AS wi',
            'JOINS' => array(
                array(
                    'LEFT JOIN' => 'users AS u',
                    'ON' => 'wi.posted_by=u.id'
                ),
            ),
            'WHERE' => 'work_id=' . $work['id'],
            'ORDER BY' => 'posted',
        );
        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to load work interaction', __FILE__, __LINE__, NFW::i()->db->error);
            return false;
        }

        $langMain = NFW::i()->getLang('main');
        $records = [[
            'dupe_check' => '',
            'message' => $langMain['work uploaded'],
            'is_message' => false,
            'posted' => $work['posted'],
            'posted_by' => intval($work['posted_by']),
            'poster_username' => $work['posted_username'],
            'is_new' => $lastReadID == 0,
        ]];

        if ($work['description']) {
            $records[] = [
                'dupe_check' => '',
                'message' => $work['description'],
                'is_message' => true,
                'posted' => $work['posted'],
                'posted_by' => intval($work['posted_by']),
                'poster_username' => $work['posted_username'],
                'is_new' => $lastReadID == 0,
            ];
        }

        $lastID = 0;
        $lang = NFW::i()->getLang("interaction");
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $lastID = $record['id'];
            $records[] = $this->format($lang, $langMain, $lastReadID, $record);
        }

        self::updateLastReadState($lastID, $work['id']);

        // Resetting unread state for current user
        if (!NFW::i()->db->query_build(array('DELETE' => 'works_interaction_unread', 'WHERE' => 'work_id=' . $work['id'].' AND user_id='.NFW::i()->user['id']))) {
            NFW::i()->errorHandler(null, 'Unable to reset unread states', __FILE__, __LINE__, NFW::i()->db->error());
        }

        return $this->removeDupes($records);
    }

    function actionAdminList() {
        $workID = intval($_GET['work_id']);

        $CWorks = new works($workID);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $records = $this->records($CWorks->record);
        if ($this->error) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        NFWX::i()->jsonSuccess(['records' => $records]);
    }

    function actionAdminMessage() {
        $workID = intval($_GET['work_id']);
        $message = $_POST['message'];
        if ($message == "") {
            NFWX::i()->jsonError(400, 'Message can not be empty');
        }

        if (!self::addMessage($workID, $message)) {
            $this->error('Unable to save message', __FILE__, __LINE__, NFW::i()->db->error);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        NFWX::i()->jsonSuccess([
            'message' => $message,
            'is_message' => true,
            'posted' => time(),
            'poster_username' => NFW::i()->user['username']
        ]);
    }
}
