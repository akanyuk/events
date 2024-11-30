<?php
/**
 * @desc Interactions between work author and organizers
 */
class works_interaction extends base_module {
    const AUTHOR_ADD_FILE = 100;
    const ADMIN_ADD_FILE = 101;
    const ADMIN_DELETE_FILE = 102;
    const ADMIN_UPDATE_FILE_PROPS = 103;
    const ADMIN_RENAME_FILE = 104;
    const ADMIN_CONVERT_ZX = 105;
    const ADMIN_FILE_ID_DIZ = 106;
    const ADMIN_MAKE_RELEASE = 107;
    const ADMIN_REMOVE_RELEASE = 108;

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
                isset($props['screenshot']) &&  $props['screenshot'] ? 'screenshot' : null,
                isset($props['audio']) &&  $props['audio'] ? 'audio' : null,
                isset($props['image']) &&  $props['image'] ? 'image' : null,
                isset($props['voting']) &&  $props['voting'] ? 'voting' : null,
                isset($props['release']) &&  $props['release'] ? 'release' : null,
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

    private static function saveNoMessage(int $type, int $workID, string $metadata = "") {
        $query = array(
            'INSERT' => '`type`, work_id, metadata, posted, posted_by',
            'INTO' => 'works_interaction',
            'VALUES' => $type . ', ' . $workID . ', \'' . NFW::i()->db->escape($metadata) . '\', ' . time() . ',' . NFW::i()->user['id']
        );
        if (!NFW::i()->db->query_build($query)) {
            NFW::i()->errorHandler(null, 'Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
        }
    }

    private function format(array $lang, $record): array {
        $dupeCheck = '';
        switch ($record['type']) {
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
            default:
                $message = $record['message'];
        }

        return [
            'dupe_check' => $dupeCheck,
            'message' => $message,
            'posted' => $record['posted'],
            'poster_username' => $record['poster_username'],
        ];
    }

    private function removeDupes(array $records): array {
        $result = [];
        $lastDupe = '';
        foreach (array_reverse($records) as $record) {
            if ($record['dupe_check'] == '' || $record['dupe_check'] != $lastDupe) {
                $result[] = $record;
            }
            $lastDupe = $record['dupe_check'];
        }
        return array_reverse($result);
    }

    function actionAdminList() {
        $workID = intval($_GET['record_id']);

        $query = array(
            'SELECT' => 'wi.*, u.username AS poster_username',
            'FROM' => 'works_interaction AS wi',
            'JOINS' => array(
                array(
                    'LEFT JOIN' => 'users AS u',
                    'ON' => 'wi.posted_by=u.id'
                ),
            ),
            'WHERE' => 'work_id=' . $workID,
            'ORDER BY' => 'posted',
        );
        if (!$result = NFW::i()->db->query_build($query)) {
            $this->error('Unable to load work interaction', __FILE__, __LINE__, NFW::i()->db->error);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $lang = NFW::i()->getLang("interaction");
        $records = [];
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $records[] = $this->format($lang, $record);
        }

        NFWX::i()->jsonSuccess(['records' => $this->removeDupes($records)]);
    }
}
