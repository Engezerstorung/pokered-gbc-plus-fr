; Note: after calling this, you may need to set W2_ForceBGPUpdate/ForceOBPUpdate to nonzero.
; d = palette to load (see constants/palette_constants.), e = palette index
LoadSGBPalette_Sprite:
    set 3, e
	; fallthrought

LoadSGBPalette:
    ld bc, SuperPalettes
	; fallthrought

LoadPalette:
    ld a, e
    ld l, d
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, bc

    ld de, W2_BgPaletteData

    add a
    add a
    add a
    add e
    ld e, a

    ldh a, [rWBK]
    ld c, a
    ld a, 2
    ldh [rWBK], a

    ld b, 8

.palLoop
    ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .palLoop

    ld a, c
    ldh [rWBK], a
    ret

LoadMapPalette:
	ld bc, MapPalettes
	jr LoadPalette

LoadMapPalette_Sprite:
	ld bc, SpritePalettes
	; fallthrought

LoadPalette_Sprite:
    set 3, e
	jr LoadPalette

LoadOutdoorMapSpritePalette_Sprite::
    set 3, e
LoadOutdoorMapSpritePalette::
	ld bc, MapSpritePalettes_Outdoor
	jr LoadPalette

IF GEN_2_GRAPHICS
LoadBattlePalette:
	ld a, [wPokedexNum]
	and a
	jr z, LoadSGBPalette
	; fallthrought

LoadPokemonPalette:
	ld bc, PokemonPalettes
	jr LoadPalette

LoadShinyBattlePalette:
	ld a, [wPokedexNum]
	and a
	jr z, LoadSGBPalette
	; fallthrought

LoadShinyPokemonPalette:
	ld bc, ShinyPokemonPalettes
	jr LoadPalette

LoadPokemonPalette_Sprite:
    set 3, e
	jr LoadPokemonPalette

LoadShinyPokemonPalette_Sprite:
    set 3, e
	jr LoadShinyPokemonPalette
ENDC

LoadAndUpdatePokemonTextPalette:
	ld e, 7
LoadAndUpdatePokemonPalette:
IF GEN_2_GRAPHICS
	call LoadPokemonPalette
ELSE
	call LoadSGBPalette
ENDC
	jr UpdatePalette

LoadPcTextPalette:
	lb de, PC_POKEBALL_PAL, 7	
	jr LoadAndUpdateMapPalette

LoadAndUpdateMapTextPalette:
	ld e, 7
LoadAndUpdateMapPalette:
	call LoadMapPalette
	jr UpdatePalette

LoadAndUpdateMapPalette_Sprite:
	call LoadMapPalette_Sprite
	jr UpdatePalette

LoadDefaultAnimationPalette:
	ld d, SPRITE_PAL2_DUST
LoadAnimationPalette:
	ld e, 7
	ld bc, MapSpritePalettes_Animations
	jp LoadPalette_Sprite

LoadAndUpdateDefaultAnimationPalette::
	ld d, SPRITE_PAL2_DUST
LoadAndUpdateAnimationPalette:
	call LoadAnimationPalette
;	jr UpdatePalette

;LoadAndUpdateDefaultAnimationPalette:
;	call LoadDefaultAnimationPalette
;	; fallthrough

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
