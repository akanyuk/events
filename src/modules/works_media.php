<?php

/**
 * @desc Manage works media
 */
class works_media extends media {
    function __construct($options = false) {
        $this->db_table = 'media';

        if (!is_array($options)) {
            parent::__construct($options);
            return;
        }

        parent::__construct();
    }

    private function jsonResponseRecord(array $mediaInfo): array {
        return [
            'result' => 'success',
            'id' => $this->record['id'],
            'type' => $this->record['type'],
            'filesize_str' => $this->record['filesize_str'],
            'posted' => $this->record['posted'],
            'posted_username' => $this->record['posted_username'],
            'url' => $this->record['url'],
            'basename' => $this->record['basename'],
            'extension' => $this->record['extension'],
            'tmb_prefix' => $this->record['tmb_prefix'] ?? null,
            'icons' => $this->record['icons'],
            'mediaInfo' => $mediaInfo,
        ];
    }

    private function updateMediaProperties(int $workID, array $mediaInfo): bool {
        $query = array('UPDATE' => 'works', 'SET' => 'media_info=\'' . NFW::i()->serializeArray($mediaInfo) . '\'', 'WHERE' => 'id=' . $workID);
        if (!NFW::i()->db->query_build($query)) {
            $this->error('Unable to update media_info', __FILE__, __LINE__, NFW::i()->db->error());
            return false;
        }

        return true;
    }

    private function deleteReleaseFile($works_record): bool {
        if (!$works_record['release_basename']) {
            return true;
        }

        $filename = PUBLIC_HTML . '/files/' . $works_record['event_alias'] . '/' . $works_record['competition_alias'] . '/' . $works_record['release_basename'];

        if (!file_exists($filename)) {
            return true;
        }

        if (!unlink($filename)) {
            $this->error('Unable to delete release file.');
            return false;
        }

        return true;
    }

    function generateDescription($works_record): string {
        $description = 'Full name of prod: ' . $works_record['title'] . "\n";
        $description .= $works_record['author'] ? 'Author: ' . $works_record['author'] . "\n" : '';
        $description .= 'Event: ' . $works_record['event_title'] . ' (' . (date('d.m.Y', $works_record['event_from']) == date('d.m.Y', $works_record['event_to']) ? date('d.m.Y', $works_record['event_from']) : date('d.m.Y', $works_record['event_from']) . ' - ' . date('d.m.Y', $works_record['event_to'])) . ')' . "\n";
        $description .= 'Compo: ' . $works_record['competition_title'] . "\n";
        $description .= 'Platform: ' . $works_record['platform'] . ($works_record['format'] ? ' / ' . $works_record['format'] : '');
        $description .= "\n\n" . 'Link: ' . $works_record['main_link'];

        return $description;
    }

    function actionAdminUpdateProperties() {
        $this->error_report_type = 'plain';

        $CWorks = new works($_GET['record_id']);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $req = json_decode(file_get_contents('php://input'));
        if (!$this->load($req->id)) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $props = $CWorks->record['media_props'];
        $props[$req->id][$req->prop] = $req->value;

        if (!$this->updateMediaProperties($CWorks->record['id'], $props)) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        works_activity::adminUpdateFileProps($CWorks->record['id'], $this->record['basename'], $props[$req->id]);
        NFWX::i()->jsonSuccess();
    }

    function actionAdminRenameFile() {
        if (!$this->load($_POST['file_id'])) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if ($this->record['basename'] == $_POST['basename']) {
            NFWX::i()->jsonSuccess([
                'id' => $this->record['id'],
                'basename' => $this->record['basename'],
            ]);
        }

        $oldName = $this->record['basename'];
        $this->record['basename'] = $_POST['basename'] ?? '';
        $errors = $this->validate();
        if (!empty($errors)) {
            NFWX::i()->jsonError(400, $errors);
        }

        $this->save();
        if ($this->error) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        works_activity::adminRenameFile($this->record['owner_id'], $oldName, $this->record['basename']);

        NFWX::i()->jsonSuccess([
            'id' => $this->record['id'],
            'basename' => $this->record['basename'],
        ]);
    }

