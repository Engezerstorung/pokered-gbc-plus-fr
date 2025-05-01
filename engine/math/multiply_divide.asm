_Multiply::
	ld a, $8
	ld b, a
	xor a
	ldh [hProduct], a
	ldh [hMultiplyBuffer], a
	ldh [hMultiplyBuffer+1], a
	ldh [hMultiplyBuffer+2], a
	ldh [hMultiplyBuffer+3], a
.loop
	ldh a, [hMultiplier]
	srl a
	ldh [hMultiplier], a ; (aliases: hDivisor, hMultiplier, hPowerOf10)
	jr nc, .smallMultiplier
	ldh a, [hMultiplyBuffer+3]
	ld c, a
	ldh a, [hMultiplicand+2]
	add c
	ldh [hMultiplyBuffer+3], a
	ldh a, [hMultiplyBuffer+2]
	ld c, a
	ldh a, [hMultiplicand+1]
	adc c
	ldh [hMultiplyBuffer+2], a
	ldh a, [hMultiplyBuffer+1]
	ld c, a
	ldh a, [hMultiplicand] ; (aliases: hMultiplicand)
	adc c
	ldh [hMultiplyBuffer+1], a
	ldh a, [hMultiplyBuffer]
	ld c, a
	ldh a, [hProduct] ; (aliases: hProduct, hPastLeadingZeros, hQuotient)
	adc c
	ldh [hMultiplyBuffer], a
.smallMultiplier
	dec b
	jr z, .done
	ldh a, [hMultiplicand+2]
	sla a
	ldh [hMultiplicand+2], a
	ldh a, [hMultiplicand+1]
	rl a
	ldh [hMultiplicand+1], a
	ldh a, [hMultiplicand]
	rl a
	ldh [hMultiplicand], a
	ldh a, [hProduct]
	rl a
	ldh [hProduct], a
	jr .loop
.done
	ldh a, [hMultiplyBuffer+3]
	ldh [hProduct+3], a
	ldh a, [hMultiplyBuffer+2]
	ldh [hProduct+2], a
	ldh a, [hMultiplyBuffer+1]
	ldh [hProduct+1], a
	ldh a, [hMultiplyBuffer]
	ldh [hProduct], a
	ret

_Divide::
	xor a
	ldh [hDivideBuffer], a
	ldh [hDivideBuffer+1], a
	ldh [hDivideBuffer+2], a
	ldh [hDivideBuffer+3], a
	ldh [hDivideBuffer+4], a
	ld a, $9
	ld e, a
.loop
	ldh a, [hDivideBuffer]
	ld c, a
	ldh a, [hDividend+1] ; (aliases: hMultiplicand)
	sub c
	ld d, a
	ldh a, [hDivisor] ; (aliases: hDivisor, hMultiplier, hPowerOf10)
	ld c, a
	ldh a, [hDividend] ; (aliases: hProduct, hPastLeadingZeros, hQuotient)
	sbc c
	jr c, .next
	ldh [hDividend], a ; (aliases: hProduct, hPastLeadingZeros, hQuotient)
	ld a, d
	ldh [hDividend+1], a ; (aliases: hMultiplicand)
	ldh a, [hDivideBuffer+4]
	inc a
	ldh [hDivideBuffer+4], a
	jr .loop
.next
	ld a, b
	cp $1
	jr z, .done
	ldh a, [hDivideBuffer+4]
	sla a
	ldh [hDivideBuffer+4], a
	ldh a, [hDivideBuffer+3]
	rl a
	ldh [hDivideBuffer+3], a
	ldh a, [hDivideBuffer+2]
	rl a
	ldh [hDivideBuffer+2], a
	ldh a, [hDivideBuffer+1]
	rl a
	ldh [hDivideBuffer+1], a
	dec e
	jr nz, .next2
	ld a, $8
	ld e, a
	ldh a, [hDivideBuffer]
	ldh [hDivisor], a ; (aliases: hDivisor, hMultiplier, hPowerOf10)
	xor a
	ldh [hDivideBuffer], a
	ldh a, [hDividend+1] ; (aliases: hMultiplicand)
	ldh [hDividend], a ; (aliases: hProduct, hPastLeadingZeros, hQuotient)
	ldh a, [hDividend+2]
	ldh [hDividend+1], a ; (aliases: hMultiplicand)
	ldh a, [hDividend+3]
	ldh [hDividend+2], a
