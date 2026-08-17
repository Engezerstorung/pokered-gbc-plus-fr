DelayFrames::
; wait c frames
	ld a, c
	ldh [hPassedOamTiles], a
.loop
	call DelayFrame
	dec c
	jr nz, .loop
	xor a
	ldh [hPassedOamTiles], a
	ret

PlaySoundWaitForCurrent::
	push af
	call WaitForSoundToFinish
	pop af
	jp PlaySound

; Wait for sound to finish playing
WaitForSoundToFinish::
	ld a, [wLowHealthAlarm]
	and $80
	ret nz
	push hl
.waitLoop
	ld hl, wChannelSoundIDs + CHAN5
	xor a
	or [hl]
	inc hl
	or [hl]
	inc hl
	inc hl
	or [hl]
	jr nz, .waitLoop
	pop hl
	ret
