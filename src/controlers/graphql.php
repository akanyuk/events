<?php

require_once(SRC_ROOT.'/lib/graphql/loader.php');

use GraphQL\GraphQL;
use GraphQL\Error\DebugFlag;
use GraphQL\Type\Schema;
use GraphQL\Type\SchemaConfig;

use Events\GraphQL\Types;
use Events\GraphQL\Type\QueryType;

$rawInput = file_get_contents('php://input');
$input = json_decode($rawInput, true);
$query = isset($input['query']) ? $input['query'] : null;
$variableValues = isset($input['variables']) ? $input['variables'] : null;

$schema = new Schema(
    (new SchemaConfig())->setQuery(new QueryType())->setTypeLoader([Types::class, 'byTypename'])
);

$debug = DebugFlag::NONE;
if (defined('NFW_DEBUG')) {
    $debug = DebugFlag::INCLUDE_DEBUG_MESSAGE || DebugFlag::INCLUDE_TRACE;
}

try {
    $result = GraphQL::executeQuery($schema, $query, [], null, $variableValues);
    $output = $result->toArray($debug);
} catch (Exception $e) {
    $output = [
        'errors' => [
            [
                'message' => $e->getMessage()
            ]
        ]
    ];
}

header('Content-Type: application/json');
NFW::i()->stop(json_encode($output));