    function actionAdminPreviewZx() {
        if (!$this->load($_POST['file_id'], array('load_data' => true))) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $CWorks = new works($_POST['record_id']);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $ZXGFX = new ZXGFX();
        $ZXGFX->setPalette(NFW::i()->cfg['zxgfx']['palette']);
        $ZXGFX->setOutputType('gif');
        $ZXGFX->setBorder('none');
        $ZXGFX->setOption('showHiddenPixels', true);
        $ZXGFX->setOption('isTransparent');
        if (!$ZXGFX->loadData($this->record['data'])) {
            $this->error('Unable to load selected file for conversion.', __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        NFWX::i()->jsonSuccess(['data' => base64_encode($ZXGFX->generate())]);
    }

    function actionAdminConvertZx() {
        if (!$this->load($_POST['file_id'], array('load_data' => true))) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $CWorks = new works($_POST['record_id']);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $origBasename = $this->record['basename'];

        $data = $this->record['data'];
        $mediaProps = $CWorks->record['media_props'];

        $ZXGFX = new ZXGFX();
        $ZXGFX->setOutputScale(3);
        $ZXGFX->setOutputType('png');
        $ZXGFX->setPalette(NFW::i()->cfg['zxgfx']['palette']);
        $ZXGFX->setBorder(NFW::i()->cfg['zxgfx']['border']);
        $ZXGFX->setBorderColor($_POST['border_color']);
        if (!$ZXGFX->loadData($data)) {
            $this->error('Unable to load selected file for conversion.', __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }
        $basename1 = $this->record['filename'] . '.' . $ZXGFX->getOutputType();
        $this->insertFromString($ZXGFX->generate(), array(
            'owner_class' => 'works',
            'owner_id' => $CWorks->record['id'],
            'secure_storage' => true,
            'basename' => $basename1,
        ));

        $props1 = [
            'screenshot' => 1,
            'image' => 0,
            'audio' => 0,
            'voting' => 0,
            'release' => 0,
        ];
        $mediaProps[$this->record['id']] = $props1;

        $responseRecord = $this->jsonResponseRecord($mediaProps[$this->record['id']]);

        $ZXGFX = new ZXGFX();
        $ZXGFX->setOutputScale(NFW::i()->cfg['zxgfx']['output_scale']);
        $ZXGFX->setPalette(NFW::i()->cfg['zxgfx']['palette']);
        $ZXGFX->setOutputType('gif');
        $ZXGFX->setBorder(NFW::i()->cfg['zxgfx']['border']);
        $ZXGFX->setBorderColor($_POST['border_color']);
        if (!$ZXGFX->loadData($data)) {
            $this->error('Unable to load selected file for conversion.', __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }
        $basename2 = 'main.' . $ZXGFX->getOutputType();
        $this->insertFromString($ZXGFX->generate(), array(
            'owner_class' => 'works',
            'owner_id' => $CWorks->record['id'],
            'secure_storage' => true,
            'basename' => $basename2,
        ));

        $props2 = [
            'screenshot' => 0,
            'image' => 1,
            'audio' => 0,
            'voting' => 0,
            'release' => 0,
        ];
        $mediaProps[$this->record['id']] = $props2;

        if (!$this->updateMediaProperties($CWorks->record['id'], $mediaProps)) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        works_activity::adminConvertZX($this->record['owner_id'], $basename1, $basename2, $origBasename);
        works_activity::adminUpdateFileProps($this->record['owner_id'], $basename1, $props1);
        works_activity::adminUpdateFileProps($this->record['owner_id'], $basename2, $props2);

        NFWX::i()->jsonSuccess([$responseRecord, $this->jsonResponseRecord($mediaProps[$this->record['id']])]);
    }

    function actionAdminFileIdDiz() {
        $this->error_report_type = 'active_form';

        $CWorks = new works($_GET['record_id']);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $this->insertFromString($this->generateDescription($CWorks->record), array('owner_class' => 'works', 'owner_id' => $CWorks->record['id'], 'secure_storage' => true, 'basename' => 'file_id.diz'));

        $props = [
            'screenshot' => 0,
            'image' => 0,
            'audio' => 0,
            'voting' => 0,
            'release' => 1,
        ];
        $mediaProps = $CWorks->record['media_props'];
        $mediaProps[$this->record['id']] = $props;
        if (!$this->updateMediaProperties($CWorks->record['id'], $mediaProps)) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        works_activity::adminFileIdDiz($CWorks->record['id']);
        works_activity::adminUpdateFileProps($this->record['owner_id'], 'file_id.diz', $props);

        NFWX::i()->jsonSuccess($this->jsonResponseRecord($mediaProps[$this->record['id']]));
    }

    function actionAdminMakeRelease() {
        $CWorks = new works($_GET['record_id']);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (empty($CWorks->record['release_files'])) {
            $this->error('Nothing to add into archive!' . "\n" . 'Please check almost one "Release" button.', __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (!file_exists(PUBLIC_HTML . '/files/' . $CWorks->record['event_alias'])) {
            if (!mkdir(PUBLIC_HTML . '/files/' . $CWorks->record['event_alias'])) {
                $this->error('Unable to make event directory', __FILE__, __LINE__);
                NFWX::i()->jsonError(400, $this->last_msg);
            }
        }

        // Remove old release
        if (!$this->deleteReleaseFile($CWorks->record)) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $pack_dir = PUBLIC_HTML . '/files/' . $CWorks->record['event_alias'] . '/' . $CWorks->record['competition_alias'];
        if (!file_exists($pack_dir)) {
            if (!mkdir($pack_dir)) {
                $this->error('Unable to make competition directory', __FILE__, __LINE__);
                NFWX::i()->jsonError(400, $this->last_msg);
            }
        }

        // Try to generate custom release basename
        if (isset($_POST['release_basename']) && $_POST['release_basename'] && $result = NFWX::i()->safeFilename($_POST['release_basename'])) {
            if (file_exists($pack_dir . '/' . $result . '.zip')) {
                $this->error('File "' . $result . '.zip" already exist!', __FILE__, __LINE__);
                NFWX::i()->jsonError(400, $this->last_msg);
            }

            $release_basename = $result . '.zip';
        } else {
            // Try to generate release basename from title
            $release_basename = NFWX::i()->safeFilename($CWorks->record['title']) . '.zip';

            if (file_exists($pack_dir . '/' . $release_basename)) {
                $this->error('File "' . $release_basename . '" already exist!', __FILE__, __LINE__);
                NFWX::i()->jsonError(400, $this->last_msg);
            }
        }

        $release_link = NFW::i()->absolute_path . '/files/' . $CWorks->record['event_alias'] . '/' . $CWorks->record['competition_alias'] . '/' . $release_basename;

        $zip = new ZipArchive();
        if ($zip->open($pack_dir . '/' . $release_basename, ZIPARCHIVE::OVERWRITE | ZIPARCHIVE::CREATE) !== TRUE) {
            $this->error('Unable to create zip-archive', __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $already_added = array();

        foreach ($CWorks->record['release_files'] as $a) {
            if ($a['mime_type'] == 'application/zip') {
                // Repack zip-archive
                $eZip = zip_open($a['fullpath']);
                while ($zip_entry = zip_read($eZip)) {
                    if (zip_entry_open($eZip, $zip_entry, "r")) {
                        $already_added[] = strtolower(zip_entry_name($zip_entry));
                        $zip->addFromString(zip_entry_name($zip_entry), zip_entry_read($zip_entry, zip_entry_filesize($zip_entry)));
                        zip_entry_close($zip_entry);
                    }
                }
            } else {
                $basename = strtolower($a['basename']);
                $basename = in_array($basename, $already_added) ? $a['id'] . '_' . $basename : $basename;
                $already_added[] = $basename;
                $zip->addFile($a['fullpath'], $basename);
            }
        }

        $description = $this->generateDescription($CWorks->record);
        $description .= "\n" . 'Download: ' . $release_link;
        $zip->setArchiveComment($description);

        $zip->close();
        chmod($pack_dir . '/' . $release_basename, 0666);

        if (!NFW::i()->db->query_build(array('UPDATE' => 'works', 'SET' => 'release_basename=\'' . NFW::i()->db->escape($release_basename) . '\'', 'WHERE' => 'id=' . $CWorks->record['id']))) {
            $this->error('Unable to update release file', __FILE__, __LINE__, NFW::i()->db->error());
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        works_activity::adminMakeRelease($CWorks->record['id'], $release_basename);

        NFWX::i()->jsonSuccess(['result' => 'success', 'url' => rawurlencode($release_link)]);
    }

    function actionAdminRemoveRelease() {
        $this->error_report_type = 'plain';

        $CWorks = new works($_GET['record_id']);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        if (!$this->deleteReleaseFile($CWorks->record)) {
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        works_activity::adminRemoveRelease($CWorks->record['id']);
        NFWX::i()->jsonSuccess();
    }

    function actionAdminDownloadFiles() {
        $CWorks = new works($_GET['record_id']);
        if (!$CWorks->record['id']) {
            $this->error($CWorks->last_msg, __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $dirName = $CWorks->record['competition_title'] . '/' . str_replace('/', '^', $CWorks->record['title'] . ' by ' . $CWorks->record['author']);
        $tmpName = tempnam(sys_get_temp_dir(), "_WORK_FILES_");

        $zip = new ZipArchive;
        $result = $zip->open($tmpName, ZipArchive::OVERWRITE);
        if ($result === false) {
            $this->error("open temporary zip file failed", __FILE__, __LINE__);
            NFWX::i()->jsonError(400, $this->last_msg);
        }

        $alreadyAdded = array();
        foreach ($CWorks->record['media_info'] as $a) {
            $basename = str_replace('/', '^', strtolower($a['basename']));
            $basename = in_array($basename, $alreadyAdded) ? $a['id'] . '/' . $basename : $basename;
            $alreadyAdded[] = $basename;
            $zip->addFile($a['fullpath'], $dirName . '/' . $basename);
        }

        $zip->close();

        header("Content-Description: File Transfer");
        header("Content-Type: application/zip");
        header("Content-Disposition: attachment; filename=\"" . NFWX::i()->safeFilename($CWorks->record['title']) . ".zip\"");
        readfile($tmpName);
        NFW::i()->stop();
    }
}
