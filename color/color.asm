; Extending bank 1C, same bank as engine/palettes.asm (for "SetPal" functions)
SECTION "bank1C_extension", ROMX

; Load Palettes for cut animation and pokecenter healing machine when needed
InitCutAnimOAM:
	ld hl, wCurrentMapScriptFlags
	set 0, [hl] ; prevent SetPal_Overworld before cut is done
	ld a, [wCurMapTileset]
	ld d, SPRITE_PAL_OUTDOORTREE
	and a ; check if OVERWORLD tileset
	jr z, .paletteSelected
	CP FOREST
	jr z, .paletteSelected
	CP PLATEAU
	jr z, .paletteSelected
	ld d, SPRITE_PAL_CAVETREE
	cp CAVERN
	jr z, .paletteSelected
	ld d, SPRITE_PAL_INDOORTREE
.paletteSelected
	call LoadAndUpdateAnimationPalette
	jpfar _InitCutAnimOAM

AnimateHealingMachine:
	ld d, SPRITE_PAL_HEALINGMACHINE
	call LoadAndUpdateAnimationPalette
	farcall _AnimateHealingMachine
	jp SetPal_Overworld

LoadAndUpdateAnimationPalette:
	ld e, 7
	farcall LoadMapPalette_Sprite
	; Update palettes
	ld a, 2
	ldh [rSVBK], a
	ld a, 1
	ld [W2_ForceOBPUpdate], a
	ldh [rSVBK], a
	ret

; Change palettes to alternate palettes for special case white fades ; see home/fade.asm
; LoadMapPalette use : d = palette to load (see constants/palette_constants.), e = palette index
SetPal_FadeWhite::
	ld hl, WhiteFadePaletteSets.pointers
	ld a, [wCurMapTileset]
	ld c, a
	ld b, 0
	add hl, bc

	ld a, [hl]
	ld hl, WhiteFadePaletteSets
	ld c, a
	add hl, bc

.loop
	ld a, [hli]
	cp -1
	ret z
	ld d, a
	ld a, [hli]
	ld e, a
	push hl
	farcall LoadMapPalette
	pop hl
	jr .loop

WhiteFadePaletteSets::
.overworld   ; OVERWORLD
.forest      ; FOREST
	db OUTDOOR_FLOWER_FADE, 1
	; fallthrough
.plateau     ; PLATEAU
	db OUTDOOR_GRASS_FADE, 2
	db OUTDOOR_BLUE_FADE, 3
	db -1

.gym         ; GYM
	db INDOOR_FLOWER_FADE, 4
	; fallthrough
.forestGate  ; FOREST_GATE
.facility    ; FACILITY
.lab         ; LAB
	db INDOOR_GREEN, 2
	db INDOOR_BROWN, 5
	db -1

.ship        ; SHIP
	db INDOOR_GRAY, 6
	; fallthrough
.museum      ; MUSEUM
.gate        ; GATE
.cemetery    ; CEMETERY
	db INDOOR_GRAY, 4
	db -1

.redsHouse1  ; REDS_HOUSE_1
	db INDOOR_BROWN, 4
	db -1

.underground ; UNDERGROUND
	db INDOOR_RED, 1
	db -1

.shipPort    ; SHIP_PORT
	db INDOOR_BLUE, 2
	db INDOOR_BROWN, 5
	db INDOOR_BLUE, 6
	db -1

.cavern      ; CAVERN
	db CAVE_BROWN, 4
	db -1

.lobby       ; LOBBY
	db INDOOR_LIGHT_BLUE, 2
	db INDOOR_LIGHT_BLUE, 4
	db INDOOR_BLUE, 6
	db -1

.mansion     ; MANSION
	db INDOOR_GREEN, 2
	db INDOOR_BLUE, 3
	db INDOOR_BLUE, 6
	; fallthrough
