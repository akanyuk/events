$(document).ready(function(){
	if ($.blockUI) {
		$.blockUI.defaults.message = null;
		$.blockUI.defaults.fadeOut = 0;
		$.blockUI.defaults.fadeIn = 0;
		$.blockUI.defaults.timeout = 10000;
		$.blockUI.defaults.overlayCSS.backgroundColor = '#26f';
		$.blockUI.defaults.overlayCSS.opacity = 0.4;
		$.blockUI.defaults.baseZ = 2000;
		$(document).ajaxStart($.blockUI).ajaxStop($.unblockUI);
	}
});