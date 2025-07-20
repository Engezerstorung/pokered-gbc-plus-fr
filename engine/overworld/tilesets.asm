LoadTilesetHeader:
	call GetPredefRegisters
	push hl
	ld d, 0
	ld a, [wCurMapTileset]
;	add a
;	add a
;	ld b, a
;	add a
;	add b ; a = tileset * 12
;	jr nc, .noCarry
;	inc d
;.noCarry
;	ld e, a
;	ld hl, Tilesets
;	add hl, de
;	ld de, wTilesetBank
;	ld c, 11

	ld e, a
	ld h, d
	ld l, e
	add hl, hl ; x2 = 2
	add hl, de ; +1 = 3
	add hl, hl ; x2 = 6
	add hl, de ; +1 = 7
	add hl, hl ; x2 = 14 ; hl = tileset * 14
	ld de, Tilesets
	add hl, de
	ld de, wTilesetBank
	ld c, 13

.copyTilesetHeaderLoop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .copyTilesetHeaderLoop
	ld a, [hl]
	ldh [hTileAnimations], a
	xor a
	ldh [hMovingBGTilesCounter1], a
	pop hl
	ld a, [wCurMapTileset]
	push hl
	push de
	ld hl, DungeonTilesets
	ld de, $1
	call IsInArray
	pop de
	pop hl
	jr c, .dungeon
	ld a, [wCurMapTileset]
	ld b, a
	ldh a, [hPreviousTileset]
	cp b
	jr z, .done
.dungeon
	ld a, [wDestinationWarpID]
	cp $ff
	jr z, .done
	call LoadDestinationWarpPosition
	ld a, [wYCoord]
	and $1
	ld [wYBlockCoord], a
	ld a, [wXCoord]
	and $1
	ld [wXBlockCoord], a
.done
	ret

INCLUDE "data/tilesets/dungeon_tilesets.asm"

INCLUDE "data/tilesets/tileset_headers.asm"