.mart        ; MART
.redsHouse2  ; REDS_HOUSE_2
.dojo        ; DOJO
.pokecenter  ; POKECENTER
.house       ; HOUSE
.interior    ; INTERIOR
.club        ; CLUB
	db -1

.pointers	
	table_width 1
	db .overworld - WhiteFadePaletteSets  ; OVERWORLD
	db .redsHouse1 - WhiteFadePaletteSets ; REDS_HOUSE_1
	db .mart - WhiteFadePaletteSets       ; MART
	db .forest - WhiteFadePaletteSets     ; FOREST
	db .redsHouse2 - WhiteFadePaletteSets ; REDS_HOUSE_2
	db .dojo - WhiteFadePaletteSets       ; DOJO
	db .pokecenter - WhiteFadePaletteSets ; POKECENTER
	db .gym - WhiteFadePaletteSets        ; GYM
	db .house - WhiteFadePaletteSets      ; HOUSE
	db .forestGate - WhiteFadePaletteSets ; FOREST_GATE
	db .museum - WhiteFadePaletteSets     ; MUSEUM
	db .underground - WhiteFadePaletteSets; UNDERGROUND
	db .gate - WhiteFadePaletteSets       ; GATE
	db .ship - WhiteFadePaletteSets       ; SHIP
	db .shipPort - WhiteFadePaletteSets   ; SHIP_PORT
	db .cemetery - WhiteFadePaletteSets   ; CEMETERY
	db .interior - WhiteFadePaletteSets   ; INTERIOR
	db .cavern - WhiteFadePaletteSets     ; CAVERN
	db .lobby - WhiteFadePaletteSets      ; LOBBY
	db .mansion - WhiteFadePaletteSets    ; MANSION
	db .lab - WhiteFadePaletteSets        ; LAB
	db .club - WhiteFadePaletteSets       ; CLUB
	db .facility - WhiteFadePaletteSets   ; FACILITY
	db .plateau - WhiteFadePaletteSets    ; PLATEAU
	assert_table_length NUM_TILESETS	

MapFadePalList:
	; Map, new palette , palette slot to replace (0-7)
;	db VIRIDIAN_CITY, OUTDOOR_FLOWER, 5
;	db VIRIDIAN_FOREST_SOUTH_GATE, OUTDOOR_FLOWER, 5
;	db DIGLETTS_CAVE_ROUTE_2, OUTDOOR_FLOWER, 5
;	db LAVENDER_TOWN, OUTDOOR_FLOWER, 5
	db -1
	
; Set all palettes to black at beginning of battle
SetPal_BattleBlack::
	ld a, $02
	ldh [rSVBK], a

	ld d, PAL_BLACK
	ld e, 7
.palLoop ; Set all bg and sprite palettes to SGB Palette $1e
	push de
	farcall LoadSGBPalette
	pop de
	push de
	farcall LoadSGBPalette_Sprite
	pop de
	dec e
	ld a, e
	inc a
	jr nz, .palLoop

	ld a, 1
	ld [W2_ForceBGPUpdate], a
	ld [W2_ForceOBPUpdate], a

	xor a
	ldh [rSVBK], a
	ret


; This is almost identical to SetPal_Battle, but it's specifically called after the player
; and enemy scroll in, not at other times. The only difference is the timing of when it
; requests a palette update.
SetPal_BattleAfterBlack:
	call SetPal_Battle_Common

	; Wait 3 frames (if LCD is on) to allow tilemap updates to apply. Prevents garbage
	; from appearing on player/enemy silhouettes.
	ldh a, [rLCDC]
	and 1 << rLCDC_ENABLE
	jr z, .doneDelay
	ld c, 3
	call DelayFrames
.doneDelay

	; Update palettes (AFTER frame delay, so the tilemap is updated after player/enemy
	; scroll in)
	ld a, 2
	ldh [rSVBK], a
	ld a, 1
	ld [W2_ForceBGPUpdate], a
	ld [W2_ForceOBPUpdate], a
	ldh [rSVBK], a
	ret

