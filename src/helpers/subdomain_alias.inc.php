<?php
/**
 * Helpers for subdomain aliases of the main domain.
 *
 * A request to `<label>.<main_domain>` is an alias for the festival
 * (events with `alias_group` = <label>): redirect to the freshest event
 * of the group on the main domain.
 */

/**
 * Returns the alias label if $host is a subdomain of $main_domain, null otherwise.
 */
function subdomain_alias_label(string $host, string $main_domain): ?string {
    $host = strtolower(trim($host));
    $main_domain = strtolower(trim($main_domain));

    $host = preg_replace('/:\d+$/', '', $host);
    $main_domain = preg_replace('/:\d+$/', '', $main_domain);

    if ($host === '' || $main_domain === '') {
        return null;
    }

    $suffix = '.' . $main_domain;
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
