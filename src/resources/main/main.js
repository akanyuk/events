$(document).ready(function(){
	$('#work-frames-nav a').click(function (e) {
		e.preventDefault();

		const container = $(this).closest('.works-media-container');
		const iframeContainer = container.find('#work-iframe');
		const nav = container.find('#work-frames-nav');
		const iframeHTML = $(this).data('iframe');

		nav.find('li').removeClass('active');
		$(this).closest('li').addClass('active');

		iframeContainer.empty().html(iframeHTML);
	})
	$('[id="work-frames-nav"]').each(function(i, obj){
		$(obj).find('a:first').trigger('click');
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