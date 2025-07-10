MACRO safefarcall
    push hl
    push bc
	ld b, BANK(\1)
	ld hl, \1
	rst _Bankswitch
    pop bc
    pop hl
ENDM

MACRO map_vram_swap
	db \1

	IF !STRCMP("\2", "NOEVENT")
		db -1
		db -1
	ELSE
		db (\2) % 8
		db ((\2) / 8)
	ENDC

	IF _NARG > 7
		db \3
		db \4

		IF !STRCMP("\5", "NONE") | !STRCMP("\5", "NOXY") | !STRCMP("\5", "AFTER_X") | !STRCMP("\5", "AFTER_Y")
			db %00
		ELIF !STRCMP("\5", "BEFORE_X") | !STRCMP("\5", "BEFORE_X_AFTER_Y")
			db %01
		ELIF  !STRCMP("\5", "BEFORE_Y") | !STRCMP("\5", "AFTER_X_BEFORE_Y")
			db %10
		ELIF !STRCMP("\5", "BEFORE_X_BEFORE_Y")
			db %11
		ELSE
			fail "Invalid Argument. NOXY or AFTER/BEFORE_X/Y or AFTER/BEFORE_X_AFTER/BEFORE_Y"
		ENDC

		IF !STRCMP("\6", "sprite") | !STRCMP("\6", "stillsprite")
			dw vNPCSprites tile \<10>
		ELIF !STRCMP("\6", "tileset")
			dw vTileset tile \<10>
		ELSE
			fail "Invalid GFX type. Must be sprite, stillsprite or tileset."
		ENDC

		db \9
		db BANK(\7)
		dw \7 tile \8

	ELSE
		IF !STRCMP("\3", "sprite") | !STRCMP("\3", "stillsprite")
			dw vNPCSprites tile \7
		ELIF !STRCMP("\3", "tileset")
			dw vTileset tile \7
		ELSE
			fail "Invalid GFX type. Must be sprite, stillsprite or tileset."
		ENDC

		db \6
		db BANK(\4)
		dw \4 tile \5
	ENDC	
ENDM

MACRO map_sprite_swap
	db \1
	db \2

	IF !STRCMP("\3", "NOEVENT")
		db -1
		db -1
		db -1
	ELSE
		db (\3) % 8
		db ((\3) / 8)
		db \4
	ENDC

	db \5
	db \6

	IF !STRCMP("\7", "NONE") | !STRCMP("\7", "NOXY") | !STRCMP("\7", "AFTER_X") | !STRCMP("\7", "AFTER_Y")
		db %00
	ELIF !STRCMP("\7", "BEFORE_X") | !STRCMP("\7", "BEFORE_X_AFTER_Y")
		db %01
	ELIF  !STRCMP("\7", "BEFORE_Y") | !STRCMP("\7", "AFTER_X_BEFORE_Y")
		db %10
	ELIF !STRCMP("\7", "BEFORE_X_BEFORE_Y")
		db %11
	ELSE
		fail "Invalid Argument. NOXY or AFTER/BEFORE_X/Y or AFTER/BEFORE_X_AFTER/BEFORE_Y"
	ENDC

	db \8
ENDM