; Set proper palettes for pokemon/trainers. Called a lot during battle, like when the
; active pokemon changes.
SetPal_Battle:
	call SetPal_Battle_Common

	; Update palettes (BEFORE frame delay, so lifebars get updated snappily)
	ld a, 2
	ldh [rSVBK], a
	ld a, 1
	ld [W2_ForceBGPUpdate], a
	ld [W2_ForceOBPUpdate], a
	ldh [rSVBK], a

	; Wait 3 frames (if LCD is on) to allow tilemap updates to apply. Prevents garbage
	; from appearing after closing pokemon menu.
	ldh a, [rLCDC]
	and 1 << rLCDC_ENABLE
	jr z, .doneDelay
	ld c, 3
	call DelayFrames
.doneDelay
	ret

SetPal_Battle_Common:
	ld a, [wPlayerBattleStatus3]
	bit TRANSFORMED, a
	jr z, .getBattleMonPal

	; If transformed, don't trust the "DetermineBackSpritePaletteID" function.
	ld a, $02
	ldh [rSVBK], a
	ld a, [W2_BattleMonPalette]
	ld b, a
	xor a
	ldh [rSVBK], a
	jr .getEnemyMonPal

.getBattleMonPal
	ld a, [wBattleMonSpecies]        ; player Pokemon ID
	call DetermineBackSpritePaletteID
	ld b, a

.getEnemyMonPal
	ld a, [wEnemyMonSpecies2]         ; enemy Pokemon ID (without transform effect?)
	call DeterminePaletteID
	ld c, a

	ld a, $02
	ldh [rSVBK], a

	; Save the player mon's palette in case it transforms later
	ld a, b
	ld [W2_BattleMonPalette], a

	; Player palette
	push bc
	ld d, b
	ld e, 0
	farcall LoadSGBPalette

	; Enemy palette
	pop bc
	ld d, c
	ld e, 1
	farcall LoadSGBPalette

	; Player lifebar
	ld a, [wPlayerHPBarColor]
	add PAL_GREENBAR
	ld d, a
	ld e, 2
	farcall LoadSGBPalette

	; Enemy lifebar
	ld a, [wEnemyHPBarColor]
	add PAL_GREENBAR
	ld d, a
	ld e, 3
	farcall LoadSGBPalette

IF GEN_2_GRAPHICS
	; Player exp bar
	ld d, PAL_EXP
ELSE
	; Black palette
	ld d, PAL_BLACK
ENDC
	ld e, 4
	farcall LoadSGBPalette
	
	ld d, BATTLE_TEXT
	ld e, 7
	farcall LoadMapPalette

	; Now set the tilemap

	; Top half; enemy lifebar
	ld hl, W2_TilesetPaletteMap
	ld a, 3
	ld b, 4
	ld c, 11
	call FillBox

;IF GEN_2_GRAPHICS
;	; Bottom half; player lifebar
;	ld hl, W2_TilesetPaletteMap + 7 * 20 + 9
;	ld a, 2
;	ld b, 4
;	ld c, 11
;	call FillBox

;	; Player exp bar
;	ld hl, W2_TilesetPaletteMap + 9 + 11 * 20
;	ld a, 4
;	ld b, 1
;	ld c, 11
;	call FillBox
;ENDC

;IF !GEN_2_GRAPHICS
	; Bottom half; player lifebar
	ld hl, W2_TilesetPaletteMap + 7 * 20 + 9
	ld a, 2
	ld b, 5
	ld c, 11
	call FillBox
;ENDC

IF GEN_2_GRAPHICS
	; Player exp bar
	ld hl, W2_TilesetPaletteMap + 10 + 11 * 20
	ld a, 4
	ld b, 8
	call FillLine
