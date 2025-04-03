; Most of the functions here are called during vblank, maybe they belong in vblank.asm...


; Called when a map is loaded. Loads tilemap and tile attributes.
; LCD is disabled, so we have free reign over vram.
LoadMapVramAndColors::
	ld a, $02
	ldh [rSVBK], a

	hlcoord 0, 0
	ld de, vBGMap0
	ld b, SCREEN_HEIGHT
.vramCopyLoop
	ld c, SCREEN_WIDTH
.vramCopyInnerLoop
	ld a, $01
	ldh [rVBK], a
	ld a, [hl]
	push hl

	push bc
	ld bc, W2_TileMapPalMap - wTileMap
	add hl, bc
	pop bc

	ld a, [hl]
	ld [de], a
	pop hl
	xor a
	ldh [rVBK], a
	ld a, [hli]
	res 7, a
	ld [de], a
	inc e

	dec c
	jr nz, .vramCopyInnerLoop
	ld a, BG_MAP_WIDTH - SCREEN_WIDTH
	add e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	dec b
	jr nz, .vramCopyLoop

	xor a
	ldh [rSVBK], a
	ret



; Refresh 1/3 of the window each frame. Called during vblank.
RefreshWindow::
	ldh a, [hAutoBGTransferEnabled]
	and a
	ret z

	ld a, 2
	ldh [rSVBK], a

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
;	ld sp, hAutoBGTransferDest
;	pop hl
	coord sp, 0, 12
	ld de, (12 * 32)
	add hl, de
	xor a ; TRANSFERTOP
	jr .doTransfer
.transferTopThird
;	ld sp, hAutoBGTransferDest
;	pop hl
	coord sp, 0, 0
	ld a, TRANSFERMIDDLE
	jr .doTransfer
.transferMiddleThird
;	ld sp, hAutoBGTransferDest
;	pop hl
	coord sp, 0, 6
	ld de, (6 * 32)
	add hl, de
	ld a, TRANSFERBOTTOM

; sp now points to map data in wram, hl points to vram destination.
.doTransfer
	ldh [hAutoBGTransferPortion], a ; store next portion
	ld b, 6

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

;	ld a, 13
;	add l
;	ld l, a
;	jr nc, .noCarry
;	inc h
;.noCarry
	ld de, 13
	add hl, de

	dec b
	jr nz, .drawRow

	; Restore sp and set hl to point to destination again
	ld b, h
	ld c, l

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	ld h, b
	ld l, c
	ld bc, -$c0
	add hl, bc

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

	; DMA from W2_ScreenPalettesBuffer to hl (window attribute map)
	ld c, $51
	ld a, W2_ScreenPalettesBuffer >> 8
	ld [$ff00+c], a
	inc c
	ld a, W2_ScreenPalettesBuffer & $ff
	ld [$ff00+c], a
	inc c
	ld a, h
	ld [$ff00+c], a
	inc c
	ld a, l
	ld [$ff00+c], a
	inc c

	ld a, 6 * 32 / $10 - 1
	ld [$ff00+c], a ; Start DMA transfer

.palettesDone
	xor a
	ldh [rVBK], a
	ldh [rSVBK], a
	ret


; Replaces the "TransferBgRows" function. Called when menus first appear on top of bg
; layer. (called 3 times to fully draw it)
; b = # rows to copy
; hl = destination ; hVBlankCopyBGDest
; sp = source (need to restore sp after this) ; hVBlankCopyBGSource
WindowTransferBgRowsAndColors::
	; Store # of rows to ocpy
	ld a, $02
	ldh [rSVBK], a
	ld a, b
	ld [W2_VBCOPYBGNUMROWS], a

