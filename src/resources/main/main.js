$(document).ready(function(){
	// Multiple images in one prod
	$('.owl-carousel').each(function(){
		$(this).owlCarousel({ 
			items: 1, 
			center: true,
			loop: true
		});
	});

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