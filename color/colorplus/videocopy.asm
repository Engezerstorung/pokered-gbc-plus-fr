CopyVideoData_NoDelay::
; de = graphic to use
; hl = where in vram
; b = wich bank the graphic is in
; c = which vbank to copy to
; a = how many tile to copy from the source graphic

	di
	
	ldh [hColorHackTmp], a

	ldh a, [rSVBK]
	ld b, a
	ld a, 3
	ldh [rSVBK], a
	push bc

	ld [hSPTemp], sp

	ld a, h
	ld [W3_HLTemp + 1], a
	ld a, l
	ld [W3_HLTemp], a

	ld sp, W3_SPCopyPtr
	pop hl
	ld sp, hl

	ld a, [W3_HLTemp + 1]
	ld h, a
	ld a, [W3_HLTemp]
	ld l, a

	ldh a, [hColorHackTmp]

	push de ; source
	push hl ; destination
	push bc ; bank, vbank
	push af ; tiles

	ld [W3_SPCopyPtr], sp

	ld sp, hSPTemp
	pop hl
	ld sp, hl

	pop af
	ldh [rSVBK], a

	ei	

	ret

DoCopyVideoData_NoDelay::
	di

	ldh a, [rSVBK]
	ld b, a
	ld a, 3
	ldh [rSVBK], a
	push bc

	ld [hSPTemp], sp

	ld sp, W3_SPCopyPtr
	pop hl
	ld sp, hl

	pop af
	and a ; number of tiles
	jr z, .done

	pop bc ; bank and vbank
	pop de ; destination
	pop hl ; source
	ld sp, hl
	ld h, d
	ld l, e

	ldh [hColorHackTmp], a
	ldh a, [hLoadedROMBank]
	ld [W3_BKCopyBank], a
	ld a, b
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	ldh a, [hColorHackTmp]

	ld b, a ; number of tiles to copy
	ld a, c
	and a
	jr z, .rVBK0
	ld a, 1
	ldh [rVBK], a
.rVBK0
	
	ld c, 12 ; max amount to copy per vblank
.copyLoop
REPT 8
	pop de
	ld a, e
	ld [hli], a
	ld a, d
	ld [hli], a
ENDR
	dec c
	jr z, .stopCopy
	dec b
	jr nz, .copyLoop
	jr .donecopy
	
.stopCopy
	dec b
	jr z, .doneScheduled
.doneCopy

	ld d, h ; destination
	ld e, l

	ld hl, sp ; source

	ld a, h
	ld [W3_HLTemp + 1], a
	ld a, l
	ld [W3_HLTemp], a
	
	ld sp, W3_SPCopyPtr
	pop hl
	ld hl, sp

	ld a, [W3_HLTemp + 1]
	ld h, a
	ld a, [W3_HLTemp]
	ld l, a

	push hl ; source
	push de ; destination

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WIP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;	push bc ; bank, vbank
;	push af ; tiles


.doneScheduled
	ld W3_SPCopyPtr, sp

	ld a, [W3_BKCopyBank]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a


.done
	ld sp, hSPTemp
	pop hl
	ld sp, hl

	pop af
	ldh [rSVBK], a
	xor a
	ldh [rVBK], a

	ei	

	ret
