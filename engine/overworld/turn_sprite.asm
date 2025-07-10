UpdateSpriteFacingOffsetAndDelayMovement::
	ld h, HIGH(wSpriteStateData2)
;	ldh a, [hCurrentSpriteOffset]
	ldh a, [hSpriteIndex]
	swap a
	assert SPRITESTATEDATA1_FACINGDIRECTION == SPRITESTATEDATA2_MOVEMENTDELAY + 1
	add SPRITESTATEDATA2_MOVEMENTDELAY

;	add $8
	ld l, a
	ld a, $7f ; maximum movement delay
;	ld [hl], a ; x#SPRITESTATEDATA2_MOVEMENTDELAY
	ld [hli], a ; x#SPRITESTATEDATA2_MOVEMENTDELAY

	dec h ; HIGH(wSpriteStateData1)
;	ldh a, [hCurrentSpriteOffset]
;	add $9
;	ld l, a
	ld a, [hld] ; x#SPRITESTATEDATA1_FACINGDIRECTION
	ld b, a
	xor a
	ld [hld], a ; x#SPRITESTATEDATA1_ANIMFRAMECOUNTER
	ld [hl], a ;  x#SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER
;	ldh a, [hCurrentSpriteOffset]
;	add SPRITESTATEDATA1_IMAGEINDEX
	ld a, l
	assert SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER > SPRITESTATEDATA1_IMAGEINDEX
	sub SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER - SPRITESTATEDATA1_IMAGEINDEX

	ld l, a
	ld a, [hl] ; x#SPRITESTATEDATA1_IMAGEINDEX
;	and $f0
	or b ; or in the facing direction
	ld [hld], a
;	ld a, $2 ; delayed movement status
;	ld [hl], a ; x#SPRITESTATEDATA1_MOVEMENTSTATUS
	ld [hl], $2

	ret
