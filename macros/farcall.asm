; Far calls to another bank

; There is no difference between `farcall` and `callfar`, except the arbitrary
; order in which they set `b` and `hl` before calling `FarCall`.
; We use the more natural name "farcall" for the more common order.
; The same goes for `farjp` and `jpfar`.

MACRO farcall
;	IF \1 < $8000
;		rst _Bankswitch_sf
		call Bankswitch_sf
	.farData\@
		dwb \1, BANK(\1)
	.farDataEnd\@
;	ELSE
;		ld b, BANK(\1)
;		ld hl, \1
;		rst _Bankswitch
;		call Bankswitch
;	ENDC
ENDM

MACRO callfar
;	IF \1 < $8000
		farcall \#
;	ELSE
;		ld hl, \1
;		ld b, BANK(\1)
;		rst _Bankswitch
;		call Bankswitch
;	ENDC
ENDM

MACRO farjp
;	rst _Bankswitch_sf
;	IF \1 < $8000
;		rst _Bankswitch_sf
		call Bankswitch_sf
	.farData\@	
		dwb \1 | $8000, BANK(\1)
	.farDataEnd\@
;	ELSE
;		ld b, BANK(\1)
;		ld hl, \1
;		rst _Bankswitch_jp
;		jp Bankswitch
;	ENDC
ENDM

MACRO jpfar
;	IF \1 < $8000
		farjp \#
;	ELSE
;		ld hl, \1
;		ld b, BANK(\1)
;		rst _Bankswitch_jp
;		jp Bankswitch
;	ENDC
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
