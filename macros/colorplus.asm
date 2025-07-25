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
		db -1
	ELSE
		db (\2) % 8
		db ((\2) / 8)
		db \3
	ENDC

		db \4
		db \5

		IF !STRCMP("\6", "NONE") | !STRCMP("\6", "NOXY") | !STRCMP("\6", "AFTER_X") | !STRCMP("\6", "AFTER_Y")
			db %00
		ELIF !STRCMP("\6", "BEFORE_X") | !STRCMP("\6", "BEFORE_X_AFTER_Y")
			db %01
		ELIF  !STRCMP("\6", "BEFORE_Y") | !STRCMP("\6", "AFTER_X_BEFORE_Y")
			db %10
		ELIF !STRCMP("\6", "BEFORE_X_BEFORE_Y")
			db %11
		ELSE
			fail "Invalid Argument. NOXY or AFTER/BEFORE_X/Y or AFTER/BEFORE_X_AFTER/BEFORE_Y"
		ENDC

		dw \<10>
		db \9
		db BANK(\7)
		dw \7 tile \8
		db \<11>	
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