ENDC

	; Player pokemon
	ld hl, W2_TilesetPaletteMap + 4 * 20
	ld a, 0
	ld b, 8
	ld c, 9
	call FillBox

	; Enemy pokemon
	ld hl, W2_TilesetPaletteMap + 11
	ld a, 1
	ld b, 7
	ld c, 9
	call FillBox

	; text box
	ld hl, W2_TilesetPaletteMap + 12 * 20
	ld a, 7
	ld b, 6
	ld c, 20
	call FillBox

	xor a
	ld [W2_TileBasedPalettes], a ; Use a direct color map instead of assigning colors to tiles
	ld a, 3
	ld [W2_StaticPaletteMapChanged], a

	xor a
	ldh [rSVBK], a

	ld a, SET_PAL_BATTLE
	ld [wDefaultPaletteCommand], a

	ret

; hl: starting address
; a: pal number
; b: number of rows
; c: number of columns
FillBox:
	push af
	ld a, SCREEN_WIDTH
	sub c
	ld e, a
	ld d, 0
	pop af
	push bc
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	add hl, de
	pop bc
	dec b
	push bc
	jr nz, .loop
	pop bc
	ret

; Load town map
SetPal_TownMap:

	farcall LoadOverworldSpritePalettes
	
	ld a, 2
	ldh [rSVBK], a

	ld d, PAL_TOWNMAP
	ld e, 0
	farcall LoadSGBPalette

	ld d, PAL_TOWNMAP2
	ld e, 1
	farcall LoadSGBPalette

	ld a, 1
	ld [W2_TileBasedPalettes], a

	ld hl, W2_TilesetPaletteMap
	ld bc, $100
	xor a
	call FillMemory

	; Give tile $65 a different color
	ld hl, W2_TilesetPaletteMap + $65
	ld [hl], 1

	xor a
	ld [W2_UseOBP1], a
	ldh [rSVBK], a
	ret

; Status screen
SetPal_StatusScreen:
	ld a, [wCurPartySpecies]
	cp NUM_POKEMON_INDEXES + 1
	jr c, .pokemon
	ld a, $1 ; not pokemon
.pokemon
	call DeterminePaletteID
	ld b, a

	ld a, 2
	ldh [rSVBK], a

	push bc

	; Load Lifebar palette
	ld a, [wStatusScreenHPBarColor]
	add PAL_GREENBAR
	ld d, a
	ld e, 1
	farcall LoadSGBPalette

IF GEN_2_GRAPHICS
	ld d, PAL_EXP
	ld e, 4
	farcall LoadSGBPalette
ENDC

	; Load pokemon palette
	pop af
	ld d, a
	ld e, 0
	farcall LoadSGBPalette


	; Set palette map
	xor a
	ld [W2_TileBasedPalettes], a
	ld a, 3
	ld [W2_StaticPaletteMapChanged], a

	; Set everything to the lifebar palette
	ld hl, W2_TilesetPaletteMap
	ld bc, 18 * 20
	ld d, 1
.fillLoop
	ld [hl], d
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .fillLoop

	; Set upper-left to pokemon's palette
	ld hl, W2_TilesetPaletteMap
	ld de, 20 - 8
	ld b, 7
	xor a
.drawRow
	ld c, 8
.palLoop
	ld [hli], a
	dec c
	jr nz, .palLoop
	add hl, de
	dec b
	jr nz, .drawRow

IF GEN_2_GRAPHICS
	; Player exp bar
	ld hl, W2_TilesetPaletteMap + 11 + 5 * SCREEN_WIDTH
	ld b, 8
	ld a, 4
	call FillLine
ENDC

	xor a
	ldh [rSVBK], a
	ret

; hl: starting address
; a: pal number
; b: number of tiles
FillLine:
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

; Show pokedex data
SetPal_Pokedex:
	ld a, [wCurPartySpecies]
	call DeterminePaletteID
	ld d, a
	ld e, 0

	ld a, 2
	ldh [rSVBK], a

	farcall LoadSGBPalette

