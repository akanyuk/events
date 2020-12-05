<?php 
/**
 * @var $lang_platform_description array
 */
$lang_platform_description = array (
	'ZX Spectrum' => array(
		'default' => array(
			'default' => array(
				'CPU Z80 3.5MHz, 48Kb RAM.',
				'Screen 256х192, 15 colors, attributes 8x8, 2 colors per attribute.',
				'1-bit sound generated by CPU.',
			),
		),
		'music' => array(
			'default' => array(
				'1-bit sound generated by CPU.',
				'CPU Z80 3.5MHz, 48Kb RAM.',
			),
		),
		'picture' => array(
			'default' => array(
				'256х192px, 15 colors.',
				'Attributes 8x8, 2 colors per attribute.',
			),
			'53c' => array(
				'Platform limitations: 256х192px, 15 colors. Attributes 8x8, 2 colors per attribute.',
				'Format limitations: used only attributes area 32x24 with 53 unique halftone .',
			),
			'SpecSCII' => array(
				'Platform limitations: 256х192px, 15 colors. Attributes 8x8, 2 colors per attribute.',
				'Format limitations: used only text characters of ZX Spectrum.',
			),
		)
	),
	
	'ZX Spectrum 128' => array(
		'demo' => array(
			'default' => array(
				'CPU Z80 3.5MHz, 128Kb RAM.',
				'Screen 256х192, 15 colors, attributes 8x8, 2 colors per attribute.',
				'Sound chip AY-3-8912 / YM2149.',
			),
		),
	),

	'ZX Spectrum + AY' => array(
		'demo' => array(
			'default' => array(
				'CPU Z80 3.5MHz, 48Kb RAM.',
				'Screen 256х192, 15 colors, attributes 8x8, 2 colors per attribute.',
				'Sound chip AY-3-8912 / YM2149.',
			),
		),
		'music' => array(
			'default' => array(
				'Sound chip AY-3-8912 / YM2149.',
			),
		),
	),
		
	'ZX Spectrum + TS' => array(
		'music' => array(
			'default' => array(
				'2x Sound chips AY-3-8912 / YM2149.',
			),
		),
	),

	'БК 0010' => array(
		'default' => array(
			'default' => array(
				'CPU: К1801ВМ1 3МГц, 32Kb RAM',
				'Screen 256х256, 4 colors.',
			),
		),
		'picture' => array(
			'default' => array(
				'Screen 256х256, 4 colors.',
			),
		),
	),
	
	'БК 0011' => array(
		'default' => array(
			'default' => array(
				'CPU: К1801ВМ1 4МГц, 128Kb RAM',
				'Screen 256х256, 4 colors on screen from 8 total.',
			),
		),
	),
		
	'MSX' => array(
		'picture' => array(
			'default' => array(
				'256x192px, 15 colors.',
				'Attributes 8x1, 2 colors per attribute.',
			),
			'sc2' => array(
				'256x192px, 15 colors.',
				'Attributes 8x1, 2 colors per attribute.',
			),
			'sc3' => array(
				'64x48px, 15 colors.',
				'One color per pixel.',
			),
		)
	),
	
	'Commodore VIC-20' => array(
		'picture' => array(
			'default' => array(
				'176х184px, 16 colors.',
				'Attributes 8x8. One color per attribute, one color per whole screen.',
			),
			'PETSCII' => array(
				'Platform limitations: 176х184px, 16 colors. Attributes 8x8, One color per attribute.',
				'Format limitations: Textmode 22х23 chars, 9 colors on screen.',
			),
		)
	),
		
	'Game Boy Color' => array(
		'picture' => array(
			'default' => array(
				'160х144px, RGB palette 15-bit. Maximum 56 colors on screen.',
			),
		)
	),

	'Famicom' => array(
		'picture' => array(
			'default' => array(
				'256х240px, 54 colors palette. Maximum 25 colors on screen.',
				'256 tiles 8x8, 64 sprites 8х8 or 8х16',
			),
		)
	),
	'Sharp MZ-700' => array(
		'picture' => array(
			'default' => array(
				'Textmode 40х25 chars with 8x8 size.',
				'8 colors palette, 2 colors per char.',
				'Fixed chars table.',
			),
		)
	),
		
	'Mattel Intellivision' => array(
		'picture' => array(
			'default' => array(
				'160х96px, 16 colors.',
				'Attributes 8x8, 2 colors per attribute.'
			),
		)
	),
    'Sega Master System' => array(
        'picture' => array(
            'default' => array(
                '256х192, 256х224 or 256х240.',
                '64 colors palette, 31 colors on-screen',
                '<a href="http://chipwiki.ru/wiki/Master_System/Pixel_Art">Подробнее об ограничениях платформы</a>.',
            ),
        )
    ),
);