; Note: after calling this, you may need to set W2_ForceBGPUpdate/ForceOBPUpdate to nonzero.
; d = palette to load (see constants/palette_constants.), e = palette index
LoadMapPalette:
	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	push bc

	ld a, e
	ld l, d
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, MapPalettes
	add hl, de

	ld de, W2_BgPaletteData
	jr startPaletteTransfer

LoadMapPalette_Sprite::
	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	push bc

	ld a, e
	ld l, d
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, SpritePalettes
	add hl, de

	ld de, W2_BgPaletteData + $40
	jr startPaletteTransfer

LoadSGBPalette:
	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	push bc

	ld a, e
	ld l, d
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, SuperPalettes
	add hl, de

	ld de, W2_BgPaletteData
	jr startPaletteTransfer

LoadSGBPalette_Sprite:
	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	push bc

	ld a, e
	ld l, d
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	ld de, SuperPalettes
	add hl, de

	ld de, W2_BgPaletteData + $40

startPaletteTransfer:
	add a
	add a
	add a
	add e
	ld e, a
	ld b, 8

.palLoop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .palLoop

	pop af
	ldh [rWBK], a
	ret

LoadAndUpdateSGBTextPalette:
	ld e, 7
LoadAndUpdateSGBPalette:
	call LoadSGBPalette
	jr UpdatePalette

ReloadDefaultTextPalette:
	ld d, CRYS_TEXTBOX
LoadAndUpdateMapTextPalette:
	ld e, 7
LoadAndUpdateMapPalette:
	call LoadMapPalette
	jr UpdatePalette

LoadAndUpdateAnimationPalette:
	ld e, 7
LoadAndUpdateMapPalette_Sprite:
	call LoadMapPalette_Sprite

UpdatePalette:
	; Update palettes
	ldh a, [rWBK]
	ld d, a
	ld a, 2
	ldh [rWBK], a
	ld [W2_ForceBGPUpdate], a
	ld [W2_ForceOBPUpdate], a
	ld a, d
	ldh [rWBK], a
	ret

INCLUDE "data/sgb/sgb_palettes.asm"
