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
	jp Bankswitch
ENDM

MACRO jpfar
	ld hl, \1
	ld b, BANK(\1)
	jp Bankswitch
ENDM

MACRO setrombank
	IF _NARG > 0
;		IF \1 >= $FF80
;			ldh a, [\1]
;		ELIF \1 > $FF
;			ld a, [\1]
;		ELSE
			ld a, \1
;		ENDC
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
;	ldh a, [hLoadedROMBank]
;	push af
;	ld a, BANK(\1)
;;	ldh [hLoadedROMBank], a
;;	ld [MBC1RomBank], a
;	rst SetRomBank
;	call \1
;	pop af
;;	ldh [hLoadedROMBank], a
;;	ld [MBC1RomBank], a
;	rst SetRomBank
	pushrombank
	setrombank BANK(\1)
	call \1
	poprombank
ENDM

MACRO homecall_sf ; homecall but save flags by popping into bc instead of af
;	ldh a, [hLoadedROMBank]
;	push af
;	ld a, BANK(\1)
;;	ldh [hLoadedROMBank], a
;;	ld [MBC1RomBank], a
;	rst SetRomBank
;	call \1
;	pop bc
;	ld a, b
;;	ldh [hLoadedROMBank], a
;;	ld [MBC1RomBank], a
;	rst SetRomBank
	pushrombank
	setrombank BANK(\1)
	call \1
	poprombank_sf
ENDM
