GetScreenViewBlocksIDs::
	ld a, [wCurrentTileBlockMapViewPointer] ; address of upper left corner of current map view
	ld l, a
	ld a, [wCurrentTileBlockMapViewPointer + 1]
	ld h, a

	ld de, wBuffer
	ld a, [wCurMapWidth]
	ld c, a
	ld b, 0

REPT 5 - 1
REPT 6
	ld a, [hli]
	ld [de], a
	inc de
ENDR
	add hl, bc
ENDR
REPT 6
	ld a, [hli]
	ld [de], a
	inc de
ENDR
	ret

_MakeTileMapOrPalMap::
	di

	ld a, 2
	ldh [rWBK], a

	ld [hSPTemp], sp
	ld sp, hl

	ld h, d
	ld l, e

REPT SCREEN_HEIGHT - 1
REPT SCREEN_WIDTH / 2
	pop de
	ld a, e
	or c
	ld [hli], a
	ld a, d
	or c
	ld [hli], a
ENDR
	add sp, 4
ENDR
REPT SCREEN_WIDTH / 2
	pop de
	ld a, e
	or c
	ld [hli], a
	ld a, d
	or c
	ld [hli], a
ENDR

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	xor a
	ldh [rWBK], a

	reti

MACRO scheduleredrawcopy
IF \1 == REDRAW_ROW
	ld hl, \2
REPT (2 * SCREEN_WIDTH) - 1
	ld a, [de]
	ld [hli], a
	inc de
ENDR
	ld a, [de]
	ld [hl], a

;	    ld [hSPTemp], sp
;
;		ld hl, SCREEN_WIDTH
;		add hl, de
;		ld sp, hl
;		ld hl, \2
;
;	REPT SCREEN_WIDTH / 2 - 1
;	REPT 2
;		ld a, [de]
;		ld [hli], a
;		inc de
;	ENDR
;		pop bc
;		ld a, c
;		ld [hli], a
;		ld a, b
;		ld [hli], a
;	ENDR
;		ld a, [de]
;		ld [hli], a
;		inc de
;		ld a, [de]
;		ld [hli], a
;		pop bc
;		ld a, c
;		ld [hli], a
;		ld [hl], b
;
;		ld sp, hSPTemp
;		pop hl
;		ld sp, hl

;		ld bc, \2
;		ld hl, SCREEN_WIDTH
;		add hl, de
;	REPT SCREEN_WIDTH / 2 - 1
;		REPT 2
;			ld a, [de]
;			ld [bc], a
;			inc de
;			inc bc
;		ENDR
;		REPT 2
;			ld a, [hli]
;			ld [bc], a
;			inc bc
;		ENDR
;	ENDR
;		ld a, [de]
;		ld [bc], a
;		inc de
;		inc bc
;		ld a, [de]
;		ld [bc], a
;		inc bc
;		ld a, [hli]
;		ld [bc], a
;		inc bc
;		ld a, [hl]
;		ld [bc], a

ELIF \1 == REDRAW_COL
		ld de, \2
	REPT SCREEN_HEIGHT - 1
		ld a, [hli]
		ld [de], a
		inc de
		ld a, [hl]
		ld [de], a
		inc de
		add hl, bc
	ENDR
		ld a, [hli]
		ld [de], a
		inc de
		ld a, [hl]
		ld [de], a

ELSE
	fail "Invalid Argument. 1\ must be REDRAW_ROW or REDRAW_COL, 2\ must be the schedule redraw copy destination"
ENDC
ENDM

_CopyToRedrawRowOrColumnSrcTiles::
	ld a, 2
	ldh [rWBK], a

	ld hl, W2_TileMapPalMap - wTileMap
	add hl, de
	push hl
;	di
	scheduleredrawcopy REDRAW_ROW, wRedrawRowOrColumnSrcTiles

	pop de
	scheduleredrawcopy REDRAW_ROW, W2_RedrawRowOrColumnSrcTiles
;	ei

	xor a
	ldh [rWBK], a
	ret

