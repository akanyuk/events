<?php
const NFW_CLASSNAME = 'NFWX';

class NFWX extends NFW {
    private static NFWX $_ext_instance;

    // Come from `settings` DB table
    var $project_settings = array();
    var array $notify_emails = array();
    var array $main_menu = array();

    var $actual_date = false;

    var array $main_og = array();             # мета теги для Open Graph
    var bool $main_login_form = true;        # форма авторизации, по умолчанию включена
    var bool $main_search_box = true;        # строка поиска, по умолчанию включена
    var bool $main_right_pane = true;        # правая панель, по умолчанию включена

    function __construct($init_cfg = null) {
        // Глобально кодировка для mb-операций
        mb_internal_encoding('UTF-8');

        // Define kinds for use in logs::write
        require_once(SRC_ROOT . '/configs/logs_kinds_defines.php');

        parent::__construct($init_cfg);
        self::$_ext_instance = $this;

        $this->resources_depends['main'] = array('resources' => array('jquery', 'bootstrap3.typeahead', 'font-awesome'));

        // Preload all available settings
        $CSettings = new settings();
        foreach ($CSettings->getConfigs() as $key => $config) {
            $this->$key = $config;
        }
        $this->project_settings = reset($this->project_settings);

        if ($this->user['is_blocked']) {
            NFW::i()->stop($this->lang['Errors']['Account_disabled'] . ' <a href=?action=logout>' . $this->lang['Logout'] . '</a>', 'error-page');
        }

        // Actual date (i.e. for debugging)
        $this->actual_date = time();
        if (isset($this->cfg['dbg']['userId']) && $this->user['id'] == $this->cfg['dbg']['userId'] && isset($this->cfg['dbg']['actualDate']) && $result = strtotime($this->cfg['dbg']['actualDate'])) {
            $this->actual_date = $result;
        }
    }

    /**
     * @return self instance
     */
    public static function i(): NFWX {
        return self::$_ext_instance;
    }

