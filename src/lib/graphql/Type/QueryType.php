<?php

namespace Events\GraphQL\Type;

use GraphQL\Type\Definition\ListOfType;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\ResolveInfo;

use NFW;

use Events\GraphQL\Data\Work;
use Events\GraphQL\Data\User;
use Events\GraphQL\Types;

class QueryType extends ObjectType {
    public function __construct() {
        parent::__construct([
            'name' => 'Query',
            'fields' => [
                'currentUser' => [
                    'type' => Types::user(),
                    'description' => 'Current logged-in user',
                ],
                'works' => [
                    'type' => new ListOfType(Types::work()),
                    'description' => 'Returns subset of works',
                    'args' => [
                        'eventAlias' => [
                            'type' => Types::string(),
                            'description' => 'The works will be filtered by the specified event alias',
                        ],
                        'limit' => [
                            'type' => Types::int(),
                            'description' => 'Number of works to be returned',
                            'defaultValue' => 10,
                        ],
                    ],
                ],
            ],
            'resolveField' => fn($rootValue, array $args, $context, ResolveInfo $info) => $this->{$info->fieldName}($args),
        ]);
    }

    public function currentUser(): User {
        return new User(NFW::i()->user);
    }

    public function works(array $args): array {
        return Work::fetch($args);
    }
}
