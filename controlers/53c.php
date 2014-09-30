<?php
define('COMPETITION_ID', 8);

class works53c extends works {
	function add53c($data, $competition) {
		$this->formatAttributes($data);
		$this->record['platform'] = 'ZX-Spectrum';
		$this->record['format'] = 'attributes';
		$this->record['competition_id'] = COMPETITION_ID;

		$this->errors = $this->validate();
		if (!empty($this->errors)) return false;

		// Save
		$this->db_table = 'works';
		$this->save();
		if ($this->error) return false;

		$tap = urldecode($data['tap']);
		
		// Add tap
		if (!NFW::i()->db->query_build(array(
			'INSERT'	=> 'owner_class, owner_id, secure_storage, basename, filesize, comment, posted_by, posted_username, poster_ip, posted',
			'INTO'		=> 'media',
			'VALUES'	=> '\'works\', '.$this->record['id'].', 1, \'53c.tap\', '.strlen($tap).', \''.NFW::i()->db->escape($this->record['title']).'\', '.NFW::i()->user['id'].', \''.NFW::i()->db->escape(NFW::i()->user['username']).'\', \''.logs::get_remote_address().'\','.time()
		))) {
			$this->error('Unable to insert media record.', __FILE__, __LINE__, NFW::i()->db->error());
			return false;
		}
		$media_id = NFW::i()->db->insert_id();
		$fp = fopen(PROJECT_ROOT.'var/protected_media/'.$media_id, 'w');
		fwrite($fp, $tap);
		fclose($fp);

		NFW::i()->sendNotify('works_add', $competition['event_id'], array('work' => $this->record));
		return true;
	}

	function validate() {
		return active_record::validate($this->record, $this->attributes);
	}
}



$CCompetitions = new competitions(COMPETITION_ID);
if (!$CCompetitions->record['id']) {
	NFW::i()->stop(404);
}

$reception_available = $CCompetitions->record['reception_from'] < NFW::i()->actual_date && $CCompetitions->record['reception_to'] > NFW::i()->actual_date ? true : false;
$lang_main = NFW::i()->getLang('main');

if (empty($_POST)) {
	NFW::i()->assign('attributes', array(
		'title' => array('type' => 'str', 'desc' => $lang_main['works title'], 'required' => true, 'maxlength' => 200),
		'author' => array('type' => 'str', 'desc' => $lang_main['works author'], 'required' => true, 'maxlength' => 200)
	));
	NFW::i()->assign('reception_available', $reception_available);
	NFW::i()->assign('competition', $CCompetitions->record);
	
	NFW::i()->display('53c.tpl');
}

// Start sending

if (!$reception_available) {
	NFW::i()->renderJSON(array('result' => 'error', 'errors' => array('general' => 'Reception unavailable.')));
}

$CWorks = new works53c();
if (!$CWorks->add53c($_POST, $CCompetitions->record)) {
	NFW::i()->renderJSON(array('result' => 'error', 'errors' => $CWorks->errors));
}

NFW::i()->renderJSON(array('result' => 'success', 'message' => $lang_main['works upload success message']));