<?php
/**
 * Helpers for subdomain aliases of the main domain.
 *
 * A request to `<label>.<main_domain>` is an alias for the festival
 * (events with `alias_group` = <label>): redirect to the freshest event
 * of the group on the main domain.
 */

/**
 * Returns the alias label if $host is a subdomain of the main domain zone, null otherwise.
 *
 * Alias subdomains live in the zone of the main domain:
 * `dihalt.retroscene.org` for `events.retroscene.org` (shared zone `retroscene.org`),
 * `dihalt.events.local` for `events.local` (zone `events.local` - `local` is too broad).
 */
function subdomain_alias_label(string $host, string $main_domain): ?string {
    $host = strtolower(trim($host));
    $main_domain = strtolower(trim($main_domain));

    $host = preg_replace('/:\d+$/', '', $host);
    $main_domain = preg_replace('/:\d+$/', '', $main_domain);

    if ($host === '' || $main_domain === '' || $host === $main_domain) {
        return null;
    }

    // Zone: main domain without the first label, if at least two labels remain
    $dot = strpos($main_domain, '.');
    $zone = $dot === false ? $main_domain : substr($main_domain, $dot + 1);
    if (strpos($zone, '.') === false) {
        $zone = $main_domain;
    }

    $suffix = '.' . $zone;
    if (substr($host, -strlen($suffix)) !== $suffix) {
        return null;
    }

    $label = explode('.', substr($host, 0, -strlen($suffix)))[0];

    return $label === '' ? null : $label;
}

/**
 * Builds redirect target: main domain + festival page (or main page if no alias).
 */
function subdomain_alias_redirect_url(string $scheme, string $main_domain, ?string $alias = null): string {
    return $scheme . '://' . $main_domain . '/' . ($alias === null || $alias === '' ? '' : $alias);
}
