DEF GEN_2_GRAPHICS EQU 1
DEF ALT_PARTY_MENU_COLOR EQU 1
DEF SHADOW_TRANSPARENCY EQU 1

DEF LCD_COLORS EQU 0
	;; Color Options
	; 0 to turn OFF all color modification

DEF COLOR_MATRIX = 1
	;; Color correction
	; 0 to turn OFF, 1 to 2 for 3 options (values above 3 will default to 1)
	; 1 : Personal one based of hunterk with values rounded up to single digits
	; 2 : hunterk Color Mangler matrix from their gbc shader
	; 3 : Jojobear13 matrix from their "Built-in Color Correction for GBC games" tutorial

DEF GAMMA = 1.3
	; 0 or 1.0 to turn OFF
	; Don't omit the .0 for integer numbers

DEF WHITE_POINT = 0
	; 0 to turn OFF, value above defined profiles will default to 0
	; 1 : Personal lightish white point
	; 2 : Lighter profile proposed in BGB to emulate the GBC screen reflector hue
	; 3 : Darker profile proposed in BGB to emulate the GBC screen reflector hue


;; White point profiles
; Values  0-31 or $00-$1F
IF WHITE_POINT == 1 ; Personal lightish white point
	DEF wRed = 30
	DEF wGreen = 31
	DEF wBlue = 28

ELIF WHITE_POINT == 2 ; Lighter BGB white point
	DEF wRed = 26
	DEF wGreen = 27
	DEF wBlue = 24

ELIF WHITE_POINT == 3 ; Darker BGB white point
	DEF wRed = 16
	DEF wGreen = 17
	DEF wBlue = 15

; You can add more white point profiles following those exemples.
ELSE
	REDEF WHITE_POINT = 0
ENDC


INCLUDE "macros/asserts.asm"
INCLUDE "macros/const.asm"
INCLUDE "macros/predef.asm"
INCLUDE "macros/farcall.asm"
INCLUDE "macros/data.asm"
INCLUDE "macros/code.asm"
INCLUDE "macros/gfx.asm"
INCLUDE "macros/coords.asm"
INCLUDE "macros/vc.asm"

INCLUDE "macros/scripts/audio.asm"
INCLUDE "macros/scripts/maps.asm"
INCLUDE "macros/scripts/events.asm"
INCLUDE "macros/scripts/text.asm"

INCLUDE "macros/color.asm"

INCLUDE "macros/colorplus.asm"

INCLUDE "constants/charmap.asm"
INCLUDE "constants/hardware_constants.asm"
INCLUDE "constants/oam_constants.asm"
INCLUDE "constants/ram_constants.asm"
INCLUDE "constants/misc_constants.asm"
INCLUDE "constants/gfx_constants.asm"
INCLUDE "constants/input_constants.asm"
INCLUDE "constants/serial_constants.asm"
INCLUDE "constants/script_constants.asm"
INCLUDE "constants/type_constants.asm"
INCLUDE "constants/battle_constants.asm"
INCLUDE "constants/battle_anim_constants.asm"
INCLUDE "constants/move_constants.asm"
INCLUDE "constants/move_animation_constants.asm"
INCLUDE "constants/move_effect_constants.asm"
INCLUDE "constants/item_constants.asm"
INCLUDE "constants/pokemon_constants.asm"
INCLUDE "constants/pokedex_constants.asm"
INCLUDE "constants/pokemon_data_constants.asm"
INCLUDE "constants/trainer_constants.asm"
INCLUDE "constants/icon_constants.asm"
INCLUDE "constants/sprite_constants.asm"
INCLUDE "constants/sprite_data_constants.asm"
INCLUDE "constants/palette_constants.asm"
INCLUDE "constants/list_constants.asm"
INCLUDE "constants/map_constants.asm"
INCLUDE "constants/map_data_constants.asm"
INCLUDE "constants/map_object_constants.asm"
INCLUDE "constants/hide_show_constants.asm"
INCLUDE "constants/sprite_set_constants.asm"
INCLUDE "constants/credits_constants.asm"
INCLUDE "constants/audio_constants.asm"
INCLUDE "constants/music_constants.asm"
INCLUDE "constants/tileset_constants.asm"
INCLUDE "constants/event_constants.asm"
INCLUDE "constants/text_constants.asm"
INCLUDE "constants/menu_constants.asm"

IF DEF(_RED_VC)
INCLUDE "vc/pokered.constants.asm"
ENDC
IF DEF(_BLUE_VC)
INCLUDE "vc/pokeblue.constants.asm"
ENDC

INCLUDE "color/wram.asm"
INCLUDE "color/data/map_palette_constants.asm"
