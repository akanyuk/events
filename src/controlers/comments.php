<?php

$CWorksComments = new works_comments();

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