.next2
	ld a, e
	cp $1
	jr nz, .okay
	dec b
.okay
	ldh a, [hDivisor] ; (aliases: hDivisor, hMultiplier, hPowerOf10)
	srl a
	ldh [hDivisor], a ; (aliases: hDivisor, hMultiplier, hPowerOf10)
	ldh a, [hDivideBuffer]
	rr a
	ldh [hDivideBuffer], a
	jr .loop
.done
	ldh a, [hDividend+1] ; (aliases: hMultiplicand)
	ldh [hRemainder], a ; (aliases: hDivisor, hMultiplier, hPowerOf10)
	ldh a, [hDivideBuffer+4]
	ldh [hQuotient+3], a
	ldh a, [hDivideBuffer+3]
	ldh [hQuotient+2], a
	ldh a, [hDivideBuffer+2]
	ldh [hQuotient+1], a ; (aliases: hMultiplicand)
	ldh a, [hDivideBuffer+1]
	ldh [hDividend], a ; (aliases: hProduct, hPastLeadingZeros, hQuotient)
	ret

; calculates all 5 stats of current mon and writes them to [de]
_CalcStats::
	ld c, $0
.statsLoop
	inc c
	call _CalcStat
	ldh a, [hMultiplicand+1]
	ld [de], a
	inc de
	ldh a, [hMultiplicand+2]
	ld [de], a
	inc de
	ld a, c
	cp NUM_STATS
	jr nz, .statsLoop
	ret

; calculates stat c of current mon
; c: stat to calc (HP=1,Atk=2,Def=3,Spd=4,Spc=5)
; b: consider stat exp?
; hl: base ptr to stat exp values ([hl + 2*c - 1] and [hl + 2*c])
_CalcStat::
	push hl
	push de
	push bc
	ld a, b
	ld d, a
	push hl
	ld hl, wMonHeader
	ld b, $0
	add hl, bc
	ld a, [hl]          ; read base value of stat
	ld e, a
	pop hl
	push hl
	sla c
	ld a, d
	and a
	jr z, .statExpDone  ; consider stat exp?
	add hl, bc          ; skip to corresponding stat exp value
.statExpLoop            ; calculates ceil(Sqrt(stat exp)) in b
	xor a
	ldh [hMultiplicand], a
	ldh [hMultiplicand+1], a
	inc b               ; increment current stat exp bonus
	ld a, b
	cp $ff
	jr z, .statExpDone
	ldh [hMultiplicand+2], a
	ldh [hMultiplier], a
	call Multiply
	ld a, [hld]
	ld d, a
	ldh a, [hProduct + 3]
	sub d
	ld a, [hli]
	ld d, a
	ldh a, [hProduct + 2]
	sbc d               ; test if (current stat exp bonus)^2 < stat exp
	jr c, .statExpLoop
.statExpDone
	srl c
	pop hl
	push bc
	ld bc, wPartyMon1DVs - (wPartyMon1HPExp - 1) ; also wEnemyMonDVs - wEnemyMonHP
	add hl, bc
	pop bc
	ld a, c
	cp $2
	jr z, .getAttackIV
	cp $3
	jr z, .getDefenseIV
	cp $4
	jr z, .getSpeedIV
	cp $5
	jr z, .getSpecialIV
