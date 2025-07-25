; This file only included if GEN_2_GRAPHICS is set

LoadHPBarAndEXPBar::
	ld de, HpBarAndStatusGraphics
	ld hl, vChars2 tile $62
	lb bc, BANK(HpBarAndStatusGraphics), (HpBarAndStatusGraphicsEnd - HpBarAndStatusGraphics) / $10
	call GoodCopyVideoData
	ld de, EXPBarGraphics tile $1
	ld hl, vChars1 tile $4D
	lb bc, BANK(EXPBarGraphics), ((EXPBarGraphicsEnd - EXPBarGraphics) - 32) / $10

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
