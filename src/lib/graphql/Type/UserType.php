<?php declare(strict_types=1);

namespace Events\GraphQL\Type;

use Events\GraphQL\Types;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\ResolveInfo;

class UserType extends ObjectType {
    public function __construct() {
        parent::__construct([
            'name' => 'User',
            'description' => 'User account',
            'fields' => static fn(): array => [
                'id' => Types::id(),
                'username' => [
                    'type' => Types::string(),
                    'description' => 'User login',
                ],
                'realname' => [
                    'type' => Types::string(),
                    'description' => 'Full user name',
                ],
                'email' => [
                    'type' => Types::string(),
                    'description' => 'User\'s e-mail address',
                ],
                'isGuest' => [
                    'type' => Types::boolean(),
                    'description' => 'Indicates whether the user is a guest',
                ],
            ],
            'resolveField' => function ($user, $args, $context, ResolveInfo $info) {
                $fieldName = $info->fieldName;

                $method = 'resolve'.ucfirst($fieldName);
                if (method_exists($this, $method)) {
                    return $this->{$method}($user, $args, $context, $info);
                }

                return $user->{$fieldName};
            },
        ]);
    }
}