IF DEF(_BLUE)
	ld d, PAL_BLUEMON
ELSE
	ld d, PAL_REDMON
ENDC
	ld e, 1
	farcall LoadSGBPalette

	ld bc, 20 * 18
	ld hl, W2_TilesetPaletteMap
	ld d, 1
.palLoop
	ld [hl], d
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .palLoop

	ld hl, W2_TilesetPaletteMap + 21
	ld de, 20 - 8
	ld b, 7
	xor a
.pokeLoop
	ld c, 8
.pokeInnerLoop
	ld [hli], a
	dec c
	jr nz, .pokeInnerLoop
	add hl, de
	dec b
	jr nz, .pokeLoop

	CALL_INDIRECT ClearSpritePaletteMap

	ld a, 3
	ld [W2_StaticPaletteMapChanged], a
	xor a
	ld [W2_TileBasedPalettes], a

	;xor a
	ldh [rSVBK], a
	ret

; Slots
SetPal_Slots:
	ld a, 2
	ldh [rSVBK], a

	ld d, PAL_SLOTS1
	ld e, 0
	farcall LoadSGBPalette
	ld d, PAL_SLOTS2
	ld e, 1
	farcall LoadSGBPalette
	ld d, PAL_SLOTS3
	ld e, 2
	farcall LoadSGBPalette
	ld d, PAL_SLOTS4
	ld e, 3
	farcall LoadSGBPalette
	ld d, PAL_SLOTS5
	ld e, 4
	farcall LoadSGBPalette

	ld hl, SlotPaletteMap
	ld a, BANK(SlotPaletteMap)
	ld de, W2_TilesetPaletteMap
	ld bc, 20 * 18
	call FarCopyData

	ld a, 3
	ld [W2_StaticPaletteMapChanged], a

	xor a
	ld [W2_TileBasedPalettes], a

	; Manage sprites

	CALL_INDIRECT LoadAttackSpritePalettes

	ld hl, SlotSpritePaletteMap
	ld a, BANK(SlotSpritePaletteMap)
	ld de, W2_SpritePaletteMap
	ld bc, $18
	call FarCopyData

	xor a
	ld [W2_UseOBP1], a
	ldh [rSVBK], a
	ret

; Titlescreen with cycling pokemon
SetPal_TitleScreen:
	ld a, [wWhichTrade] ; Get the pokemon on the screen
	call DeterminePaletteID
	ld d, a
	ld e, 0

	ld a, 2
	ldh [rSVBK], a

	farcall LoadSGBPalette

	ld d, PAL_LOGO2 ; Title logo
	ld e, 1
	farcall LoadSGBPalette

	ld d, PAL_LOGO1
	ld e, 2
	farcall LoadSGBPalette

	ld d, PAL_BLACK
	ld e, 3
	farcall LoadSGBPalette

IF GEN_2_GRAPHICS
	ld d, PAL_HERO
ELSE
	ld d, PAL_REDMON
ENDC
	ld e, 0
	farcall LoadSGBPalette_Sprite

	; Start drawing the palette map

	; Pokemon logo
	ld hl, W2_TilesetPaletteMap
	ld a, 1
	ld b, 8
.logo2Loop
	ld c, 20
.logo2InnerLoop
	ld [hli], a
	dec c
	jr nz, .logo2InnerLoop
	dec b
	jr nz, .logo2Loop

	; "Red/Blue Version"
	ld bc, 20
	ld a, 2
	call FillMemory

	; Set the text at the bottom to grey
	ld hl, W2_TilesetPaletteMap + 17 * 20
	ld bc, 20
	ld a, 3
	call FillMemory

	ld a, 3
	ld [W2_StaticPaletteMapChanged], a
	xor a
	ld [W2_TileBasedPalettes], a

	ld a, 1
	ld [W2_ForceBGPUpdate], a ; Palettes must be redrawn

	;ld a, 1
	ldh [rSVBK], a

	; This fixes the text at the bottom being the wrong color for a second or so.
	; It's a real hack, but the game's using two vram maps at once, and the color code
	; will only update one of them.
	; I'm not sure why this didn't used to be a problem...
	di
	ld a, 1
	ldh [rVBK], a
