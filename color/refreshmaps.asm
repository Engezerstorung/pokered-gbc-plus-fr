; Most of the functions here are called during vblank, maybe they belong in vblank.asm...


; Called when a map is loaded. Loads tilemap and tile attributes.
; LCD is disabled, so we have free reign over vram.
LoadMapVramAndColors::
	ld a, $02
	ldh [rWBK], a

	hlcoord 0, 0
	ld de, vBGMap0
	ld b, SCREEN_HEIGHT
.vramCopyLoop
	ld c, SCREEN_WIDTH / 2
.vramCopyInnerLoop
	push bc

	ld a, [hli]
	ld [de], a

	push hl
	ld a, 1
	ldh [rVBK], a
	ld bc, W2_TileMapPalMap - (wTileMap + 1)
	add hl, bc

	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a

	xor a
	ldh [rVBK], a
	pop hl

	ld a, [hli]
	ld [de], a
	inc e

	pop bc
	dec c
	jr nz, .vramCopyInnerLoop

	ld a, e
	add TILEMAP_WIDTH - SCREEN_WIDTH
	ld e, a
	adc d
	sub e
	ld d, a

	dec b
	jr nz, .vramCopyLoop

	xor a
	ldh [rWBK], a
	ret

; Refresh 1/3 of the window each frame. Called during vblank.
RefreshWindow::
	ld a, 2
	ldh [rWBK], a

	; Check that the pre-vblank functions have run already (if not, let it catch up)
	ld hl, W2_UpdatedWindowPortion
	ld a, [hl]
	and a
	jp z, .palettesDone
	ld [hl], 0

	ld [hSPTemp], sp
	ld sp, hAutoBGTransferDest
	pop hl

	ldh a, [hAutoBGTransferPortion]
	and a
	jr z, .transferTopThird
	dec a
	jr z, .transferMiddleThird
.transferBottomThird
	coord sp, 0, 12
	ld de, (12 * 32)
	add hl, de
	xor a ; TRANSFERTOP
	jr .doTransfer
.transferTopThird
	coord sp, 0, 0
	inc a ; TRANSFERMIDDLE
	jr .doTransfer
.transferMiddleThird
	coord sp, 0, 6
	ld de, (6 * 32)
	add hl, de
	ld a, TRANSFERBOTTOM

; sp now points to map data in wram, hl points to vram destination.
.doTransfer
	ldh [hAutoBGTransferPortion], a ; store next portion
	ld b, SCREEN_HEIGHT / 3

.drawRow:
; unrolled loop and using pop for speed

REPT SCREEN_WIDTH / 2 - 1
	pop de
	ld [hl], e
	inc l
	ld [hl], d
	inc l
ENDR
	pop de
	ld [hl], e
	inc l
	ld [hl], d
	; Don't inc l this time.
	; Careful here, because credits break due to carry if you inc l and add a
	; with 12 instead of 13.

	ld de, 13
	add hl, de

	dec b
	jr nz, .drawRow

	; Set de to point to destination again and restore sp
	ld de, -$c0
	add hl, de
	ld d, h
	ld e, l

	ld sp, hSPTemp
	pop hl
	ld sp, hl

; BEGIN loading palette maps

	ld a, 1
	ldh [rVBK], a

	; Always update if using tile-based palettes
	ld a, [W2_TileBasedPalettes]
	and a
	jr nz, .continue

	; If using static palettes, we can check whether that's been updated
	ld a, [W2_StaticPaletteMapChanged_vbl]
	and a
	jr z, .palettesDone
	xor a
	ld [W2_StaticPaletteMapChanged_vbl], a

.continue

	; DMA from W2_ScreenPalettesBuffer to de (window attribute map)
	ld c, LOW(rVDMA_SRC_HIGH)
	ld a, HIGH(W2_ScreenPalettesBuffer)
	ldh [c], a
	inc c
	ld a, LOW(W2_ScreenPalettesBuffer)
	ldh [c], a
	inc c
	ld a, d
	ldh [c], a
	inc c
	ld a, e
	ldh [c], a
	inc c

	ld a, 6 * 32 / $10 - 1
	ldh [c], a ; Start DMA transfer

.palettesDone
	xor a
	ldh [rVBK], a
	ldh [rWBK], a

	ldh a, [hLoadedROMBank]
	jp SetRomBank


