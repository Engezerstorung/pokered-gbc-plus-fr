VBlank::

	push af
	push bc
	push de
	push hl

	ldh a, [hLoadedROMBank]
	ld [wVBlankSavedROMBank], a

	ldh a, [rVDMA_LEN]
	inc a
	jr z, .noHDMAInProgress
	dec a
	res 7, a
	; the double instruction here is not a mistake
	ldh [rVDMA_LEN], a ; this first write with bit 7 unset terminate the HDMA in progress
	ldh [rVDMA_LEN], a ; this second write finish the transfer as a GDMA
;	jp .doneHDMA
.noHDMAInProgress

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


	ldh a, [hDelayFrameHookBank]
	and a
	jr nz, .passDMA

;	call hDMARoutine
	ld a, HIGH(wShadowOAM)
	ldh [rDMA], a
	; wait for DMA to finish
	ld a, $28
.wait
	dec a
	jr nz, .wait

.passDMA

.doneHDMA
	ld a, BANK(GbcVBlankHook)
	ld [rROMB], a
	call GbcVBlankHook

	; VBlank-sensitive operations end.

	call Random
	
	ldh a, [hBlink]
	xor 80
	ldh [hBlink], a

;	jr .noNpcAnimation

	ld a, [wSpriteFlags]
	bit 0, a
	jr nz, .noNpcAnimation ; dont animate npcs or update reflection during an OverworldDelayFrame vblank

	; check if the owerworld is actually showing
	ld a, 2
	ldh [rWBK], a
	ld a, [W2_TileBasedPalettes]
	cp 2
	ld a, 0
	ldh [rWBK], a
	jr nz, .noNpcAnimation

;	ldh a, [hVBlankOccurred]
;	and a
;	jr z, .notOverworldLoopDelayFrame ; if vblank outside of Delayframe, not overworld loop Delayframe
;	ldh a, [hWY]
;	and a
;	jr z, .notOverworldLoopDelayFrame ; if windows is up, not overworld loop Delayframe
;	ld a, [wStatusFlags3]
;	bit BIT_EMOTION_BUBBLE, a
;	jr nz, .notOverworldLoopDelayFrame ; if emotion bubble is up, not overworld loop Delayframe
;
;	ldh a, [hAutoBGTransferEnabled]
;	and a
;	jr nz, .notOverworldLoopDelayFrame
;
;	ld a, [wFontLoaded]
;	bit BIT_FONT_LOADED, a
;	jr z, .noNpcAnimation
;.notOverworldLoopDelayFrame

	; only update npc animation every other frame
	ldh a, [hBlink]
	and a
	jr z, .dontAnimateNpcThisVblank
	ld a, BANK(AnimateNpcDuringText)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call AnimateNpcDuringText
.dontAnimateNpcThisVblank

	ldh a, [hPassedOamTiles]
	and a
	jr z, .skipDecDelayFramesCounter
	dec a
	ldh [hPassedOamTiles], a
	jr nz, .noNpcAnimation
.skipDecDelayFramesCounter

	ldh a, [hDelayFrameHookBank]
	and a
	jr nz, .noNpcAnimation ; dont PrepareOAMData during vblank if it interrupted a Delayframe preparation
	ld a, BANK(PrepareOAMData)
	ldh [hLoadedROMBank], a
	ld [rROMB], a
	call PrepareOAMData
.noNpcAnimation

	ld hl, wSpriteFlags
	res 0, [hl]

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

OverworldDelayFrame::
	push hl
	ld hl, wSpriteFlags
	set 0, [hl]
	pop hl

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

STATInterrupt::
	push af ; 4
	ldh a, [rVDMA_LEN] ; 3
	inc a ; 1
	jr z, .noVDMA ; 2

	add b ; 1
	ld [hl], a ; 2 ; total : 13 ; target : 11

;	set 7, [hl] ; 4 ; total : 14 ; target : 11

.return
	pop af
	reti

.noVDMA
	ldh a, [rSTAT]
	and STAT_LYC | STAT_LYCF ; keep only both LYC and LYCF bits
	jr z, .return
	xor STAT_LYC | STAT_LYCF ; result will be 0 if both bit were set
	jr nz, .return
	pop af

;	reti

	push hl
	ld hl, _GbcPrepareVBlank
	jp InterruptWrapper

;	push af
;	ldh a, [rSTAT]
;	and STAT_LYC | STAT_LYCF ; keep only both LYC and LYCF bits
;	jr nz, .LYC_LY
;
;.hBlank
;	pop af
;	reti
;
;.LYC_LY
;	xor STAT_LYC | STAT_LYCF ; result will be 0 if both bit were set
;	jr nz, .hBlank
;	pop af
;	push hl
;	ld hl, _GbcPrepareVBlank
;	jp InterruptWrapper
