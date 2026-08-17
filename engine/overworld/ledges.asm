HandleLedges::
	ld a, [wMovementFlags]
	bit BIT_LEDGE, a
	ret nz

	ld a, [wCurMapTileset]
	ld b, a
	ld hl, LedgeTilesets
.searchTileset
	ld a, [hli]
	cp -1
	ret z
	cp b
	jr z, .tilesetMatch
	inc hl
	inc hl
	jr .searchTileset

.tilesetMatch	
	ld a, [hli]
	ld e, a
	ld d, [hl]

	ld a, [wSpritePlayerStateData1FacingDirection]
	rra
	ld c, a
	rra
	add c
	add LOW(LedgeCheckDataTable)
	ld l, a
	adc HIGH(LedgeCheckDataTable)
	sub l
	ld h, a

	ld a, [hli]
	ld b, a
	ldh a, [hJoyHeld]
	and b
	ret z

	push bc

	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld b, [hl]

	ld a, c
	add e
	ld l, a
	adc d
	sub l
	ld h, a

	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, c
	cp SPRITE_FACING_LEFT / 2
	jr nz, .notLeft
	lda_coord 7, 9
	jr .gotTile
.notLeft
	cp SPRITE_FACING_DOWN / 2
	jr nz, .done
	lda_coord 8, 10
.gotTile
	ld c, a
	push hl
	call .checkTileLoop
	pop hl
	ccf
	jr nc, .notLedge
.done

	ld a, [wTileInFrontOfPlayer]
	ld c, a
	call .checkTileLoop
	jr nc, .notLedge

	ld h, d
	ld l, e
	dec hl
	ld a, [hld]
	ld l, [hl]
	ld h, a

	push hl
	ld c, b
	call .checkTileLoop
	pop hl
	jr nc, .notLedge

	lda_coord 8, 9
	ld c, a
	call .checkTileLoop
.notLedge
	pop bc
	ret nc

	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, wMovementFlags
	set BIT_LEDGE, [hl]
	call StartSimulatingJoypadStates
	ld a, b
	ld [wSimulatedJoypadStatesEnd], a
	ld [wSimulatedJoypadStatesEnd + 1], a
	ld a, $2
	ld [wSimulatedJoypadStatesIndex], a
	call LoadHoppingShadowOAM
	ld a, SFX_LEDGE
	call PlaySound
	ret

.checkTileLoop
	ld a, [hli]
	cp -1
	ret z
	cp c
	jr nz, .checkTileLoop
	scf
	ret


HandleLedges2::
	ld a, [wMovementFlags]
	bit BIT_LEDGE, a
	ret nz
	ld a, [wCurMapTileset]
	and a ; OVERWORLD
	ret nz
;	predef GetTileAndCoordsInFrontOfPlayer
	ld a, [wSpritePlayerStateData1FacingDirection]
	ld b, a
	lda_coord 8, 9
	ld c, a
	ld a, [wTileInFrontOfPlayer]
	ld d, a

;	lda_coord 8, 9
;	ld c, a
;	ld a, [wSpritePlayerStateData1FacingDirection]
;	ld b, a
;	rra
;	add LOW(.tilesInFrontTable)
;	ld l, a
;	adc HIGH(.tilesInFrontTable)
;	sub l
;	ld h, a
;	ld a, [hli]
;	ld h, [hl]
;	ld l, a
;	ld d, [hl]

	ld hl, LedgeTiles
.loop
	ld a, [hli]
	cp $ff
	ret z
	cp b
	jr nz, .nextLedgeTile1
	ld a, [hli]
	cp c
	jr nz, .nextLedgeTile2
	ld a, [hli]
	cp d
	jr nz, .nextLedgeTile3
;	ld a, [hl]
;	ld e, a
	ld e, [hl]
	jr .foundMatch
.nextLedgeTile1
	inc hl
.nextLedgeTile2
	inc hl
.nextLedgeTile3
	inc hl
	jr .loop
.foundMatch
	ldh a, [hJoyHeld]
	and e
	ret z
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, wMovementFlags
	set BIT_LEDGE, [hl]
	call StartSimulatingJoypadStates
	ld a, e
	ld [wSimulatedJoypadStatesEnd], a
	ld [wSimulatedJoypadStatesEnd + 1], a
	ld a, $2
	ld [wSimulatedJoypadStatesIndex], a
	call LoadHoppingShadowOAM
	ld a, SFX_LEDGE
	call PlaySound
	ret

;.tilesInFrontTable
;	dw wTileMap +  8 + 20*11
;	dw wTileMap +  8 + 20 *6
;	dw wTileMap +  6 + 20 *9
;	dw wTileMap + 11 + 20 *9

INCLUDE "data/tilesets/tiles/ledge_tiles.asm"

LoadHoppingShadowOAM:
	ldh a, [rVBK]
	push af
	ld a, 1
	ldh [rVBK], a
	ld hl, vChars0 tile $7f
	ld de, LedgeHoppingShadow
	lb bc, BANK(LedgeHoppingShadow), (LedgeHoppingShadowEnd - LedgeHoppingShadow) / TILE_1BPP_SIZE
	call CopyVideoDataDouble
	ld a, $9
	lb bc, $54, $48 ; b, c = y, x coordinates of shadow
	ld de, LedgeHoppingShadowOAMBlock
	call WriteOAMBlock
	pop af
	ldh [rVBK], a
	ret

LedgeHoppingShadow:
	INCBIN "gfx/overworld/shadow.1bpp"
LedgeHoppingShadowEnd:

LedgeHoppingShadowOAMBlock:
; tile ID, attributes
	db $7f, OAM_BANK1
	db $7f, OAM_XFLIP | OAM_BANK1
	db $7f, OAM_YFLIP | OAM_BANK1
	db $7f, OAM_YFLIP | OAM_XFLIP | OAM_BANK1
