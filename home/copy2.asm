FarCopyData2::
; Identical to FarCopyData, but uses hROMBankTemp
; as temp space instead of wBuffer.
	ldh [hROMBankTemp], a
	ldh a, [hLoadedROMBank]
	push af
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call CopyData
	pop af
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	ret

FarCopyData3::
; Copy bc bytes from a:de to hl.
	ldh [hROMBankTemp], a
	ldh a, [hLoadedROMBank]
	push af
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	push hl
	push de
	push de
	ld d, h
	ld e, l
	pop hl
	call CopyData
	pop de
	pop hl
	pop af
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	ret

FarCopyDataDouble::
; Expand bc bytes of 1bpp image data
; from a:hl to 2bpp data at de.
	ldh [hROMBankTemp], a
	ldh a, [hLoadedROMBank]
	push af
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
.loop
	ld a, [hli]
	ld [de], a
	inc de
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	pop af
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	ret

CopyVideoDataHDMA::
	ldh a, [rVDMA_LEN]
	inc a
	jr nz, CopyVideoDataHDMA ; wait for an already in progress HDMA to finish

	ldh a, [hAutoBGTransferEnabled]
	push af
	xor a ; disable auto-transfer while copying
	ldh [hAutoBGTransferEnabled], a

	ldh a, [hLoadedROMBank]
	ldh [hROMBankTemp], a
	setrombank b

.wait
	ldh a, [rLY]
	cp 142
	jr nc, .wait ; wait if potentially not enought time to start the HDMA

	ldh a, [rSTAT]
	push af
	ld a, B_STAT_MODE_0 ; disable all LCD interrupt except hblank
	ldh [rSTAT], a	

	dec c
	set B_VDMA_LEN_MODE, c

	ld a, d
	ldh [rVDMA_SRC_HIGH], a
	ld a, e
	ldh [rVDMA_SRC_LOW], a
	ld a, h
	ldh [rVDMA_DEST_HIGH], a
	ld a, l
	ldh [rVDMA_DEST_LOW], a

.hblankInProgress
	ldh a, [rSTAT]
	and STAT_MODE
	jr z, .hblankInProgress ; if PPU Mode 0 (hblank) wait for it to finish

	ld a, c
	ldh [rVDMA_LEN], a
.halt
	halt
	ldh a, [rVDMA_LEN]
	inc a ; no DMA in progress = $FF
	jr nz, .halt ; wait for HDMA to finish

	pop af
	ldh [rSTAT], a

	ldh a, [hROMBankTemp]
	setrombank
	pop af
	ldh [hAutoBGTransferEnabled], a
	ret

CopyVideoData::
; Wait for the next VBlank, then copy c 2bpp
; tiles from b:de to hl, 12 tiles at a time.
; This takes c/12 frames.
; de = graphic to use
; hl = where in vram
; b = wich bank the graphic is in
; c = how many tile to copy from the source graphic
; see exemple : LoadPartyPokeballGfx
	ldh a, [hAutoBGTransferEnabled]
	push af

	inc a
	jr z, .dontDisable

	xor a ; disable auto-transfer while copying
	ldh [hAutoBGTransferEnabled], a

.dontDisable

	ldh a, [hLoadedROMBank]
	ldh [hROMBankTemp], a

	ld a, b
	ldh [hLoadedROMBank], a
	ld [rROMB], a

	ld a, e
	ldh [hVBlankCopySource], a
	ld a, d
	ldh [hVBlankCopySource + 1], a

	ld a, l
	ldh [hVBlankCopyDest], a
	ld a, h
	ldh [hVBlankCopyDest + 1], a

.loop
	ld a, c
	cp 12 + 1
	jr nc, .keepgoing

.done
	ldh [hVBlankCopySize], a
	call DelayFrame
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	pop af
	ldh [hAutoBGTransferEnabled], a
	ret

.keepgoing
	ld a, 12
	ldh [hVBlankCopySize], a
	call DelayFrame
	ld a, c
	sub 12
	ld c, a
	jr .loop

