<?php declare(strict_types=1);

namespace Events\GraphQL\Data;

use Events\GraphQL\Util\EventsError;

use NFW;

class Work {
    public int $id;
    public string $title;
    public string $author;

    /**
     * @param array<string, mixed> $data
     */
    public function __construct(array $data) {
        $this->id = isset($data['id']) ? intval($data['id']) : 0;
        $this->title = isset($data['title']) ? strval($data['title']) : '';
        $this->author = isset($data['author']) ? strval($data['author']) : '';
    }

    public static function fetch(array $args): array {
        $select = [
            'w.id', 'w.title', 'w.author',
        ];

        $joins = array(
            array(
                'INNER JOIN' => 'competitions AS c',
                'ON' => 'w.competition_id=c.id'
            ),
            array(
                'INNER JOIN' => 'events AS e',
                'ON' => 'c.event_id=e.id'
            ),
        );

        $where = array();

        if (isset($args['eventAlias'])) {
            $where[] = 'e.alias="'.NFW::i()->db->escape($args['eventAlias']).'"';
        }

        $query = array(
            'SELECT' => implode(', ', $select),
            'FROM' => 'works AS w',
            'JOINS' => $joins,
            'WHERE' => count($where) ? join(' AND ', array_unique($where)) : null,
            'LIMIT' => '0,'.intval($args['limit']),
            'ORDER BY' => 'w.posted'
        );
        if (!$result = NFW::i()->db->query_build($query)) {
            EventsError::throw("Fetch works error", __FILE__, __LINE__, NFW::i()->db->error());
        }

        $records = [];
        while ($record = NFW::i()->db->fetch_assoc($result)) {
            $records[] = new Work($record);
        }

        return $records;
    }
}

