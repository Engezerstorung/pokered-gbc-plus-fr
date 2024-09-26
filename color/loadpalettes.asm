INCLUDE "color/data/map_palettes.asm"
INCLUDE "color/data/map_palette_sets.asm"
INCLUDE "color/data/map_palette_assignments.asm"
INCLUDE "color/data/roofpalettes.asm"

DEF TILESET_SIZE EQU $60

; Load colors for new map and tile placement
LoadTilesetPalette:
	push bc
	push de
	push hl
	ldh a, [rSVBK]
	ld d, a
	xor a
	ldh [rSVBK], a
	ld a, [wCurMapTileset] ; Located in wram bank 1
	ld b, a
	ld a, $02
	ldh [rSVBK], a
	push de ; push previous wram bank

	ld a, 1
	ld [W2_TileBasedPalettes], a

	ld a, b ; Get wCurMapTileset
	push af
	ld hl, MapPaletteSets
	ld b, 0
	ld c, a
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld hl, W2_BgPaletteData ; palette data to be copied to wram at hl
	ld b, $08
.nextPalette
	ld c, $08
	ld a, [de] ; # at de is the palette index for MapPalettes
	inc de
	push de
	ld d, 0
	ld e, a
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	push hl
	ld hl, MapPalettes
	add hl, de
	ld d, h
	ld e, l ; de now points to map's palette data
	pop hl
.nextColor
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .nextColor
	pop de
	dec b
	jr nz, .nextPalette

	; Start copying palette assignments
	pop af ; Retrieve wCurMapTileset
	ld hl, MapPaletteAssignments
	ld b, 0
	ld c, a
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	ld hl, W2_TilesetPaletteMap
	ld b, TILESET_SIZE
.copyLoop
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .copyLoop

	; Set the remaining values to 7 for text
	ld b, $100 - TILESET_SIZE
	ld a, 7
.fillLoop
	ld [hli], a
	dec b
	jr nz, .fillLoop

	; There used to be special-case code for tile $78 here (pokeball in pc), but now
	; it uses palette 7 as well. Those areas still need to load the variant of the
	; textbox palette (PC_POKEBALL_PAL).

	; Switch to wram bank 1 just to read wCurMap
	xor a
	ldh [rSVBK], a
	ld a, [wCurMap]
	ld b, a
	ld a, [wCurMapTileset]
	ld c, a
	ld a, 2
	ldh [rSVBK], a

; Check Tileset to load proper boulder dust palette if outside location
	push bc
	ld a, c
	and a ; check if OVERWORLD tileset
	jr z, .isOutside
	cp FOREST
	jr z, .isOutside
	cp PLATEAU
	jr nz, .notOutside
.isOutside
	lb de, SPRITE_PAL_OUTDOORDUST, 7
	farcall LoadMapPalette_Sprite
.notOutside
	pop bc

; Check Map to replace BG and Sprites palettes in special cases
; Like on Celadon Mansion Roof, for Gym Leaders or map Pokémons
	push bc
	ld a, b
	ld hl, MapPalSwapList ; loading list for identification and properties values
	ld de, 4 ; define the number of properties in list
	call IsInArray
	jr nc, .noMapPaletteSwap ; jump if not in list
.loopMapPalSwap
	ld a, [hli]
	push af
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	push hl
	and a ; Check if BG or Sprite palette (BG=0, Sprite=1)
	jr nz, .swapSpritePal
	farcall LoadMapPalette
	jr .doneSwapPal
.swapSpritePal	
	farcall LoadMapPalette_Sprite
.doneSwapPal	
	pop hl
	pop af
	cp [hl]
	jr z, .loopMapPalSwap

.noMapPaletteSwap
	pop bc

; Check Map to replace Tiles used palettes in special cases
; Like on Celadon Mansion Roof and on Celadon Mart 1F and Roof
	push bc
	ld a, b
	ld hl, TilePalSwapList ; loading list for identification and properties values
	ld de, 4 ; define the number of properties in list
	call IsInArray
	jr nc, .noTilePaletteSwap ; jump if not in list
	ld de, W2_TilesetPaletteMap
.loopTilepalSwapList
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld c, a
	ld a, [hli]
.loopTilePalSwap
	ld [de], a
	inc de
	dec c
	jr nz, .loopTilePalSwap
	ld a, b
	cp [hl]
	jr z, .loopTilepalSwapList

.noTilePaletteSwap
	pop bc

	; Retrieve former wram bank
	pop af
	ld b, a

	xor a
	ldh [rSVBK], a
	ld a, [wCurMapTileset]
	ld c, a

	ld a, b
	ldh [rSVBK], a ; Restore previous wram bank

	ld a, c
	and a ; Check whether tileset 0 is loaded
	call z, LoadTownPalette
	cp PLATEAU ; tileset 0 isn't the only outside tileset
	call z, LoadTownPalette

	pop hl
	pop de
	pop bc
	ret

