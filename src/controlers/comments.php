<?php

$CWorksComments = new works_comments();

// Do action
if (isset($_GET['action'])) {
    switch ($_GET['action']) {
        case 'commentsList':
            $result = $CWorksComments->workComments(intval($_GET['work_id']));
            if ($result === false) {
                NFWX::i()->jsonError(400, $CWorksComments->last_msg);
            }
            NFWX::i()->jsonSuccess(['comments' => $result]);
            break;
        case 'addComment':
            if (!NFWX::i()->checkPermissions('works_comments', 'add_comment')) {
                NFWX::i()->jsonError(403, 'No permissions');
            }

            $req = json_decode(file_get_contents('php://input'));
            if (!$CWorksComments->addComment($req->workID, $req->message)) {
                NFWX::i()->jsonError(400, $CWorksComments->errors, $CWorksComments->last_msg);
            }
            NFWX::i()->jsonSuccess();
            break;
        case 'deleteComment':
            $req = json_decode(file_get_contents('php://input'));
            $CWorksComments->reload($req->commentID);
            if (!$CWorksComments->record['id']) {
                NFWX::i()->jsonError(400, $CWorksComments->last_msg);
            }

            if (!NFWX::i()->checkPermissions(
                'works_comments',
                'delete',
                ['work_id' => $CWorksComments->record['work_id']],
            )) {
                NFWX::i()->jsonError(403, 'No permissions');
            }

            if (!$CWorksComments->delete()) {
                NFWX::i()->jsonError(400, $CWorksComments->last_msg);
            }
            NFWX::i()->jsonSuccess();
            break;
        default:
            NFWX::i()->jsonError(400, "Unknown action");
    }
}

// Determine page, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));
switch (count($pathParts) == 2 ? $pathParts[1] : false) {
    case 'all':
        list ($comments, $screenshots, $numPages, $curPage) = $CWorksComments->allComments(20, isset($_GET['p']) ? intval($_GET['p']) : 1);
        $pagingLinks = $numPages > 1 ? NFWX::i()->paginate($numPages, $curPage, NFW::i()->absolute_path . '/comments/all', ' ') : '';
        $content = $CWorksComments->renderAction([
            'comments' => $comments,
            'screenshots' => $screenshots,
            'pagingLinks' => $pagingLinks,
        ], 'all');
        break;
    default:
        NFW::i()->stop(404);
        return; // Not necessary. Linter related
}

NFW::i()->assign('page', ['path' => 'comments', 'content' => $content]);
NFW::i()->display('main.tpl');
