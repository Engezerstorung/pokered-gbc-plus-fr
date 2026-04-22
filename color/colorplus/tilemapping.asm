GetScreenViewBlocksIDs::
	ld a, [wCurrentTileBlockMapViewPointer] ; address of upper left corner of current map view
	ld l, a
	ld a, [wCurrentTileBlockMapViewPointer + 1]
	ld h, a

	ld de, wBuffer
	ld a, [wCurMapWidth]
	ld c, a
	ld b, 0

FOR _ROW, 1, 1+ SCREEN_BLOCK_HEIGHT
	REPT SCREEN_BLOCK_WIDTH
		ld a, [hli]
		ld [de], a
		inc de
	ENDR
	IF _ROW < SCREEN_BLOCK_HEIGHT
		add hl, bc
	ENDC
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

FOR _ROW, 1, 1+ SCREEN_HEIGHT
REPT SCREEN_WIDTH / 2
	pop de
	ld a, e
;	or c
	ld [hli], a
	ld a, d
;	or c
	ld [hli], a
ENDR
IF _ROW < SCREEN_HEIGHT
	add sp, 4
ENDC
ENDR

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	xor a
	ldh [rWBK], a

	reti

UpdateRedrawPointer::
	ld hl, RedrawPointerFunctionsTable
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp hl

RedrawPointerFunctionsTable:
	dw GetNorthRowRedrawPointer
	dw GetSouthRowRedrawPointer
	dw GetWestColumnRedrawPointer
	dw GetEastColumnRedrawPointer

GetNorthRowRedrawPointer:
	ld b, REDRAW_ROW
	jr GetNorthOrWestRedrawPointer

GetWestColumnRedrawPointer:
	ld b, REDRAW_COL
	; fallthrough

GetNorthOrWestRedrawPointer:
	ld a, [wMapViewVRAMPointer]
	ldh [hRedrawRowOrColumnDest], a
	ld a, [wMapViewVRAMPointer + 1]
	ldh [hRedrawRowOrColumnDest + 1], a
	ld a, b
	ldh [hRedrawRowOrColumnMode], a
	ret

GetSouthRowRedrawPointer:
	ld a, [wMapViewVRAMPointer]
	ldh [hRedrawRowOrColumnDest], a
	ld a, [wMapViewVRAMPointer + 1]
	add HIGH($200)
	and $03
	or $98
	ldh [hRedrawRowOrColumnDest + 1], a
	ld a, REDRAW_ROW
	ldh [hRedrawRowOrColumnMode], a
	ret

GetEastColumnRedrawPointer:
	ld a, [wMapViewVRAMPointer]
	ld c, a
	and $e0
	ld b, a
	ld a, c
	add 18
	and $1f
	or b
	ldh [hRedrawRowOrColumnDest], a
	ld a, [wMapViewVRAMPointer + 1]
	ldh [hRedrawRowOrColumnDest + 1], a
	ld a, REDRAW_COL
	ldh [hRedrawRowOrColumnMode], a
	ret	

_ScheduleNorthRowRedraw::
	hlcoord 0, 0
	call _CopyToRedrawRowOrColumnSrcTiles
	jr GetNorthRowRedrawPointer

_ScheduleSouthRowRedraw::
	hlcoord 0, 16
	call _CopyToRedrawRowOrColumnSrcTiles
	jr GetSouthRowRedrawPointer
	
_ScheduleWestColumnRedraw::
	hlcoord 0, 0
	call _ScheduleColumnRedrawHelper
	jr GetWestColumnRedrawPointer

_ScheduleEastColumnRedraw::
	hlcoord 18, 0
	call _ScheduleColumnRedrawHelper
	jr GetEastColumnRedrawPointer


_CopyToRedrawRowOrColumnSrcTiles::
	ld a, 2
	ldh [rWBK], a

	push hl
	ld de, wRedrawRowOrColumnSrcTiles

FOR _NREPT, 1, 1 + 2 * SCREEN_WIDTH
	ld a, [hli]
	ld [de], a
	IF _NREPT < 2 * SCREEN_WIDTH
		inc de
	ENDC
ENDR

	pop hl
	ld de, W2_TileMapPalMap - wTileMap
	add hl, de
	ld de, W2_RedrawRowOrColumnSrcTiles

