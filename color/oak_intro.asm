; Helper functions for oak intro

GetNidorinoPalID:
	call ClearScreen
IF GEN_2_GRAPHICS
	ld a, PAL_NIDORINO
ELSE
	ld a, PAL_PURPLEMON
ENDC
	jr GotPalID

GetRedPalID:
	call ClearScreen
IF GEN_2_GRAPHICS
	ld a, PAL_HERO
ELSE
	ld a, PAL_REDMON
ENDC
	jr GotPalID

GetRivalPalID:
	call ClearScreen
IF GEN_2_GRAPHICS
	ld a, PAL_GARY1
ELSE
	ld a, PAL_MEWMON
ENDC
	jr GotPalID

GotPalID:
	ld e, 0
	ld d, a

	ld a, 2
	ldh [rWBK], a
	CALL_INDIRECT LoadSGBPalette
	xor a
	ldh [rWBK], a
	ret

; Load red sprite palette at the end of Oack Speech, before the player map sprite appear
OakIntro_ResetPlayerSpriteData:
	lb de, SPRITE_PAL_RED, 0
	farcall LoadMapPalette_Sprite
	; Update palettes
	ld a, 2
	ldh [rSVBK], a
	ld a, 1
	ld [W2_ForceOBPUpdate], a
	ldh [rSVBK], a
	jp ResetPlayerSpriteData
