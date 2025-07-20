SECTION "rst0", ROM0[$0000]
;_LoadMapVramAndColors:
;	ldh a, [hLoadedROMBank]
;	push af
;	ld a, BANK(LoadMapVramAndColors)
;	ld [rROMB], a
;	call LoadMapVramAndColors
;	pop af
;	ld [rROMB], a
	ret

	ds $8 - @, 0

SECTION "rst8", ROM0[$0008]

	ds $10 - @, 0

; HAX: rst10 can be used for "Bankswitch"
SECTION "rst10", ROM0[$0010]
_Bankswitch::
	jp Bankswitch

	ds $18 - @, 0 ; unused

; HAX: rst18 can be used for "Bankswitch"
SECTION "rst18", ROM0[$0018]
_Bankswitch_jp::
	add sp, 2
	jp Bankswitch

	ds $20 - @, 0

SECTION "rst20", ROM0[$0020]
SetRomBank::
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	ret

	ds $28 - @, 0

SECTION "rst28", ROM0[$0028]
	ret

	ds $30 - @, 0 ; unused

SECTION "rst30", ROM0[$0030]
	ret

	ds $38 - @, 0 ; unused

SECTION "rst38", ROM0[$0038]
	ret

	ds $40 - @, 0 ; unused

; Game Boy hardware interrupts

SECTION "vblank", ROM0[$0040]
	push hl
	ld hl, VBlank
	jp InterruptWrapper

	ds $48 - @, 0

SECTION "lcd", ROM0[$0048] ; HAX: interrupt wasn't used in original game
	jp STATInterrupt

	ds $50 - @, 0

SECTION "timer", ROM0[$0050]
	push hl
	ld hl, Timer
	jp InterruptWrapper

	ds $58 - @, 0

SECTION "serial", ROM0[$0058]
	push hl
	ld hl, Serial
	jp InterruptWrapper

	ds $60 - @, 0

SECTION "joypad", ROM0[$0060]
	reti


SECTION "Header", ROM0[$0100]

Start::
jp InitializeColor

; The Game Boy cartridge header data is patched over by rgbfix.
; This makes sure it doesn't get used for anything else.

	ds $0150 - @

ENDSECTION