; Replaces the "TransferBgRows" function. Called when menus first appear on top of bg
; layer. (called 3 times to fully draw it)
; b = # rows to copy
; hl = destination ; hVBlankCopyBGDest
; sp = source (need to restore sp after this) ; hVBlankCopyBGSource
WindowTransferBgRowsAndColors::
	ld a, $02
	ldh [rWBK], a

	ld c, b

.drawTiles
REPT SCREEN_WIDTH / 2 - 1
	pop de
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
ENDR
	pop de
	ld a, e
	ld [hli], a
	ld [hl], d

	; Advance through "unused" tiles
	ld de, 13
	add hl, de

	dec b
	jp nz, .drawTiles

	ld a, 1
	ldh [rVBK], a

	ld sp, W2_VBlankCopyBGSource
	pop hl
	ld sp, hl

	ldh a, [hVBlankCopyBGDest]
	ld l, a
	ldh a, [hVBlankCopyBGDest+1]
	ld h, a

.drawPalettes
REPT SCREEN_WIDTH / 2 - 1
	pop de
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
ENDR
	pop de
	ld a, e
	ld [hli], a
	ld [hl], d

	; Advance through "unused" tiles
	ld de, 13
	add hl, de

	dec c
	jp nz, .drawPalettes
	
	xor a
	ldh [rVBK], a
	ldh [rWBK], a

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	; Restore ROM bank (we obviously can't do that here, so jump to bank 0)
	ldh a, [hLoadedROMBank]
	jp SetRomBank

_RedrawRowOrColumn::
	ldh a, [hRedrawRowOrColumnMode]
	dec a

	ld a, 2
	ldh [rWBK], a

	ld a, 1
	ld [W2_DrewRowOrColumn], a

	ld [hSPTemp], sp
	ld sp, hRedrawRowOrColumnDest
	pop hl
	ld sp, wRedrawRowOrColumnSrcTiles

	jp z, .redrawColumn
	; fallthrough

.redrawRow
; prepare the values needed to wrap around the horizontal edges on the second row if necessary
	ld a, l
	and %11100000 ; mask the BGMAP Y position bits of L and save them in b
	ld b, a
	ld c, %00011111 ; mask for the BGMAP X position bits of L

FOR _N, 1, 1+ 4
	; Draw tiles
	FOR _COL, 1, 1+ SCREEN_WIDTH / 2
		pop de
		ld a, e
		ld [hli], a
		ld [hl], d
		IF _COL < SCREEN_WIDTH / 2
		; the following 5 lines wrap us from the right edge to the left edge if necessary in the second row
			inc l
			ld a, l
			and c
			or b
			ld l, a
		ENDC
	ENDR
	IF _N & 1
		; to the destination next line
		ldh a, [hRedrawRowOrColumnDest]
		add TILEMAP_WIDTH
		ld l, a
		and %11100000
		ld b, a
	ELIF _N < 3
		ld a, 1
		ldh [rVBK], a
	; go back to the starting destination
		ldh a, [hRedrawRowOrColumnDest]
		ld l, a
		and %11100000
		ld b, a
		ld sp, W2_RedrawRowOrColumnSrcTiles
	ENDC
ENDR

	jp .done

.redrawColumn
	ld bc, TILEMAP_WIDTH - 1

FOR _N, 1, 1+ 2
	FOR _COL, 1, 1+ SCREEN_HEIGHT
		pop de
		ld a, e
		ld [hli], a
		ld [hl], d
		IF _COL < SCREEN_HEIGHT
			add hl, bc
		ENDC
		IF !(_COL & 1) && _COL < SCREEN_HEIGHT
		; the following 5 lines wrap us from bottom to top if necessary
		;	res 2, h ; this only work for vBGMap0
			ldh a, [hRedrawRowOrColumnDest + 1]
			xor h
			and ~$3
			xor h
			ld h, a
		ENDC
	ENDR
	IF _N < 2
		ld a, 1
		ldh [rVBK], a

		ld sp, hRedrawRowOrColumnDest
		pop hl
		ld sp, W2_RedrawRowOrColumnSrcTiles
	ENDC
ENDR

 .done
	ld sp, hSPTemp
	pop hl
	ld sp, hl

	xor a
	ldh [rVBK], a
	ldh [rWBK], a
	ldh [hRedrawRowOrColumnMode], a

	ldh a, [hLoadedROMBank]
	jp SetRomBank
