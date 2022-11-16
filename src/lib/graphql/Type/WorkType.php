<?php declare(strict_types=1);

namespace Events\GraphQL\Type;

use Events\GraphQL\Types;
use GraphQL\Type\Definition\ObjectType;
use GraphQL\Type\Definition\ResolveInfo;

class WorkType extends ObjectType {
    public function __construct() {
        parent::__construct([
            'name' => 'Work',
            'description' => 'Event work',
            'fields' => static fn(): array => [
                'id' => Types::id(),
                'title' => [
                    'type' => Types::string(),
                    'description' => 'Title of the work',
                ],
                'author' => [
                    'type' => Types::string(),
                    'description' => 'The displayed author of the work',
                ],
            ],
            'resolveField' => function ($work, $args, $context, ResolveInfo $info) {
                $fieldName = $info->fieldName;

                $method = 'resolve'.ucfirst($fieldName);
                if (method_exists($this, $method)) {
                    return $this->{$method}($work, $args, $context, $info);
                }

                return $work->{$fieldName};
            },
        ]);
    }
}