.getHpIV
	push bc
	ld a, [hl]  ; Atk IV
	swap a
	and $1
	sla a
	sla a
	sla a
	ld b, a
	ld a, [hli] ; Def IV
	and $1
	sla a
	sla a
	add b
	ld b, a
	ld a, [hl] ; Spd IV
	swap a
	and $1
	sla a
	add b
	ld b, a
	ld a, [hl] ; Spc IV
	and $1
	add b      ; HP IV: LSB of the other 4 IVs
	pop bc
	jr .calcStatFromIV
.getAttackIV
	ld a, [hl]
	swap a
	and $f
	jr .calcStatFromIV
.getDefenseIV
	ld a, [hl]
	and $f
	jr .calcStatFromIV
.getSpeedIV
	inc hl
	ld a, [hl]
	swap a
	and $f
	jr .calcStatFromIV
.getSpecialIV
	inc hl
	ld a, [hl]
	and $f
.calcStatFromIV
	ld d, $0
	add e
	ld e, a
	jr nc, .noCarry
	inc d                     ; de = Base + IV
.noCarry
	sla e
	rl d                      ; de = (Base + IV) * 2
	srl b
	srl b                     ; b = ceil(Sqrt(stat exp)) / 4
	ld a, b
	add e
	jr nc, .noCarry2
	inc d                     ; de = (Base + IV) * 2 + ceil(Sqrt(stat exp)) / 4
.noCarry2
	ldh [hMultiplicand+2], a
	ld a, d
	ldh [hMultiplicand+1], a
	xor a
	ldh [hMultiplicand], a
	ld a, [wCurEnemyLevel]
	ldh [hMultiplier], a
	call Multiply            ; ((Base + IV) * 2 + ceil(Sqrt(stat exp)) / 4) * Level
	ldh a, [hMultiplicand]
	ldh [hDividend], a
	ldh a, [hMultiplicand+1]
	ldh [hDividend+1], a
	ldh a, [hMultiplicand+2]
	ldh [hDividend+2], a
	ld a, $64
	ldh [hDivisor], a
	ld a, $3
	ld b, a
	call Divide             ; (((Base + IV) * 2 + ceil(Sqrt(stat exp)) / 4) * Level) / 100
	ld a, c
	cp $1
	ld a, 5 ; + 5 for non-HP stat
	jr nz, .notHPStat
	ld a, [wCurEnemyLevel]
	ld b, a
	ldh a, [hMultiplicand+2]
	add b
	ldh [hMultiplicand+2], a
	jr nc, .noCarry3
	ldh a, [hMultiplicand+1]
	inc a
	ldh [hMultiplicand+1], a ; HP: (((Base + IV) * 2 + ceil(Sqrt(stat exp)) / 4) * Level) / 100 + Level
.noCarry3
	ld a, 10 ; +10 for HP stat
.notHPStat
	ld b, a
	ldh a, [hMultiplicand+2]
	add b
	ldh [hMultiplicand+2], a
	jr nc, .noCarry4
	ldh a, [hMultiplicand+1]
	inc a                    ; non-HP: (((Base + IV) * 2 + ceil(Sqrt(stat exp)) / 4) * Level) / 100 + 5
	ldh [hMultiplicand+1], a ; HP: (((Base + IV) * 2 + ceil(Sqrt(stat exp)) / 4) * Level) / 100 + Level + 10
.noCarry4
	ldh a, [hMultiplicand+1] ; check for overflow (>999)
	cp HIGH(MAX_STAT_VALUE) + 1
	jr nc, .overflow
	cp HIGH(MAX_STAT_VALUE)
	jr c, .noOverflow
	ldh a, [hMultiplicand+2]
	cp LOW(MAX_STAT_VALUE) + 1
	jr c, .noOverflow
.overflow
	ld a, HIGH(MAX_STAT_VALUE) ; overflow: cap at 999
	ldh [hMultiplicand+1], a
	ld a, LOW(MAX_STAT_VALUE)
	ldh [hMultiplicand+2], a
.noOverflow
	pop bc
	pop de
	pop hl
	ret

