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

	jr .fullUpdate

; If too close to vblank only update the sprites screen position to prevent sprite tearing.
	ldh a, [rLY]
	cp 144
	jr nc, .fullUpdate ; full update if in vblank
	cp 133
	jr c, .fullUpdate ; full update if enought time before vblank

	ld b, 160
	ld a, [rSCY]
	ld c, a
	ld a, [hSCY]
	sub c
	jr nz, .gotVector
	ld b, 168
	inc hl
	ld a, [rSCX]
	ld c, a
	ld a, [hSCX]
	sub c
	ret z

.gotVector
	ld c, a

	ld a, [wMovementFlags]
	ld d, a
	ld a, [wSpritePlayerStateData2 + $F]
	and %0001_0001
	ld a, 36
	jr z, .dontPreventShiftingReflection
	sub 4
.dontPreventShiftingReflection
	bit BIT_LEDGE, d
	jr z, .dontPreventShiftingJumpShadow
	sub 4
.dontPreventShiftingJumpShadow

	ld d, a
	ld e, 4
	ld hl, wShadowOAM + 4 * 4	
.oamShiftLoop
	ld a, [hl]
	cp b
	jr nc, .passShift
	sub c
	ld [hl], a
.passShift
	ld a, l
	add e
	ld l, a
	dec d
	jr nz, .oamShiftLoop
	ret
.fullUpdate

	ld a, [wMovementFlags]
	and (1 << BIT_CUTTING) | (1 << BIT_LEDGE) | (1 << BIT_FISHING)
	ld b, a
	ld a, LOW(wShadowOAMEnd) - 1
	jr z, .gotOAMEndPosition
; Don't clear the last 4 entries because they are used for the shadow in the
; jumping down ledge animation and the rod in the fishing animation.
	ld a, LOW(wShadowOAMSprite39) - 1
	bit BIT_FISHING, b
	jr nz, .gotOAMEndPosition
	ld a, LOW(wShadowOAMSprite36) - 1
.gotOAMEndPosition
	ld [wEndOfOAMCleaner], a

	ld a, [wStatusFlags3]
	bit BIT_EMOTION_BUBBLE, a
	ld a, 4*4
	jr nz, .emotionBubble	
	xor a
.emotionBubble
	ldh [hOAMBufferOffset], a
	xor a

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

