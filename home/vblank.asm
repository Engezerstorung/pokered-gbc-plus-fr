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

	ldh a, [hWUp]
	and a
	jr z, .noMapSignToHandle

	ld a, BANK(HandleMapEntrySign)
	ld [rROMB], a
	call HandleMapEntrySign
	ldh a, [hLoadedROMBank]
	ld [rROMB], a
.noMapSignToHandle

	ldh a, [hWY]
	ldh [rWY], a
.ok

	ldh a, [hBlink]
	xor 1
	ldh [hBlink], a

	ldh a, [hAutoBGTransferEnabled]
	and a
	call nz, AutoBgMapTransfer
	ldh a, [hVBlankCopyBGSource] ; doubles as enabling byte
	and a
	call nz, VBlankCopyBgMap
	ldh a, [hRedrawRowOrColumnMode]
	and a
	call nz, RedrawRowOrColumn
	ldh a, [hVBlankCopySize]
	and a
	call nz, VBlankCopy
	ldh a, [hVBlankCopyDoubleSize]
	and a
	call nz, VBlankCopyDouble
;	call UpdateMovingBgTiles
;	call hDMARoutine

	ld a, HIGH(wShadowOAM)
	ldh [rDMA], a
	; wait for DMA to finish
	ld a, $28
.wait
	dec a
	jr nz, .wait

	ldh a, [rVDMA_LEN]
	inc a
	call z, DoGbcVBlankHook

;	nop
;	nop
;	; HAX: don't update sprites here. They're updated elsewhere to prevent wobbliness.
;	;ld a, BANK(PrepareOAMData)
;	nop
;	nop
;	;ldh [hLoadedROMBank], a
;	nop
;	nop
;	;ld [rROMB], a
;	nop
;	nop
;	nop
;	;call PrepareOAMData
;	nop
;	nop
;	nop

	; VBlank-sensitive operations end.

	ei
.waitForHDMAEnd
	ldh a, [rVDMA_LEN]
	inc a
	jr nz, .waitForHDMAEnd
	di

	call Random

	xor a
	ldh [hVBlankOccurred], a

	ldh a, [hFrameCounter]
	and a
	jr z, .skipDec
	dec a
	ldh [hFrameCounter], a

.skipDec
	farcall FadeOutAudio

	ld a, [wAudioROMBank] ; music ROM bank
	ldh [hLoadedROMBank], a
	ld [rROMB], a

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
	ld [rROMB], a

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
	;ld a, NOT_VBLANKED
	;ldh [hVBlankOccurred], a
.halt
	halt
	ldh a, [hVBlankOccurred]
	and a
	jr nz, .halt
	ret

DoGbcVBlankHook:
	setrombank BANK(GbcVBlankHook)
	jp GbcVBlankHook	

STATInterrupt::
	push af
	ldh a, [rSTAT]
	and B_STAT_LYC | B_STAT_LYCF ; keep only both LYC and LYCF bits
	jr nz, LYC_LY

HBlank:
	pop af
	reti

LYC_LY:
	xor B_STAT_LYC | B_STAT_LYCF ; result will be 0 if both bit were set
	jr nz, HBlank
	pop af
	push hl
	ld hl, _GbcPrepareVBlank
	jp InterruptWrapper
