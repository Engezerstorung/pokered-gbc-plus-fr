; This file only included if GEN_2_GRAPHICS is set

LoadHPBarAndEXPBar::
	ld de, HpBarAndStatusGraphics
	ld hl, vChars2 tile $62
	lb bc, BANK(HpBarAndStatusGraphics), (HpBarAndStatusGraphicsEnd - HpBarAndStatusGraphics) / $10
;	call GoodCopyVideoData
;	ld de, EXPBarGraphics tile $1
;	ld hl, vChars1 tile $4D
;	lb bc, BANK(EXPBarGraphics), ((EXPBarGraphicsEnd - EXPBarGraphics) - 32) / $10

	jp GoodCopyVideoData
;GoodCopyVideoData:
;	ldh a, [rLCDC]
;	bit B_LCDC_ENABLE, a ; is the LCD enabled?
;	jp nz, CopyVideoData ; if LCD is on, transfer during V-blank
;	ld a, b
;	push hl
;	push de
;	ld h, 0
;	ld l, c
;	add hl, hl
;	add hl, hl
;	add hl, hl
;	add hl, hl
;	ld b, h
;	ld c, l
;	pop hl
;	pop de
;	jp FarCopyData2 ; if LCD is off, transfer all at once

LoadPartialBarTile::
	; inputs
	; d = identification value of the partial bar tile
	;    0~6
	;    0 : EXP tile
	;    1 : Enemy pokemon HP and party pokemon 1
	;    2 : Player pokemon HP, status screen and party pokemon 2
	;    3 : Party pokemon 3
	;    ... and so on
	; e = partial bar tile pixel amount 1~7
	swap d
	swap e
	ld c, d
	ld b, 0
	ld d, b

	ld a, c
	and a
	ld hl, EXPBarGraphics
	jr z, .isEXPGraphics
	ld hl, HpBarAndStatusGraphics tile $1
.isEXPGraphics
	add hl, de
	ld d, h
	ld e, l

.done	
	ld hl, vChars2 tile $64
	add hl, bc
	lb bc, BANK(EXPBarGraphics), 1
	assert BANK(EXPBarGraphics) == BANK(HpBarAndStatusGraphics)
	call GoodCopyVideoDataHDMA

	ret