FOR _NREPT, 1, 1 + 2 * SCREEN_WIDTH
	ld a, [hli]
	ld [de], a
	IF _NREPT < 2 * SCREEN_WIDTH
		inc de
	ENDC
ENDR

	xor a
	ldh [rWBK], a
	ret

_ScheduleColumnRedrawHelper::
	ld a, 2
	ldh [rWBK], a

	ld bc, SCREEN_WIDTH - 1

	ld de, wRedrawRowOrColumnSrcTiles
	push hl

FOR _ROW, 1, 1+ SCREEN_HEIGHT
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	IF _ROW < SCREEN_HEIGHT
	inc de
	add hl, bc
	ENDC
ENDR

	pop hl
	ld de, W2_TileMapPalMap - wTileMap
	add hl, de
	ld de, W2_RedrawRowOrColumnSrcTiles

FOR _ROW, 1, 1+ SCREEN_HEIGHT
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	IF _ROW < SCREEN_HEIGHT
	inc de
	add hl, bc
	ENDC
ENDR

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

	ld a, SCREEN_WIDTH
	sub c
	ld e, a
	ld d, 0
	ld a, 7
.rowLoop
	push bc
.colLoop
	ld [hli], a
	dec c
	jr nz, .colLoop
	add hl, de
	pop bc
	dec b
	jr nz, .rowLoop

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

_UpdateMapView::
	ld a, [wSpritePlayerStateData1YStepVector]
	and a
	jp nz, .verticalShift
	ld a, [wSpritePlayerStateData1XStepVector]
	and a
	ret z

	dec a
	ld a, 2
	ldh [rWBK], a
	jp z, .shiftLeft

; shifting maps right
	ld de, wTileMap + 20 * 18 - 3
	ld hl, wTileMap + 20 * 18 - 1
	ld c, 2
.nextShiftRight
FOR _ROW, 1, 1+ 18
	FOR _COL, 1, 1+ 20 - 2
		ld a, [de]
		ld [hld], a
		IF _ROW < 18 || _COL < 20 - 2
			dec de
		ENDC
	ENDR
	IF _ROW < 18
		dec hl
		dec hl
		dec de
		dec de
	ENDC
ENDR
	dec c
	jp z, .doneShifting
	ld de, W2_TileMapPalMap + 20 * 18 - 3
	ld hl, W2_TileMapPalMap + 20 * 18 - 1
	jp .nextShiftRight

.shiftLeft
; shifting maps left
	di
	ld [hSPTemp], sp

	ld sp, wTileMap + 2
	ld hl, sp - 2
	ld c, 2
.nextShiftLeft
FOR _ROW, 1, 1+ 18
	FOR _COL, 1, 1+ 20 / 2 - 1
		pop de
		ld a, e
		ld [hli], a
		IF _ROW < 18 || _COL < 20 / 2 - 1 
			ld a, d
			ld [hli], a
		ELSE
			ld [hl], d
		ENDC
	ENDR
	IF _ROW < 18
		pop de
		inc hl
		inc hl
	ENDC
ENDR
	dec c
	jp z, .doneShiftingWithSP
	ld sp, W2_TileMapPalMap + 2
	ld hl, sp - 2
	jp .nextShiftLeft

.verticalShift
	dec a
	ld a, 2
	ldh [rWBK], a
	jp z, .shiftUp

; shifting map down
	ld de, wTileMap + 20 * 18 - 41
	ld hl, wTileMap + 20 * 18 - 1
	ld c, 2
.nextShiftDown
FOR _MAP, 1, 1+ 20 * (18 - 2)
	ld a, [de]
	ld [hld], a
	IF _MAP < 20 * (18 - 2)
		dec de
	ENDC
ENDR
	dec c
	jp z, .doneShifting
	ld de, W2_TileMapPalMap + 20 * 18 - 41
	ld hl, W2_TileMapPalMap + 20 * 18 - 1
	jp .nextShiftDown

.shiftUp
; shifting map up
	di
	ld [hSPTemp], sp

	ld sp, wTileMap + 40
	ld hl, sp - 40
	ld c, 2
	jr .startShiftUp
.nextShiftUp
	ld sp, W2_TileMapPalMap + 40
	ld hl, sp - 40
.startShiftUp
FOR _MAP, 1, 1+ 20 * (18 - 2) / 2
	pop de
	ld a, e
	ld [hli], a
	IF _MAP < 20 * (18 - 2) / 2
		ld a, d
		ld [hli], a
	ELSE
		ld [hl], d
	ENDC
