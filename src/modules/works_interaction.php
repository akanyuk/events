<?php
/**
 * @desc Interactions between work author and organizers
 */

class works_interaction extends base_module {
    const AUTHOR_ADD_FILE = 100;
    const ADMIN_ADD_FILE = 101;
    const ADMIN_DELETE_FILE = 102;

    function __construct() {
        parent::__construct();
    }

    public static function authorAddFile(int $workID, string $basename) {
        self::saveNoMessage(self::AUTHOR_ADD_FILE, $workID, $basename);
    }

    public static function adminAddFile(int $workID, string $basename) {
        self::saveNoMessage(self::ADMIN_ADD_FILE, $workID, $basename);
    }

    public static function adminDeleteFile(int $workID, string $basename) {
        self::saveNoMessage(self::ADMIN_DELETE_FILE, $workID, $basename);
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

    public function format(array $lang, $record): array {
        switch ($record['type']) {
            case self::AUTHOR_ADD_FILE;
            case self::ADMIN_ADD_FILE;
            case self::ADMIN_DELETE_FILE:
                $message = $lang[$record['type']] . $record['metadata'];
                break;
            default:
                $message = $record['message'];
        }

        return [
            'message' => $message,
            'posted' => $record['posted'],
            'poster_username' => $record['poster_username'],
        ];
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

        NFWX::i()->jsonSuccess(['records' => $records]);
    }
}
