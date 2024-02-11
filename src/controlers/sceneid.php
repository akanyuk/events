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
        exit("SceneID3->GetClientCredentialsToken failed");
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
    exit;
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
    NFW::i()->stop("Search user error: ".NFW::i()->db->error()['error_msg'], "error-page");
}
if (NFW::i()->db->num_rows($result)) {
    NFW::i()->user = NFW::i()->db->fetch_assoc($result);
    $CUsers = new users();
    $CUsers->cookie_update(NFW::i()->user);
    logs::write(LOGS_KIND_LOGIN_SCENEID);
    header("Location: /");
    exit;
}

// TODO: register as new user

echo "<pre>";
var_export($me);
exit;