    function checkPermissions($module = 1, $action = '', $additional = false): bool {
        if (parent::checkPermissions($module, $action, $additional)) return true;

        // Search
        if ($module == 'works' && $action == 'search') return true;

        // Voting actions
        if ($module == 'vote' && in_array($action, array('request_votekey', 'add_vote'))) return true;

        // (re) load comments list
        if ($module == 'works_comments' && $action == 'comments_list') return true;

        // Adding works comments - all registered
        if ($module == 'works_comments' && $action == 'add_comment') {
            if (NFW::i()->user['is_guest']) return false;    // Guests never adding comments

            if (empty($_POST) || !isset($_POST['work_id'])) return true;

            $CWorks = new works($_POST['work_id']);
            if (!$CWorks->record['id']) return false;

            $CCompetitions = new competitions($CWorks->record['competition_id']);
            if (!$CCompetitions->record['id']) return false;

            // Add comments only if voting opened, or release opened
            return $CCompetitions->record['voting_status']['available'] || $CCompetitions->record['release_status']['available'];
        }

        // --- special permissions for works authors REQUIRED BEFORE event's managers! ---

        // Any operations with `works` session files for authors
        if ($module == 'works' && in_array($action, array('media_get', 'media_upload', 'media_modify')) && $additional == 0) return true;

        // Fetching works
        if ($module == 'works' && $action == 'media_get') {
            $CWorks = new works($additional);
            if (!$CWorks->record['id']) return false;

            // Always return work to author
            if ($CWorks->record['posted_by'] == NFW::i()->user['id']) return true;
        }

        // --- special permissions for event's managers ---

        // The rights are checked later by means of the module
        $bypass_module = array(
            'competitions' => array('set_pos', 'set_dates'),
            'works' => array('get_pos', 'set_pos'),
        );
        if (isset($bypass_module[$module]) && in_array($action, $bypass_module[$module])) return true;

        $managed_events = events::get_managed();

        // Access rights to the control panel for all managers
        $allow_cp = array(
            'admin' => array(''),
            'profile' => array('admin'),
            'events' => array('admin'),
            'users' => array('admin', 'ip2geo'),
            'view_logs' => array('admin', 'export'),
        );
        if (!empty($managed_events) && isset($allow_cp[$module]) && in_array($action, $allow_cp[$module])) return true;

        // Custom calls of checkPermissions
        if ($module == 'check_manage_event' && in_array($action, $managed_events)) return true;

        if ($module == 'events' && $action == 'update') {
            return isset($_GET['record_id']) && in_array($_GET['record_id'], $managed_events);
        }

        if (($module == 'events' || $module == 'events_preview' || $module == 'events_preview_large') && ($action == 'media_upload' || $action == 'media_modify')) {
            return in_array($additional, $managed_events);
        }

        if ($module == 'competitions_groups' && ($action == 'admin' || $action == 'update')) {
            return isset($_GET['event_id']) && in_array($_GET['event_id'], $managed_events);
        }

        if ($module == 'competitions' && ($action == 'admin' || $action == 'insert')) {
            return isset($_GET['event_id']) && in_array($_GET['event_id'], $managed_events);
        }

        if ($module == 'competitions' && ($action == 'update' || $action == 'delete')) {
            if (!isset($_GET['record_id'])) return false;

            $Competition = new competitions($_GET['record_id']);
            return in_array($Competition->record['event_id'], $managed_events);
        }

        if ($module == 'works' && in_array($action, array('admin', 'insert'))) {
            return isset($_GET['event_id']) && in_array($_GET['event_id'], $managed_events);
        }

        if ($module == 'works' && in_array($action, array('update', 'delete', 'preview', 'update_work', 'update_status', 'update_links', 'my_status'))) {
            if (!isset($_GET['record_id'])) {
                return false;
            }

            $CWorks = new works($_GET['record_id']);
            return in_array($CWorks->record['event_id'], $managed_events);
        }

        if ($module == 'works_media' && in_array($action, array('update_properties', 'file_id_diz', 'make_release', 'remove_release'))) {
            if (!isset($_GET['record_id'])) {
                return false;
            }

            $CWorks = new works($_GET['record_id']);
            return in_array($CWorks->record['event_id'], $managed_events);
        }

        if ($module == 'works_media' && in_array($action, array('rename_file', 'preview_zx', 'convert_zx'))) {
            $CMedia = new media($_POST['file_id']);
            if ($CMedia->record['owner_class'] != "works") {
                return false;
            }

            $CWorks = new works($CMedia->record['owner_id']);
            return in_array($CWorks->record['event_id'], $managed_events);
        }

        if ($module == 'works' && ($action == 'media_get' || $action == 'media_upload' || $action == 'media_modify') && $additional) {
            $CWorks = new works($additional);
            return in_array($CWorks->record['event_id'], $managed_events);
        }

        if ($module == 'works_comments' && $action == 'delete') {
            if (is_array($additional) && isset($additional['work_id'])) {
                $CWorks = new works($additional['work_id']);
                return in_array($CWorks->record['event_id'], $managed_events);
            } elseif (isset($_POST['record_id'])) {
                $CWorksComments = new works_comments($_POST['record_id']);
                return in_array($CWorksComments->record['event_id'], $managed_events);
            } else {
                return false;
            }
        }

        if ($module == 'vote' && in_array($action, array('admin', 'votekeys', 'votes', 'results'))) {
            return isset($_GET['event_id']) && in_array($_GET['event_id'], $managed_events);
        }

        if ($module == 'live_voting' && in_array($action, array('admin', 'read_state', 'update_state'))) {
            return isset($_GET['event_id']) && in_array($_GET['event_id'], $managed_events);
        }

        if ($module == 'live_voting' && $action == 'open_voting') {
            if (!isset($_POST['competition_id'])) {
                return false;
            }

            $Competition = new competitions($_POST['competition_id']);
            return in_array($Competition->record['event_id'], $managed_events);
        }

        if ($module == 'timeline' && in_array($action, array('admin', 'update'))) {
            return isset($_GET['event_id']) && in_array($_GET['event_id'], $managed_events);
        }

        return false;
    }

    function renderNews($options = array()) {
        $CNews = new news();
        if (!$records = $CNews->getRecords($options)) {
            return false;
        }

        // Generate paging links
        $baseURL = $options['pagination_baseurl'] ?? NFW::i()->absolute_path . '/news.html';
        $paging_links = $CNews->num_pages > 1 ? $this->paginate($CNews->num_pages, $CNews->cur_page, $baseURL, ' ') : '';

        // Render page content
        return $CNews->renderAction(array(
            'category' => $options['category'] ?? null,
            'records' => $records,
            'paging_links' => $paging_links,
        ), $options['template']);
    }