_ScheduleColumnRedrawHelper::
	ld a, 2
	ldh [rWBK], a

	ld h, d
	ld l, e
	ld bc, SCREEN_WIDTH - 1

	push hl
	scheduleredrawcopy REDRAW_COL, wRedrawRowOrColumnSrcTiles

	pop hl
	ld de, W2_TileMapPalMap - wTileMap
	add hl, de
	scheduleredrawcopy REDRAW_COL, W2_RedrawRowOrColumnSrcTiles

	xor a
	ldh [rWBK], a
	ret

CorrectTileMapTilesIDs::
	ld a, 2
	ldh [rWBK], a
	ld hl, wTileMap
	ld de, W2_TileMapPalMap
	ld b, SCREEN_HEIGHT
	ld c, 7 ; used both as a mask for palette bits and as value for text palette
.loop
REPT SCREEN_WIDTH
	ld a, [de]
	inc de
	and c ; mask the attribute info to keep only palette bits
	cp c ; check if text palette
	jr z, .isText\@
	res 7, [hl]
.isText\@
	inc hl
ENDR
	dec b
	jp nz, .loop
	xor a
	ldh [rWBK], a
	ret

FillTileMapPalMapWithTextPal::
	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	push bc

	ld a, 7
	ld hl, W2_TileMapPalMap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call FillMemory

	pop af
	ldh [rWBK], a
	ret

FarDrawTextPalBoxOnTileMapPalMap::
	ld b, a
DrawTextPalBoxOnTileMapPalMap::
	ldh a, [rWBK]
	ld h, a
	ld a, 2
	ldh [rWBK], a
	push hl

	ld hl, W2_TileMapPalMap - wTileMap
	add hl, de

	inc b
	inc b
	inc c
	inc c

	ld a, 7
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

	pop af
	ldh [rWBK], a
	ret

_SaveScreenTilesToBuffer1::
	hlcoord 0, 0
	ld de, wTileMapBackup
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyData
_SaveScreenPalsToBuffer1::
	ld de, W2_TileMapPalMapBackup1
	jr Save_PalMap

_LoadScreenTilesFromBuffer1::
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld hl, wTileMapBackup
	decoord 0, 0
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call CopyData
_LoadScreenPalsFromBuffer1_Common::
	ld hl, W2_TileMapPalMapBackup1
	call Load_PalMap
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ret

_LoadScreenPalsFromBuffer1::
	xor a
	ldh [hAutoBGTransferEnabled], a
	jr _LoadScreenPalsFromBuffer1_Common

_SaveScreenTilesToBuffer2::
	hlcoord 0, 0
	ld de, wTileMapBackup2
	call CopyData_TileMap
_SaveScreenPalsToBuffer2::
	ld de, W2_TileMapPalMapBackup2
	jr Save_PalMap

_LoadScreenTilesFromBuffer2::
	call _LoadScreenTilesFromBuffer2DisableBGTransfer
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ret

_LoadScreenPalsFromBuffer2::
	call _LoadScreenPalsFromBuffer2DisableBGTransfer
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ret

; loads screen tiles stored in wTileMapBackup2 but leaves hAutoBGTransferEnabled disabled
_LoadScreenTilesFromBuffer2DisableBGTransfer::
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld hl, wTileMapBackup2
	decoord 0, 0
	call CopyData_TileMap
_LoadScreenPalsFromBuffer2_Common:
	ld hl, W2_TileMapPalMapBackup2
	jr Load_PalMap

; loads screen palettes stored in W2_TileMapPalMapBackup2 but leaves hAutoBGTransferEnabled disabled
_LoadScreenPalsFromBuffer2DisableBGTransfer::
	xor a
	ldh [hAutoBGTransferEnabled], a
	jr _LoadScreenPalsFromBuffer2_Common

CopyData_TileMap:
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	jp CopyData

Save_PalMap:
	ld hl, W2_TileMapPalMap
	jr CopyData_PalMap
Load_PalMap:
	ld de, W2_TileMapPalMap
CopyData_PalMap:
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	ld a, 2
	ldh [rWBK], a	
	call CopyData
	xor a
	ldh [rWBK], a
	ret
