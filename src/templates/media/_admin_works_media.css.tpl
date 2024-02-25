<?php
/**
 * @var string $session_id
 */
?>
FORM#<?php echo $session_id?> .dropzone { background-color: #b6efb6; border-color: #769e84; padding-top: 36px; padding-bottom: 36px; text-align: center; font-weight: bold; }
FORM#<?php echo $session_id?> .dropzone.hover { background: #46af46; }
FORM#<?php echo $session_id?> .dropzone.fade { -webkit-transition: all 0.3s ease-out; -moz-transition: all 0.3s ease-out; -ms-transition: all 0.3s ease-out; -o-transition: all 0.3s ease-out; transition: all 0.3s ease-out; opacity: 1;	}

FORM#<?php echo $session_id?> .uploading-status { margin-top: 20px; background-color: #f4f4f4; border: 1px solid #cacaca; border-radius: 4px; padding: 10px; }
FORM#<?php echo $session_id?> .uploading-status .log { white-space: nowrap; overflow: hidden; margin-right: 20px; font-size: 14px; }
FORM#<?php echo $session_id?> .uploading-status .status { float: right; position: absolute; right: 24px; }
FORM#<?php echo $session_id?> .uploading-status .error { overflow: auto; white-space: normal; font-size: 90%; }

@media (max-width: 768px) {
    LABEL[for="<?php echo $session_id?>-upload-button"] {
        display: block; width: 100%;
    }
}

FORM#<?php echo $session_id?> #media-list { padding-bottom: 20px; }
FORM#<?php echo $session_id?> #media-list .cell-i { text-align: center; padding-left: 10px; min-width: 74px; }
FORM#<?php echo $session_id?> #media-list .cell-f { width: 100%; padding: 5px 10px; }
FORM#<?php echo $session_id?> #media-list .cell-settings { min-width: 280px; white-space: nowrap; text-align: right; padding-right: 10px; }

@media (max-width: 768px) {
    FORM#<?php echo $session_id?> #media-list .cell { display: inline-block; }
    FORM#<?php echo $session_id?> #media-list .cell-i { text-align: center; vertical-align: top; padding-top: 10px; }
    FORM#<?php echo $session_id?> #media-list .cell-f { width: inherit; max-width: 200px; overflow: hidden; }
    FORM#<?php echo $session_id?> #media-list .cell-f .info { font-size: 12px; color: #999; }
    FORM#<?php echo $session_id?> #media-list .cell-settings { text-align: left; padding-bottom: 20px; padding-left: 90px; padding-top: 0; }
}

#worksMediaZXSCRModal .btn-black { background-color: #040204; color: #cccecc; width: 40px; height: 32px; overflow: hidden; }
#worksMediaZXSCRModal .btn-blue { background-color: #0402cc; color: #cccecc; width: 40px; height: 32px; overflow: hidden; }
#worksMediaZXSCRModal .btn-red { background-color: #cc0204; color: #cccecc; width: 40px; height: 32px; overflow: hidden; }
#worksMediaZXSCRModal .btn-magenta { background-color: #cc02cc; color: #cccecc; width: 40px; height: 32px; overflow: hidden; }
#worksMediaZXSCRModal .btn-green { background-color: #04ce04; color: #040204; width: 40px; height: 32px; overflow: hidden; }
#worksMediaZXSCRModal .btn-cyan { background-color: #04cecc; color: #040204; width: 40px; height: 32px; overflow: hidden; }
#worksMediaZXSCRModal .btn-yellow { background-color: #ccce04; color: #040204; width: 40px; height: 32px; overflow: hidden; }
#worksMediaZXSCRModal .btn-white { background-color: #cccecc; color: #040204; width: 40px; height: 32px; overflow: hidden; }