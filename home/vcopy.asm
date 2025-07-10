; this function seems to be used only once
; it store the address of a row and column of the VRAM background map in hl
; INPUT: h - row, l - column, b - high byte of background tile map address in VRAM
GetRowColAddressBgMap::
	xor a
	srl h
	rr a
	srl h
	rr a
	srl h
	rr a
	or l
	ld l, a
	ld a, b
	or h
	ld h, a
	ret

; clears a VRAM background map with blank space tiles
; INPUT: h - high byte of background tile map address in VRAM
ClearBgMap::
	ld a, " "
	; fallthrough

FillBgMap::
	ld bc, BG_MAP_WIDTH * BG_MAP_HEIGHT
	ld l, c
	jp FillMemory

; clears a VRAM background map attributes with text palette (BGP7)
; INPUT: h - high byte of background tile map address in VRAM
ClearBgMapAttributes::
	di
	ld a, 7
	ldh [rVBK], a
	call FillBgMap
	xor a
	ldh [rVBK], a
	reti

; This function redraws a BG row of height 2 or a BG column of width 2.
; One of its main uses is redrawing the row or column that will be exposed upon
; scrolling the BG when the player takes a step. Redrawing only the exposed
; row or column is more efficient than redrawing the entire screen.
; However, this function is also called repeatedly to redraw the whole screen
; when necessary. It is also used in trade animation and elevator code.
; This function has beex HAXed to call other functions, which will also refresh palettes.
RedrawRowOrColumn::
	ld a, BANK(_RedrawRowOrColumn)
	ld [MBC1RomBank], a
	call _RedrawRowOrColumn
	ldh a, [hLoadedROMBank]
	ld [MBC1RomBank], a
	ret

;	ldh a, [hRedrawRowOrColumnMode]
;	and a
;	ret z
;	ld b, a
;	xor a
;	ldh [hRedrawRowOrColumnMode], a
;	dec b
;	jr nz, .redrawRow
;	CALL_INDIRECT DrawMapColumn
;	ret
;.redrawRow
;	CALL_INDIRECT DrawMapRow
;	ret

; This function automatically transfers tile number data from the tile map at
; wTileMap to VRAM during V-blank. Note that it only transfers one third of the
; background per V-blank. It cycles through which third it draws.
; This transfer is turned off when walking around the map, but is turned
; on when talking to sprites, battling, using menus, etc. This is because
; the above function, RedrawRowOrColumn, is used when walking to
; improve efficiency.
AutoBgMapTransfer:: ; HAXED function
	ld a, BANK(RefreshWindow)
	ld [MBC1RomBank], a
	call RefreshWindow
	ldh a, [hLoadedROMBank]
	ld [MBC1RomBank], a
	ret

; HAX: Squeeze this little function in here
_GbcPrepareVBlank:
	push af
	push bc
	push de
	push hl
	CALL_INDIRECT GbcPrepareVBlank
	pop hl
	pop de
	pop bc
	pop af
	reti

; Prevent data shifting
SECTION "JpPoint", ROM0

; HAX: This function is reimplemented elsewhere.
; Note: this doesn't update "hLoadedROMBank", but no interrupts will occur at this time,
; so it's fine.
TransferBgRows::
	ld a, BANK(WindowTransferBgRowsAndColors)
	ld [MBC1RomBank], a
	jp WindowTransferBgRowsAndColors

; Copies [hVBlankCopyBGNumRows] rows from hVBlankCopyBGSource to hVBlankCopyBGDest.
; If hVBlankCopyBGSource is XX00, the transfer is disabled.
VBlankCopyBgMap::
	ldh a, [hVBlankCopyBGSource] ; doubles as enabling byte
	and a
	ret z

	ld [hSPTemp], sp ; save stack pointer

	ld sp, hVBlankCopyBGSource
	pop hl
	pop de ; hVBlankCopyBGDest
	ld sp, hl
	ld h, d
	ld l, e

	ldh a, [hVBlankCopyBGNumRows]
	ld b, a
	xor a
	ldh [hVBlankCopyBGSource], a ; disable transfer so it doesn't continue next V-blank
	jr TransferBgRows


VBlankCopyDouble::
; Copy [hVBlankCopyDoubleSize] 1bpp tiles
; from hVBlankCopyDoubleSource to hVBlankCopyDoubleDest.

; While we're here, convert to 2bpp.
; The process is straightforward:
; copy each byte twice.

	ldh a, [hVBlankCopyDoubleSize]
	and a
	ret z

	ld [hSPTemp], sp

	ld sp, hVBlankCopyDoubleSource
	pop hl
	pop de ; hVBlankCopyDoubleDest
	ld sp, hl
	ld h, d
	ld l, e

;	ldh a, [hVBlankCopyDoubleSize]
	ld b, a
	xor a ; transferred
	ldh [hVBlankCopyDoubleSize], a

.loop
REPT LEN_2BPP_TILE / 4
	pop de
	ld a, e
	ld [hli], a
	ld [hli], a
	ld a, d
	ld [hli], a
	ld [hli], a
