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

CopyVideoDataVDMA::
	ldh a, [hAutoBGTransferEnabled]
	push af
	xor a
	ldh [hAutoBGTransferEnabled], a

	call CopyVideoDataVDMA_BgTransfer

	pop af
	ldh [hAutoBGTransferEnabled], a
	ret


CopyVideoDataVDMA_BgTransfer::
; Copy c tiles from b:de to hl from a .2bpp assets aligned on a $XXX0 address
	ldh a, [hLoadedROMBank]
	ldh [hROMBankTemp], a
	setrombank b

	dec c

	di 

	ld a, d
	ldh [rVDMA_SRC_HIGH], a
	ld a, e
	ldh [rVDMA_SRC_LOW], a
	ld a, h
	ldh [rVDMA_DEST_HIGH], a
	ld a, l
	ldh [rVDMA_DEST_LOW], a

	ldh a, [rLCDC]
	bit B_LCDC_ENABLE, a ; is the LCD enabled?
	jr nz, .doHDMA ; do HDMA if LCD enabled

; do GDMA
	ld a, c
	ldh [rVDMA_LEN], a
	ei
	jr .done

.doHDMA
	ldh a, [rSTAT]
	push af
	ld a, STAT_MODE_0 ; disable all STAT interrupt except hblank
	ldh [rSTAT], a

	push hl
	push bc

	set B_VDMA_LEN_MODE, c ; set HDMA mode
	ld hl, rVDMA_LEN
	ld b, $7f

.hblankInProgress
	ldh a, [rSTAT]
	and STAT_MODE
	jr z, .hblankInProgress ; if PPU Mode 0 (hblank) wait for it to finish

	ld [hl], c

	ei
.halt
	halt
	ld a, [hl]
	inc a ; no DMA in progress = $FF
	jr nz, .halt ; wait for HDMA to finish

	pop bc
	pop hl
	pop af
	ldh [rSTAT], a

.done
	inc c

	ldh a, [hROMBankTemp]
	setrombank
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

;.loop
;	ld a, c
;	cp 12 + 1
;	jr nc, .keepgoing
;
;.done
;	ldh [hVBlankCopySize], a
;	call DelayFrame
;	ldh a, [hROMBankTemp]
;	ldh [hLoadedROMBank], a
;	ld [rROMB], a
;	pop af
;	ldh [hAutoBGTransferEnabled], a
;	ret
;
;.keepgoing
;	ld a, 12
;	ldh [hVBlankCopySize], a
;	call DelayFrame
;	ld a, c
;	sub 12
;	ld c, a
;	jr .loop

	ld a, c
.continueTransfer
	sub 12
	ld c, 0
	jr c, .lastTransfer
	ld c, a
	xor a
.lastTransfer
	add 12
	ldh [hVBlankCopySize], a
	call DelayFrame
	ld a, c
	and a
	jr nz, .continueTransfer

	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	pop af
	ldh [hAutoBGTransferEnabled], a
	ret

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
	ld a, ' '

ClearScreenAreaWithA::
; optimisation by PokefanMarcel from the Pret Discord
	ld d, a
	ld a, SCREEN_WIDTH
	sub c
	ld e, a    ; e = SCREEN_WIDTH - c
	ld a, d
.loopRows
	ld d, c
.loopTiles
	ld [hli], a
	dec d
	jr nz, .loopTiles
	add hl, de ; d = 0
	dec b
	jr nz, .loopRows
	ret

;	ld de, SCREEN_WIDTH
;.loopRows
;	push hl
;	push bc
;.loopTiles
;	ld [hli], a
;	dec c
;	jr nz, .loopTiles
;	pop bc
;	pop hl
;	add hl, de
;	dec b
;	jr nz, .loopRows
;	ret

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

	ld c, SCREEN_HEIGHT / 3

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
	call ClearScreen_NoDelay
	jp Delay3

ClearScreenPal0::
	ld d, 0
	call ClearScreen_NoDelay
	jp Delay3

ClearScreenPalD::
	call ClearnScreenWithPalD_NoDelay
	jp Delay3

ClearScreenPal0_NoDelay::
	ld d, 0
	jr ClearnScreenWithPalD_NoDelay

ClearScreen_NoDelay::
	ld d, 7
	; fallthrough

ClearnScreenWithPalD_NoDelay::
; Clear wTileMap, then wait
; for the bg map to update.
	ldh a, [rWBK]
	push af
	ld a, 2
	ldh [rWBK], a
	push de ; save palette value

	hlcoord 0, 0
	ld a, ' '
	ld bc, SCREEN_AREA
	push bc
	call FillMemory
	pop bc

	pop af ; retrieve palette value in a
	hlcoord 0, 0, W2_TileMapPalMap
	call FillMemory

	pop af
	ldh [rWBK], a

	ret

GoodCopyVideoData::
	call CopyVideoDataToFarCopyData2
	jp nz, CopyVideoData ; if LCD is on, transfer during V-blank
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
