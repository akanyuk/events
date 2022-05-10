<?php
	NFW::i()->registerResource('bootstrap');
	NFW::i()->registerResource('jquery.activeForm');
	$lang_main = NFW::i()->getLang('main');
?>
<html lang="<?php echo NFW::i()->lang['lang']?>"><head>
<meta http-equiv=Content-Type content="text/html; charset=utf-8">
<title>53c Chunkypaint</title>
<script type="text/javascript">
// Chunky paint
var dragStartX, dragStartY;
$.fn.drag = function(startHandler, dragHandler, endHandler) {
	var source = this;
	var mousemoveHandler = function(e) {
		e.offsetX = e.clientX - dragStartX;
		e.offsetY = e.clientY - dragStartY;
		if (dragHandler != null) dragHandler.call(source, e);
	}
	var mouseupHandler = function(e) {
		if (endHandler != null) endHandler.call(source, e);
		$(window).unbind('mousemove', mousemoveHandler);
		$(window).unbind('mouseup', mouseupHandler);
	}
	this.mousedown(function(e) {
		if (startHandler != null) startHandler.call(this, e);
		dragStartX = e.clientX;
		dragStartY = e.clientY;
		$(window).mousemove(mousemoveHandler).mouseup(mouseupHandler);
		return false; /* prevent bubbling of mousedown event to things underneath */
	})
	return this;
}

function byteToHex(byte) {
	var hexDigits = '0123456789abcdef'
	return '%' + hexDigits.substr(byte >> 4,1) + hexDigits.substr(byte & 0x0f,1);
}

var SPECTRUM_PALETTE = [
	/* nonbright */
	[
		[0,0,0],[0,0,192],[192,0,0],[192,0,192],[0,192,0],[0,192,192],[192,192,0],[192,192,192]
	],
	/* bright */
	[
		[0,0,0],[0,0,255],[255,0,0],[255,0,255],[0,255,0],[0,255,255],[255,255,0],[255,255,255]
	]
];

var HALFTONE_PALETTE = [];
for (var bright = 0; bright < 2; bright++) {
	for (var paper = 0; paper < 8; paper++) {
		for (var ink = paper; ink < 8; ink++) {
			var r = (SPECTRUM_PALETTE[bright][paper][0] + SPECTRUM_PALETTE[bright][ink][0]) >> 1;
			var g = (SPECTRUM_PALETTE[bright][paper][1] + SPECTRUM_PALETTE[bright][ink][1]) >> 1;
			var b = (SPECTRUM_PALETTE[bright][paper][2] + SPECTRUM_PALETTE[bright][ink][2]) >> 1;
			var hue;
			if (r == g && g == b) {
				hue = -1;
			} else if (r >= g && r >= b) {
				min = Math.min(g,b);
				hue = (60 * (g - b) / (r - min) + 360) % 360;
			} else if (g >= r && g >= b) {
				min = Math.min(r,b);
				hue = 60 * (b - r) / (g - min) + 120;
			} else { /* b >= r && b >= g */
				min = Math.min(r,g);
				hue = 60 * (r - g) / (b - min) + 240;
			}
			HALFTONE_PALETTE.push({
				index: i,
				attributeByte: (ink | paper << 3 | bright << 6),
				rgbForm: 'rgb(' + r + ',' + g + ',' + b + ')',
				bmpPaletteHex: byteToHex(b)+byteToHex(g)+byteToHex(r)+byteToHex(0),
				hue: hue,
				brightness: r+g+b
			});
		}
	}
}
var coloursByAttributeByte = {};

HALFTONE_PALETTE.sort(function(a,b) {return (a.hue - b.hue)*1000 + (a.brightness - b.brightness)} );
for (var i = 0; i < HALFTONE_PALETTE.length; i++) {
	HALFTONE_PALETTE[i].index = i;
	coloursByAttributeByte[HALFTONE_PALETTE[i].attributeByte] = HALFTONE_PALETTE[i];
}

var brushColours = [];
var screenColours = [];
var currentButton = null;

