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
; If too close to vblank only update the sprites screen position to prevent sprite tearing.
	ldh a, [rLY]
	cp 133
	jr c, .fullUpdate

	ld hl, wShadowOAM + 4 * 4
	ld a, [rSCY]
	ld c, a
	ld a, [hSCY]
	sub c
	jr nz, .gotVector
	inc hl
	ld a, [rSCX]
	ld c, a
	ld a, [hSCX]
	sub c
	jr z, .fullUpdate
.gotVector
	ld c, a
	ld de, 4
	ld b, 36
	ld a, [wMovementFlags]
	bit BIT_LEDGE_OR_FISHING, a
	jr z, .notLedge
	ld b, 32
.notLedge	
	ld a, [hl]
	sub c
	ld [hl], a
	add hl, de
	dec b
	jr nz, .notLedge
	ret
.fullUpdate

	xor a
	ldh [hOAMBufferOffset], a

.spriteLoop
	ldh [hSpriteOffset2], a

	ld d, HIGH(wSpriteStateData1)
	ld e, a
	ld a, [de] ; [x#SPRITESTATEDATA1_PICTUREID]
	and a
	jp z, .nextSprite

	inc e
	inc e
	call GetSpriteScreenXY

	ld a, [hl] ; [x#SPRITESTATEDATA1_IMAGEINDEX]
	cp $ff ; off-screen (don't draw)
	jp z, .nextSprite

	swap a ; high nybble determines sprite used ($0 is always player sprite, $1 to $b are some npcs)
	and $f
	ld e, a
	ld a, [hld] ; [x#SPRITESTATEDATA1_IMAGEINDEX]
	and $f ; low nybble determines the current frame of the sprite
	ld c, a
	inc h
	ld b, [hl] ; [x#SPRITESTATEDATA2_$1] custom animation table used by the sprite if any, $0 if using default table

	ld a, l
	add 6
	ld l, a

	ld a, [hl] ; [x#SPRITESTATEDATA2_GRASSPRIORITY]
	and OAM_PRIO | OAM_BANK1 | OAM_PALETTE
	ldh [hSpritePriority], a ; temp store sprite priority

	ld d, 0
	ld hl, SpriteTileVRAMOffset
	add hl, de
	ld a, [hl]
	ld [wSavedSpriteImageIndex], a ; save sprite VRAM offset

	ld l, b
	ld h, d
	ld b, d

	ld a, e
.checkifstillsprite
	cp $a ; is it a still sprite like an item ball or boulder?
	jr c, .usefacing
	ld a, l
	and a
	jr nz, .usefacing
	inc l ; if the animation table is the default $0 for a still sprite, change it to table $1
.usefacing
	; Find line to use in SpriteFacingAndAnimationTable (data/sprites/facings.asm)
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl ; animation table value * 16 to find the start of the table used (each table have 16 lines)
	add hl, bc ; add sprite current frame value to find the line used in the table

	add hl, hl
	add hl, hl ; line value * 4 to get line byte offset in the tables list, each line have 4 bytes
	ld bc, SpriteFacingAndAnimationTable
	add hl, bc ; add the line byte offset and the table list address together in hl
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a ; tiles to use for the current frame in bc
	ld a, [hli]
	ld h, [hl]
	ld l, a ; cooridinates and properties of the tiles used in hl

	ldh a, [hOAMBufferOffset]
	ld e, a
	ld d, HIGH(wShadowOAM)

.tileLoop
;	ld a, [hli]
;	and a
;	jr z, .noTransparency
;	ldh a, [hBlink]
;	and a
;	ld a, 160
;	jr nz, .blink

;.noTransparency
	ldh a, [hSpriteScreenY]   ; temp for sprite Y position
	add [hl]                 ; add Y offset from table
;.blink	
	ld [de], a               ; write new sprite OAM Y position

	inc hl
	ldh a, [hSpriteScreenX]   ; temp for sprite X position
	add [hl]                 ; add X offset from table
	inc e
	ld [de], a               ; write new sprite OAM X position
	inc e
	ld a, [bc]               ; read pattern number offset (accommodates orientation (offset 0,4 or 8) and animation (offset 0 or $80))
	inc bc

	push bc
	ld b, a
	ld a, [wSavedSpriteImageIndex]
	add b ; add the tile offset from the table (based on frame and facing direction)
	ld [de], a ; tile id
	inc hl
	inc e

	ldh a, [hSpritePriority]
	ld b, a
	and OAM_BANK1 | OAM_PALETTE ; keep palette attribute bits
	or [hl]
	ld c, a
	and OAM_YFLIP | OAM_XFLIP ; keep x/y flip attribute bits
	or b
	and c
	ld [de], a ; transfer attributes in wShadowOAM
	inc e
	pop bc

	ld a, e
	cp LOW(wShadowOAMEnd) ; is the OAM full?
	ret z  ; if so stop there to prevent issues

	bit BIT_END_OF_OAM_DATA, [hl]
	inc hl
	jr z, .tileLoop

	ldh [hOAMBufferOffset], a

.nextSprite
	ldh a, [hSpriteOffset2]
	add $10
	jp nz, .spriteLoop

	; Clear unused OAM.
	ldh a, [hOAMBufferOffset]
	ld l, a
	ld h, HIGH(wShadowOAM)
	ld de, $4
	ld b, $a0
	ld a, [wMovementFlags]
	bit BIT_LEDGE_OR_FISHING, a
IF SHADOW_TRANSPARENCY
	push af
ENDC
	ld a, LOW(wShadowOAMEnd)
	jr z, .clear
; Don't clear the last 4 entries because they are used for the shadow in the
; jumping down ledge animation and the rod in the fishing animation.
	ld a, LOW(wShadowOAMEnd) - 4 * 4

.clear
	ld [hl], b
	add hl, de
	cp l
	jr nz, .clear
IF SHADOW_TRANSPARENCY
; Done if not jumping down ledge
	pop af
	bit BIT_LEDGE_OR_FISHING - 1, a
	ret z

; Hide the jumping down ledge shadow every other frame for transparency effect
	ldh a, [hBlink]
	and a
	ld b, 2
	ld a, $54
	jr z, .visibleShadow
	ld a, 160
.visibleShadow
	ld c, 2
.visibleShadowLoop
	ld [hl], a
	add hl, de
	dec c
	jr nz, .visibleShadowLoop
	dec b
	ret z
	add 8
	jr .visibleShadow
ELSE
	ret
ENDC

GetSpriteScreenXY:
	push de
	inc e
	inc e
	lb hl, 1, 6
	add hl, de

	ld a, [de] ; [x#SPRITESTATEDATA1_YPIXELS]
	add [hl] ; [x#SPRITESTATEDATA2_$A] custom Y pixel offset, $0 if none
	add $10    ; Y=16 is top of screen (Y=0 is invisible)
	ldh [hSpriteScreenY], a
	sub $10 - 4 ; sub the value added previously, minus the 4 pixel Y offset of the sprite
	and $f0
	dec h
	ld [hli], a ; [x#SPRITESTATEDATA1_YADJUSTED]
	inc e
	inc e
	ld a, [de] ; [x#SPRITESTATEDATA1_XPIXELS]
	and $f0
	ld [hl], a ; [x#SPRITESTATEDATA1_XADJUSTED]
	ld a, [de] ; reload the unmodified value from DE to calculate hSpriteScreenX
	inc h
	add [hl] ; [x#SPRITESTATEDATA2_$B] custom X pixel offset, $0 if none
	add $8     ; X=8 is left of screen (X=0 is invisible)
	ldh [hSpriteScreenX], a

	pop hl
	ret

SpriteTileVRAMOffset:
	db $0 * 24
	db $1 * 24
	db $2 * 24
	db $3 * 24
	db $4 * 24
	db $0 * 24
	db $1 * 24
	db $2 * 24
	db $3 * 24
	db $4 * 24
	db $5 * 24      ; Sprites $a and $b have one face (and therefore 4 tiles instead of 12).
	db $5 * 24 + 4  ; As a result, sprite $b's tile offset is less than normal.
