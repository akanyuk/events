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

    function __construct() {
        parent::__construct();
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

    public static function adminUpdateFileProps(int $workID, array $oldProps, array $newProps) {
        // Extracting props changes
        $oldPropsMap = [];
        foreach ($oldProps as $p) {
            $oldPropsMap[$p['id']] = $p;
        }
        $changes = [];
        foreach ($newProps as $p) {
            if (isset($oldPropsMap[$p['id']])) {
                if ($p['is_screenshot'] == $oldPropsMap[$p['id']]['is_screenshot'] &&
                    $p['is_audio'] == $oldPropsMap[$p['id']]['is_audio'] &&
                    $p['is_image'] == $oldPropsMap[$p['id']]['is_image'] &&
                    $p['is_voting'] == $oldPropsMap[$p['id']]['is_voting'] &&
                    $p['is_release'] == $oldPropsMap[$p['id']]['is_release']) {
                    continue;
                }
            }

            $changes[] = [
                'basename' => $p['basename'],
                'props' => array_filter([
                    $p['is_screenshot'] ? 'screenshot' : null,
                    $p['is_audio'] ? 'audio' : null,
                    $p['is_image'] ? 'image' : null,
                    $p['is_voting'] ? 'voting' : null,
                    $p['is_release'] ? 'release' : null,
                ]),
            ];
        }

        foreach ($changes as $c) {
            self::saveNoMessage(self::ADMIN_UPDATE_FILE_PROPS, $workID, json_encode($c));
        }
    }

    public static function adminRenameFile(int $workID, string $oldName, string $basename) {
        self::saveNoMessage(self::ADMIN_RENAME_FILE, $workID, json_encode([
            'oldName' => $oldName,
            'basename' => $basename,
        ]));
    }

    private static function saveNoMessage(int $type, int $workID, string $metadata) {
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
            case self::AUTHOR_ADD_FILE;
            case self::ADMIN_ADD_FILE;
            case self::ADMIN_DELETE_FILE:
                $metadata = json_decode($record['metadata'], true);
                $message = sprintf($lang[$record['type']], $metadata['basename']);
                break;
            case self::ADMIN_UPDATE_FILE_PROPS:
                $metadata = json_decode($record['metadata'], true);
                $message = sprintf($lang[$record['type']], $metadata['basename'], implode(", ", $metadata['props']));
                $dupeCheck = sprintf($lang[$record['type']], $metadata['basename'], '');
                break;
            case self::ADMIN_RENAME_FILE:
                $metadata = json_decode($record['metadata'], true);
                $message = sprintf($lang[$record['type']], $metadata['oldName'], $metadata['basename']);
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