.vblankWait
	ldh a, [rLY]
	cp $90
	jr nz, .vblankWait

	ld hl, $9c00 + 9 * 32
	ld bc, 20
	ld a, 3
	call FillMemory

	xor a
	ldh [rVBK], a
	ei

	; Execute custom command 0e after titlescreen to clear colors.
	ld a, SET_PAL_OAK_INTRO
	ld [wDefaultPaletteCommand], a
	ret

; Called during the intro
SetPal_NidorinoIntro:
	ld a, 2
	ldh [rSVBK], a

IF GEN_2_GRAPHICS
	ld d, PAL_NIDORINO
ELSE
	ld d, PAL_PURPLEMON
ENDC
	ld e, 0
	farcall LoadSGBPalette_Sprite

	ld d, PAL_PURPLEMON
	ld e, 0
	farcall LoadSGBPalette

	ld a, 1
	ld [W2_ForceOBPUpdate], a
	ld [W2_ForceBGPUpdate], a ; Palettes must be redrawn

	xor a
	ldh [rSVBK], a
	ret

; used mostly for menus and the Oak intro, pokedex screen
SetPal_Generic:
	ld a, 2
	ldh [rSVBK], a

	ld d, PAL_REDBAR ; Red lifebar color (for pokeballs)
	ld e, 0
	push de
	farcall LoadSGBPalette
	pop de
	inc e
	farcall LoadSGBPalette ; Load it into the second slot as well. Prevents a minor glitch.

	ld bc, 20 * 18
	ld hl, W2_TilesetPaletteMap
	xor a
	call FillMemory

	ld a, 3
	ld [W2_StaticPaletteMapChanged], a
	xor a
	ld [W2_TileBasedPalettes], a

	ld a, 1
	ld [W2_ForceBGPUpdate], a

	;xor a
	ldh [rSVBK], a
	ret

; Loading a map. Called when first loading, and when transitioning between maps.
SetPal_Overworld::

	ld hl, wCurrentMapScriptFlags
	bit 0, [hl]
	res 0, [hl]
	ret nz

	ld a, 2
	ldh [rSVBK], a
	dec a ; ld a, 1
	ld [W2_TileBasedPalettes], a

	; Clear sprite palette map, except for exclamation marks above people's heads
	CALL_INDIRECT ClearSpritePaletteMap

	; Pokecenter uses OBP1 when healing pokemons; also cut animation
	ld a, %10000000
	ld [W2_UseOBP1], a

	CALL_INDIRECT LoadOverworldSpritePalettes

	xor a
	ldh [rSVBK], a

	CALL_INDIRECT LoadTilesetPalette

	; Wait 2 frames before updating palettes (if LCD is on)
	ldh a, [rLCDC]
	and 1 << rLCDC_ENABLE
	jr z, .doneDelay
	ld c, 2
	call DelayFrames
.doneDelay:

	ld a, 2
	ldh [rSVBK], a

	; Signal to refresh palettes
	ld a, 1
	ld [W2_ForceBGPUpdate], a
	ld [W2_ForceOBPUpdate], a

	xor a
	ldh [rSVBK], a

	ld a, SET_PAL_OVERWORLD
	ld [wDefaultPaletteCommand], a
	ret

; Open pokemon menu
SetPal_PartyMenu:
	ld a, 2
	ldh [rSVBK], a

