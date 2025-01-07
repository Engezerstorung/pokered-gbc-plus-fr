MakeTileMapAndPalMap::
	ld a, 2
	ldh [rSVBK], a

	di
	ld [hSPTemp], sp
	ld sp, hl

	hlcoord 0, 0

REPT SCREEN_HEIGHT
REPT SCREEN_WIDTH / 2
	pop de
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
ENDR
	add sp, 4
ENDR

	ld sp, wTileMap
	ld hl, W2_TileMapPalMap
	ld b, HIGH(W2_TilesetPaletteMap)

REPT (SCREEN_WIDTH * SCREEN_HEIGHT) / 2
	pop de
	ld c, e
;	res 7, e
	ld a, [bc]
	ld [hli], a

	ld c, d
;	res 7, d
	ld a, [bc]
	ld [hli], a
;	push de
;	add sp, 2
ENDR

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	ei

	xor a
	ldh [rSVBK], a

	ret

ClearTileMapPalMap::
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

ClearBGMap0_sVBK1::
	ld a, 1
	ldh [rVBK], a

	call ClearBGMap0
	
	xor a
	ldh [rVBK], a
	ret

ClearBGMap0::
	ld hl, vBGMap0
	ld bc, BG_MAP_WIDTH * BG_MAP_HEIGHT
	call FillMemory
	ret

FarUpdateTileMapPaletteMap::
	ld b, a
UpdateTileMapPaletteMap::
	ld h, d
	ld l, e

	ldh a, [rSVBK]
	ld d, a
	ld a, 2
	ldh [rSVBK], a
	push de

	ld de, W2_TileMapPalMap-wTileMap
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
	call CopyData_TileMap
_SaveScreenPalsToBuffer1::
	ld de, W2_TileMapPalMapBackup1
	jp Save_PalMap

_LoadScreenTilesFromBuffer1::
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld hl, wTileMapBackup
	decoord 0, 0
	call CopyData_TileMap
_LoadScreenPalsFromBuffer1_Common:
	ld hl, W2_TileMapPalMapBackup1
	call Load_PalMap
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	ret

_LoadScreenPalsFromBuffer1::
	xor a
	ldh [hAutoBGTransferEnabled], a
	jp _LoadScreenPalsFromBuffer1_Common

_SaveScreenTilesToBuffer2::
	hlcoord 0, 0
	ld de, wTileMapBackup2
	call CopyData_TileMap
_SaveScreenPalsToBuffer2::
	ld de, W2_TileMapPalMapBackup2
	jp Save_PalMap

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
	jp Load_PalMap

; loads screen palettes stored in W2_TileMapPalMapBackup2 but leaves hAutoBGTransferEnabled disabled
_LoadScreenPalsFromBuffer2DisableBGTransfer::
	xor a
	ldh [hAutoBGTransferEnabled], a
	jp _LoadScreenPalsFromBuffer2_Common

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
