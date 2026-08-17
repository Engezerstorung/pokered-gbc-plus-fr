; These routines manage gradual fading
; (e.g., entering a doorway)
LoadGBPal::
	ld a, [wMapPalOffset] ; tells if wCurMap is dark (requires HM5_FLASH?)
	ld b, a
	ld hl, FadePal4
	ld a, l
	sub b
	ld l, a
	jr nc, .ok
	dec h
.ok
	ld a, [hli]
	ldh [rBGP], a
	ld a, [hli]
	ldh [rBGP1], a
	ld a, [hli]
	ldh [rBGP2], a
	ld a, [hli]
	ldh [rOBP0], a
	ld a, [hli]
	ldh [rOBP1], a
	ret

GBFadeInFromBlack::
	ld hl, FadePal1
	ld b, 4
	jr GBFadeIncCommon

GBFadeOutToWhite::
	farcall SetPal_FadeWhite
	ld hl, FadePal5
	ld b, 4

GBFadeIncCommon:
	ld a, [hli]
	ldh [rBGP], a
	ld a, [hli]
	ldh [rBGP1], a
	ld a, [hli]
	ldh [rBGP2], a
	ld a, [hli]
	ldh [rOBP0], a
	ld a, [hli]
	ldh [rOBP1], a
	ld c, 4
	call DelayFrames
	dec b
	jr nz, GBFadeIncCommon
	ret

GBFadeOutToBlack::
	ld hl, FadePal4 + 5 - 1
	ld b, 4
	ld d, 2
	jr GBFadeDecCommon

GBFadeInFromWhite::
	farcall SetPal_FadeWhite
	ld hl, FadePal7 + 5 - 1
	ld b, 3
	ld d, 1

GBFadeDecCommon:
	ld a, [hld]
	ldh [rOBP1], a
	ld a, [hld]
	ldh [rOBP0], a
	ld a, [hld]
	ldh [rBGP2], a
	ld a, [hld]
	ldh [rBGP1], a
	ld a, [hld]
	ldh [rBGP], a
	ld c, 4
	call DelayFrames
	
; Load Normal map_palette_sets before the frame in `d` of the fade as to not have the final colors suddently "pop-in"
	ld a, b
	cp d
	jr nz, .nosetpaloverworld
	push hl
	push bc
	push de
	farcall SetPal_Overworld
	pop de
	pop bc
	pop hl
.nosetpaloverworld

	dec b
	jr nz, GBFadeDecCommon

	ret

; HAX: some of these palettes have been modified, mostly to make BGP/OBP0/OBP1 consistent
; with each other.
FadePal1:: dc 3,3,3,3, 3,3,3,3, 3,3,3,3, 3,3,3,3, 3,3,3,3
FadePal2:: dc 3,3,3,2, 3,3,2,3, 3,3,2,3, 3,3,3,2, 3,3,3,2 ; This is used in dark areas
FadePal3:: dc 3,3,2,1, 3,3,1,2, 3,2,1,3, 3,3,2,1, 3,3,2,1
FadePal4:: dc 3,2,1,0, 3,2,0,1, 3,1,0,2, 3,2,1,0, 3,2,1,0 ; This is the "standard" palette
;              rBGP     rBGP1    rBGP2    rOBP0    rOBP1
FadePal5:: dc 3,2,1,0, 3,2,0,1, 3,1,0,2, 3,2,1,0, 3,2,1,0
FadePal6:: dc 2,1,0,0, 2,1,0,0, 2,0,0,1, 2,1,0,0, 2,1,0,0
FadePal7:: dc 1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0, 1,0,0,0
FadePal8:: dc 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0
