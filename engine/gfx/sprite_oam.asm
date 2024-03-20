PrepareOAMData::
; Determine OAM data for currently visible
; sprites and write it to wShadowOAM.

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

	xor a
	ld [wPictureID], a ; reset value to 0

	ld a, [de] ; [x#SPRITESTATEDATA1_PICTUREID]
	ld b, a ; store PICTUREID in b to identify sprite

	and a
	jp z, .nextSprite

	inc e
	inc e
	ld a, [de] ; [x#SPRITESTATEDATA1_IMAGEINDEX]
	ld [wSavedSpriteImageIndex], a
	cp $ff ; off-screen (don't draw)
	jr nz, .visible

	call GetSpriteScreenXY
	jp .nextSprite

.visible
; Checking if sprite is in SpecialOAMlist ; see data/sprites/facings.asm
	ld a, b ; loading back PICTUREID to identify sprite
	ld hl, SpecialOAMlist ; loading list for identification and properties values
	push de ; save d and e
	ld de, 4 ; define the number of properties in list
	call IsInArray ; check if Sprite is in list ; modify a/b/de
	pop de ; restore d and e
	ld a, [wSavedSpriteImageIndex] ; restoring a to value before sprite identification
	jr nc, .notspecialsprite ; jump if not in list
	ld a, 1
	ld [wPictureID], a ; set value to 1 to later check if GetSpriteScreenXY function is called for a special sprite
	ld a, [wSavedSpriteImageIndex] 
	and $f
	inc hl; select Animation table property in SpecialOAMlist
	add [hl] ; load appropriate Animation Table value
	ld b, l ; preserve l in b for later use in GetSpriteScreenXY
	jr .next

; Original OAM Table selection code
.notspecialsprite
	cp $a0 ; is the sprite unchanging like an item ball or boulder?
	jr c, .usefacing

; unchanging
	and $f
	add $10 ; skip to the second part of the table which doesn't account for facing direction
	jr .next

.usefacing
	and $f

.next
	ld l, a

; get sprite priority
	push de
	inc d
	ld a, e
	add $5
	ld e, a
	ld a, [de] ; [x#SPRITESTATEDATA2_GRASSPRIORITY]
	and $80
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
	pop bc
	ld [de], a ; tile id
	inc hl
	inc e
	ld a, [hl]
	bit 1, a ; is the tile allowed to set the sprite priority bit?
	jr z, .skipPriority
	ldh a, [hSpritePriority]
	or [hl]
.skipPriority
	call _ColorOverworldSprite	; HAX
	bit 0, a ; OAMFLAG_ENDOFDATA
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
	ld a, [wd736]
	bit 6, a ; jumping down ledge or fishing animation?
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
	ld c, l ; preserve l from outside of the function
	inc e
	inc e
; Checking if sprite is in SpecialOAMlist ; see data/sprites/facings.asm
	ld a, [wPictureID]
	cp 1 ; check if function is called for a special sprite, set flag c if it's not
	ld a, [de] ; [x#SPRITESTATEDATA1_YPIXELS]
	push af ; save c flag from "add" operations, needed for next "jr nc, .noXoffset"
	jr c, .noYoffset
	ld l, b ; restore previously saved l to continue using the YX offset values from SpecialOAMlist
	inc hl ; select Y offset property in SpecialOAMlist
	add [hl] ; add Y offset value
.noYoffset
	ldh [hSpriteScreenY], a
	pop af ; restore c flag after "add" operations, needed for next "jr nc, .noXoffset"
	inc e
	inc e
	ld a, [de] ; [x#SPRITESTATEDATA1_XPIXELS]
	jr c, .noXoffset
	inc hl ; select X offset property in SpecialOAMlist
	add [hl] ; add X offset value
.noXoffset
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
	ld l, c ; restore l from outside of the function
	ret