ENDR
	dec b
	jr nz, .loop

	ld [hVBlankCopyDoubleSource], sp

	ld sp, hVBlankCopyDoubleDest + 2
	push hl

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	ret


VBlankCopy::
; Copy [hVBlankCopySize] 2bpp tiles (or 16 * [hVBlankCopySize] tile map entries)
; from hVBlankCopySource to hVBlankCopyDest.

; Source and destination addresses are updated,
; so transfer can continue in subsequent calls.

	ldh a, [hVBlankCopySize]
	and a
	ret z

	ld hl, wSpriteFlags
	bit 4, [hl]
	jp nz, VBlankSpriteCopy

.doCopy	

	ld [hSPTemp], sp

	ld sp, hVBlankCopySource
	pop hl
	pop de ; hVBlankCopyDest
	ld sp, hl
	ld h, d
	ld l, e

	ldh a, [hVBlankCopySize]
	ld b, a
	xor a ; transferred
	ldh [hVBlankCopySize], a

.loop
REPT LEN_2BPP_TILE / 2 - 1
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
	inc hl
	dec b
	jr nz, .loop

	ld [hVBlankCopySource], sp

	ld sp, hVBlankCopyDest + 2
	push hl

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	ret


UpdateMovingBgTiles::
; Animate water and flower
; tiles in the overworld.

	ldh a, [hTileAnimations]
	and a
	ret z

	ldh a, [hMovingBGTilesCounter1]
	inc a
	ldh [hMovingBGTilesCounter1], a
	cp 20
	ret c
	cp 21
	jr z, .flower

; water

	ldh a, [rVBK]
	push af
	ld a, 1
	ldh [rVBK], a

	ld a, [wMovingBGTilesCounter2]
	inc a
	and 7
	ld [wMovingBGTilesCounter2], a

	cp 5
	jr c, .toTheRight
	cpl
	and 3
	inc a
.toTheRight
	swap a
	ld l, a
	ld a, [wCurMapTileset]
	and a
	jr z, .overworldWater
	ld a, 5 tiles
.overworldWater
	add l
	add LOW(WaterTiles)
	ldh [rHDMA2], a
	ld a, HIGH(WaterTiles)
	adc 0
	ldh [rHDMA1], a
	ld a, HIGH(vTileset tile $14)
	ldh [rHDMA3], a
	ld a, LOW(vTileset tile $14)
	ldh [rHDMA4], a
	xor a
	ldh [rHDMA5], a
	

	pop af
	ldh [rVBK], a

	ldh a, [hTileAnimations]
	rrca
	ret nc

	xor a
	ldh [hMovingBGTilesCounter1], a
	ret

.flower
	ldh a, [rVBK]
	push af
	ld a, 1
	ldh [rVBK], a

	xor a
	ld b, a
	ldh [hMovingBGTilesCounter1], a

	ld a, [wMovingBGTilesCounter2]
	and 3

;	cp 2
;	ld hl, FlowerTile1
;	jr c, .copy
;	ld hl, FlowerTile2
;	jr z, .copy
;	ld hl, FlowerTile3
;.copy
;	ld de, vTileset tile $03
;	ld c, $10
;.loop
;	ld a, [hli]
;	ld [de], a
;	inc de
;	dec c
;	jr nz, .loop

	jr z, .noDec
	dec a
.noDec
	swap a
	add LOW(FlowerTile1)
	ldh [rHDMA2], a

	ld a, HIGH(FlowerTile1)
	adc b
	ldh [rHDMA1], a
	ld a, HIGH(vTileset tile $03)
	ldh [rHDMA3], a
	ld a, LOW(vTileset tile $03)
	ldh [rHDMA4], a
	xor a
	ldh [rHDMA5], a

	pop af
	ldh [rVBK], a
	ret

PUSHS
SECTION "Flower Tiles", ROM0, ALIGN[4]
FlowerTile1: INCBIN "gfx/tilesets/flower/flower1.2bpp"
FlowerTile2: INCBIN "gfx/tilesets/flower/flower2.2bpp"
FlowerTile3: INCBIN "gfx/tilesets/flower/flower3.2bpp"
WaterTiles:  INCBIN "gfx/tilesets/water/water.2bpp"
POPS

VBlankSpriteCopy::
	cp 12
	push af
	jr c, .canCopy

	ldh a, [hMovingBGTilesCounter1]
	cp 19
	jr c, .canCopy
	pop af
	ret

.canCopy
	res 4, [hl]

	ldh a, [hVBlankCopyDest]
	ld l, a
	ldh a, [hVBlankCopyDest + 1]
	ld h, a
	push hl

	call VBlankCopy.doCopy

	pop hl
	pop af
	ret c

	ldh [hVBlankCopySize], a
	set 3, h ; add $800 ($80 tiles) to hl (1 << 3 == $8)
	ld a, l
	ldh [hVBlankCopyDest], a
	ld a, h
	ldh [hVBlankCopyDest + 1], a

	jp VBlankCopy.doCopy
