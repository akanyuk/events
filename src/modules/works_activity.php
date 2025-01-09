<?php

/**
 * @desc Activity between work author and organizers
 */
class works_activity extends base_module {
    const MESSAGE = 1;

    const AUTHOR_ADD_WORK = 100;
    const AUTHOR_ADD_FILE = 101;

    const ADMIN_ADD_FILE = 200;
    const ADMIN_DELETE_FILE = 201;
    const ADMIN_UPDATE_FILE_PROPS = 202;
    const ADMIN_RENAME_FILE = 203;
    const ADMIN_CONVERT_ZX = 204;
    const ADMIN_FILE_ID_DIZ = 205;
    const ADMIN_MAKE_RELEASE = 206;
    const ADMIN_REMOVE_RELEASE = 207;
    const ADMIN_UPDATE_STATUS = 208;
    const ADMIN_UPDATE = 209;
    const ADMIN_LINK_ADDED = 210;
    const ADMIN_LINK_REMOVED = 211;

    public static function authorAddWork(array $work) {
        self::saveNoMessage(self::AUTHOR_ADD_WORK, $work['id']);
        if ($work['description']) {
            self::addMessage($work['id'], $work['description']);
        }
    }

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
        removeLastPropsChangeSameFile($workID, $basename);

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
            'INTO' => 'works_activity',
            'VALUES' => self::MESSAGE . ', ' . $workID . ', \'' . NFW::i()->db->escape($message) . '\', ' . time() . ',' . NFW::i()->user['id']
        );
        if (!NFW::i()->db->query_build($query)) {
            NFW::i()->errorHandler(null, 'Unable to insert new activity', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        $id = NFW::i()->db->insert_id();
        self::updateUnreadState($workID);
        self::updateLastReadState($id, $workID);
        return true;
    }

    public static function authorUnread(): int {
        if (!$result = NFW::i()->db->query_build([
            'SELECT' => 'COUNT(*)',
            'FROM' => 'works_activity_unread AS wi',
            'JOINS' => array(
                array(
                    'INNER JOIN' => 'works AS w',
                    'ON' => 'w.id=wi.work_id'
                ),
            ),
            'WHERE' => 'wi.user_id=' . NFW::i()->user['id'] . ' AND w.posted_by=' . NFW::i()->user['id'],
        ])) {
            NFW::i()->errorHandler(null, 'Unable to load work activity last read', __FILE__, __LINE__, NFW::i()->db->error());
            return 0;
        }
        if (!NFW::i()->db->num_rows($result)) {
            return 0;
        }
        list($cnt) = NFW::i()->db->fetch_row($result);

        return $cnt;
    }

    public static function adminUnread(): int {
        if (!$result = NFW::i()->db->query_build([
            'SELECT' => 'COUNT(*)',
            'FROM' => 'works_activity_unread AS wi',
            'JOINS' => array(
                array(
                    'INNER JOIN' => 'works AS w',
                    'ON' => 'w.id=wi.work_id'
                ),
            ),
            'WHERE' => 'wi.user_id=' . NFW::i()->user['id'] . ' AND w.posted_by!=' . NFW::i()->user['id'],
        ])) {
            NFW::i()->errorHandler(null, 'Unable to load admin activities unread', __FILE__, __LINE__, NFW::i()->db->error());
            return 0;
        }
        if (!NFW::i()->db->num_rows($result)) {
            return 0;
        }
        list($cnt) = NFW::i()->db->fetch_row($result);

        return $cnt;
    }

    public static function unreadExplained(): array {
        $subSql = '(
SELECT COUNT(*) FROM works_activity AS i2
LEFT JOIN works_activity_last_read AS l ON l.work_id=i2.work_id AND l.user_id=' . NFW::i()->user['id'] . '
WHERE i2.work_id = i.work_id AND (i2.id > l.activity_id OR l.activity_id IS NULL)
) AS unread';
        $query = [
            'SELECT' => 'i.work_id, ' . $subSql,
            'FROM' => 'works_activity AS i',
            'JOINS' => [
                [
                    'INNER JOIN' => 'works_activity_unread AS u',
                    'ON' => 'u.work_id=i.work_id AND u.user_id=' . NFW::i()->user['id'],
                ],
            ],
            'GROUP BY' => 'i.work_id',
        ];
        if (!$result = NFW::i()->db->query_build($query)) {
            NFW::i()->errorHandler(null, 'Unable to load work activity unread explained', __FILE__, __LINE__, NFW::i()->db->error());
            return [];
        }
        if (!NFW::i()->db->num_rows($result)) {
            return [];
        }
        $response = [];
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            if ($record['unread'] > 0) {
                $response[$record['work_id']] = $record['unread'];
            }
        }

        return $response;
    }

    public static function markRead(int $workID): bool {
        if (!NFW::i()->db->query_build([
            'DELETE' => 'works_activity_unread',
            'WHERE' => 'work_id=' . $workID . ' AND user_id=' . NFW::i()->user['id'],
        ])) {
            NFW::i()->errorHandler(null, 'Unable to mark work read', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        return true;
    }

    public static function workDeleted(int $workID) {
        if (!NFW::i()->db->query_build(array('DELETE' => 'works_activity_unread', 'WHERE' => 'work_id=' . $workID))) {
            NFW::i()->errorHandler(null, 'Unable to delete activity unread states', __FILE__, __LINE__, NFW::i()->db->error());
        }

        if (!NFW::i()->db->query_build(array('DELETE' => 'works_activity_last_read', 'WHERE' => 'work_id=' . $workID))) {
            NFW::i()->errorHandler(null, 'Unable to delete old activity last read state', __FILE__, __LINE__, NFW::i()->db->error());
        }

        if (!NFW::i()->db->query_build(array('DELETE' => 'works_activity', 'WHERE' => 'work_id=' . $workID))) {
            NFW::i()->errorHandler(null, 'Unable to delete activities', __FILE__, __LINE__, NFW::i()->db->error());
        }
    }

    private static function saveNoMessage(int $type, int $workID, string $metadata = "") {
        $query = array(
            'INSERT' => '`type`, work_id, metadata, posted, posted_by',
            'INTO' => 'works_activity',
            'VALUES' => $type . ', ' . $workID . ', \'' . NFW::i()->db->escape($metadata) . '\', ' . time() . ',' . NFW::i()->user['id']
        );
        if (!NFW::i()->db->query_build($query)) {
            NFW::i()->errorHandler(null, 'Unable to insert new activity', __FILE__, __LINE__, NFW::i()->db->error());
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

        // Prune old activity unread with same `work_id`
        if (!NFW::i()->db->query_build(array('DELETE' => 'works_activity_unread', 'WHERE' => 'work_id=' . $workID))) {
            NFW::i()->errorHandler(null, 'Unable to delete old activity unread states', __FILE__, __LINE__, NFW::i()->db->error());
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
                'INTO' => 'works_activity_unread',
                'VALUES' => $workID . ', ' . $userID
            ))) {
                NFW::i()->errorHandler(null, 'Unable to insert works activity unread state', __FILE__, __LINE__, NFW::i()->db->error());
            }
        }
    }

    private static function updateLastReadState(int $id, $workID) {
        if ($id <= 0) {
            return;
        }

        if (!NFW::i()->db->query_build(array('DELETE' => 'works_activity_last_read', 'WHERE' => 'work_id=' . $workID . ' AND user_id=' . NFW::i()->user['id']))) {
            NFW::i()->errorHandler(null, 'Unable to delete old activity last read', __FILE__, __LINE__, NFW::i()->db->error());
        }

        if (!NFW::i()->db->query_build([
            'INSERT' => 'activity_id, work_id, user_id',
            'INTO' => 'works_activity_last_read',
            'VALUES' => $id . ',' . $workID . ',' . NFW::i()->user['id'],
        ])) {
            NFW::i()->errorHandler(null, 'Unable to update work activity last read', __FILE__, __LINE__, NFW::i()->db->error());
        }
    }

    private function format(array $lang, $langMain, int $lastReadID, array $record): array {
        $isMessage = false;
        switch ($record['type']) {
            case self::MESSAGE:
                $message = $record['message'];
                $isMessage = true;
                break;
            case self::AUTHOR_ADD_WORK:
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
            'message' => $message,
            'is_message' => $isMessage,
            'posted' => $record['posted'],
            'posted_by' => intval($record['posted_by']),
            'poster_username' => $record['poster_username'],
            'is_new' => $lastReadID < $record['id'],
        ];
    }

    public function records(array $work) {
        if (!$result = NFW::i()->db->query_build([
            'SELECT' => 'activity_id',
            'FROM' => 'works_activity_last_read',
            'WHERE' => 'work_id=' . $work['id'] . ' AND user_id=' . NFW::i()->user['id'],
        ])) {
            $this->error('Unable to load work activities', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }
        $lastReadID = 0;
        if (NFW::i()->db->num_rows($result)) {
            list($lastReadID) = NFW::i()->db->fetch_row($result);
        }

        $query = array(
            'SELECT' => 'wi.*, u.username AS poster_username',
            'FROM' => 'works_activity AS wi',
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
            $this->error('Unable to load work activities', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        $langMain = NFW::i()->getLang('main');
        $lastID = 0;
        $isLegacy = true;
        $lang = NFW::i()->getLang("activity");
        $records = [];
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $lastID = $record['id'];
            if ($record['type'] == self::AUTHOR_ADD_WORK) {
                $isLegacy = false;
            }
            $records[] = $this->format($lang, $langMain, $lastReadID, $record);
        }

        self::updateLastReadState($lastID, $work['id']);

        // Resetting unread state for current user
        if (!NFW::i()->db->query_build(array('DELETE' => 'works_activity_unread', 'WHERE' => 'work_id=' . $work['id'] . ' AND user_id=' . NFW::i()->user['id']))) {
            NFW::i()->errorHandler(null, 'Unable to reset unread states', __FILE__, __LINE__, NFW::i()->db->error());
        }

        if (!$isLegacy) {
            return $records;
        }

        if ($work['description']) {
            array_unshift($records, [
                'message' => $work['description'],
                'is_message' => true,
                'posted' => $work['posted'],
                'posted_by' => intval($work['posted_by']),
                'poster_username' => $work['posted_username'],
                'is_new' => $lastReadID == 0,
            ]);
        }

        array_unshift($records, [
            'message' => $langMain['work uploaded'],
            'is_message' => false,
            'posted' => $work['posted'],
            'posted_by' => intval($work['posted_by']),
            'poster_username' => $work['posted_username'],
            'is_new' => $lastReadID == 0,
        ]);

        return $records;
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

        NFWX::i()->jsonSuccess([
            'records' => $records,
            'unread' => self::adminUnread(),
        ]);
    }

    function actionAdminMessage() {
        $workID = intval($_GET['work_id']);
        $message = $_POST['message'];
        if ($message == "") {
            NFWX::i()->jsonError(400, 'Message can not be empty');
        }

        if (!self::addMessage($workID, $message)) {
            $this->error('Unable to save message', __FILE__, __LINE__, NFW::i()->db->error());
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

function removeLastPropsChangeSameFile(int $workID, string $basename) {
    if (!$result = NFW::i()->db->query('SELECT id, type, metadata FROM works_activity WHERE work_id=' . $workID . ' ORDER BY id DESC LIMIT 0, 1')) {
        NFW::i()->errorHandler(null, 'Unable to get activity of work', __FILE__, __LINE__, NFW::i()->db->error());
        return;
    }
    if (!NFW::i()->db->num_rows($result)) {
        return;
    }

    list($id, $type, $meta) = NFW::i()->db->fetch_row($result);
    $metadata = json_decode($meta, true);
    if ($type != works_activity::ADMIN_UPDATE_FILE_PROPS || $metadata['basename'] != $basename) {
        return;
    }

    if (!NFW::i()->db->query('DELETE FROM works_activity WHERE id=' . $id)) {
        NFW::i()->errorHandler(null, 'Unable to delete last activity of work', __FILE__, __LINE__, NFW::i()->db->error());
    }
}
