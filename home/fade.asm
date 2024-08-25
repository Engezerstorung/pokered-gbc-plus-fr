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
	ldh [rOBP0], a
	ld a, [hli]
	ldh [rOBP1], a
	ld c, 4
	call DelayFrames
	dec b
	jr nz, GBFadeIncCommon
	ret

GBFadeOutToBlack::
	ld hl, FadePal4 + 2
	ld b, 4
	jr GBFadeDecCommon

GBFadeInFromWhite::
	farcall SetPal_FadeWhite
	ld hl, FadePal7 + 2
	ld b, 3

GBFadeDecCommon:
	ld a, [hld]
	ldh [rOBP1], a
	ld a, [hld]
	ldh [rOBP0], a
	ld a, [hld]
	ldh [rBGP], a
	ld c, 4
	call DelayFrames
	
; Load Normal map_palette_sets before the last frame of the fade as to not have the final colors suddently "pop-in"
	ld a, b
	cp 2
	push hl
	push bc
	jr nz, .nosetpaloverworld
	farcall SetPal_Overworld
.nosetpaloverworld
	pop bc
	pop hl

	dec b
	jr nz, GBFadeDecCommon

	ret

; HAX: some of these palettes have been modified, mostly to make BGP/OBP0/OBP1 consistent
; with each other.
FadePal1:: dc 3,3,3,3, 3,3,3,3, 3,3,3,3
FadePal2:: dc 3,3,3,2, 3,3,3,2, 3,3,3,2 ; This is used in dark areas
FadePal3:: dc 3,3,2,1, 3,3,2,1, 3,3,2,1
FadePal4:: dc 3,2,1,0, 3,2,1,0, 3,2,1,0 ; This is the "standard" palette
;              rBGP     rOBP0    rOBP1
FadePal5:: dc 3,2,1,0, 3,2,1,0, 3,2,1,0
FadePal6:: dc 2,1,0,0, 2,1,0,0, 2,1,0,0
FadePal7:: dc 1,0,0,0, 1,0,0,0, 1,0,0,0
FadePal8:: dc 0,0,0,0, 0,0,0,0, 0,0,0,0