;	ld a, [hl] ; [x#SPRITESTATEDATA1_IMAGEINDEX]
	ld a, [hld] ; [x#SPRITESTATEDATA1_IMAGEINDEX]
	cp $ff ; off-screen (don't draw)
	jp z, .nextSprite

	and $f ; low nybble determines the current frame of the sprite
	ld c, a
;	ld a, [hld] ; [x#SPRITESTATEDATA1_IMAGEINDEX]
	inc h
;	swap a ; high nybble determines sprite used ($0 is always player sprite, $1 to $b are some npcs)
;	and $f
;	ld e, a

;	cp $a ; is it a still sprite like an item ball or boulder?
	ld a, [hl] ; [x#SPRITESTATEDATA2_$1] custom animation table used by the sprite if any, $0 if using default table
	ld b, a
;	jr c, .gotAnimationTableOffset
;	and a
;	jr nz, .gotAnimationTableOffset
;	ld c, a
;.gotAnimationTableOffset

	ld a, l
	add 6
	ld l, a

	ld a, [hl] ; [x#SPRITESTATEDATA2_GRASSPRIORITY]
	ldh [hSpritePriority], a ; temp store sprite priority

;;;;;;;;;;;;;;;;;;;;;;
	ld a, l
	add 7
	ld l, a
	ld a, [hl] ; [x#SPRITESTATEDATA2_IMAGEBASEOFFSET]
	dec a
	ld e, a
	cp $a ; is it a still sprite like an item ball or boulder?
	ld a, b
	jr c, .gotAnimationTableOffset
	and a
	jr nz, .gotAnimationTableOffset
	ld c, a
.gotAnimationTableOffset
;;;;;;;;;;;;;;;;;;;;;

	ld d, 0
	ld hl, SpriteTileVRAMOffset
	add hl, de
	ld a, [hl]
	ld [wSavedSpriteImageIndex], a ; save sprite VRAM offset	

	ld l, b
	ld h, d
	ld b, d

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
;	push af ; save LOW(object OAM starting address)
	ld e, a
	ld d, HIGH(wShadowOAM)

.tileLoop
	ld a, [hli]
	and a
	jr z, .noTransparency
	ldh a, [hBlink]
	add a
	jr nz, .blink
.noTransparency
	ldh a, [hSpriteScreenY]   ; temp for sprite Y position
	add [hl]                 ; add Y offset from table
	inc hl
.blink
;	cp 9
;	jr c, .tileInvisibleY
;	cp 160
;	jr c, .tileVisibleY
;.tileInvisibleY
;	inc hl
;.tileInvisibleX
;	inc bc
;	scf
;	jr .passTile
;.tileVisibleY
	ld [de], a               ; write new sprite OAM Y position
	ldh a, [hSpriteScreenX]   ; temp for sprite X position
	add [hl]                 ; add X offset from table
	inc hl
;	and a
;	jr z, .tileInvisibleX
;	cp 168
;	jr nc, .tileInvisibleX
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
	inc e	

	ldh a, [hSpritePriority]
	xor [hl]
	and ~(OAM_YFLIP | OAM_XFLIP)
	xor [hl]
	ld b, a
	xor [hl]
	and ~OAM_PRIO 
	xor [hl]
	and b

	ld [de], a ; transfer attributes in wShadowOAM
	inc e
	pop bc

	ld a, e
	cp LOW(wShadowOAMEnd) ; is the OAM full?
	ret z ; if so stop there to prevent issues

;	jr nz, .notEndOfOAM
;	pop bc ; pop saved LOW(object OAM starting address)
;	ret
;.notEndOfOAM

	bit BIT_END_OF_OAM_DATA, [hl]
	inc hl
	jr z, .tileLoop

	ld a, e
	ldh [hOAMBufferOffset], a

;	jr .noReflection

	ld a, [wEndOfOAMCleaner]
	sub 16
	cp e
	jr c, .noReflection ; skip reflection if it would overwrite current sprites

;	ldh a, [hPassedOamTiles]
;	and %1111
;	cp %1111 ; if all tiles have been passed, no reflection
;	jr nc, .noReflection

	ld h, HIGH(wSpritePlayerStateData2)
	ldh a, [hSpriteOffset2]
	add $F
	ld l, a
	ld a, [hl]
	and a
	jr z, .noReflection

	call SpriteReflection
	ld a, e
	ld [wEndOfOAMCleaner], a
.noReflection

;	pop bc ; retrieve LOW(object OAM starting address) in b
;	call CullInvisibleTiles

	ldh a, [hSpriteOffset2]
	and a
	jr nz, .nextSprite
	ld a, [wMovementFlags]
	bit BIT_FISHING, a
	jr z, .nextSprite
	ldh a, [hOAMBufferOffset]
	ld e, a
	ld hl, wShadowOAMSprite39
REPT 4
	ld a, [hli]
	ld [de], a
	inc e
ENDR
	ld a, e
	ldh [hOAMBufferOffset], a

.nextSprite

	ldh a, [hSpriteOffset2]
	add $10
	jp nz, .spriteLoop

	; Clear unused OAM.
	ldh a, [hOAMBufferOffset]
	ld l, a
	ld h, HIGH(wShadowOAM)
	ld de, OBJ_SIZE
	ld b, SCREEN_HEIGHT_PX + OAM_Y_OFS
;	ld a, [wMovementFlags]
;	bit BIT_LEDGE_OR_FISHING, a
;IF SHADOW_TRANSPARENCY
;	push af
;ENDC
;	ld a, LOW(wShadowOAMEnd)
;	jr z, .clear
;; Don't clear the last 4 entries because they are used for the shadow in the
;; jumping down ledge animation and the rod in the fishing animation.
;	ld a, LOW(wShadowOAMSprite36)

	ld a, [wEndOfOAMCleaner]
	inc a
	cp l
IF SHADOW_TRANSPARENCY
	jr z, .doneClearing
	jr c, .doneClearing
ELSE
	ret z
	jr nc, .clear
	xor a
	ret
ENDC

.clear
	ld [hl], b
	add hl, de
	cp l
	jr nz, .clear

IF SHADOW_TRANSPARENCY
.doneClearing
; Done if not jumping down ledge
;	pop af
	ld a, [wMovementFlags]
	bit BIT_LEDGE, a
	ret z

; Hide the jumping down ledge shadow every other frame for transparency effect
	ldh a, [hBlink]
	add a
	ld b, 2
	jr nz, .invisibleShadow
	ld a, $54
.invisibleShadow
	ld c, 2
.invisibleShadowLoop
	ld [hl], a
	add hl, de
	dec c
	jr nz, .invisibleShadowLoop
	dec b
	ret z
	add 8
	jr .invisibleShadow
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

SpriteReflection:
	ld c, a
	ld h, d
	ld l, e
	dec l
	ld a, [wEndOfOAMCleaner]
	ld e, a

	ldh a, [hBlink]
	ld b, a

	bit 0, c
	call nz, FloorReflection

	bit 4, c
	ret z

	bit 6, c
	jr nz, .clearReflection
	ld a, b
	and a
	ret nz
.clearReflection

	ld a, 3
	ldh [rWBK], a
	ld a, [hSpriteOffset2]
	swap a
	add LOW(w3MirrorReflectionDistance)
	ld c, a
	ld b, HIGH(w3MirrorReflectionDistance)
	ld a, [bc]
	ld b, a
	xor a
	ldh [rWBK], a
	ld a, b
	ldh [hSpriteScreenY], a

	ldh a, [hSpriteOffset2]
	add SPRITESTATEDATA1_IMAGEINDEX
	ld c, a
	ld b, HIGH(wSpriteStateData1)
	ld a, [bc]
	ld bc, 0
	and $f
	cp 8
	jr nc, .gotMirroringValues
	lb bc, -4, 8
	cp 7
	jr z, .gotMirroringValues
	cp 3
	jr z, .facingDown
	ld c, -8
	cp 4
	jr nc, .gotMirroringValues
.facingDown
	ld b, 4

.gotMirroringValues
	cp 8 ; to set c flag if facing up or down
	ld a, 4
.nextWallReflectionTile
	push af

;	ldh a, [hPassedOamTiles]
;	rrca
;	ldh [hPassedOamTiles], a
;	jr c, .passTile
;	pop af
;	push af

	; attributes
	ld a, [hld]
	jr nc, .passXFlip
	xor OAM_XFLIP
.passXFlip
	or OAM_PRIO
	ld [de], a
	dec e
	; tile ID
	ld a, [hld]
	add b
	ld [de], a
	dec e
	; X position
	ld a, [hld]
	add c
	ld [de], a
	dec e
	; Y position
	ldh a, [hSpriteScreenY]
	add [hl]
	dec l
	ld [de], a
	dec e

.passTile
	ld a, c
	cpl
	inc a
	ld c, a

	pop af
	dec a
	jr nz, .nextWallReflectionTile

	ret

FloorReflection:
	ld a, b
	and a
	ret z

	push bc
	push hl

	ld a, 3
	ldh [rWBK], a
	ld a, [hSpriteOffset2]
	swap a
	ld c, a
	ld b, HIGH(w3FloorReflectionDistance)
	ld a, [bc]
	ld b, a
	xor a
	ldh [rWBK], a
	ld a, b
	ld c, 4

.nextFloorReflectionRow
	ld b, a
.nextFloorReflectionTile

;	ldh a, [hPassedOamTiles]
;	rrca
;	ldh [hPassedOamTiles], a
;	jr c, .passTile

	; attributes
	ld a, [hld]
	or OAM_YFLIP | OAM_PRIO 
	ld [de], a
	dec e
	; tile ID
	ld a, [hld]
	ld [de], a
	dec e
	; X position
	ld a, [hld]
	ld [de], a
	dec e
	; Y position
	ld a, [hld]
	add b
	ld [de], a
	dec e
.passTile
	dec c
	jr z, .doneFloorReflection
	bit 0, c
	jr nz, .nextFloorReflectionTile
	ld a, b
	add 16
	jr .nextFloorReflectionRow
.doneFloorReflection
	pop hl
	pop bc

;	ldh a, [hPassedOamTiles]
;	swap a
;	ldh [hPassedOamTiles], a

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

CullInvisibleTiles:
	ldh a, [hOAMBufferOffset]
	ld l, a
	ld h, d

.cullLastTiles
	ld a, l
	ldh [hOAMBufferOffset], a
	cp b ; LOW(object OAM starting address)
	ret z
	dec l
	dec l
	dec l
	ld a, [hld]
	and a
	jr z, .cullLastTiles
	cp 168
	jr nc, .cullLastTiles
	ld a, [hl]
	cp 9
	jr c, .cullLastTiles
	cp 160
	jr nc, .cullLastTiles

; Found first visible tile
	ld a, l
	cp b ; LOW(object OAM starting address)
	ret z

	ld c, 1 ; initialize visible tile counter

.countVisibleTiles
	dec l
	dec l
	dec l
	ld a, [hld]
	and a
	jr z, .foundInvisibleTile
	cp 168
	jr nc, .foundInvisibleTile
	ld a, [hl]
	cp 9
	jr c, .foundInvisibleTile
	cp 160
	jr nc, .foundInvisibleTile
	inc c
	ld a, l
	cp b ; LOW(object OAM starting address)
	jr nz, .countVisibleTiles
	ret
.foundInvisibleTile

; counted visible tiles and found first invisible tile
	ld a, l
	add 4
	ld e, a ; address of last visible tile found

	push bc

.findLastInvisibleTile
	ld a, l
	cp b ; LOW(object OAM starting address)
	jr z, .foundLastInvisibleTile
	dec l
	dec l
	dec l
	ld a, [hld]
	and a
	jr z, .findLastInvisibleTile
	cp 168
	jr nc, .findLastInvisibleTile
	ld a, [hl]
	cp 9
	jr c, .findLastInvisibleTile
	cp 160
	jr nc, .findLastInvisibleTile

	ld a, l
	add 4
	ld l, a ; address of last invisible tile found

.foundLastInvisibleTile

	push hl

.shiftVisibleTiles
REPT 4
	ld a, [de]
	inc e
	ld [hli], a
ENDR
	dec c
	jr nz, .shiftVisibleTiles
	ld a, l
	ldh [hOAMBufferOffset], a

	pop hl
	pop bc

	ld a, l
	cp b ; LOW(object OAM starting address)
	ret z
	jr .countVisibleTiles
