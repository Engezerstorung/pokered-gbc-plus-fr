FarCopyData2::
; Identical to FarCopyData, but uses hROMBankTemp
; as temp space instead of wBuffer.
	ldh [hROMBankTemp], a
	ldh a, [hLoadedROMBank]
	push af
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	call CopyData
	pop af
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	ret

FarCopyData3::
; Copy bc bytes from a:de to hl.
	ldh [hROMBankTemp], a
	ldh a, [hLoadedROMBank]
	push af
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
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
	ld [MBC1RomBank], a
	ret

FarCopyDataDouble::
; Expand bc bytes of 1bpp image data
; from a:hl to 2bpp data at de.
	ldh [hROMBankTemp], a
	ldh a, [hLoadedROMBank]
	push af
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
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
	ld [MBC1RomBank], a
	ret

;DoCopySpriteVideoData:
;	push hl
;	ld hl, wSpriteFlags
;	set 4, [hl]
;	pop hl
CopyVideoData::
; Wait for the next VBlank, then copy c 2bpp
; tiles from b:de to hl, 8 tiles at a time.
; This takes c/8 frames.
; de = graphic to use
; hl = where in vram
; b = wich bank the graphic is in
; c = how many tile to copy from the source graphic
; see exemple : LoadPartyPokeballGfx
	ldh a, [hAutoBGTransferEnabled]
	push af
	xor a ; disable auto-transfer while copying
	ldh [hAutoBGTransferEnabled], a

	ldh a, [hLoadedROMBank]
	ldh [hROMBankTemp], a

	ld a, b
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a

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
	cp 12
	jr nc, .keepgoing

.done
	ldh [hVBlankCopySize], a
	call DelayFrame
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	pop af
	ldh [hAutoBGTransferEnabled], a
	ret

.keepgoing
	ld a, 12
	ldh [hVBlankCopySize], a
;	call DelayFrame

.retry
	call DelayFrame
	ldh a, [hVBlankCopySize]
	and a
	jr nz, .retry

	ld a, c
	sub 12
	ld c, a
	jr .loop

CopyVideoDataDouble::
; Wait for the next VBlank, then copy c 1bpp
; tiles from b:de to hl, 8 tiles at a time.
; This takes c/8 frames.
	ldh a, [hAutoBGTransferEnabled]
	push af
	xor a ; disable auto-transfer while copying
	ldh [hAutoBGTransferEnabled], a
	ldh a, [hLoadedROMBank]
	ldh [hROMBankTemp], a

	ld a, b
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a

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
	cp 12
	jr nc, .keepgoing

.done
	ldh [hVBlankCopyDoubleSize], a
	call DelayFrame
	ldh a, [hROMBankTemp]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
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

	ld c, 6

	hlbgcoord 0, 0, $0
;	ld hl, $600 * 0
	decoord 0, 6 * 0
	call .setup
;	decoord 0, 6 * 0, W2_TileMapPalMap
;	call .setup2_DelayFrame

	hlbgcoord 0, 6, $0
;	ld hl, $600 * 1
	decoord 0, 6 * 1
	call .setup
;	decoord 0, 6 * 1, W2_TileMapPalMap
;	call .setup2_DelayFrame

	hlbgcoord 0, 12, $0
;	ld hl, $600 * 2
	decoord 0, 6 * 2
;	call .setup
;	decoord 0, 6 * 2, W2_TileMapPalMap
;	jp .setup2_DelayFrame

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
	ldh [rSVBK], a
	ld a, h
	ld [W2_VBlankCopyBGSource+1], a
	ld a, l
	ld [W2_VBlankCopyBGSource], a
	xor a
	ldh [rSVBK], a

	jp DelayFrame

;	ret

;.setup2_DelayFrame
;	ld a, 2
;	ldh [rSVBK], a
;	ld a, d
;	ld [W2_VBlankCopyBGSource+1], a
;	ld a, e
;	ld [W2_VBlankCopyBGSource], a
;	xor a
;	ldh [rSVBK], a
;	jp DelayFrame

ClearScreen::
; Clear wTileMap, then wait
; for the bg map to update.
	ldh a, [rSVBK]
	ld b, a
	ld a, 2
	ldh [rSVBK], a
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
	ldh [rSVBK], a

	jp Delay3

;	farcall FillTileMapPalMapWithTextPal
;
;	ld bc, 20 * 18
;;	inc b
;	hlcoord 0, 0
;	ld a, " "
;;.loop
;;	ld [hli], a
;;	dec c
;;	jr nz, .loop
;;	dec b
;;	jr nz, .loop
;	call FillMemory
;	jp Delay3

GoodCopyVideoData::
	call CopyVideoDataToFarCopyData2
	jp nz, CopyVideoData ; if LCD is on, transfer during V-blank
	jp FarCopyData2 ; if LCD is off, transfer all at once

CopyVideoDataToFarCopyData2:
	ldh a, [rLCDC]
	bit rLCDC_ENABLE, a ; is the LCD enabled?
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

;CopySpriteVideoData::
;	call CopyVideoDataToFarCopyData2
;;	jp nz, DoCopySpriteVideoData ; if LCD is on, transfer during V-blank
;
;	jp nz, CopyVideoData ; if LCD is on, transfer during V-blank
;
;;	jr z, FarCopySpriteData2 ; if LCD is off, transfer all at once
;	; fallthrough if LCD is off, transfer all at once
;FarCopySpriteData2:
;	push de
;	push af
;
;	push bc
;	call FarCopyData2
;	pop bc
;
;	ld a, c
;	cp 12 tiles
;	pop de ; pop af into de to preserve flags
;	ld a, d
;	pop de
;	ret c
;
;	set 3, d ; add $800 ($80 tiles) to de (1 << 3 == $8)
;	jp FarCopyData2
;