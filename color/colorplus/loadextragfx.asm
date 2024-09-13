; Called during InitMapSprites and LoadTilesetTilePatternData to load special GFX at appropriate times
; Exemple : 
; In the Celadon Mansion Roof map, load some duplicates tiles from mansion_gfx into unused 
; vram space as to color them differently and be used for the building facade and external walls.
VramSwap::
	ld hl, VramSwapList
	jr VramSwapMain
VramSwapCoords::
	ld hl, wSpriteFlags
	set 6, [hl]
	ld hl, VramSwapListCoords
VramSwapMain:
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
	jp z, .done

	inc hl

	ld a, [wSpriteFlags]
	bit 6, a
	jr z, .noCoordCheck

	call ListCoordsCheck ; use from \3 up to \5
	jr nz, .done

	inc hl ; up to \6

.noCoordCheck
	ld a, [hli]
	ld e, a
	cp LOW(vNPCSprites tile $78)
	ld a, [hli]
	ld d, a
	jr nc, .noWCarry
	jr z, .noWCarry
	dec a
.noWCarry
	cp HIGH(vNPCSprites tile $78)
	push af

	push de ; save DE value to load it in HL as its final position
	ld a, [hli] ; \9 amount of tiles to copy from gfx - up to BANK(7\)
	ld c, a
	ld a, [hli] ; BANK(7\) bank of gfx to use - up to HIGH(\10)
	ld b, a
	ld a, [hli] ; HIGH(\7 tile \8) starting tile in gfx - up to LOW(\7 tile \8)
	ld e, a
	ld a, [hl] ; LOW(\7 tile \8) starting tile in gfx
	ld d, a
	pop hl ; load value saved from DE earlier in HL
	push hl
	push de
	push bc
	call GoodCopyVideoData
	pop bc
	pop de
	pop hl
	pop af
	jr nc, .done

;	ld a, [wFontLoaded]
;	bit 0, [hl]
;	jr nz, .done
	push hl
	ld hl, wSpriteFlags
	bit 7, [hl]
	res 7, [hl]
	pop hl
	jr nz, .done
	set 3, h ; add "tile $80" to hl
	ld a, tile 12 ; start to adding "tile 12" to de
	add e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	call GoodCopyVideoData

.done
	pop af
	pop de
	pop hl
	add hl, de
	cp [hl]
	jr z, .vramSwapLoop
.noVramSwap
	ld hl, wSpriteFlags
	bit 6, [hl]
	jp z, VramSwapCoords
	res 6, [hl]
	ret

; Called during InitMapSprites to substitute sprites in special occasions
; Exemple : 
; Subsitute the blank sprite in Fuchsia City by either OMANYTE or KABUTO sprite based on the fossil events 
SpriteSwap:
	ld hl, SpriteSwapList
	ld a, [hli] ; first byte of list is for IsInArray DE value
	ld d, 0
	ld e, a
	ld a, [wCurMap]
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
	jp z, .checkNextLine

	inc hl

	call ListCoordsCheck ; use from \3 up to \5
	jr nz, .checkNextLine

	inc hl

	ld a, [hl]
	jr .preReturn

.checkNextLine
	pop bc
	ld a, b
	pop de
	pop hl
	add hl, de
	cp [hl]
	ld a, [wSavedSpritePictureID]
	jr z, .SpriteSwapLoop
	jr .return
.preReturn
	pop bc
	pop de
	pop hl
.return
	ld [wSavedSpritePictureID], a
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
	and a
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
; 1/ map, 2/ Event to check for, 3/ GFX type (sprite, stillsprite, tileset), 4/ gfx to use,
; 5/ which gfx tile to start from, /6 amount of tiles to copy, /7 where in vram
	db 9
	map_vram_swap CELADON_MANSION_ROOF, NOEVENT, tileset, Mansion_GFX, $5A, 6, $10
	map_vram_swap CELADON_MANSION_ROOF, NOEVENT, tileset, Mansion_GFX, $36, 3, $16

VramSwapListCoords:
; 1/ map, 2/ Event to check for, 3/ X Coordinate, 4/ Y Coordinate, 5/ coordinates conditions (NOXY, AFTER/BEFORE_X/Y, AFTER/BEFORE_X_AFTER/BEFORE_Y),
; 6/ GFX type (sprite, stillsprite, tileset), 7/ gfx to use, 8/ which gfx tile to start from, /9 amount of tiles to copy, /10 where in vram
	db 12	
IF DEF(_DEBUG)	
	map_vram_swap ROUTE_18, NOEVENT, 47, 0, AFTER_X, sprite, LaprasSprite, 0, 12, $18 ; used to test the function for sprites
ENDC
	db -1

SpriteSwapList:
; 1/ map, 2/ Sprite to replace, 3/ Event to check for, 4/ X Coordinate, 5/ Y Coordinate,
; 6/ coordinates conditions (NOXY, AFTER/BEFORE_X/Y, AFTER/BEFORE_X_AFTER/BEFORE_Y), 7/ replacement Sprite
	db 8
	map_sprite_swap FUCHSIA_CITY, SPRITE_BLANK, EVENT_GOT_DOME_FOSSIL,  0, 0, NOXY, SPRITE_OMANYTE
	map_sprite_swap FUCHSIA_CITY, SPRITE_BLANK, EVENT_GOT_HELIX_FOSSIL, 0, 0, NOXY, SPRITE_KABUTO
	db -1