CopyVideoDataDouble::
; Wait for the next VBlank, then copy c 1bpp
; tiles from b:de to hl, 12 tiles at a time.
; This takes c/12 frames.
	ldh a, [hAutoBGTransferEnabled]
	push af

	inc a
	jr z, .dontDisable

	xor a ; disable auto-transfer while copying
	ldh [hAutoBGTransferEnabled], a

.dontDisable

	ldh a, [hLoadedROMBank]
	ldh [hROMBankTemp], a

	ld a, b
	ldh [hLoadedROMBank], a
	ld [rROMB], a

	ld a, e
	ldh [hVBlankCopyDoubleSource], a
	ld a, d
	ldh [hVBlankCopyDoubleSource + 1], a

	ld a, l
	ldh [hVBlankCopyDoubleDest], a
	ld a, h
	ldh [hVBlankCopyDoubleDest + 1], a

.loop
	ld a, c
	cp 12 + 1
	jr nc, .keepgoing

.done
	ldh [hVBlankCopyDoubleSize], a
	call DelayFrame
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	pop af
	ldh [hAutoBGTransferEnabled], a
	ret

.keepgoing
	ld a, 12
	ldh [hVBlankCopyDoubleSize], a
	call DelayFrame
	ld a, c
	sub 12
	ld c, a
	jr .loop

ClearScreenArea::
; Clear tilemap area cxb at hl.
	ld a, " " ; blank tile
	ld de, 20 ; screen width
.y
	push hl
	push bc
.x
	ld [hli], a
	dec c
	jr nz, .x
	pop bc
	pop hl
	add hl, de
	dec b
	jr nz, .y
	ret

CopyScreenTileBufferToVRAM::
; Copy wTileMap to the BG Map starting at b * $100.
; This is done in thirds of 6 rows, so it takes 3 frames.

	ldh a, [hWUp]
	and a
	jr z, .wUPDone
	xor a
	ldh [hWUp], a
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
.wUPDone

	ld c, 6

	hlbgcoord 0, 0, $0
	decoord 0, 6 * 0
	call .setup

	hlbgcoord 0, 6, $0
	decoord 0, 6 * 1
	call .setup

	hlbgcoord 0, 12, $0
	decoord 0, 6 * 2

.setup
	ld a, d
	ldh [hVBlankCopyBGSource+1], a
;	call GetRowColAddressBgMap
	ld a, l
	ldh [hVBlankCopyBGDest], a
	ld a, h
	add b
	ldh [hVBlankCopyBGDest+1], a
	ld a, c
	ldh [hVBlankCopyBGNumRows], a
	ld a, e
	ldh [hVBlankCopyBGSource], a

	ld hl, W2_TileMapPalMap - wTileMap
	add hl, de

	ld a, 2
	ldh [rWBK], a
	ld a, h
	ld [W2_VBlankCopyBGSource+1], a
	ld a, l
	ld [W2_VBlankCopyBGSource], a
	xor a
	ldh [rWBK], a

	jp DelayFrame

ClearScreen::
; Clear wTileMap, then wait
; for the bg map to update.
	ldh a, [rWBK]
	ld b, a
	ld a, 2
	ldh [rWBK], a
	push bc

	hlcoord 0, 0
	ld a, " "
	ld bc, SCREEN_WIDTH * SCREEN_HEIGHT
	push bc
	call FillMemory
	pop bc
	hlcoord 0, 0, W2_TileMapPalMap
	ld a, 7
	call FillMemory

	pop af
	ldh [rWBK], a

	jp Delay3

GoodCopyVideoData::
	call CopyVideoDataToFarCopyData2
	jp nz, CopyVideoData ; if LCD is on, transfer during V-blank
	jp FarCopyData2 ; if LCD is off, transfer all at once

GoodCopyVideoDataHDMA::
	call CopyVideoDataToFarCopyData2
	jp nz, CopyVideoDataHDMA
	jp FarCopyData2 ; if LCD is off, transfer all at once

CopyVideoDataToFarCopyData2:
	ldh a, [rLCDC]
	bit B_LCDC_ENABLE, a ; is the LCD enabled?
	ret nz
	ld a, b
	push de
	ld d, h
	ld e, l
	ld h, 0
	ld l, c
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld b, h
	ld c, l
	pop hl
	ret
