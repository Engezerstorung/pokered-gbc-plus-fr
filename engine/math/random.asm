Random_::
; Generate a random 16-bit value.
	ldh a, [rDIV]
	ld b, a
	ldh a, [hRandomAdd]
	adc b
	ldh [hRandomAdd], a
	ldh a, [rDIV]
	ld b, a
	ldh a, [hRandomSub]
	sbc b
	ldh [hRandomSub], a
	ret


RandomValueInRange_::
	call Random
	ldh a, [hRandomAdd]
	; fallthrough

AdjustValueToRange_::
; inputs :
	; a : value to adjust
	; d : max value
	; e : min value
; output :
	; a : adjusted value
	; de is preserved

	push de
	ld b, a

	ld a, d
	sub e
	inc a
	ld c, a ; amount of values in the range [max;min]

	ld a, d
	ld d, %11111111
.getMaxBitValue
	rla
	jr c, .gotmaxBitValue
	srl d
	jr .getMaxBitValue
.gotmaxBitValue

	ld a, b
	and d
	pop de

	sub e
	jr c, .addLoop
.subLoop
	sub c
	jr nc, .subLoop
.addLoop
	add c
	jr nc, .addLoop
	add e
	ret

;	ld b, a
;	inc d ; d = max value + 1
;	ld a, d
;	sub e
;	ld c, a ; amount of values in desired bracket [max;min]
;	ld a, b
;
;	cp d
;	jr nc, .checkMaxLoop
;
;	dec d ; return d to max value
;.checkMinLoop
;	cp e
;	ret nc
;	add c
;	jr .checkMinLoop
;
;.checkMaxLoop
;	sub c
;	cp d
;	jr nc, .checkMaxLoop
;	dec d ; return d to max value
;	ret