$(function() {
	var screenTable = $('#screen');
	screenTable.get(0).oncontextmenu = function() { return false; }
	
	function addCell(tr, x, y) {
		var td = $('<td></td>')
		function setColour(colour) {
			screenColours[y][x] = colour.index;
			td.css('background-color', colour.rgbForm);
		}
		setColour(HALFTONE_PALETTE[0]);
		td.drag(function(e) {
			currentButton = e.which;
			setColour(brushColours[currentButton]);
		}, null, function() {
			currentButton = null;
		}).mouseover(function() {
			if (currentButton) setColour(brushColours[currentButton]);
		})
		row.append(td);
	}
	
	for (var y = 0; y < 24; y++) {
		screenColours[y] = [];
		var row = $('<tr></tr>');
		for (var x = 0; x < 32; x++) {
			addCell(row, x, y);
		}
		screenTable.append(row);
	}

	for (var brush = 1; brush <= 3; brush++) {
		brushColours[brush] = HALFTONE_PALETTE[0];
		$('#brush_' + brush).css('background-color', HALFTONE_PALETTE[0].rgbForm);
	}
	
	var palette = $('#palette');
	palette.get(0).oncontextmenu = function() { return false; }
	function addColour(colour) {
		var li = $('<li></li>').css('background-color', colour.rgbForm);
		li.mousedown(function(e) {
			brushColours[e.which] = colour;
			$('#brush_' + e.which).css('background-color', colour.rgbForm);
			return false;
		});
		palette.append(li);
	}
	for (var i = 0; i < HALFTONE_PALETTE.length; i++) {
		addColour(HALFTONE_PALETTE[i]);
	}
});

$(document).ready(function(){
<?php if ($reception_available): ?>	
	var f = $('form[id="send"]');
	f.activeForm({
 	 	'cleanErrors': function() {
 	 		f.find('div[id="error-response"]').empty().hide();
 	 	},
		'error': function(response) {
			f.find('div[id="error-response"]').text(response.message).show();
		},
		'success': function(response){
			$('div[id="success-dialog"]').find('div[id="message"]').html(response.message);
			$('div[id="success-dialog"]').modal('show').on('hide.bs.modal', function () {
				window.location.href = '/';
			});
		}
	});

	$('button[id="send"]').click(function() {
		f.find('input[name="tap"]').val(makeTap());
		f.submit();
		return false;
	});
<?php endif; ?>

	$('button[id="export-tap"]').click(function() {
		window.open('data:application/octet-stream,'+makeTap(),'_blank','height=300,width=400');
	});
	
	$('button[id="clear-screen"]').click(function() {
		for (var y = 0; y < 24; y++) {
			var cells = $('#screen tr').eq(y).find('td');
			for (var x = 0; x < 32; x++) {
				var colour = coloursByAttributeByte[0];
				screenColours[y][x] = colour.index;
				cells.eq(x).css('background-color', colour.rgbForm);
			}
		}
	});	
	
	$('button[id="save-draft"]').click(function() {
		var bytes = [];
		for (var y = 0; y < 24; y++) {
			for (var x = 0; x < 32; x++) {
				bytes.push(HALFTONE_PALETTE[screenColours[y][x]].attributeByte);
			}
		}

		localStorage.setItem('chunkypaint-draft', bytes);
	});

	$('button[id="load-draft"]').click(function() {
		var bytes = localStorage.getItem('chunkypaint-draft');
		if (!bytes) return;

		bytes = bytes.split(/\D+/);
		
		for (var y = 0; y < 24; y++) {
			var cells = $('#screen tr').eq(y).find('td');
			for (var x = 0; x < 32; x++) {
				var colour = coloursByAttributeByte[bytes.shift()];
				screenColours[y][x] = colour.index;
				cells.eq(x).css('background-color', colour.rgbForm);
			}
		}
	}).trigger('click'); // Autoload draft


	function makeTap() {
		var loader = '%13%00%00%00%63%68%75%6e%6b%79%20%20%20%20%7e%00%0a%00%7e%00%08%80%00%ff%00%00%1c%00%ea%21%00%40%11%01%40%36%55%01%00%01%ed%b0%36%aa%0d%ed%b0%21%00%40%06%16%ed%b0%c9%0d%00%0a%10%00%ef%22%22%af%32%32%35%32%38%0e%00%00%00%58%00%0d%00%14%39%00%e7%30%0e%00%00%00%00%00%3a%f9%c0%28%be%32%33%36%33%35%0e%00%00%53%5c%00%2b%32%35%36%0e%00%00%00%01%00%2a%be%32%33%36%33%36%0e%00%00%54%5c%00%2b%35%0e%00%00%05%00%00%29%0d%00%1e%09%00%f2%30%0e%00%00%00%00%00%0d%1f';
		var header = '%13%00%00%03%73%63%72%65%65%6e%20%20%20%20%00%03%00%58%00%80%d4';
		
		var data = '%02%03%ff';
		var checksum = 0xff;
		var hexDigits = '0123456789abcdef'
		for (var y = 0; y < 24; y++) {
			for (var x = 0; x < 32; x++) {
				var byte = HALFTONE_PALETTE[screenColours[y][x]].attributeByte;
				checksum = checksum ^ byte;
				data += ( '%' + hexDigits.substr(byte >> 4,1) + hexDigits.substr(byte & 0x0f,1) );
			}
		}
		var checksumString = '%' + hexDigits.substr(checksum >> 4,1) + hexDigits.substr(checksum & 0x0f,1);	
		return loader+header+data+checksumString;
	}
});
</script>		
<style>
	body { margin: 15px; color: white; background-color: black; font: 10pt Verdana, Arial; }
	table#screen { border: 1px solid white; border-spacing: 0; cursor: crosshair; }
	table#screen tr { height: 16px; }
	table#screen td { width: 16px; padding: 0; }
	ul#palette { margin: 0; padding: 0; clear: both; width: 310px; }
	ul#palette li { border: 1px solid white; display: block; float: left; width: 32px; height: 32px; }
	
	ul#brushes { list-style-type: none; padding: 5px 0 0 0; margin: 0; }
	ul#brushes li { float: left; margin-right: 8px; }
	ul#brushes li .desc { float: left; padding-top: 8px; }
	ul#brushes li .cell { float: left; padding: 16px; margin-left: 4px; border: 1px solid #777; }
	
	FORM#send LEGEND { color: #dddddd; }
	FORM#send .col-md-8 { padding-left: 0; }
	FORM#send  .help-block { font-size: 85%; }
	FORM#send  .has-error .help-block, .has-error .control-label { color: #ff0000; }
	
	#success-dialog { color: #333333; }
