Random::
; Return a random number in a.
; For battles, use BattleRandom.
	push hl
	push de
	push bc
	farcall Random_
	ldh a, [hRandomAdd]
	pop bc
	pop de
	pop hl
	ret

RandomValueInRange::
; Return a random number from range [d;e] in a.
	; d : max value
	; e : min value
	push hl
	push bc
	farcall RandomValueInRange_
	pop bc
	pop hl
	ret

AdjustValueToRange::
; Adjust value in a to be contained in range [d;e].
	; a : value to adjust
	; d : max value
	; e : min value
	ld b, a
	pushrombank
	setrombank BANK(AdjustValueToRange_)
	ld a, b
	call AdjustValueToRange_
	ld b, a
	poprombank
	ld a, b
	ret
