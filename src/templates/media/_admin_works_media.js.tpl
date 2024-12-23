<?php
/**
 * @var string $session_id
 * @var integer $owner_id
 */

$langMedia = NFW::i()->getLang('media');
?>
$(function () {
    const form = $('form[id="<?php echo $session_id?>"]');
    const mediaContainer = form.find('#media-list');

    const renameDialog = $('#worksMediaRenameModal');
    const renameForm = $('form[id="works-rename-file"]');

    const zxScrDialog = $('#worksMediaZXSCRModal');

    form.trigger('reset');

    form.find('input[type="file"]').fileupload({
        dataType: 'json',
        dropZone: form.find('#dropzone'),
        add: function (e, data) {
            $.each(data.files, function (index, file) {
                form.find('#uploading-status').show();	// show log
                form.find('#uploading-status > p').slice(0, -5).remove();	// reduce log
                data.context = $('<p/>').html('<div class="status"><span class="fa fa-spinner"></span></div><div class="log"><?php echo $langMedia['Uploading']?>: ' + file.name + '</div>').appendTo(form.find('#uploading-status'));
            });

            data.submit();
        },
        done: function (e, data) {
            const response = data.result;

            data.context.find('.status').remove();	// remove spinner

            if (response.result === 'error') {
                data.context.append('<div class="text-danger error">' + response['last_message'] + '</div>');
                return;
            }

            data.context.prepend('<div class="text-success status"><span class="fa fa-check"></span></div>');

            mediaContainer.appendRow(response);

            form.find('*[id="session-size"]').text(number_format(response['iSessionSize'] / 1048576, 2, '.', ' '));

            loadInteractions();
        }
    });


    // DropZones for multiple forms

    $(document).bind('dragover', function (e) {
        const dropZones = $('.dropzone');
        const timeout = window.dropZoneTimeout;

        if (timeout) {
            clearTimeout(timeout);
        } else {
            dropZones.addClass('in');
        }

        const hoveredDropZone = $(e.target).closest(dropZones);

        dropZones.not(hoveredDropZone).removeClass('hover');

        hoveredDropZone.addClass('hover');

        window.dropZoneTimeout = setTimeout(function () {
            window.dropZoneTimeout = null;
            dropZones.removeClass('in hover');
        }, 100);
    });

    // Sortable `media`
    mediaContainer.sortable({
        items: 'div[id="record"]',
        axis: 'y',
        update: function () {
            const aPositions = [];
            let iCurPos = 1;
            mediaContainer.find('[id="record"]').each(function () {
                aPositions.push({'id': $(this).data('id'), 'position': iCurPos++});
            });

            $.post('<?php echo NFW::i()->base_path . 'media.php?action=sort&session_id=' . $session_id?>', {'positions': aPositions}, function (response) {
                if (response !== 'success') {
                    alert(response);
                }
                return false;
            });
        }
    });

    mediaContainer.appendRow = function (data) {
        let tpl = form.find('#record-template').html();

        tpl = tpl.replace(/%id%/g, data.id);
        tpl = tpl.replace(/%basename%/g, data.basename);
        tpl = tpl.replace(/%filesize%/g, data.filesize_str);
        tpl = tpl.replace(/%type%/g, data.type);
        tpl = tpl.replace(/%url%/g, data.url);
        tpl = tpl.replace(/%comment%/g, data.comment);
        tpl = tpl.replace(/%posted%/g, data.posted);
        tpl = tpl.replace(/%posted_username%/g, data['posted_username']);
        tpl = tpl.replace(/%posted_str%/g, formatDateTime(data.posted, true, true));

        if (data.type === 'image') {
            tpl = tpl.replace(/%iconsrc%/g, 'src="' + data.tmb_prefix + '64x64-cmp.' + data.extension + '"');
        } else {
            tpl = tpl.replace(/%iconsrc%/g, 'src="' + data.icons['64x64'] + '"');
        }

        const mediaInfo = data['mediaInfo'] === undefined ? [] : data['mediaInfo'];
        tpl = tpl.replace(/%btn-screenshot%/g, mediaInfo['screenshot'] ? 'btn-info active' : 'btn-default');
        tpl = tpl.replace(/%btn-audio%/g, mediaInfo['audio'] ? 'btn-info active' : 'btn-default');
        tpl = tpl.replace(/%btn-image%/g, mediaInfo['image'] ? 'btn-info active' : 'btn-default');
        tpl = tpl.replace(/%btn-voting%/g, mediaInfo['voting'] ? 'btn-info active' : 'btn-default');
        tpl = tpl.replace(/%btn-release%/g, mediaInfo['release'] ? 'btn-info active' : 'btn-default');

        mediaContainer.append(tpl);
    };

    // Properties buttons
    $(document).on('click', '[role="<?php echo $session_id?>-prop"]', async function () {
        $(this).hasClass('active') ? $(this).removeClass('active btn-info') : $(this).addClass('active btn-info');

        // Only one screenshot allowed
        if ($(this).attr('id') === 'screenshot') {
            $('[role="<?php echo $session_id?>-prop"][id="screenshot"]').not($(this)).removeClass('active btn-info');
        }

        $(this).blur();

        const requestBody = {
            'id': $(this).closest('[id="record"]').data('id'),
            'prop': $(this).attr('id'),
            'value': $(this).hasClass('active')
        }
        let response = await fetch('<?php echo NFW::i()->base_path . 'admin/works_media?action=update_properties&record_id=' . $owner_id?>', {
            method: "POST",
            body: JSON.stringify(requestBody),
            headers: {
                "Content-type": "application/json; charset=UTF-8"
            }
        });

        if (!response.ok) {
            const resp = await response.json();
            if (resp.errors["general"] !== undefined) {
                $.jGrowl(resp.errors["general"], {theme: 'error'});
            }
            return;
        }

        loadInteractions();
    });

    // Rename file
    renameDialog.modal({'show': false});
    $(document).on('click', '[id="works-media-rename"]', function (e) {
        e.preventDefault();

        const recordRow = $(this).closest('div[id="record"]');
        if (!recordRow.data('basename')) {
            console.log('Record basename not found!');
            return;
        }

        renameForm.trigger('cleanErrors');

        renameDialog.find('input[name="file_id"]').val(recordRow.data('id'));
        renameDialog.find('input[name="basename"]').val(recordRow.data('basename'));
        renameDialog.modal('show');
    });

    renameForm.activeForm({
        success: function (response) {
            mediaContainer.find('[id="record"][data-id="' + response['id'] + '"]').find('[id="basename"]').text(response['basename']);
            renameDialog.modal('hide');
            loadInteractions();
        }
    });

    // ZX SCR
    zxScrDialog.modal({'show': false});
    $(document).on('click', '[id="works-media-zx-spectrum-scr"]', function (e) {
        e.preventDefault();

        const recordRow = $(this).closest('div[id="record"]');
        if (!recordRow.data('id')) {
            console.log('Record id not found!');
            return;
        }

        // Set border
        zxScrDialog.find('input[name="border_color"]:checked').trigger('click');

        $.ajax('<?php echo NFW::i()->base_path . 'admin/works_media?action=preview_zx'?>',
            {
                method: "POST",
                dataType: "json",
                data: {
                    'file_id': recordRow.data('id'),
                    'record_id': <?php echo $owner_id?>
                },
                error: function (response) {
                    if (response['responseJSON']['errors']['general'] === undefined) {
                        return
                    }

                    alert(response['responseJSON']['errors']['general']);
                },
                success: function (response) {
                    var src = 'data:image/png;base64,' + response['data'];
                    zxScrDialog.find('img[id="preview"]').attr("src", src);
                    zxScrDialog.data('fileID', recordRow.data('id'));

                    $('[id="border-buttons"] .btn:first').trigger('click');

                    zxScrDialog.modal('show');
                }
            }
        );
    });

    const borderButtons = $('[id="border-buttons"] .btn')
    borderButtons.click(function () {
        borderButtons.html('');
        borderButtons.data('checked', '0');

        $(this).html('<span class="fa fa-check"></span>');
        $(this).data('checked', '1');

        const selBorder = $(this).css("background-color");
        $('img[id="preview"]').parent().css("background-color", selBorder);
    });

    zxScrDialog.find('button[id="make"]').click(function () {
        var borderColor = 0;
        $('[id="border-buttons"] .btn').each(function (i, obj) {
            if ($(obj).data('checked') === "1") {
                borderColor = parseInt($(obj).data('value'));
            }
        });

        $.ajax('<?php echo NFW::i()->base_path . 'admin/works_media?action=convert_zx'?>',
            {
                method: "POST",
                dataType: "json",
                data: {
                    'file_id': zxScrDialog.data('fileID'),
                    'record_id': <?php echo $owner_id?>,
                    'border_color': borderColor
                },
                error: function (response) {
                    if (response['responseJSON']['errors']['general'] === undefined) {
                        return
                    }

                    $.jGrowl(response['responseJSON']['errors']['general'], {theme: 'error'});
                },
                success: function (response) {
                    zxScrDialog.modal("hide");
                    response.forEach((item) => mediaContainer.appendRow(item));
                    loadInteractions();
                }
            },
        );
    });

    // Remove file
    $(document).on('click', '[id="works-media-delete"]', function (e) {
        e.preventDefault();

        const recordRow = $(this).closest('div[id="record"]');
        if (!recordRow.data('id')) {
            console.log('Record id not found!');
            return;
        }

        if (!confirm('<?php echo $langMedia['Remove confirm']?>')) {
            return;
        }

        $.post('<?php echo NFW::i()->base_path?>media.php?action=remove', {'file_id': recordRow.data('id')}, function (response) {
            if (response !== 'success') {
                $.jGrowl(response, {theme: 'error'});
                return;
            }

            recordRow.remove();
            loadInteractions();
        });
    });

    // file_id.diz
    form.find('button[id="file_id.diz"]').click(function () {
        $.post('<?php echo NFW::i()->base_path . 'admin/works_media?action=file_id_diz&record_id=' . $owner_id?>', function (response) {
            if (response.result !== 'success') {
                alert(response['last_message']);
                return;
            }

            mediaContainer.appendRow(response);
            loadInteractions();
        }, 'json');

        return false;
    });


    $('form[id="make-release"]').activeForm({
        action: '<?php echo NFW::i()->base_path . 'admin/works_media?action=make_release&record_id=' . $owner_id?>',
        error: function (response) {
            alert(response.message);
        },
        success: function (response) {
            const sUrl = decodeURIComponent(response.url);
            $('span[id="permanent-link"]').html('<a href="' + sUrl + '">' + sUrl + '</a>');
            $('button[id="media-remove-release"]').show();
            loadInteractions();
        }
    });

    $('button[id="media-remove-release"]').click(function () {
        if (!confirm('Remove release file?')) {
            return false;
        }

        $.ajax('<?php echo NFW::i()->base_path . 'admin/works_media?action=remove_release&record_id=' . $owner_id?>',
            {
                dataType: "json",
                success: function () {
                    $('span[id="permanent-link"]').html('<em>none</em>');
                    $('button[id="media-remove-release"]').hide();
                    $.jGrowl('File removed');
                    loadInteractions();
                },
                error: function (response) {
                    if (response['responseJSON']['errors']['general'] === undefined) {
                        return
                    }
                    alert(response['responseJSON']['errors']['general']);
                }
            }
        );

        return false;
    });
});