;	CALL_INDIRECT LoadOverworldSpritePalettes

	ld d, PAL_GREENBAR ; Filler for palette 0 (technically, green)
	ld e, 0
	farcall LoadSGBPalette
	ld d, PAL_GREENBAR
	ld e, 1
	farcall LoadSGBPalette
	ld d, PAL_YELLOWBAR
	ld e, 2
	farcall LoadSGBPalette
	ld d, PAL_REDBAR
	ld e, 3
	farcall LoadSGBPalette

	ld b, 9 ; there are only 6 pokemon but iterate 9 times to fill the whole screen
	ld hl, wPartyMenuHPBarColors
	ld de, W2_TilesetPaletteMap
.loop
	ld a, [hli]
	and 3
	inc a

	ld c, 40
.loop2
	ld [de], a
	inc de
	dec c
	jr nz, .loop2

	dec b
	jr nz, .loop

	CALL_INDIRECT ClearSpritePaletteMap

	ld a, 3
	ld [W2_StaticPaletteMapChanged], a
	xor a
	ld [W2_UseOBP1], a
	ld [W2_TileBasedPalettes], a
	ldh [rSVBK], a
	ret


; used when a Pokemon is the only thing on the screen
; such as evolution, trading and the Hall of Fame
; Evolution / Hall of Fame
;
; Takes parameter 'c' from 0-2.
; 0: calculate palette based on loaded pokemon
; 1: make palettes black
; 2: previously used during trades, now unused.
SetPal_PokemonWholeScreen:
	ld a, c
	dec a
	ld a, PAL_BLACK
	jr z, .loadPalette
	ld a, c
	cp 2
	ld a, PAL_MEWMON
	jr z, .loadPalette
	ld a, [wWholeScreenPaletteMonSpecies]
	; Use the "BackSprite" version for the player sprite in the hall of fame.
	call DetermineBackSpritePaletteID

.loadPalette
	ld d, a
	ld a, 2
	ldh [rSVBK], a

	ld e, 0
	farcall LoadSGBPalette

	ld d, PAL_MEWMON
	ld e, 1
	push de
.loop
	farcall LoadSGBPalette
	pop de
	ld a, e
	inc a
	ld e, a
	push de
	cp 8
	jr nz, .loop
	pop de

	ld d, PAL_MEWMON
	ld e, 0
	push de
.loop_sprites
	farcall LoadSGBPalette_Sprite
	pop de
	ld a, e
	inc a
	ld e, a
	push de
	cp 8
	jr nz, .loop_sprites
	pop de

	xor a
	ld [W2_TileBasedPalettes], a
	ld hl, W2_TilesetPaletteMap
	ld bc, 20 * 18
	call FillMemory

	inc a ; ld a, 1
	ld [W2_ForceBGPUpdate], a ; Refresh palettes
	ld a, 3
	ld [W2_StaticPaletteMapChanged], a

	xor a
	ldh [rSVBK], a
	ret


; Called as the game starts up
SetPal_GameFreakIntro:
	ld a, $02
	ldh [rSVBK], a

	; Load "INTRO_GRAY" palette from map_palettes.asm
	ld hl, MapPalettes + INTRO_GRAY * 4
	ld a, BANK(MapPalettes)
	ld de, W2_BgPaletteData
	ld bc, $08
	call FarCopyData

	; Palette 0 used by logo; palettes 4-7 used by sparkles
	ld d, PAL_GAMEFREAK
	ld e, 0
	farcall LoadSGBPalette_Sprite

	ld d, PAL_REDMON
	ld e, 4
	farcall LoadSGBPalette_Sprite

	ld d, PAL_BLUEMON
	ld e, 5
	farcall LoadSGBPalette_Sprite

	ld d, PAL_GAMEFREAK
	ld e, 6
	farcall LoadSGBPalette_Sprite

	ld d, PAL_VIRIDIAN ; PAL_GREENMON
	ld e, 7
	farcall LoadSGBPalette_Sprite

	; Set the star to use palette 6
	ld a, 6
	ld hl, W2_SpritePaletteMap + $a0
	ld [hli], a
	ld [hli], a
	; Set the sparkles underneath the logo to all use different palettes (4-7)
	ld [hl], 10

	; Everything else will use palette 0 by default

	; Use OBP1 just for the shooting star
	ld a, %11110000
	ld [W2_UseOBP1], a

	xor a
	ldh [rSVBK], a
	ret

