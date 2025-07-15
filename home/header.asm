SECTION "rst0", ROM0[$0000]
_LoadMapVramAndColors:
	ldh a, [hLoadedROMBank]
	push af
	ld a, BANK(LoadMapVramAndColors)
	ld [MBC1RomBank], a
	call LoadMapVramAndColors
	pop af
	ld [MBC1RomBank], a
	ret

;SECTION "rst8", ROM0[$0008]

; HAX: rst10 is used for the vblank hook
SECTION "rst10", ROM0[$0010]
	ld b, BANK(GbcVBlankHook)
	ld hl, GbcVBlankHook
	jp Bankswitch

; HAX: rst18 can be used for "Bankswitch"
SECTION "rst18", ROM0[$0018]
_Bankswitch::
	jp Bankswitch

	ds $20 - @, 0

SECTION "rst20", ROM0[$0020]
SetRomBank::
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a
	ret


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
