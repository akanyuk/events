<?php declare(strict_types=1);

namespace Events\GraphQL\Data;

class User {
    public int $id;
    public string $email;
    public string $username;
    public string $realname;
    public bool $isGuest;

    /**
     * @param array<string, mixed> $data
     */
    public function __construct(array $data) {
        $this->id = isset($data['id']) ? intval($data['id']) : 0;
        $this->email = isset($data['email']) ? strval($data['email']) : '';
        $this->username = isset($data['username']) ? strval($data['username']) : '';
        $this->realname = isset($data['realname']) ? strval($data['realname']) : '';
        $this->isGuest = isset($data['is_guest']) ? boolval($data['is_guest']) : true;
    }
}
