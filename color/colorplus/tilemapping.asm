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
	ldh [rSVBK], a

	ld [hSPTemp], sp
	ld sp, hl

	ld h, d
	ld l, e

REPT SCREEN_HEIGHT - 1
REPT SCREEN_WIDTH / 2
	pop de
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
ENDR
	add sp, 4
ENDR
REPT SCREEN_WIDTH / 2
	pop de
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
ENDR

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	xor a
	ldh [rSVBK], a

	ei

	ret

;MakeTileMapAndPalMap::
;	ld a, 2
;	ldh [rSVBK], a
;
;	di
;	ld [hSPTemp], sp
;	ld sp, hl
;
;	hlcoord 0, 0
;
;REPT SCREEN_HEIGHT
;REPT SCREEN_WIDTH / 2
;	pop de
;	ld a, e
;	ld [hli], a
;	ld a, d
;	ld [hli], a
;ENDR
;	add sp, 4
;ENDR
;
;	ld sp, wTileMap
;	ld hl, W2_TileMapPalMap
;	ld b, HIGH(W2_TilesetPaletteMap)
;
;REPT (SCREEN_WIDTH * SCREEN_HEIGHT) / 2
;	pop de
;	ld c, e
;;	res 7, e
;	ld a, [bc]
;	ld [hli], a
;
;	ld c, d
;;	res 7, d
;	ld a, [bc]
;	ld [hli], a
;;	push de
;;	add sp, 2
;ENDR
;
;	ld sp, hSPTemp
;	pop hl
;	ld sp, hl
;
;	ei
;
;	xor a
;	ldh [rSVBK], a
;
;	ret

ClearBGMap0Attributes::
	ld a, 1
	ldh [rVBK], a

	xor a
	ld hl, vBGMap0
	ld bc, BG_MAP_WIDTH * BG_MAP_HEIGHT
	call FillMemory
	
	xor a
	ldh [rVBK], a
	ret

FillTileMapPalMapWithTextPal::
	ldh a, [rSVBK]
	ld b, a
	ld a, 2
	ldh [rSVBK], a
	push bc

	ld a, 7
	ld hl, W2_TileMapPalMap
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	call FillMemory

	pop af
	ldh [rSVBK], a
	ret

FarDrawTextPalBoxOnTileMapPalMap::
	ld b, a
DrawTextPalBoxOnTileMapPalMap::
	ldh a, [rSVBK]
	ld h, a
	ld a, 2
	ldh [rSVBK], a
	push hl

	ld hl, W2_TileMapPalMap-wTileMap
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
	ldh [rSVBK], a
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
	ldh [rSVBK], a	
	call CopyData
	xor a
	ldh [rSVBK], a
	ret
