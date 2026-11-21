<?php
/**
 * Unit tests for subdomain alias helpers.
 *
 * Run: php tests/subdomain_alias_test.php
 */

require_once dirname(__DIR__) . '/src/helpers/subdomain_alias.inc.php';

$failures = 0;
$assertions = 0;

function assert_same(string $name, $expected, $actual): void {
    global $failures, $assertions;
    $assertions++;
    if ($expected === $actual) {
        echo "ok - $name\n";
    } else {
        $failures++;
        echo "not ok - $name\n";
        echo "    expected: " . var_export($expected, true) . "\n";
        echo "    actual:   " . var_export($actual, true) . "\n";
    }
}

// subdomain_alias_label(): host belongs to the main domain zone
assert_same('extracts alias label from subdomain host', 'dihalt', subdomain_alias_label('dihalt.events.local', 'events.local'));
assert_same('extracts single-character label', 'd', subdomain_alias_label('d.events.local', 'events.local'));
assert_same('label comparison is case-insensitive', 'dihalt', subdomain_alias_label('Dihalt.Events.Local', 'events.local'));
assert_same('port in request host is ignored', 'dihalt', subdomain_alias_label('dihalt.events.local:8080', 'events.local'));
assert_same('port in configured domain is ignored', 'dihalt', subdomain_alias_label('dihalt.events.local', 'events.local:8080'));
assert_same('multi-level subdomain takes the first label', 'a', subdomain_alias_label('a.b.events.local', 'events.local'));

// subdomain_alias_label(): production, alias subdomains share the main domain zone (retroscene.org)
assert_same('production alias subdomain takes label', 'dihalt', subdomain_alias_label('dihalt.retroscene.org', 'events.retroscene.org'));
assert_same('production alias subdomain with port', 'dihalt', subdomain_alias_label('dihalt.retroscene.org:8080', 'events.retroscene.org'));
assert_same('production main domain itself has no label', null, subdomain_alias_label('events.retroscene.org', 'events.retroscene.org'));

// subdomain_alias_label(): not an alias subdomain
assert_same('main domain itself has no label', null, subdomain_alias_label('events.local', 'events.local'));
assert_same('host outside the domain zone has no label', null, subdomain_alias_label('example.com', 'events.local'));
assert_same('suffix lookalike is not a match', null, subdomain_alias_label('dihalt.events.local.evil.com', 'events.local'));
assert_same('bare suffix lookalike is not a match', null, subdomain_alias_label('myevents.local', 'events.local'));
assert_same('empty host has no label', null, subdomain_alias_label('', 'events.local'));
assert_same('empty domain disables the feature', null, subdomain_alias_label('dihalt.events.local', ''));

// subdomain_alias_redirect_url()
assert_same('festival page url', 'http://events.local/dh2026summer', subdomain_alias_redirect_url('http', 'events.local', 'dh2026summer'));
assert_same('festival page url keeps https', 'https://events.local/dh2026summer', subdomain_alias_redirect_url('https', 'events.local', 'dh2026summer'));
assert_same('main page url when there is no festival', 'http://events.local/', subdomain_alias_redirect_url('http', 'events.local', null));
assert_same('empty alias means main page url', 'http://events.local/', subdomain_alias_redirect_url('http', 'events.local', ''));
assert_same('configured domain keeps its port in url', 'http://events.local:8080/dh2026summer', subdomain_alias_redirect_url('http', 'events.local:8080', 'dh2026summer'));
assert_same('production festival page url', 'https://events.retroscene.org/dh2026summer', subdomain_alias_redirect_url('https', 'events.retroscene.org', 'dh2026summer'));

echo "\n$assertions assertions, $failures failures\n";
exit($failures ? 1 : 0);
