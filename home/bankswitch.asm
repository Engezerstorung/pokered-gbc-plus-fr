BankswitchHome::
; switches to bank # in a
; Only use this when in the home bank!
	ld [wBankswitchHomeTemp], a
	ldh a, [hLoadedROMBank]
	ld [wBankswitchHomeSavedROMBank], a
	ld a, [wBankswitchHomeTemp]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	ret

BankswitchBack::
; returns from BankswitchHome
	ld a, [wBankswitchHomeSavedROMBank]
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	ret

Bankswitch::
	dec sp
	call DoBankswitch
	jr Bankswitch_return

DoBankswitch::
	push hl
	push af

	ld hl, sp + 6
	ldh a, [hLoadedROMBank]
	ld [hl], a
	ld a, b
	ldh [hLoadedROMBank], a
	ld [rROMB], a

	pop af
	ret

Deref_Farcall::
	push hl ; push dwb target fucntion address

	push af
	inc hl
	inc hl
	inc hl ; pass dwb data to reach hl data
	ld a, [hli]
	ld h, [hl]
	ld l, a ; get hl data from table
	pop af

;ret-dba	11	13
;saved bank	10	12
;JPreturn	8	10
;JPaddress	6	8
;push af	4	6
;push bc	2	4
;push hl 	0	2
;	push hl		0

Bankswitch_sf::
	dec sp
	call DoBankswitch_sf
	; fallthrough

Bankswitch_return:
	push af
	push hl
	ld hl, sp + 4
	ld a, [hl]
	pop hl
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	pop af
	inc sp
	ret

DoBankswitch_sf::
; self-contained bankswitch, use this when not in the home bank
; to use exclusively with macro farcall/callfar or farjp/jpfar
	push af ; make room for jump address

	push af
	push bc
	push hl

	ld hl, sp + 10
	ldh a, [hLoadedROMBank]
	ld [hli], a ; save bank on the stack

	ld a, [hli]
	ld h, [hl]
	ld l, a ; deref function dwb data address

	ld a, [hli]
	ld c, a
	ld a, [hli]
	rlca
	srl a
	ld b, a ; get jump address in bc after reseting highest bit to check for farjp

	ld a, [hli]
	ldh [hLoadedROMBank], a
	ld [rROMB], a ; change bank

	jr nc, .notFarJP ; replace macro return address if farjp
	ld hl, JustRet
.notFarJP

	push hl
	ld hl, sp + 8
	ld a, c
	ld [hli], a
	ld [hl], b ; save jump address on the stack
	pop bc

	ld hl, sp + 11
	ld a, c
	ld [hli], a
	ld [hl], b ; save return from farcall/jp address

	pop hl
	pop bc
	pop af

	ret ; jump to address

JumpToAddress::
	jp hl

JumpToAddress_DE::
	push de
	ret 

JumpToAddress_BC::
	push bc
	ret 
