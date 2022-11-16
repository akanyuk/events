<?php declare(strict_types=1);

namespace Events\GraphQL;

use Closure;
use Exception;

use GraphQL\Type\Definition\NamedType;
use GraphQL\Type\Definition\ScalarType;
use GraphQL\Type\Definition\Type;

use Events\GraphQL\Type\UserType;
use Events\GraphQL\Type\WorkType;

/**
 * Acts as a registry and factory for your types.
 *
 * As simplistic as possible for the sake of clarity of this example.
 * Your own may be more dynamic (or even code-generated).
 */
final class Types {
    /** @var array<string, Type&NamedType> */
    private static array $types = [];

    public static function user(): callable {
        return self::get(UserType::class);
    }

    public static function work(): callable {
        return self::get(WorkType::class);
    }

    /**
     * @param class-string<Type&NamedType> $classname
     *
     * @return Closure(): Type
     */
    private static function get(string $classname): Closure {
        return static fn() => self::byClassName($classname);
    }

    /**
     * @param class-string<Type&NamedType> $classname
     * @return Type
     */
    private static function byClassName(string $classname): Type {
        $parts = explode('\\', $classname);

        $withoutTypePrefix = preg_replace('~Type$~', '', $parts[count($parts) - 1]);
        assert(is_string($withoutTypePrefix), 'regex is statically known to be correct');

        $cacheName = strtolower($withoutTypePrefix);

        if (!isset(self::$types[$cacheName])) {
            return self::$types[$cacheName] = new $classname();
        }

        return self::$types[$cacheName];
    }

    /**
     * @param string $shortName
     * @return Type&NamedType
     * @throws Exception
     */
    public static function byTypeName(string $shortName): Type {
        $cacheName = strtolower($shortName);
        $type = null;

        if (isset(self::$types[$cacheName])) {
            return self::$types[$cacheName];
        }

        $method = lcfirst($shortName);
        if (method_exists(self::class, $method)) {
            $type = self::{$method}();
        }

        if (!$type) {
            throw new Exception("Unknown graphql type: {$shortName}");
        }

        return $type;
    }

    public static function boolean(): ScalarType {
        return Type::boolean();
    }

    public static function float(): ScalarType {
        return Type::float();
    }

    public static function id(): ScalarType {
        return Type::id();
    }

    public static function int(): ScalarType {
        return Type::int();
    }

    public static function string(): ScalarType {
        return Type::string();
    }
}
