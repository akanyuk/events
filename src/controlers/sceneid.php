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
    header("Location: /");
    exit;
}

if (!isset($me["success"]) || !$me["success"]) {
    header("Location: /");
    exit;
}

echo "<pre>"; var_export($me);
exit;
