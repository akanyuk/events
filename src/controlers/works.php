<?php
const SEARCH_LIMIT = 10;

$CWorks = new works();

// Determine page, disable subdirectories
$pathParts = explode(DIRECTORY_SEPARATOR, parse_url(trim($_SERVER['REQUEST_URI'], DIRECTORY_SEPARATOR), PHP_URL_PATH));
switch (count($pathParts) == 2 ? $pathParts[1] : false) {
    case 'search':
        $searchString = isset($_GET['q']) ? trim($_GET['q']) : '';
        $page = isset($_GET['p']) ? intval($_GET['p']) : 1;
        $pagingLinks = '';
        $works = [];
        if ($searchString) {
            list($works, $total, $filtered) = $CWorks->getRecords([
                'filter' => [
                    'search_main' => $searchString,
                ],
                'load_attachments' => true,
                'limit' => SEARCH_LIMIT,
                'offset' => ($page - 1) * SEARCH_LIMIT,
            ]);
            $numPages = ceil($filtered / SEARCH_LIMIT);
            $curPage = ($page <= 1 || $page > $numPages) ? 1 : $page;
            $pagingLinks = $numPages > 1 ? NFWX::i()->paginate($numPages, $curPage, NFW::i()->absolute_path . '/works/search?q=' . $searchString, ' ') : '';
        }
        $content = $CWorks->renderAction([
            'searchString' => $searchString,
            'pagingLinks' => $pagingLinks,
            'works' => $works,
        ], 'search');
        break;
    default:
        NFW::i()->stop(404);
        return; // Not necessary. Linter related
}

NFW::i()->assign('page', ['path' => 'works', 'content' => $content]);
NFW::i()->display('main.tpl');