    function paginate($num_pages, $cur_page, $link_to, $separator = ", "): string {
        $pages = array();
        $link_to_all = false;

        $first_letter = (strstr($link_to, '?')) ? '&' : '?';

        if ($cur_page == -1) {
            $cur_page = 1;
            $link_to_all = true;
        }

        if ($num_pages <= 1)
            $pages = array('<li class="active"><span>1</span></li>');
        else {
            if ($cur_page > 3) {
                $pages[] = '<li><a href="' . $link_to . $first_letter . 'p=1">1</a></li>';

                if ($cur_page != 4)
                    $pages[] = '<li class="disabled"><span>...</span></li>';
            }

            // Don't ask me how the following works. It just does, OK? :-)
            for ($current = $cur_page - 2, $stop = $cur_page + 3; $current < $stop; ++$current) {
                if ($current < 1 || $current > $num_pages)
                    continue;
                else if ($current != $cur_page || $link_to_all)
                    $pages[] = '<li><a href="' . $link_to . $first_letter . 'p=' . $current . '">' . $current . '</a></li>';
                else
                    $pages[] = '<li class="active"><span>' . $current . '</span></li>';
            }

            if ($cur_page <= ($num_pages - 3)) {
                if ($cur_page != ($num_pages - 3))
                    $pages[] = '<li class="disabled"><span>...</span></li>';

                $pages[] = '<li><a href="' . $link_to . $first_letter . 'p=' . $num_pages . '">' . $num_pages . '</a></li>';
            }
        }

        return '<ul class="pagination">' . implode($separator, $pages) . '</ul>';
    }

    function safeFilename($filename) {
        $filename = str_replace(
            array(' ', 'а', 'б', 'в', 'г', 'д', 'е', 'ё', 'ж', 'з', 'и', 'й', 'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф', 'х', 'ц', 'ч', 'ш', 'щ', 'ъ', 'ы', 'ь', 'э', 'ю', 'я'),
            array('_', 'a', 'b', 'v', 'g', 'd', 'e', 'e', 'zh', 'z', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'r', 's', 't', 'u', 'f', 'h', 'c', 'ch', 'sh', 'sch', '', 'y', '', 'e', 'yu', 'ya'),
            mb_convert_case($filename, MB_CASE_LOWER, 'UTF-8'));

        return preg_replace('/[^a-zA-Z0-9.]/', '_', $filename);
    }

    function formatTimeDelta($time): string {
        NFW::i()->registerFunction('word_suffix');
        $lang_main = NFW::i()->getLang('main');

        $left = $time - $this->actual_date;
        if (intval($left / 86400)) {
            return intval($left / 86400) . ' ' . word_suffix(intval($left / 86400), $lang_main['days suffix']);
        } elseif (intval($left / 3600)) {
            return intval($left / 3600) . ' ' . word_suffix(intval($left / 3600), $lang_main['hours suffix']);
        } else {
            return intval($left / 60) . ' ' . word_suffix(intval($left / 60), $lang_main['minutes suffix']);
        }
    }

    function sendNotify($tp, $event_id, $data = array(), $attachments = array()): bool {
        foreach ($this->notify_emails as $email) {
            email::sendFromTemplate($email, $tp, array('data' => $data));
        }

        $query = array(
            'SELECT' => 'u.email',
            'FROM' => 'events_managers AS e',
            'JOINS' => array(
                array(
                    'INNER JOIN' => 'users AS u',
                    'ON' => 'e.user_id=u.id'
                ),
            ),
            'WHERE' => 'e.event_id=' . $event_id
        );
        if (!$result = NFW::i()->db->query_build($query)) return false;
        while ($u = NFW::i()->db->fetch_assoc($result)) {
            email::sendFromTemplate($u['email'], $tp, array('data' => $data), $attachments);
        }

        return true;
    }

    function jsonError(int $errorCode, $req = array()) {
        if (is_array($req)) {
            $response = [
                'errors' => $req,
            ];
        } else {
            $response = [
                'errors' => [
                    'general' => $req,
                ],
            ];
        }

        http_response_code($errorCode);
        header('Content-Type: application/json');
        NFW::i()->stop(json_encode($response));
    }

    function jsonSuccess($message = array()) {
        header('Content-Type: application/json');
        NFW::i()->stop(json_encode($message));
    }

    function hook($hook_name, $alias = "", $hook_additional = array()) {
        if (function_exists($hook_name)) {
            return $hook_name($hook_additional);
        }

        if (!file_exists(SRC_ROOT . '/hooks/' . $alias . '/' . $hook_name . '.php')) {
            return "";
        }

        include(SRC_ROOT . '/hooks/' . $alias . '/' . $hook_name . '.php');
        if (function_exists($hook_name)) {
            return $hook_name($hook_additional);
        }

        return "";
    }
}
