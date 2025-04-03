PrepareOAMData::
; Determine OAM data for currently visible
; sprites and write it to wShadowOAM.
.wait
	ldh a, [rLY]
	cp $80
	jr nc, .wait

	ld a, [wUpdateSpritesEnabled]
	dec a
	jr z, .updateEnabled

	cp -1
	ret nz
	ld [wUpdateSpritesEnabled], a
	jp HideSprites

.updateEnabled
	xor a
	ldh [hOAMBufferOffset], a

.spriteLoop
	ldh [hSpriteOffset2], a

	ld d, HIGH(wSpriteStateData1)
	ldh a, [hSpriteOffset2]
	ld e, a
	ld a, [de] ; [x#SPRITESTATEDATA1_PICTUREID]
	and a
	jp z, .nextSprite

	inc e

	inc d
	ld a, [de]
	ld b, a
	and a
	jr z, .isZero
	sub $10
.isZero	
	ld c, a
	dec d

	inc e
	ld a, [de] ; [x#SPRITESTATEDATA1_IMAGEINDEX]
	ld [wSavedSpriteImageIndex], a
	cp $ff ; off-screen (don't draw)
	jr nz, .visible

	call GetSpriteScreenXY
	jp .nextSprite

.visible
	cp $a0 ; is the sprite unchanging like an item ball or boulder?
	jr c, .usefacing

; unchanging
	and $f
	add $10 ; skip to the second part of the table which doesn't account for facing direction
	add c
	jr .next

.usefacing
	and $f
	add b

.next
	ld l, a

; get sprite priority
	push de
	inc d
	ld a, e
	add $5
	ld e, a
	ld a, [de] ; [x#SPRITESTATEDATA2_GRASSPRIORITY]
	and OAM_BEHIND_BG | OAM_PALETTE
	ldh [hSpritePriority], a ; temp store sprite priority
	pop de

	call GetSpriteScreenXY

; read the entry from the table
	ld h, 0
	ld bc, SpriteFacingAndAnimationTable
	add hl, hl
	add hl, hl
	add hl, bc
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a

;	call GetSpriteScreenXY

	ldh a, [hOAMBufferOffset]
	ld e, a
	ld d, HIGH(wShadowOAM)

.tileLoop
	ldh a, [hSpriteScreenY]   ; temp for sprite Y position
	add $10                  ; Y=16 is top of screen (Y=0 is invisible)
	add [hl]                 ; add Y offset from table
	ld [de], a               ; write new sprite OAM Y position
	inc hl
	ldh a, [hSpriteScreenX]   ; temp for sprite X position
	add $8                   ; X=8 is left of screen (X=0 is invisible)
	add [hl]                 ; add X offset from table
	inc e
	ld [de], a               ; write new sprite OAM X position
	inc e
	ld a, [bc]               ; read pattern number offset (accommodates orientation (offset 0,4 or 8) and animation (offset 0 or $80))
	inc bc
	push bc
	ld b, a

	ld a, [wSavedSpriteImageIndex]
	swap a                   ; high nybble determines sprite used (0 is always player sprite, next are some npcs)
	and $f

	; Sprites $a and $b have one face (and therefore 4 tiles instead of 12).
	; As a result, sprite $b's tile offset is less than normal.
	cp $b
	jr nz, .notFourTileSprite
	ld a, $a * 12 + 4
	jr .next2

.notFourTileSprite
	; a *= 12
	sla a
	sla a
	ld c, a
	sla a
	add c

.next2
	add b ; add the tile offset from the table (based on frame and facing direction)
	ld [de], a ; tile id
	inc hl
	inc e

	bit BIT_END_OF_OAM_DATA, [hl]
	push af ; save end of OAM data flag
	bit BIT_SPRITE_UNDER_GRASS, [hl]
	ldh a, [hSpritePriority]
	jr nz, .hasPriority
	res OAM_PRIORITY, a ; res priority bit if not priority tile
.hasPriority
	ld b, a
	ld a, [hli]
	and OAM_VFLIP | OAM_HFLIP ; keep x/y flip attribute bits
	or b ; merge all attribute bits
	ld [de], a ; transfer attributes in wShadowOAM
	inc e
	pop af ; restore end of OAM data flag

	pop bc

	jr z, .tileLoop

	ld a, e
	ldh [hOAMBufferOffset], a

.nextSprite
	ldh a, [hSpriteOffset2]
	add $10
	cp LOW($100)
	jp nz, .spriteLoop

	; Clear unused OAM.
	ldh a, [hOAMBufferOffset]
	ld l, a
	ld h, HIGH(wShadowOAM)
	ld de, $4
	ld b, $a0
	ld a, [wMovementFlags]
	bit BIT_LEDGE_OR_FISHING, a
	ld a, $a0
	jr z, .clear

; Don't clear the last 4 entries because they are used for the shadow in the
; jumping down ledge animation and the rod in the fishing animation.
	ld a, $90

.clear
	cp l
	ret z
	ld [hl], b
	add hl, de
	jr .clear

GetSpriteScreenXY:
	ld b, l
	lb hl, 1, 8
	add hl, de

	inc e
	inc e
	ld a, [de] ; [x#SPRITESTATEDATA1_YPIXELS]
	add [hl]
	inc l
	ldh [hSpriteScreenY], a
	inc e
	inc e
	ld a, [de] ; [x#SPRITESTATEDATA1_XPIXELS]
	add [hl]
	ldh [hSpriteScreenX], a
	ld a, 4
	add e
	ld e, a

	ldh a, [hSpriteScreenY]
	add 4
	and $f0
	ld [de], a ; [x#SPRITESTATEDATA1_YADJUSTED]
	inc e
	ldh a, [hSpriteScreenX]
	and $f0
	ld [de], a  ; [x#SPRITESTATEDATA1_XADJUSTED]
	ld l, b

	ret
