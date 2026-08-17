LoadMapSpritePalettes_Delay::
	call LoadMapSpritePalettes
	ld a, [wFontLoaded]
	bit 0, a
	ret nz
	ldh a, [rLCDC]
	and LCDC_ON
	jp nz, DelayFrame
	ret

LoadMapSpritePalettes::
	ld de, wSpritePaletteSet
	ld a, [de]
	ld b, a

	call GetPlayerOverworldPaletteID
	inc a
	cp b
	jr nz, .updatePaletteSet

	ld hl, wSpriteFlags
	bit 1, [hl]
	res 1, [hl]
	jp z, .dontUpdatePaletteSet

.updatePaletteSet
	ld [de], a
	inc de

	ld hl, wSprite01StateData1
	ld b, 6
.clearUnusedSlotsLoop
	ld hl, wSprite01StateData1
.clearUnusedSlotsLoopCheckNextSprite
	ld a, [hli]
	and a
	jr z, .nextSpriteSlotCheck
	inc l
	ld a, [hl]
	inc a
	jr z, .nextSpriteSlotCheck
	ld a, l
	add SPRITESTATEDATA2_PALETTEID - SPRITESTATEDATA1_IMAGEINDEX
	ld l, a
	inc h
	ld c, [hl]
	dec h

	ld a, [de]
	cp c
	jr z, .slotInUse

.nextSpriteSlotCheck
	ld a, l
	and $f0
	add NUM_SPRITESTATEDATA_STRUCTS
	ld l, a
	jr nz, .clearUnusedSlotsLoopCheckNextSprite

	xor a
	ld [de], a

.slotInUse
	inc de
	dec b
	jr nz, .clearUnusedSlotsLoop

	ld a, [wSpritePlayerStateData2GrassPriority]
	and ~OAM_PALETTE
	ld [wSpritePlayerStateData2GrassPriority], a
	
	ld hl, wSprite01StateData1
.assignPaletteSlotsLoop
	ld a, [hli]
	and a
	jr z, .nextSprite
	inc l
	ld a, [hl]
	inc a
	jr z, .nextSprite
	ld a, l
	add SPRITESTATEDATA2_PALETTEID - SPRITESTATEDATA1_IMAGEINDEX
	ld l, a
	inc h
	ld c, [hl]
	dec h

; check if the sprite palette ID is already loaded
	ld de, wSpritePaletteSet
	ld b, 7
.checkIfPaletteAlreadyLoaded
	ld a, [de]
	inc de
	cp c
	jr z, .foundExistingPaletteSlot
	dec b
	jr nz, .checkIfPaletteAlreadyLoaded

; check for an empty slot if not already loaded
	ld de, wSpritePaletteSet
	ld b, 7
.checkForDuplicatePaletteLoop
	ld a, [de]
	and a
	jr z, .paletteSlotNotTaken
	dec b
	jr z, .foundExistingPaletteSlot
	inc de
	jr .checkForDuplicatePaletteLoop
.paletteSlotNotTaken
	ld a, c	
	ld [de], a

; assign the palette slot to the sprite once it has been found
.foundExistingPaletteSlot
	inc h
	ld a, l
	sub SPRITESTATEDATA2_PALETTEID - SPRITESTATEDATA2_GRASSPRIORITY
	ld l, a

	ld a, b
;	and a ; if b reached zero because no free palette slot, default to slot 0
;	jr z, .gotPaletteSlot

	cpl
	add 1+ 7 ; turn 7 into 0, 6 into 1, etc.
.gotPaletteSlot
	xor [hl]
	and OAM_PALETTE
	xor [hl]
	ld [hl], a
	dec h

.nextSprite
	ld a, l
	and $f0
	add NUM_SPRITESTATEDATA_STRUCTS
	ld l, a
	jr nz, .assignPaletteSlotsLoop

.dontUpdatePaletteSet

	ld bc, MapSpritePalettes_Outdoor

	ld hl, wSpritePaletteSet
	lb de, FIRST_MAP_ON_SPRITE_PAL, 0
.loadPaletteData
	ld a, [hli]
	and a
	jr z, .doneLoadingPalettes
	dec a

	push bc
	push de
	push hl
	cp d
	jr c, .normalPalette
	sub d
	ld d, a
	call CopyMapPaletteOnSpritePalette
	jr .nextPalette

.normalPalette
	ld d, a
	call LoadPalette_Sprite
.nextPalette
	pop hl
	pop de
	pop bc

	inc e
	jr .loadPaletteData

