VBlank::

	push af
	push bc
	push de
	push hl

	ldh a, [hLoadedROMBank]
	ld [wVBlankSavedROMBank], a

	ldh a, [hSCX]
	ldh [rSCX], a
	ldh a, [hSCY]
	ldh [rSCY], a

	ld a, [wDisableVBlankWYUpdate]
	and a
	jr nz, .ok
	ldh a, [hWY]

	and a
	jr nz, .not0
	ldh a, [hWYBK]
.not0
	ldh [rWY], a

.ok

	ldh a, [hBlink]
	xor 1
	ldh [hBlink], a
;
;	ld a, [wMovementFlags]
;	bit BIT_LEDGE_OR_FISHING, a
;	jr z, .nothing
;	ld c, $48
;	ld b, $54
;	ldh a, [hBlink]
;	and a
;	jr z, .visible
;	ld b, 160
;.visible
;	ld a, $9
;	ld de, LedgeHoppingShadowOAMBlock2
;	call WriteOAMBlock
;.nothing

	call AutoBgMapTransfer
	call VBlankCopyBgMap
	call RedrawRowOrColumn
	call VBlankCopy
	call VBlankCopyDouble
	;call UpdateMovingBgTiles
	call hDMARoutine

	ld a, BANK(GbcVBlankHook)
	rst SetRomBank
	call GbcVBlankHook

;	rst $10 ; HAX: VBlank hook (loads palettes)

;	nop
;	nop
;	; HAX: don't update sprites here. They're updated elsewhere to prevent wobbliness.
;	;ld a, BANK(PrepareOAMData)
;	nop
;	nop
;	;ldh [hLoadedROMBank], a
;	nop
;	nop
;	;ld [MBC1RomBank], a
;	nop
;	nop
;	nop
;	;call PrepareOAMData
;	nop
;	nop
;	nop

	; VBlank-sensitive operations end.

	call Random

	ldh a, [hVBlankOccurred]
	and a
	jr z, .skipZeroing
	xor a
	ldh [hVBlankOccurred], a

.skipZeroing
	ldh a, [hFrameCounter]
	and a
	jr z, .skipDec
	dec a
	ldh [hFrameCounter], a

.skipDec
	farcall FadeOutAudio

	ld a, [wAudioROMBank] ; music ROM bank
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a

	cp BANK(Audio1_UpdateMusic)
	jr nz, .checkForAudio2
.audio1
	call Audio1_UpdateMusic
	jr .afterMusic
.checkForAudio2
	cp BANK(Audio2_UpdateMusic)
	jr nz, .audio3
.audio2
	call Music_DoLowHealthAlarm
	call Audio2_UpdateMusic
	jr .afterMusic
.audio3
	call Audio3_UpdateMusic
.afterMusic

	farcall TrackPlayTime ; keep track of time played

	ldh a, [hDisableJoypadPolling]
	and a
	call z, ReadJoypad

	ld a, [wVBlankSavedROMBank]
	ldh [hLoadedROMBank], a
	ld [MBC1RomBank], a

	pop hl
	pop de
	pop bc
	pop af
	ret


DelayFrame::
; Wait for the next vblank interrupt.
; As a bonus, this saves battery.

DEF NOT_VBLANKED EQU 1

	call DelayFrameHook ; HAX
;	nop
;	;ld a, NOT_VBLANKED
;	;ldh [hVBlankOccurred], a
.halt
	halt
	ldh a, [hVBlankOccurred]
	and a
	jr nz, .halt
	ret

;LedgeHoppingShadowOAMBlock2:
;; tile ID, attributes
;	db $ff, OAM_OBP1
;	db $ff, OAM_HFLIP
;	db $ff, OAM_VFLIP
;	db $ff, OAM_HFLIP | OAM_VFLIP