; Towns have different roof colors while using the same tileset
LoadTownPalette::
	ldh a, [rSVBK]
	ld b, a
	xor a
	ldh [rSVBK], a

	; Get the current map.
	ld a, [wCurMap]
	ld c, a
	cp ROUTE_8 ; Default roof is Lavender, if closer to Saffron Route8 script load Saffron Roof
	jr z, .Route8
	cp ROUTE_6 ; Default roof is Vermilion, if closer to Saffron Route6 script load Saffron Roof
	jr nz, .notSpecialRoute
	ld a, [wYCoord]
	cp 21
	jr nc, .notSpecialRoute
	jr .useSaffronRoof
.Route8
	ld a, [wXCoord]
	cp 34
	jr nc, .notSpecialRoute
.useSaffronRoof
	ld c, SAFFRON_CITY
.notSpecialRoute
	ld a, c
	add a
	ld c, a

	ld a, $02
	ldh [rSVBK], a
	push bc ; push previous wram bank

	push de
	push hl
	ld hl, RoofPalettes
	ld b, 0
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	ld hl, W2_BgPaletteData + $32
	ld b, $04
.copyLoop
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .copyLoop
	pop hl
	pop de

	ld a, 1
	ld [W2_ForceBGPUpdate], a
	
	ld a, [wCurMap]
	ld [W2_TownMapLoaded], a

	pop af
	ldh [rSVBK], a ; Restore wram bank
	ret

MapPalSwapList:
	; Map, new palette , palette slot to replace (0-7), palette type(0=BG, 1=Sprite)
	db BILLS_HOUSE,           SPRITE_PAL_BILLSMACHINE, 5, 1
	db CELADON_GYM,           SPRITE_PAL_ERIKA,        4, 1
	db CELADON_MANSION_1F,    SPRITE_PAL_YELLOWMON,    3, 1 ; MEOWTH
	db CELADON_MANSION_1F,    SPRITE_PAL_BLUEMON,      5, 1 ; NIDORANF
	db CELADON_MANSION_ROOF,  INDOOR_LIGHT_BLUE,       2, 0
	db CELADON_MANSION_ROOF,  MANSION_SKY,             3, 0
	db CELADON_MANSION_ROOF,  MANSION_WALLS_ROOF,      6, 0
	db CERULEAN_GYM,          SPRITE_PAL_MISTY,        4, 1
	db CHAMPIONS_ROOM,        SPRITE_PAL_OAK,          4, 1
	db CINNABAR_GYM,          SPRITE_PAL_BLAINE,       4, 1
	db FUCHSIA_GYM,           SPRITE_PAL_KOGA,         4, 1
	db HALL_OF_FAME,          SPRITE_PAL_OAK,          4, 1
	db LAVENDER_CUBONE_HOUSE, SPRITE_PAL_BROWNMON,     4, 1 ; CUBONE
	db MR_FUJIS_HOUSE,        SPRITE_PAL_YELLOWMON,    5, 1 ; PSYDUCK
	db OAKS_LAB,              SPRITE_PAL_OAK,          4, 1
	db PALLET_TOWN,        	  SPRITE_PAL_OAK,          4, 1
	db PEWTER_GYM,            SPRITE_PAL_BROCK,        4, 1
	db POKEMON_FAN_CLUB,      SPRITE_PAL_REDMON,       4, 1 ; SEEL
	db POWER_PLANT,           SPRITE_PAL_YELLOWMON,    4, 1 ; ZAPDOS
	db SAFFRON_GYM,           SPRITE_PAL_SABRINA,      4, 1
	db SS_ANNE_B1F_ROOMS,     SPRITE_PAL_GREYMON,      4, 1 ; MACHOKE
	db VERMILION_CITY,        SPRITE_PAL_GREYMON,      4, 1 ; MACHOP
	db VERMILION_GYM,         SPRITE_PAL_SURGE,        4, 1
	db VIRIDIAN_GYM,          SPRITE_PAL_GIOVANNI,     4, 1
	db -1

TilePalSwapList:
	; Map, first tile to replace, number of tiles to replace, palette slot to use
	db CELADON_MANSION_ROOF, $1,  1, PAL_BG_GRAY
	db CELADON_MANSION_ROOF, $26, 3, PAL_BG_GRAY
	db CELADON_MANSION_ROOF, $36, 3, PAL_BG_GRAY
	db CELADON_MANSION_ROOF, $10, 6, PAL_BG_WATER
	db CELADON_MANSION_ROOF, $16, 3, PAL_BG_GREEN
	db CELADON_MART_1F,      $07, 2, PAL_BG_YELLOW
	db CELADON_MART_1F,      $17, 2, PAL_BG_YELLOW
	db CELADON_MART_ROOF,    $4b, 2, PAL_BG_WATER
	db CELADON_MART_ROOF,    $4f, 1, PAL_BG_WATER
	db CELADON_MART_ROOF,    $28, 1, PAL_BG_ROOF
	db CELADON_MART_ROOF,    $38, 1, PAL_BG_ROOF
	db CELADON_MART_ROOF,    $4d, 2, PAL_BG_GRAY
	db -1