.doneLoadingPalettes

	ld a, [wCurMapTileset]
	cp CAVERN
	jr nz, .noNightWhite

	ld hl, W2_SprPaletteData
	ld de, wSpritePaletteSet
	lb bc, 2, 7
.whiteLoop
	push bc
	ld a, [de]
	inc de
	and a
	jr z, .noPaletteWhite
	cp FIRST_MAP_ON_SPRITE_PAL
	jr nc, .noPaletteWhite
	ld a, b
	ldh [rWBK], a
	ld [hl], $CF
	inc l
	ld [hl], $61
	dec l
	xor a
	ldh [rWBK], a
.noPaletteWhite
	ld bc, 8
	add hl, bc
	pop bc
	dec c
	jr nz, .whiteLoop
.noNightWhite

	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	ld [W2_ForceOBPUpdate], a
	ld a, b
	ldh [rWBK], a

	ret

CopyMapPaletteOnSpritePalette::
	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	ld a, d
	add a
	add a
	add a
	ld l, a
	ld h, HIGH(W2_BgPaletteData)

	ld a, e
	add a
	add a
	add a
	add LOW(W2_SprPaletteData)
	ld e, a
	ld d, HIGH(W2_SprPaletteData)

FOR _N, 1, 1+ 8
	ld a, [hli]
	ld [de], a
	IF _N < 8
		inc e
	ENDC
ENDR

	ld a, b
	ldh [rWBK], a
	ret

GetPlayerOverworldPaletteID::
	ld a, [wWalkBikeSurfState]
	cp 2
	jr nz, .birdTest
	dec a ; if z, then need palette 1, which is 1 lower then the 2 already in 'a'
	jr .gotPlayerColor
.birdTest
	cp 3 ; if z, then need palette 3, which is already the value of 'a'
	jr z, .gotPlayerColor
	xor a ; if neither surf nor bird then need palette 0
;	ld a, SPRITE_PAL2_YELLOWMON
.gotPlayerColor
	ret

LoadPlayerOverworldPalette::
	call GetPlayerOverworldPaletteID
	ld d, a
	ld e, 0
	ld bc, MapSpritePalettes_Outdoor
	jp LoadPalette_Sprite

; Set the overworld sprites's colors when the sprites assets are loaded in vram
; Load the palette ID  in the sprite's byte $e of its wSpriteStateData1 struct
; This is called during InitMapSprites in engine/overworld/map_sprites.asm
ColorOverworldNpcSprites::
	ld hl, wSprite01StateData1
	ld bc, wSprite01StateData2PaletteID - wSprite01StateData1
	ld d, 0
