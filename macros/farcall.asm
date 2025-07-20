MACRO farcall
	ld b, BANK(\1)
	ld hl, \1
	rst _Bankswitch
;	call Bankswitch
ENDM

MACRO callfar
	ld hl, \1
	ld b, BANK(\1)
	rst _Bankswitch
;	call Bankswitch
ENDM

MACRO farjp
	ld b, BANK(\1)
	ld hl, \1
	rst _Bankswitch_jp
;	jp Bankswitch
ENDM

MACRO jpfar
	ld hl, \1
	ld b, BANK(\1)
	rst _Bankswitch_jp
;	jp Bankswitch
ENDM

MACRO setrombank
	IF _NARG > 0
			ld a, \1
	ENDC    
	rst SetRomBank
ENDM
MACRO pushrombank
	ldh a, [hLoadedROMBank]
	push af
ENDM
MACRO poprombank
	pop af
	setrombank
ENDM
MACRO poprombank_sf ; poprombank but save flags by popping into bc instead of af
	pop bc
	setrombank b
ENDM

MACRO homecall
	pushrombank
	setrombank BANK(\1)
	call \1
	poprombank
ENDM

MACRO homecall_sf ; homecall but save flags by popping into bc instead of af
	pushrombank
	setrombank BANK(\1)
	call \1
	poprombank_sf
ENDM