.drawTiles
REPT SCREEN_WIDTH / 2 - 1
	pop de
	res 7, d
	res 7, e
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
ENDR
	pop de
	res 7, d
	res 7, e
	ld a, e
	ld [hli], a
	ld [hl], d

	; Advance through "unused" tiles
	ld de, $0d
	add hl, de

	ld a, [W2_VBCOPYBGNUMROWS]
	dec a
	ld [W2_VBCOPYBGNUMROWS], a
	jp nz, .drawTiles

	ld a, b
	ld [W2_VBCOPYBGNUMROWS], a

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
	ld de, $0d
	add hl, de

	ld a, [W2_VBCOPYBGNUMROWS]
	dec a
	ld [W2_VBCOPYBGNUMROWS], a
	jp nz, .drawPalettes

	xor a
	ldh [rVBK], a
	ldh [rSVBK], a

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	; Restore ROM bank (we obviously can't do that here, so jump to bank 0)
	ldh a, [hLoadedROMBank]
	jp SetRomBank


; Called when scrolling the screen vertically (at vblank)
DrawMapRow::
	ld a, 2
	ldh [rSVBK], a

	ld a, 1
	ld [W2_DrewRowOrColumn], a

	ld hl, wRedrawRowOrColumnSrcTiles ; This is wram bank 0
	ldh a, [hRedrawRowOrColumnDest]
	ld e, a
	ldh a, [hRedrawRowOrColumnDest + 1]
	ld d, a
	push de
	push de

REPT SCREEN_WIDTH / 2
	ld a, [hli]
	res 7, a
	ld [de], a
	inc de
	ld a, [hli]
	res 7, a
	ld [de], a
	ld a, e
	inc a
; the following 6 lines wrap us from the right edge to the left edge if necessary
	and $1f
	ld b, a
	ld a, e
	and $e0
	or b
	ld e, a
ENDR

	pop de
	ld a, BG_MAP_WIDTH ; width of VRAM background map
	add e
	ld e, a

REPT SCREEN_WIDTH / 2
	ld a, [hli]
	res 7, a
	ld [de], a
	inc de
	ld a, [hli]
	res 7, a
	ld [de], a
	ld a, e
	inc a
; the following 6 lines wrap us from the right edge to the left edge if necessary
	and $1f
	ld b, a
	ld a, e
	and $e0
	or b
	ld e, a
ENDR

	; Start drawing palettes
	ld a, 1
	ldh [rVBK], a
	pop de
	ld hl, W2_RedrawRowOrColumnSrcTiles

	push de

REPT SCREEN_WIDTH / 2
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, e
	inc a
; the following 6 lines wrap us from the right edge to the left edge if necessary
	and $1f
	ld b, a
	ld a, e
	and $e0
	or b
	ld e, a
ENDR

	pop de
	ld a, BG_MAP_WIDTH ; width of VRAM background map
	add e
	ld e, a

REPT SCREEN_WIDTH / 2
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ld a, e
	inc a
; the following 6 lines wrap us from the right edge to the left edge if necessary
	and $1f
	ld b, a
	ld a, e
	and $e0
	or b
	ld e, a
ENDR

	xor a
	ldh [rSVBK], a
	ldh [rVBK], a
	ret

; Called when scrolling the screen horizontally (at vblank)
DrawMapColumn::
	ld a, 2
	ldh [rSVBK], a

	ld a, 1
	ld [W2_DrewRowOrColumn], a

	ld [hSPTemp], sp

	ld sp, hRedrawRowOrColumnDest
	pop hl
	ld sp, wRedrawRowOrColumnSrcTiles

; Draw tiles
REPT SCREEN_HEIGHT
	pop de
	res 7, d
	res 7, e
	ld a, e
	ld [hli], a
	ld [hl], d

	ld bc, BG_MAP_WIDTH - 1
	add hl, bc
; the following 4 lines wrap us from bottom to top if necessary
	ld a, h
	and $3
	or $98
	ld h, a
ENDR

	ld a, 1
	ldh [rVBK], a

	ld sp, hRedrawRowOrColumnDest
	pop hl
	ld sp, W2_RedrawRowOrColumnSrcTiles

; Draw tiles attributes
REPT SCREEN_HEIGHT
	pop de
	ld a, e
	ld [hli], a
	ld [hl], d

	ld bc, BG_MAP_WIDTH - 1
	add hl, bc
; the following 4 lines wrap us from bottom to top if necessary
	ld a, h
	and $3
	or $98
	ld h, a
ENDR

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	xor a
	ldh [hRedrawRowOrColumnMode], a
	ldh [rVBK], a
	ldh [rSVBK], a
	ret