</style>		
</head>
<body>

<div id="success-dialog" class="modal fade"><div class="modal-dialog"><div class="modal-content">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
		<h4 class="modal-title"><?php echo $lang_main['works uploaded']?></h4>
	</div>
	<div id="message" class="modal-body"></div>
	<div class="modal-footer">
		<button type="button" class="btn btn-default" data-dismiss="modal">Ok</button>
	</div>
</div></div></div>

<div class="pull-left">
	<table id="screen"></table>
	<ul id="brushes">
		<li><div class="desc">left:</div><span id="brush_1" class="cell"></span></li>
		<li><div class="desc">middle:</div><span id="brush_2" class="cell"></span></li>
		<li><div class="desc">right:</div><span id="brush_3" class="cell"></span></li>
	</ul>
	
	<div class="clearfix" style="padding-bottom: 60px;"></div>
	<div class="pull-right">
		<button id="save-draft" class="btn btn-default">Save draft</button>
		<button id="load-draft" class="btn btn-default">Load draft</button>
		<button id="export-tap" class="btn btn-success">Export TAP</button>
	</div>
	<div class="pull-left">
		<button id="clear-screen" class="btn btn-danger">Clear screen</button>
	</div>
	<div class="clearfix"></div>
</div>
<div class="pull-right" style="width: 450px;">
	<ul id="palette"></ul>
	<div class="clearfix"></div>
	
	<br />	
	<br />
	<br />
	
	<?php if ($reception_available): ?>
	<form id="send" class="form-horizontal"><fieldset>
		<legend>Submit prod</legend>
		
		<div class="alert alert-warning"><?php echo htmlspecialchars($competition['event_title'].' / '.$competition['title'])?></div>
		
		<input name="tap" type="hidden" />
		<?php echo active_field(array('name' => 'Title', 'attributes' => $attributes['title'], 'desc' => $lang_main['works title'], 'labelCols' => '3', 'inputCols' => '8'))?>
		<?php echo active_field(array('name' => 'Author', 'attributes' => $attributes['author'], 'desc' => $lang_main['works author'], 'labelCols' => '3', 'inputCols' => '8'))?>
		
		<div class="form-group"><div class="col-md-offset-3">
			<button id="send" class="btn btn-primary btn-lg"><?php echo $lang_main['works send']?></button>
		</div></div>
		
		<br />
		<div class="form-group"><div class="col-md-offset-3 col-md-8">
			<div id="error-response" style="display: none;" class="alert alert-danger"></div>
		</div></div>
	</fieldset></form>	
	<?php elseif ($reception_future): ?>
		<div class="alert alert-info"><?php echo $lang_main['53c reception form'].' <strong>'.date('d.m.Y H:i', $competition['reception_from']).'</strong>'?></div>
	<?php endif; ?>
</div>
<div class="clearfix"></div>
	
</body></html>