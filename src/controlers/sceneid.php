<?php

require(SRC_ROOT . "/helpers/sceneid3.inc.php");

$sceneID = new SceneID3(array(
    "clientID" => NFW::i()->cfg["SceneID3"]["clientID"],
    "clientSecret" => NFW::i()->cfg["SceneID3"]["clientSecret"],
    "redirectURI" => NFW::i()->cfg["SceneID3"]["redirectURI"],
));
$sceneID->SetScope(["user:email"]);

// Begin Scene ID authorization

if (isset($_GET['action']) && $_GET['action'] == "performAuth") {
    try {
        $sceneID->GetClientCredentialsToken();
    } catch (SceneID3AuthException $e) {
        NFW::i()->stop("SceneID3->GetClientCredentialsToken failed error: " . $e->getMessage(), "error-page");
    }

    $sceneID->Reset();
    $sceneID->PerformAuthRedirect();
}

// Scene ID authorization response processing

try {
    $sceneID->ProcessAuthResponse();
    $me = $sceneID->Me();
} catch (Exception $e) {
    NFW::i()->stop("Process auth response error: " . $e->getMessage(), "error-page");
}

if (!isset($me["success"]) || !$me["success"]) {
    header("Location: /");
    exit;
}

$sceneIdEmail = $me["user"]["email"] ?? "";

if ($sceneIdEmail == "") {
    NFW::i()->stop("Empty e-mail responded from sceneID", "error-page");
}

$query = [
    'SELECT' => '*',
    'FROM' => 'users',
    'WHERE' => 'email=\'' . NFW::i()->db->escape($sceneIdEmail) . '\''
];
if (!$result = NFW::i()->db->query_build($query)) {
    NFW::i()->stop("Search user error: " . NFW::i()->db->error()['error_msg'], "error-page");
}

if (NFW::i()->db->num_rows($result)) {
    $user = NFW::i()->db->fetch_assoc($result);
    if ($user["is_group"]) {
        NFW::i()->stop("Incorrect e-mail responded from SceneID: " . $user["email"], "error-page");
    }

    NFW::i()->user = $user;
    $CUsers = new users();
    $CUsers->cookie_update(NFW::i()->user);
    logs::write(LOGS_KIND_LOGIN_SCENEID);
    header("Location: /");
    exit;
}

// Begin new user registration

$username = $me["user"]["display_name"] ?? "";
if (userExists($username)) {
    $username .= " [" . users::random_key(4, true)."]";
}

NFW::i()->user["group_id"] = NFW::i()->cfg['users_group_id'];
NFW::i()->user["username"] = $username;
NFW::i()->user["password"] = users::random_key(32, true);
NFW::i()->user["salt"] = users::random_key(12, true);
NFW::i()->user["email"] = $sceneIdEmail;
NFW::i()->user["realname"] = implode(" ", [$me["user"]["first_name"] ?? null, $me["user"]["last_name"] ?? null]);
NFW::i()->user["language"] = "English";
NFW::i()->user["registered"] = time();
NFW::i()->user["registration_ip"] = logs::get_remote_address();

$query = [
    'INSERT' => 'group_id, username, password, salt, email, realname, language, registered, registration_ip',
    'INTO' => 'users',
    'VALUES' => implode(",", [
        NFW::i()->user["group_id"],
        '\'' . NFW::i()->db->escape(NFW::i()->user["username"]) . '\'',
        '\'' . NFW::i()->db->escape(NFW::i()->user["password"]) . '\'',
        '\'' . NFW::i()->db->escape(NFW::i()->user["salt"]) . '\'',
        '\'' . NFW::i()->db->escape(NFW::i()->user["email"]) . '\'',
        '\'' . NFW::i()->db->escape(NFW::i()->user["realname"]) . '\'',
        '\'' . NFW::i()->db->escape(NFW::i()->user["language"]) . '\'',
        NFW::i()->user["registered"],
        '\'' . NFW::i()->db->escape(NFW::i()->user["registration_ip"]) . '\'',
    ])
];
if (!NFW::i()->db->query_build($query)) {
    NFW::i()->stop("Create user from SceneID response error: " . NFW::i()->db->error()['error_msg'], "error-page");
}

NFW::i()->user['id'] = NFW::i()->db->insert_id();
$CUsers = new users();
$CUsers->cookie_update(NFW::i()->user);
logs::write(LOGS_KIND_REGISTER_SCENEID);
header("Location: /");
exit;

function userExists(string $username) {
    $query = [
        'SELECT' => '*',
        'FROM' => 'users',
        'WHERE' => 'username=\'' . NFW::i()->db->escape($username) . '\''
    ];
    if (!$result = NFW::i()->db->query_build($query)) {
        NFW::i()->stop("Search username error: " . NFW::i()->db->error()['error_msg'], "error-page");
    }

    return NFW::i()->db->num_rows($result);
}