ENDR
	dec c
	jp nz, .nextShiftUp

.doneShiftingWithSP
	ld sp, hSPTemp
	pop hl
	ld sp, hl
	ei
.doneShifting

	xor a
	ldh [rWBK], a

	ld a, [wCurrentTileBlockMapViewPointer] ; address of upper left corner of current map view
	ld l, a
	ld a, [wCurrentTileBlockMapViewPointer + 1]
	ld h, a

	ld a, [wCurMapWidth]
	add 6
	ld c, a
	adc 0
	sub c
	ld b, a ; bc : map width with surrouding padding

	ld a, [wSpritePlayerStateData1XStepVector]
	and a
	jp z, .yVector

	ld de, 0
	inc a
	jr z, .gotXAddressOffset
	ld a, [wXBlockCoord]
	add 4
	ld e, a
.gotXAddressOffset
	add hl, de

	ld de, wBuffer
FOR _N, 1, 1+ SCREEN_BLOCK_HEIGHT
	ld a, [hl]
	ld [de], a
	IF _N < SCREEN_BLOCK_HEIGHT
		inc de
		add hl, bc
	ENDC
ENDR

	lb bc, 5, 1
	ld hl, wTilesetBlocksPtr
	call LoadBlocksTileData

	ld hl, wTileMapBackup
	ld a, [wYBlockCoord]
	and a
	jr z, .gotYBlockCoord
	ld hl, wTileMapBackup + SURROUNDING_WIDTH * 2
.gotYBlockCoord
	ld a, [wSpritePlayerStateData1XStepVector]
	inc a
	decoord 0, 0
	ld a, [wXBlockCoord]
	jr z, .gotMapXCoord
	decoord 18, 0
	xor 1
.gotMapXCoord
	and a
	jr z, .gotBlockXcoord
	inc hl
	inc hl
.gotBlockXcoord
	push hl
	push de

FOR _MAP, 1, 1+ 2
	IF _MAP < 2
		ld bc, wRedrawRowOrColumnSrcTiles
	ELSE 
		lb bc, 5, 1
		ld hl, wTilesetAttributesPtr
		call LoadBlocksTileData

		ld a, 2
		ldh [rWBK], a

		pop de
		ld hl, W2_TileMapPalMap - wTileMap
		add hl, de
		ld d, h
		ld e, l
		pop hl

		ld bc, W2_RedrawRowOrColumnSrcTiles
	ENDC

	di
	ld [hSPTemp], sp
	ld sp, hl
	ld h, d
	ld l, e

	FOR _ROW, 1, 1+ 18
		pop de
		ld a, e
	;	IF _MAP > 1
	;		or BG_BANK1
	;	ENDC
		ld [hli], a
		ld [bc], a
		inc bc
		ld a, d
	;	IF _MAP > 1
	;		or BG_BANK1
	;	ENDC
		ld [hli], a
		ld [bc], a
		IF _ROW < 18
			inc bc
			ld de, 20 - 2
			add hl, de
			add sp, 24 - 2
		ENDC
	ENDR

	ld sp, hSPTemp
	pop hl
	ld sp, hl
	ei
ENDR

	xor a
	ldh [rWBK], a

	ret

.yVector
	ld a, [wSpritePlayerStateData1YStepVector]
	push hl

	ld hl, 0
	inc a
	jr z, .gotYAddressOffset
	add hl, bc
	add hl, hl
	add hl, hl
.gotYAddressOffset
	pop de
	add hl, de

	ld de, wBuffer
FOR _N, 1, 1+ SCREEN_BLOCK_WIDTH
	ld a, [hli]
	ld [de], a
	IF _N < SCREEN_BLOCK_WIDTH
		inc de
	ENDC
ENDR

	lb bc, 1, 6
	ld hl, wTilesetBlocksPtr
	call LoadBlocksTileData

	ld a, [wSpritePlayerStateData1YStepVector]
	inc a
	decoord 0, 0
	jr z, .gotMapYCoord
	decoord 0, 16 ; south
.gotMapYCoord

	ld hl, wTileMapBackup
	ld a, [wYBlockCoord]
	and a
	jr z, .gotYBlockCoord2
	ld hl, wTileMapBackup + SURROUNDING_WIDTH * 2
