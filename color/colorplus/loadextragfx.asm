; Called during InitMapSprites and LoadTilesetTilePatternData to load special GFX at appropriate times
; Exemple : 
; In the Celadon Mansion Roof map, load some duplicates tiles from mansion_gfx into unused 
; vram space as to color them differently and be used for the building facade and external walls.
VramSwap::
	ld hl, VramSwapList
	ld a, [hli] ; first byte of list is for IsInArray DE value
	ld d, 0
	ld e, a
	ld a, [wCurMap]
	call IsInArray
	jr nc, .noVramSwap

.vramSwapLoop
	push hl
	push de
	ld a, [hli] ; \1 map - up to \2-1
	push af

	call ListEventCheck
	inc hl
	cp -1
	jr z, .noEventCheck
	and 1
	cp [hl]
	jr nz, .done
.noEventCheck

	inc hl

	call ListCoordsCheck ; use from \3 up to \5
	jr nz, .done

	inc hl ; up to \6

	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a

	push de ; save DE value to load it in HL as its final position
	ld a, [hli] ; \8 amount of tiles to copy from gfx - up to BANK(6\)
	ld c, a
	ld a, [hli] ; BANK(6\) bank of gfx to use - up to HIGH(\9)
	ld b, a
	ld a, [hli] ; LOW(\6 tile \7) starting tile in gfx - up to HIGH(\6 tile \7)
	ld e, a
	ld a, [hli] ; HIGH(\6 tile \7) starting tile in gfx - up to \10 vram bank destination
	ld d, a

	ld a, [hl] ; \10 vram bank destination
	ldh [rVBK], a

	pop hl ; load value saved from DE earlier in HL

	call GoodCopyVideoDataHDMA

.done
	pop af
	pop de
	pop hl
	add hl, de
	cp [hl]
	jr z, .vramSwapLoop
	xor a
	ldh [rVBK], a
.noVramSwap
	ret

; Called during InitMapSprites to substitute sprites in special occasions
; Exemple : subsitute SPRITE_BLANK in Fuchsia City by either OMANYTE or KABUTO sprite based on the fossil events
; Input : PICTUREID in [wSavedSpritePictureID]
_SpriteSwap:
	push de
	ld a, [wCurMapTileset]
	and a
	ld hl, SpriteSetSpriteSwapList
	ld a, [wSpriteSetID]
	jr z, .useSpriteSet ; if Overworld tileset then the map use a SpriteSet
	ld hl, MapSpriteSwapList
	ld a, [wCurMap]
.useSpriteSet

	ld d, 0
	ld e, [hl] ; first byte of list is for IsInArray DE value
	inc hl
	call IsInArray
	ld a, [wSavedSpritePictureID]
	jr nc, .return

.SpriteSwapLoop
	push hl
	push de
	ld a, [hli] ; \1 map - up to \2-1
	push af

	ld a, [hli]
	ld b, a
	ld a, [wSavedSpritePictureID]
	cp b
	jr nz, .checkNextLine

	call ListEventCheck
	inc hl
	cp -1
	jr z, .noEventCheck
	and 1
	cp [hl]
	jr nz, .checkNextLine
.noEventCheck

	inc hl

	call ListCoordsCheck ; use from \3 up to \5
	jr nz, .checkNextLine

	inc hl

	ld a, [hl]
	jr .preReturn

.checkNextLine
	pop af
	pop de
	pop hl
	add hl, de
	cp [hl]
	ld a, [wSavedSpritePictureID]
	jr z, .SpriteSwapLoop
	and a
	jr .return
.preReturn
	pop bc
	pop de
	pop hl
	scf
.return
;	ld [wSavedSpritePictureID], a
	pop de
	ret

ListEventCheck:
	ld a, [hli] ; \2-1 bit number - to \2-2  event_byte
	ld b, a ; put bit number in b to count
	cp -1
	jr nz, .checkForEvent
	and a ; unset z flag
	ret
.checkForEvent
;	ld d, 0 ; uncomment this line if 'd' non-zero when function is called
	ld a, [hl]
	ld e, a ; 'd' is already 0 if called by VramSwap or SpriteSwap
	push hl ; \2-2 event_byte value
	ld hl, wEventFlags
	add hl, de
	ld a, [hl] ; byte containing the event bit
	pop hl
	inc b
	dec b
	jr z, .bitIs0
.rrcaLoop
	rrca
	dec b ; count down
	jr nz, .rrcaLoop
.bitIs0
	bit 0, a
	ret

ListCoordsCheck:
	ld a, [wXCoord]
	cp [hl] ; cp with /3 X Coordinate
	ld b, %01
	jr c, .doneXcheck
	ld b, %00
.doneXcheck
	inc hl ; up to /4
	ld a, [wYCoord]
	cp [hl] ; cp with /4 Y Coordinate
	ld a, %10
	jr c, .doneYcheck
	xor a ; %00 in 'a'
.doneYcheck
	add b
	inc hl ; up to /4
	cp [hl] ; cp with /5 Coordinates Conditions
	ret


VramSwapList:
; 1/ map, 2/ Event to check for, 3/ X Coordinate, 4/ Y Coordinate, 5/ coordinates conditions (NOXY, AFTER/BEFORE_X/Y, AFTER/BEFORE_X_AFTER/BEFORE_Y),
; 6/ gfx to use, 7/ which gfx tile to start from, /8 amount of tiles to copy, /9 where in vram, /10 vram bank
	db 14
