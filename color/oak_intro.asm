; Helper functions for oak intro

GetNidorinoPalID:
	call ClearScreen
IF GEN_2_GRAPHICS
	ld e, 0
	ld d, PAL_NIDORINO
	CALL_INDIRECT LoadPokemonPalette
	ret
ELSE
	ld d, PAL_PURPLEMON
	jr GotPalID
ENDC

GetRedPalID:
	call ClearScreen
IF GEN_2_GRAPHICS
	ld d, PAL_HERO
ELSE
	ld d, PAL_REDMON
ENDC
	jr GotPalID

GetRivalPalID:
	call ClearScreen
IF GEN_2_GRAPHICS
	ld d, PAL_GARY1
ELSE
	ld d, PAL_MEWMON
ENDC
	; fallthrough

GotPalID:
	ld e, 0
	CALL_INDIRECT LoadSGBPalette
	ret