.gotYBlockCoord2
	ld a, [wXBlockCoord]
	and a
	jr z, .gotBlockXcoord2
	inc hl
	inc hl
.gotBlockXcoord2
	push hl
	push de

FOR _MAP, 1, 1+ 2
	IF _MAP < 2
		ld bc, wRedrawRowOrColumnSrcTiles
	ELSE
		lb bc, 1, 6
		ld hl, wTilesetAttributesPtr
		call LoadBlocksTileData

		ld a, 2
		ldh [rWBK], a

		pop de
		ld hl, W2_TileMapPalMap - wTileMap
		add hl, de
		ld d, h
		ld e, l
		pop hl

		ld bc, W2_RedrawRowOrColumnSrcTiles
	ENDC

	di
	ld [hSPTemp], sp
	ld sp, hl
	ld h, d
	ld l, e
	FOR _ROW, 1, 1+ 2
		FOR _TILE_DUO, 1, 1+ 20 / 2
			pop de
			ld a, e
		;	IF _MAP > 1
		;		or BG_BANK1
		;	ENDC
			ld [hli], a
			ld [bc], a
			inc bc
			ld a, d
		;	IF _MAP > 1
		;		or BG_BANK1
		;	ENDC
			ld [hli], a
			ld [bc], a
			IF _ROW < 2 || _TILE_DUO < 20 / 2
				inc bc
			ENDC
		ENDR
		IF _ROW < 2
			add sp, 4
		ENDC
	ENDR
	ld sp, hSPTemp
	pop hl
	ld sp, hl
	ei
ENDR

	xor a
	ldh [rWBK], a

	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; KEPT FOR ARCHIVE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;MACRO copytileblock
