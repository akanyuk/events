<?php
/**
 * @desc Interactions between work author and orgaz
 */

class works_interaction extends base_module {
    const AUTHOR_ADD_FILE = 100;
    const ADMIN_ADD_FILE = 101;
    const ADMIN_DELETE_FILE = 102;

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
            'VALUES' => $type . ', '.$workID . ', \'' . NFW::i()->db->escape($metadata) . '\', ' . time().','.NFW::i()->user['id']
        );
        if (!NFW::i()->db->query_build($query)) {
            NFW::i()->errorHandler(null, 'Unable to insert new vote', __FILE__, __LINE__, NFW::i()->db->error());
        }
    }
}
