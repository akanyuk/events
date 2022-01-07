<?php
/**
 * @var $lang_platform_description array
 */
$lang_platform_description = array(
    'ZX Spectrum' => array(
        'default' => array(
            'default' => array(
                'Процессор Z80 3.5MHz, 48Kb RAM.',
                'Экран 256х192, 15 цветов, атрибуты 8x8, 2 цвета на атрибут.',
                '1-bit звук, генерируемый процессором.',
            ),
        ),
        'music' => array(
            'default' => array(
                '1-bit звук, генерируемый процессором.',
                'Процессор Z80 3.5MHz, 48Kb RAM.',
            ),
        ),
        'picture' => array(
            'default' => array(
                'Разрешение: 256х192, 15 цветов (7 цветов двух оттенков яркости + черный)',
                'Атрибуты 8x8, 2 цвета на атрибут. В атрибутной зоне яркость обоих цветов совпадает.',
            ),
            '53c' => array(
                'Ограничение платформы: 256х192, 15 цветов. Атрибуты 8x8, 2 цвета на атрибут.',
                'Ограничение формата: используется только атрибутная область 32х24. 53 уникальных оттенка.',
            ),
            'SpecSCII' => array(
                'Ограничение платформы: 256х192, 15 цветов. Атрибуты 8x8, 2 цвета на атрибут.',
                'Ограничение формата: используется только стандартный знакогенератор ZX Spectrum.',
            ),
        )
    ),

    'ZX Spectrum + AY' => array(
        'demo' => array(
            'default' => array(
                'Процессор Z80 3.5MHz, 48Kb RAM.',
                'Экран 256х192, 15 цветов, атрибуты 8x8, 2 цвета на атрибут.',
                'Звуковой чип AY-3-8912 / YM2149.',
            ),
        ),
        'music' => array(
            'default' => array(
                'Звуковой чип AY-3-8912 / YM2149.',
            ),
        )
    ),

    'ZX Spectrum 128' => array(
        'default' => array(
            'default' => array(
                'Процессор Z80 3.5MHz, 128Kb RAM.',
                'Экран 256х192, 15 цветов, атрибуты 8x8, 2 цвета на атрибут.',
                'Звуковой чип AY-3-8912 / YM2149.',
            ),
        ),
    ),

    'ZX Spectrum + TS' => array(
        'music' => array(
            'default' => array(
                'Два звуковых чипа AY-3-8912 / YM2149.',
            ),
        ),
    ),

    'БК 0010-01' => array(
        'default' => array(
            'default' => array(
                'Процессор: К1801ВМ1 3МГц, 32Kb RAM',
                'Экран 256х256, 4 цвета.',
            ),
        ),
        'picture' => array(
            'default' => array(
                'Экран 256х256, 4 цвета.',
            ),
        ),
    ),

    'БК 0011' => array(
        'default' => array(
            'default' => array(
                'Процессор: К1801ВМ1 4МГц, 128Kb RAM',
                'Экран 256х256, 4 цвета одновременно из 8 возможных.',
            ),
        ),
    ),

    'MSX' => array(
        'picture' => array(
            'default' => array(
                'Разрешение: 256x192, 15 цветов.',
                'Атрибуты 8x1, 2 цвета на атрибут.',
            ),
            'sc2' => array(
                'Разрешение: 256x192, 15 цветов.',
                'Атрибуты 8x1, 2 цвета на атрибут.',
            ),
            'sc3' => array(
                'Разрешение: 64x48, 15 цветов.',
                'Цвет на точку.',
            ),
        ),
    ),

    'Commodore VIC-20' => array(
        'picture' => array(
            'default' => array(
                'Разрешение: 176х184, 16 цветов.',
                'Атрибуты 8x8. Один цвет на атрибут, один цвет на фон всего экрана.',
            ),
            'PETSCII' => array(
                'Ограничение платформы: разрешение: 176х184, 16 цветов. Атрибуты 8x8, один цвет на атрибут.',
                'Ограничение формата: текстовый режим 22х23 символа, 9 цветов на экране.'
            ),
        )
    ),

    'Famicom' => array(
        'picture' => array(
            'default' => array(
                'Разрешение: 256х240. Палитра: 54 цвета. Не более 25 цветов одновременно на экране.',
                '256 уникальных тайлов 8x8, 64 аппаратных спрайта 8х8 или 8х16',
                '<a href="http://chipwiki.ru/wiki/Famicom/Pixel_Art">Подробнее об ограничениях платформы</a>.',
            ),
        )
    ),

    'Game Boy Color' => array(
        'picture' => array(
            'default' => array(
                'Разрешение: 160х144. Палитра: RGB 15-bit. Не более 56 цветов одновременно на экране.',
                '<a href="http://chipwiki.ru/wiki/Game_Boy_Color/Pixel_Art">Подробнее об ограничениях платформы</a>.',
            ),
        )
    ),

    'Sharp MZ-700' => array(
        'picture' => array(
            'default' => array(
                'Текстовый режим 40х25 символов размером 8x8.',
                'Палитра 8 цветов, 2 цвета на символ.',
                'Фиксированный набор символов.',
                '<a href="http://chipwiki.ru/wiki/MZ-700/Pixel_Art">Подробнее об ограничениях платформы</a>.',
            ),
        )
    ),

    'Mattel Intellivision' => array(
        'picture' => array(
            'default' => array(
                'Разрешение: 160х96, 16 цветов.',
                'Атрибуты 8x8, 2 цвета на атрибут.',
                '<a href="http://chipwiki.ru/wiki/Intellivision/Pixel_Art">Подробнее об ограничениях платформы</a>.',
            ),
        )
    ),

    'Sega Master System' => array(
        'picture' => array(
            'default' => array(
                'Разрешение: 256х192, 256х224 или 256х240.',
                'Цвет на точку. Палитра 64 цвета. Не более 31 цвета одновременно на экране.',
                '<a href="http://chipwiki.ru/wiki/Master_System/Pixel_Art">Подробнее об ограничениях платформы</a>.',
            ),
        )
    ),

    'Atari ST' => array(
        'picture' => array(
            'default' => array(
                'Low resolution: 320 × 200 (16 цветов), палитра 512 цветов',
                'Medium resolution: 640 × 200 (4 цвета), палитра 512 цветов',
                'High resolution: 640 × 400 (монохром)',
            ),
        )
    ),

    'Super Cassette Vision' => array(
        'picture' => array(
            'default' => array(
                'Video processor: EPOCH TV-1',
                'VRAM: 4 KB (2 × µPD4016C-2) + 2 KB (EPOCH TV-1 internal)',
                'Colors: 16',
                'Sprites: 128',
                'Display: 309×246',
            ),
        )
    ),

    'Amstrad CPC 464' => array(
        'default' => array(
            'default' => array(
                'Процессор Z80 4MHz, 64Kb or 128Kb RAM',
                'Экран 160×200px, 320×200px или 640×200px',
                'До 16 цветов на точку, палитра 27 цветов',
                'Звуковой чип AY-3-8912',
            ),
        ),
        'picture' => array(
            'default' => array(
                'Разрешение 160×200px, 16 цветов ("Mode 0")',
                'Разрешение 320×200px, 4 цвета ("Mode 1")',
                'Разрешение 640×200px, 2 цвета ("Mode 2")',
                'Палитра 27 цветов',
            ),
        )
    ),
);