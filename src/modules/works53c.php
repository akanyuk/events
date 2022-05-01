<?php

class works53c extends works {
	private $atr_data = false;
	
	function __construct() {
		$this->db_table = 'works';

		return parent::__construct();
	}

	function validate($foo = false, $bar = false) {
		$errors = active_record::validate($this->record, $this->attributes);
	
		if (!empty($errors)) {
			$this->error(reset($errors), __FILE__, __LINE__);
			return false;
		}
	
		return true;
	}
	
	public function loadFromString($str) {
		if (strlen($str)  != 768) {
			$this->error('Wrong file size! 768 bytes required!', __FILE__, __LINE__);
			return false;
		}
	
		$this->atr_data = $str;
	
		return true;
	}
	
	public function loadFromUploadedFile($fileIndex) {
		$lang_media = NFW::i()->getLang('media');

		if (!isset($_FILES[$fileIndex])) {
			$this->error($lang_media['Errors']['No_File'], __FILE__, __LINE__);
			return false;
		}

		$file = $_FILES[$fileIndex];

		// Make sure the upload went smooth
		if ($file['error']) switch ($file['error']) {
			case 1: // UPLOAD_ERR_INI_SIZE
			case 2: // UPLOAD_ERR_FORM_SIZE
				$this->error($lang_media['Errors']['Ambigious_file'], __FILE__, __LINE__);
				return false;
			case 3: // UPLOAD_ERR_PARTIAL
				$this->error($lang_media['Errors']['Partial_Upload'], __FILE__, __LINE__);
				return false;
			case 4: // UPLOAD_ERR_NO_FILE
				$this->error($lang_media['Errors']['No_File'], __FILE__, __LINE__);
				return false;
			default:
				// No error occurred, but was something actually uploaded?
				if ($file['size'] == 0) {
					$this->error($lang_media['Errors']['No_File'], __FILE__, __LINE__);
					return false;
				}
				break;
		}

		if (!is_uploaded_file($file['tmp_name'])) {
			$this->error($lang_media['Errors']['Unknown'], __FILE__, __LINE__);
			return false;
		}

		if ($file['size'] != 768) {
			$this->error('Wrong file size! 768 bytes required!', __FILE__, __LINE__);
			return false;
		}

		$this->atr_data = file_get_contents($file['tmp_name']);
		
		return true;
	}

	function add53c($fields) {
		if (!$this->atr_data) {
			$this->error('ATR file not loaded', __FILE__, __LINE__);
			return false;
		}
		
		$CCompetitions = new competitions(NFWX::i()->project_settings['53c_competition_id']);
		if (!$CCompetitions->record['id']) {
			$this->error('53c competition not found', __FILE__, __LINE__);
			return false;
		}

		$reception_available = $CCompetitions->record['reception_from'] < NFWX::i()->actual_date && $CCompetitions->record['reception_to'] > NFWX::i()->actual_date ? 1 : 0;
		if (!$reception_available) {
			$this->error('Reception 53c unavailable', __FILE__, __LINE__);
            return false;
		}

		$this->record['title'] = $fields['Title'];
		$this->record['author'] = $fields['Author'];
		$this->record['platform'] = 'ZX Spectrum';
		$this->record['format'] = '53c';
		$this->record['competition_id'] = NFWX::i()->project_settings['53c_competition_id'];

		if (!$this->validate()) {
		    return false;
        }

		// Save
		$this->save();
		if ($this->error) {
		    return false;
        }

		$grid = pack('h*', str_repeat(str_repeat('55', 256).str_repeat('aa', 256), 12));

		// Add files

		$insert_files = array(
			array('basename' => NFWX::i()->safeFilename($this->record['title'].'.atr'), 'data' => $this->atr_data, 'media_info' => array('voting' => 1, 'release' => 1)),
			array('basename' => NFWX::i()->safeFilename($this->record['title'].'.scr'), 'data' => $grid.$this->atr_data, 'media_info' => array('voting' => 1, 'release' => 1)),
		);

		// Try to make png
		require_once SRC_ROOT.'/helpers/ZXGFX.php';
		$ZXGFX = new ZXGFX();

		$ZXGFX->setOutputType(NFW::i()->cfg['zxgfx']['output_type']);
		$ZXGFX->setOutputScale(NFW::i()->cfg['zxgfx']['output_scale']);
		$ZXGFX->setPalette(NFW::i()->cfg['zxgfx']['palette']);
		$ZXGFX->setBorder(NFW::i()->cfg['zxgfx']['border']);
		$ZXGFX->setBorderColor(0);
		
		if ($ZXGFX->loadData($grid.$this->atr_data)) {
			$insert_files[] = array('basename' => NFWX::i()->safeFilename($this->record['title'].'.'.NFW::i()->cfg['zxgfx']['output_type']), 'data' => $ZXGFX->generate(), 'media_info' => array('image' => 1, 'screenshot' => 1, 'release' => 1));
		}

		// generate file_id.diz
        $wm = new works_media();
		$insert_files[] = array('basename' => 'file_id.diz', 'data' => $wm->generateDescription($this->record), 'media_info' => array('release' => 1));
		
		$CMedia = new media();
		$media_info = array();
		foreach ($insert_files as $file) {
			$CMedia->insertFromString($file['data'], array('owner_class' => 'works', 'owner_id' => $this->record['id'], 'secure_storage' => true, 'basename' => $file['basename']));
			$media_info[$CMedia->record['id']] = $file['media_info'];
		}

		$query = array('UPDATE' => $this->db_table, 'SET' => 'media_info=\''.NFW::i()->serializeArray($media_info).'\'', 'WHERE' => 'id='.$this->record['id']);
		if (!NFW::i()->db->query_build($query)) {
			$this->error('Unable to update media_info', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		
		NFWX::i()->sendNotify('works_add', $CCompetitions->record['event_id'], array('work' => $this->record));
		return true;
	}
}