; Trainer card
SetPal_TrainerCard:
	ld a, 2
	ldh [rSVBK], a

	ld d, PAL_MEWMON
	ld e, 0
	farcall LoadSGBPalette
	ld d, PAL_BADGE
	ld e, 1
	farcall LoadSGBPalette
	ld d, PAL_REDMON
	ld e, 2
	farcall LoadSGBPalette
	ld d, PAL_YELLOWMON
	ld e, 3
	farcall LoadSGBPalette

	; Red's palette
IF GEN_2_GRAPHICS
	ld d, PAL_HERO
ELSE
	ld d, PAL_REDMON
ENDC
	ld e, 4
	farcall LoadSGBPalette

	; Palette for border tiles
IF DEF(_BLUE)
	ld d, PAL_BLUEMON
ELSE ; _RED
	ld d, PAL_REDMON
ENDC
	ld e, 5
	farcall LoadSGBPalette

	; Load palette map
	ld hl, BadgePalettes
	ld a, BANK(BadgePalettes)
	ld de, W2_TilesetPaletteMap
	ld bc, $60
	call FarCopyData
	; Set everything else to be red or blue (depending on game)
	push de
	pop hl
	ld bc, $a0
	ld a, 5
	call FillMemory


	; Wait 2 frames before updating palettes
	ld c, 2
	call DelayFrames

	ld a, 1
	ld [W2_ForceBGPUpdate], a ; Signal to update palettes
	ldh [rSVBK], a
	ret


; Clear colors after titlescreen
SetPal_OakIntro:
	ld a, 2
	ldh [rSVBK], a

	ld bc, 20 * 18
	ld hl, W2_TilesetPaletteMap
	ld d, 0
.palLoop
	ld [hl], d
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, .palLoop

	xor a
	ld [W2_TileBasedPalettes], a
	ld a, 3
	ld [W2_StaticPaletteMapChanged], a

	xor a
	ldh [rSVBK], a
	ret

; Name entry
; Deals with sprites for the pokemon naming screen
SetPal_NameEntry:
	ld a, 2
	ldh [rSVBK], a

;	CALL_INDIRECT LoadOverworldSpritePalettes

	CALL_INDIRECT ClearSpritePaletteMap

	xor a
	ldh [rSVBK], a
	ret


; Code for the pokemon in the titlescreen.
; There's no particular reason it needs to be in this bank.
LoadTitleMonTilesAndPalettes:
	push de
	ld b, SET_PAL_TITLE_SCREEN
	call RunPaletteCommand
	pop de
	farcall TitleScroll ; removed from caller to make space for hook
	ret


; Everything else goes in bank $2C (unused by original game)
SECTION "bank2C", ROMX

INCLUDE "color/init.asm"
INCLUDE "color/refreshmaps.asm"
INCLUDE "color/loadpalettes.asm"

INCLUDE "color/vblank.asm"
INCLUDE "color/sprites.asm"
INCLUDE "color/ssanne.asm"
;INCLUDE "color/boulder.asm"
INCLUDE "color/super_palettes.asm"

INCLUDE "color/data/badgepalettemap.asm"

INCLUDE "color/dmg.asm"

INCLUDE "color/colorplus/loadextragfx.asm"
INCLUDE "color/colorplus/spritespecialproperties.asm"
IF GEN_2_GRAPHICS
	INCLUDE "color/colorplus/mon_gender.asm"
ENDC

; Copy of sound engine used by dmg-mode to play jingle
SECTION "bank31", ROMX
INCBIN "color/data/bank31.bin", $0000, $c8000 - $c4000