;	ld d, h
;	ld e, l
;	ld sp, wBufferPtr
;	pop hl
;	ld a, [hli]
;	push hl
;
;;	If the current map block is a border block, load the border block data.
;;	and a
;;	jr nz, .ok
;;	ld a, [wMapBorderBlock]
;;.ok
;	; Set de to the address of the current block tile data ([wTilesetBlocksPtr] or [wTilesetAttributesPtr] + (a) tiles).
;	ld l, a
;	ld h, b
;REPT \1
;	add hl, hl
;ENDR
;	ld sp, $d000
;	add hl, sp
;	ld sp, hl
;	ld h, d
;	ld l, e
;
;	; copy the \1 * \1 block data
;FOR _NROW, 1, 1 + \1 
;REPT \1 / 2 - 1
;	pop de
;	ld a, e
;	ld [hli], a
;	ld a, d
;	ld [hli], a
;ENDR
;	pop de
;	ld a, e
;	ld [hli], a
;	ld [hl], d
;IF _NROW < \1
;	add hl, bc
;ENDC
;ENDR
;ENDM
;
;MACRO loadblocksdata
;	ld a, \1
;	ldh [rWBK], a
;
;	ld sp, wBuffer
;	ld [wBufferPtr], sp
;
;	ld hl, wTileMapBackup
;	ld bc, (SCREEN_BLOCK_WIDTH * \2) - (\2 - 1) ; 24 - 3
;REPT SCREEN_BLOCK_HEIGHT
;REPT SCREEN_BLOCK_WIDTH - 1
;	copytileblock \2
;	ld de, -((SCREEN_BLOCK_WIDTH * \2) * (\2 - 1)) + 1 ; -(6*4)*(4-1) + 1 ; go back to the destination adress for the next block data
;	add hl, de
;ENDR
;	copytileblock \2
;	inc hl
;ENDR
;	xor a
;	ldh [rWBK], a
;ENDM
;
;MACRO getscreenviewblocksids
;	ld a, [wCurMapWidth]
;	ld l, a
;	ld h, 0
;
;	cpl
;	ld c, a ; bc = -(wCurMapWidth + 1)
;	ld b, $FF 
;
;	ld de, (MAP_BORDER * 2) * (SCREEN_BLOCK_HEIGHT - 1) + (SCREEN_BLOCK_WIDTH - 1)
;
;	add hl, hl
;	add hl, hl
;	add hl, de
;	ld sp, wCurrentTileBlockMapViewPointer
;	pop de
;	add hl, de ; hl : bottom right block of the TileBlockMapView
;
;	ld sp, wBuffer + SCREEN_BLOCK_WIDTH * SCREEN_BLOCK_HEIGHT
;
;FOR _NROW, 1, 1 + SCREEN_BLOCK_HEIGHT
;FOR _NCOL, 1, 1 + SCREEN_BLOCK_WIDTH / 2
;	ld a, [hld]
;	ld d, a
;IF _NCOL < SCREEN_BLOCK_WIDTH / 2
;	ld a, [hld]
;	ld e, a
;ELSE
;	ld e, [hl]
;ENDC
;	push de
;ENDR
;IF _NROW < SCREEN_BLOCK_HEIGHT
;	add hl, bc
;ENDC
;ENDR
;ENDM
;MACRO getscreenviewblocksids
;	ld sp, wCurrentTileBlockMapViewPointer
;	pop hl
;
;	ld de, wBuffer
;	ld a, [wCurMapWidth]
;	ld c, a
;	ld b, 0
;
;FOR _NROW, 1, 1 + SCREEN_BLOCK_HEIGHT
;FOR _NCOL, 1, 1 + SCREEN_BLOCK_WIDTH
;	ld a, [hli]
;	ld [de], a
;IF _NROW < SCREEN_BLOCK_HEIGHT || _NCOL < SCREEN_BLOCK_WIDTH
;	inc de
;ENDC
;ENDR
;IF _NROW < SCREEN_BLOCK_HEIGHT
;	add hl, bc
;ENDC
;ENDR
;ENDM
;
;MACRO maketilemaporpalmap
;	ld sp, hl
;	hlcoord 0,0,\#
;	IF _NARG > 0
;		ld b, BG_BANK1
;	ENDC
;;REPT SCREEN_HEIGHT - 1
;FOR _NROW, 1, 1 + SCREEN_HEIGHT
;REPT SCREEN_WIDTH / 2
;	pop de
;	ld a, e
;	IF _NARG > 0
;		or b
;	ENDC
;	ld [hli], a
;	ld a, d
;	IF _NARG > 0
;		or b
;	ENDC
;	ld [hli], a
;ENDR
;IF _NROW < SCREEN_HEIGHT
;	add sp, 4
;ENDC
;ENDR
;ENDM
;
;_LoadCurrentMapView::
;	di
;	ld [hSPTemp], sp
;
;	getscreenviewblocksids
;
;	loadblocksdata 3, BLOCK_WIDTH
;
;	ld sp, hSPTemp
;	pop hl
;	ld sp, hl
;
;;	ld hl, wTileMapBackup
;;.adjustForYCoordWithinTileBlock
;;	ld a, [wYBlockCoord]
;;	and a
;;	jr z, .adjustForXCoordWithinTileBlock
;;	ld hl, wTileMapBackup + SURROUNDING_WIDTH * 2
;;.adjustForXCoordWithinTileBlock
;;	ld a, [wXBlockCoord]
;;	and a
;;	jr z, .copyToVisibleAreaBuffer
;;	inc hl
;;	inc hl
;;.copyToVisibleAreaBuffer
;;	push hl
;	ld hl, wYBlockCoord
;	ld a, [hli]
;	swap a ; if [wYBlockCoord] = 1 : a = %0001_0000
;	ld c, a
;	rra ; if [wYBlockCoord] = 1 : a = %0000_1000
;	or c ; %0000_1000 | %0001_0000 = 24 = SURROUNDING_WIDTH if [wYBlockCoord] was 1
;	add [hl] ; a + wXBlockCoord, a = %00000000 or %00000001 or %00011000 or %00011001
;	add a ; x2 value, now have surrounding view tilemap offset
;	add LOW(wTileMapBackup)
;	ld l, a
;	adc HIGH(wTileMapBackup)
;	sub l
;	ld h, a
;	push hl
;
;	ld [hSPTemp], sp
;
;	maketilemaporpalmap
;
;	loadblocksdata 4, BLOCK_WIDTH
;
;	ld sp, hSPTemp
;	pop hl
;	ld sp, hl
;
;	pop hl
;
;	ld [hSPTemp], sp
;
;	ld a, 2
;	ldh [rWBK], a
;	maketilemaporpalmap W2_TileMapPalMap
;	xor a
;	ldh [rWBK], a
;
;	ld sp, hSPTemp
;	pop hl
;	ld sp, hl
;
;	reti