;	map_vram_swap CELADON_MANSION_ROOF, NOEVENT, 0, 0, 0, NOXY, Mansion_GFX, $5A, 6, vTileset tile $10, 0
;	map_vram_swap CELADON_MANSION_ROOF, NOEVENT, 0, 0, 0, NOXY, Mansion_GFX, $36, 3, vTileset tile $16, 0
IF DEF(_DEBUG)
;	map_vram_swap ROUTE_18, NOEVENT, 0, 0, 0, NOXY, LaprasSprite, 0, 24, vNPCSprites tile $30, 0 ; used to test the function for sprites
	map_vram_swap ROUTE_18, NOEVENT, 0, 47, 0, AFTER_X, LaprasSprite, 0, 24, vNPCSprites tile $30, 0 ; used to test the function for sprites
;	map_vram_swap ROUTE_18, NOEVENT, 0, 47, 0, BEFORE_X, CooltrainerMSprite, 0, 12, vNPCSprites tile $18, 0 ; used to test the function for sprites
ENDC
	db -1

MapSpriteSwapList:
; 1/ map, 2/ Sprite to replace, 3/ Event to check for, 4/ X Coordinate, 5/ Y Coordinate,
; 6/ coordinates conditions (NOXY, AFTER/BEFORE_X/Y, AFTER/BEFORE_X_AFTER/BEFORE_Y), 7/ replacement Sprite
	db 9
IF DEF(_DEBUG)
	map_sprite_swap CELADON_CHIEF_HOUSE, SPRITE_ROCKET, EVENT_GOT_DOME_FOSSIL, TRUE, 0, 0, NOXY, SPRITE_OMANYTE
	map_sprite_swap FUCHSIA_MART, SPRITE_CLERK, EVENT_GOT_DOME_FOSSIL, TRUE, 0, 0, NOXY, SPRITE_OMANYTE
ENDC
;	map_sprite_swap FUCHSIA_CITY, SPRITE_BLANK,   EVENT_GOT_DOME_FOSSIL,  TRUE,  0, 0, NOXY, SPRITE_OMANYTE
;	map_sprite_swap FUCHSIA_CITY, SPRITE_BLANK,   EVENT_GOT_HELIX_FOSSIL, TRUE,  0, 0, NOXY, SPRITE_KABUTO
;IF DEF(_DEBUG)	
;	map_sprite_swap FUCHSIA_CITY, SPRITE_KABUTO,  EVENT_GOT_DOME_FOSSIL,  TRUE,  0, 0, NONE, SPRITE_OMANYTE
;	map_sprite_swap FUCHSIA_CITY, SPRITE_KABUTO,  EVENT_GOT_HELIX_FOSSIL, FALSE, 0, 0, NONE, SPRITE_BLANK
;	map_sprite_swap FUCHSIA_CITY, SPRITE_OMANYTE, EVENT_GOT_HELIX_FOSSIL, TRUE,  0, 0, NONE, SPRITE_KABUTO
;	map_sprite_swap FUCHSIA_CITY, SPRITE_OMANYTE, EVENT_GOT_DOME_FOSSIL,  FALSE, 0, 0, NONE, SPRITE_BLANK
;ENDC
;	map_sprite_swap ROUTE_15, SPRITE_BLANK, EVENT_GOT_DOME_FOSSIL,  TRUE, 9, 0, BEFORE_X, SPRITE_OMANYTE
;	map_sprite_swap ROUTE_15, SPRITE_BLANK, EVENT_GOT_HELIX_FOSSIL, TRUE, 9, 0, BEFORE_X, SPRITE_KABUTO
	db -1

SpriteSetSpriteSwapList:
; 1/ map, 2/ Sprite to replace, 3/ Event to check for, 4/ X Coordinate, 5/ Y Coordinate,
; 6/ coordinates conditions (NOXY, AFTER/BEFORE_X/Y, AFTER/BEFORE_X_AFTER/BEFORE_Y), 7/ replacement Sprite
	db 9
	map_sprite_swap SPRITESET_FUCHSIA, SPRITE_BLANK,   EVENT_GOT_DOME_FOSSIL,  TRUE,  0, 0, NOXY, SPRITE_OMANYTE
	map_sprite_swap SPRITESET_FUCHSIA, SPRITE_BLANK,   EVENT_GOT_HELIX_FOSSIL, TRUE,  0, 0, NOXY, SPRITE_KABUTO
IF DEF(_DEBUG) ; used in debug to test the function when cycling through the events with the enclosure sign
;	map_sprite_swap SPRITESET_FUCHSIA, SPRITE_KABUTO,  EVENT_GOT_DOME_FOSSIL,  TRUE,  0, 0, NOXY, SPRITE_OMANYTE
	map_sprite_swap SPRITESET_FUCHSIA, SPRITE_KABUTO,  EVENT_GOT_HELIX_FOSSIL, FALSE, 0, 0, NOXY, SPRITE_BLANK
	map_sprite_swap SPRITESET_FUCHSIA, SPRITE_OMANYTE, EVENT_GOT_HELIX_FOSSIL, TRUE,  0, 0, NOXY, SPRITE_KABUTO
;	map_sprite_swap SPRITESET_FUCHSIA, SPRITE_OMANYTE, EVENT_GOT_DOME_FOSSIL,  FALSE, 0, 0, NOXY, SPRITE_BLANK
ENDC
	db -1