.spriteLoop
	ld a, [hl] ; [x#SPRITESTATEDATA1_PICTUREID]
	and a
	jr z, .nextsprite

	dec a
	ld e, a

	push hl
	add hl, bc

	push hl
	ld hl, SpritePaletteIDAssignments
	add hl, de
	ld a, [hl] ; Get the picture ID's palette
	pop hl

	; If it's SPRITE_PAL2_RANDOM, that means no particular palette is assigned
	cp SPRITE_PAL2_RANDOM
	jr nz, .norandomColor

	; Bill is always brown
	ld a, [wCurMap]
	cp BILLS_HOUSE
	ld a, SPRITE_PAL2_BROWN
	jr z, .norandomColor

	; This is a (somewhat) random but consistent color
	ld a, [wCurMap]
	ld e, a
	ld a, l
	swap a
	add e
	and %111 ; palette will be sprite palette ID 0-5
	cp 4
	jr c, .norandomColor
	jr nz, .notPalID4
	ld a, e
	and 1
	add 4 ; 5th palette will be based on map ID
	jr .norandomColor
.notPalID4
	sub 4

.norandomColor
	inc a
	ld [hl], a
	pop hl

.nextsprite
	ld a, l
	add SPRITESTATEDATA1_LENGTH
	ld l, a
	jp nz, .spriteLoop

	ret

; Load Palettes for cut animation and pokecenter healing machine when needed
InitCutAnimOAM:
	ld hl, wCurrentMapScriptFlags
	set 0, [hl] ; prevent SetPal_Overworld before cut is done

	lb de, 2, 7
	call CopyMapPaletteOnSpritePalette
	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	ld [W2_ForceOBPUpdate], a
	ld a, b
	ldh [rWBK], a

	jpfar _InitCutAnimOAM

AnimateHealingMachine:
	ld d, SPRITE_PAL2_HEALINGMACHINE
	call LoadAndUpdateAnimationPalette
	farcall _AnimateHealingMachine
	jp LoadAndUpdateDefaultAnimationPalette

	const_def
	const SPRITE_PAL2_RED
	const SPRITE_PAL2_BLUE
	const SPRITE_PAL2_GREEN
	const SPRITE_PAL2_BROWN
	const SPRITE_PAL2_PINK
	const SPRITE_PAL2_PURPLE

	const SPRITE_PAL2_OAK
	const SPRITE_PAL2_BROCK
	const SPRITE_PAL2_MISTY
	const SPRITE_PAL2_SURGE
	const SPRITE_PAL2_ERIKA
	const SPRITE_PAL2_KOGA
	const SPRITE_PAL2_SABRINA
	const SPRITE_PAL2_BLAINE
	const SPRITE_PAL2_GIOVANNI

	const SPRITE_PAL2_REDMON
	const SPRITE_PAL2_BLUEMON
	const SPRITE_PAL2_GREENMON
	const SPRITE_PAL2_BROWNMON
	const SPRITE_PAL2_PINKMON
	const SPRITE_PAL2_PURPLEMON
	const SPRITE_PAL2_YELLOWMON
	const SPRITE_PAL2_GREYMON

	const SPRITE_PAL2_POLYWRATH

	const SPRITE_PAL2_BILLSMACHINE

	DEF OW_SPRITE_PALETTES_NUM EQU const_value
	DEF FIRST_MAP_ON_SPRITE_PAL EQU const_value

	const SPRITE_PAL2_MAP_GREY
	const SPRITE_PAL2_MAP_RED
	const SPRITE_PAL2_MAP_GREEN
	const SPRITE_PAL2_MAP_BLUE
	const SPRITE_PAL2_MAP_YELLOW
	const SPRITE_PAL2_MAP_BROWN
	const SPRITE_PAL2_MAP_ROOF

	const_next $FF
	const SPRITE_PAL2_RANDOM

; Animation palettes, used for the healign machine animation, cut animation, pushing boulder dust animation
	const_def
	const SPRITE_PAL2_DUST
	const SPRITE_PAL2_HEALINGMACHINE
	DEF OW_SPRITE_ANIMATION_PALETTES_NUM EQU const_value

MapSpritePalettes_Outdoor: ; Taken from pokemon GSC.
	table_width 8
; PAL_OW_RED
	RGB 27,31,27
	RGB 31,19,10
	RGB 31,7,1
	RGB 0,0,0
; PAL_OW_BLUE
	RGB 27,31,27
	RGB 31,19,10
	RGB 10,9,31
	RGB 0,0,0
; PAL_OW_GREEN
	RGB 27,31,27
	RGB 31,19,10
	RGB 7,23,3
	RGB 0,0,0
; PAL_OW_BROWN
	RGB 27,31,27
	RGB 31,19,10
	RGB 15,10,3
	RGB 0,0,0
; PAL_OW_PINK
	RGB 27,31,27
	RGB 31,19,10
	RGB 29,5,13
	RGB 0,0,0
; PAL_OW_PURPLE
	RGB 27,31,27
	RGB 31,19,10
	RGB 18,4,18
	RGB 0,0,0

	; SPRITE_PAL_OAK
	RGB 27,31,27
	RGB 31,19,10
	RGB 13,16,0
	RGB 0,0,0
	; SPRITE_PAL_BROCK
	RGB 27,31,27
	RGB 31,19,10
	RGB 14,07,10
	RGB 0,0,0
	; SPRITE_PAL_MISTY
	RGB 27,31,27
	RGB 31,19,10
	RGB 31,10,05
	RGB 0,0,0
	; SPRITE_PAL_SURGE
	RGB 27,31,27
	RGB 31,19,10
	RGB 09,14,10
	RGB 0,0,0
	; SPRITE_PAL_ERIKA
	RGB 27,31,27
	RGB 31,19,10
	RGB 07,15,08
	RGB 0,0,0
	; SPRITE_PAL_KOGA
	RGB 27,31,27
	RGB 31,19,10
	RGB 12,07,13
	RGB 0,0,0
	; SPRITE_PAL_SABRINA
	RGB 27,31,27
	RGB 31,19,10
	RGB 24,07,09
	RGB 0,0,0
	; SPRITE_PAL_BLAINE
	RGB 27,31,27
	RGB 31,19,10
	RGB 07,11,12
	RGB 0,0,0
	; SPRITE_PAL_GIOVANNI
	RGB 27,31,27
	RGB 31,19,10
	RGB 08,10,12
	RGB 0,0,0

	; RED_MON
	RGB 27,31,27
	RGB 31,25,13
	RGB 31,6,0
	RGB 0,0,0
	; BLUE_MON
	RGB 27,31,27
	RGB 31,25,13
	RGB 14,19,26
	RGB 0,0,0
	; GREEN_MON
	RGB 27,31,27
	RGB 31,25,13
	RGB 2,19,3
	RGB 0,0,0
	; BROWN_MON
	RGB 27,31,27
	RGB 31,25,13
	RGB 20,14,8
	RGB 0,0,0
	; PINK_MON
	RGB 27,31,27
	RGB 31,25,13
	RGB 30,13,22
	RGB 0,0,0
	; PURPLE_MON
	RGB 27,31,27
	RGB 31,25,13
	RGB 20,13,28
	RGB 0,0,0
	; YELLOW_MON
	RGB 27,31,27
	RGB 31,25,13
	RGB 31,19,0
	RGB 0,0,0
	; GREY_MON
	RGB 27,31,27
	RGB 31,25,13
	RGB 16,16,16
	RGB 0,0,0

	; SPRITE_PAL_POLYWRATH
	RGB 27,31,27
	RGB 27,31,27
	RGB 16,16,31
	RGB 0,0,0

	; SPRITE_PAL_BILLSMACHINE
	RGB 30,28,26
	RGB 19,19,19
	RGB 13,13,13
	RGB 7,7,7

	assert_table_length OW_SPRITE_PALETTES_NUM

MapSpritePalettes_Animations:
	table_width 8
	; SPRITE_PAL_DUST
	RGB 31,31,31
	RGB 31,31,31
	RGB 13,13,13
	RGB 0,0,0

	; SPRITE_PAL_HEALINGMACHINE
	RGB 27,31,27
	RGB 31,19,10
	RGB 31,7,1
	RGB 0,0,0
	assert_table_length OW_SPRITE_ANIMATION_PALETTES_NUM

SpritePaletteIDAssignments: ; Characters on the overworld
	table_width 1
	; 0x01: SPRITE_RED
	db SPRITE_PAL2_RED
	; 0x02: SPRITE_BLUE
	db SPRITE_PAL2_BLUE
	; 0x03: SPRITE_OAK
	db SPRITE_PAL2_OAK
	; 0x04: SPRITE_BUG_CATCHER
	db SPRITE_PAL2_RANDOM
	; 0x05: SPRITE_MONSTER
	db SPRITE_PAL2_RED
	; 0x06: SPRITE_LASS
	db SPRITE_PAL2_RANDOM
	; 0x07: SPRITE_BLACK_HAIR_BOY_1
	db SPRITE_PAL2_RANDOM
	; 0x08: SPRITE_LITTLE_GIRL
	db SPRITE_PAL2_RANDOM
	; 0x09: SPRITE_BIRD
	db SPRITE_PAL2_BROWN
	; 0x0a: SPRITE_FAT_BALD_GUY
	db SPRITE_PAL2_RANDOM
	; 0x0b: SPRITE_GAMBLER
	db SPRITE_PAL2_RANDOM
	; 0x0c: SPRITE_BLACK_HAIR_BOY_2
	db SPRITE_PAL2_RANDOM
	; 0x0d: SPRITE_GIRL
	db SPRITE_PAL2_RANDOM
	; 0x0e: SPRITE_HIKER
	db SPRITE_PAL2_RANDOM
	; 0x0f: SPRITE_FOULARD_WOMAN
	db SPRITE_PAL2_RANDOM
	; 0x10: SPRITE_GENTLEMAN
	db SPRITE_PAL2_BLUE
	; 0x11: SPRITE_DAISY
	db SPRITE_PAL2_BLUE
	; 0x12: SPRITE_BIKER
	db SPRITE_PAL2_RANDOM
	; 0x13: SPRITE_SAILOR
	db SPRITE_PAL2_RANDOM
	; 0x14: SPRITE_COOK
	db SPRITE_PAL2_RANDOM
	; 0x15: SPRITE_BIKE_SHOP_GUY
	db SPRITE_PAL2_RANDOM
	; 0x16: SPRITE_MR_FUJI
	db SPRITE_PAL2_GREEN
	; 0x17: SPRITE_GIOVANNI
	db SPRITE_PAL2_GIOVANNI
	; 0x18: SPRITE_ROCKET
	db SPRITE_PAL2_BROWN
	; 0x19: SPRITE_MEDIUM
	db SPRITE_PAL2_RANDOM
	; 0x1a: SPRITE_WAITER
	db SPRITE_PAL2_RANDOM
	; 0x1b: SPRITE_ERIKA
	db SPRITE_PAL2_RANDOM
	; 0x1c: SPRITE_MOM_GEISHA
	db SPRITE_PAL2_RANDOM
	; 0x1d: SPRITE_BRUNETTE_GIRL
	db SPRITE_PAL2_RANDOM
	; 0x1e: SPRITE_LANCE
	db SPRITE_PAL2_RED
	; 0x1f: SPRITE_OAK_SCIENTIST_AIDE
	db SPRITE_PAL2_BROWN
	; 0x20: SPRITE_OAK_AIDE
	db SPRITE_PAL2_BROWN
	; 0x21: SPRITE_ROCKER ($20)
	db SPRITE_PAL2_RANDOM
	; 0x22: SPRITE_SWIMMER
	db SPRITE_PAL2_RANDOM
	; 0x23: SPRITE_WHITE_PLAYER
	db SPRITE_PAL2_RANDOM
	; 0x24: SPRITE_GYM_HELPER
	db SPRITE_PAL2_RANDOM
	; 0x25: SPRITE_OLD_PERSON
	db SPRITE_PAL2_RANDOM
	; 0x26: SPRITE_MART_GUY
	db SPRITE_PAL2_RANDOM
	; 0x27: SPRITE_FISHER
	db SPRITE_PAL2_RANDOM
	; 0x28: SPRITE_OLD_MEDIUM_WOMAN
	db SPRITE_PAL2_RANDOM
	; 0x29: SPRITE_NURSE
	db SPRITE_PAL2_RED
	; 0x2a: SPRITE_CABLE_CLUB_WOMAN
	db SPRITE_PAL2_GREEN
	; 0x2b: SPRITE_MR_MASTERBALL
	db SPRITE_PAL2_PURPLE
	; 0x2c: SPRITE_LAPRAS_GIVER
	db SPRITE_PAL2_RANDOM
	; 0x2d: SPRITE_WARDEN
	db SPRITE_PAL2_RANDOM
	; 0x2e: SPRITE_SS_CAPTAIN
	db SPRITE_PAL2_RANDOM
	; 0x2f: SPRITE_FISHER2
	db SPRITE_PAL2_RANDOM
	; 0x30: SPRITE_BLACKBELT
	db SPRITE_PAL2_RANDOM
	; 0x31: SPRITE_GUARD ($30)
	db SPRITE_PAL2_BLUE
	; 0x32: $32
	db SPRITE_PAL2_RANDOM
	; 0x33: SPRITE_MOM
	db SPRITE_PAL2_RED
	; 0x34: SPRITE_BALDING_GUY
	db SPRITE_PAL2_RANDOM
	; 0x35: SPRITE_YOUNG_BOY
	db SPRITE_PAL2_RANDOM
	; 0x36: SPRITE_GAMEBOY_KID
	db SPRITE_PAL2_RANDOM
	; 0x37: SPRITE_GAMEBOY_KID_COPY
	db SPRITE_PAL2_RANDOM
	; 0x38: SPRITE_CLEFAIRY
	db SPRITE_PAL2_PINKMON
	; 0x39: SPRITE_AGATHA
	db SPRITE_PAL2_BLUE
	; 0x3a: SPRITE_BRUNO
	db SPRITE_PAL2_BROWN
	; 0x3b: SPRITE_LORELEI
	db SPRITE_PAL2_RED
	; 0x3c: SPRITE_SEEL
	db SPRITE_PAL2_BLUE

; Start of custom sprites
	; SPRITE_BLANK
	db SPRITE_PAL2_GREEN
	; SPRITE_DOME_FOSSIL
	db SPRITE_PAL2_MAP_BROWN

; Gym Leaders
	; SPRITE_BROCK
	db SPRITE_PAL2_BROCK
	; SPRITE_MISTY
	db SPRITE_PAL2_MISTY
	; SPRITE_SURGE
	db SPRITE_PAL2_SURGE
	; SPRITE_ERIKA
	db SPRITE_PAL2_ERIKA
	; SPRITE_KOGA2
	db SPRITE_PAL2_KOGA
	; SPRITE_SABRINA
	db SPRITE_PAL2_SABRINA
	; SPRITE_BLAINE
	db SPRITE_PAL2_BLAINE

; Map Pokémons	
	; SPRITE_ARTICUNO
	db SPRITE_PAL2_BLUEMON
	; SPRITE_CHANSEY
	db SPRITE_PAL2_PINKMON
	; SPRITE_CLEFAIRY
	db SPRITE_PAL2_PINKMON
	; SPRITE_CUBONE
	db SPRITE_PAL2_BROWNMON
	; SPRITE_KANGASKHAN
	db SPRITE_PAL2_BROWN
	; SPRITE_LAPRAS
	db SPRITE_PAL2_BLUEMON
	; SPRITE_MEOWTH
	db SPRITE_PAL2_YELLOWMON
	; SPRITE_MEWTWO
	db SPRITE_PAL2_PURPLEMON
	; SPRITE_MOLTRES
	db SPRITE_PAL2_RED
	; SPRITE_NIDORINO
	db SPRITE_PAL2_PINKMON
	; SPRITE_OMANYTE
	db SPRITE_PAL2_BLUEMON
	; SPRITE_PIDGEOT
	db SPRITE_PAL2_BROWN
	; SPRITE_POLYWRATH
	db SPRITE_PAL2_POLYWRATH
	; SPRITE_PSYDUCK
	db SPRITE_PAL2_YELLOWMON
	; SPRITE_SLOWBRO
	db SPRITE_PAL2_PINKMON
	; SPRITE_SLOWPOKE
	db SPRITE_PAL2_PINKMON
	; SPRITE_SPEAROW
	db SPRITE_PAL2_BROWN
	; SPRITE_VOLTORB
	db SPRITE_PAL2_RED
	; SPRITE_WIGGLYTUFF
	db SPRITE_PAL2_PINKMON

; Pokémons with odd pixel number
	; SPRITE_DODUO
	db SPRITE_PAL2_BROWN
	; SPRITE_FEAROW
	db SPRITE_PAL2_BROWN
	; SPRITE_JIGGLYPUFF
	db SPRITE_PAL2_PINKMON
	; SPRITE_KABUTO
	db SPRITE_PAL2_BROWN
	; SPRITE_MACHOKE
	db SPRITE_PAL2_GREYMON
	; SPRITE_MACHOP
	db SPRITE_PAL2_GREYMON
	; SPRITE_NIDORANF
	db SPRITE_PAL2_BLUEMON
	; SPRITE_NIDORANM
	db SPRITE_PAL2_PINKMON
	; SPRITE_PIDGEY
	db SPRITE_PAL2_BROWN
	; SPRITE_PIKACHU
	db SPRITE_PAL2_RED
	; SPRITE_SEEL2
	db SPRITE_PAL2_REDMON
	; SPRITE_ZAPDOS
	db SPRITE_PAL2_YELLOWMON

; One face but use 9 tiles
	; SPRITE_SNORLAXBIG
	db SPRITE_PAL2_BLUEMON

	; 0x3d: SPRITE_POKE_BALL
	db SPRITE_PAL2_RED
	; 0x3e: SPRITE_HELIX_FOSSIL
	db SPRITE_PAL2_MAP_BROWN
	; 0x3f: SPRITE_BOULDER
	db SPRITE_PAL2_MAP_BROWN
	; 0x40: SPRITE_PAPER_SHEET
	db SPRITE_PAL2_BROWN
	; 0x41: SPRITE_BOOK_MAP_DEX
	db SPRITE_PAL2_RED
	; 0x42: SPRITE_CLIPBOARD
	db SPRITE_PAL2_BROWN
	; 0x43: SPRITE_SNORLAX
	db SPRITE_PAL2_BLUE
	; 0x44: SPRITE_OLD_AMBER_COPY
	db SPRITE_PAL2_MAP_BROWN
	; 0x45: SPRITE_OLD_AMBER
	db SPRITE_PAL2_MAP_BROWN
	; 0x46: SPRITE_LYING_OLD_MAN_UNUSED_1
	db SPRITE_PAL2_BROWN
	; 0x47: SPRITE_LYING_OLD_MAN_UNUSED_2
	db SPRITE_PAL2_BROWN
	; 0x48: SPRITE_LYING_OLD_MAN
	db SPRITE_PAL2_BROWN

; Start of custom still sprites
	; SPRITE_BENCH_GUY
	db SPRITE_PAL2_RANDOM
	; SPRITE_BILLS_MACHINE
	db SPRITE_PAL2_BILLSMACHINE

	assert_table_length NUM_SPRITES
