InitMapSprites::
; Loads tile patterns for map's sprites.
; For outside maps, it loads one of several fixed sets of sprites.
; For inside maps, it loads each sprite picture ID used in the map header.
; This is also called after displaying text because loading
; text tile patterns overwrites half of the sprite tile pattern data.
; Note on notation:
; x#SPRITESTATEDATA1_* and x#SPRITESTATEDATA2_* are used to denote wSpriteStateData1 and
; wSpriteStateData2 sprite slot, respectively, within loops. The X is the loop index.
; If there is an inner loop, Y is the inner loop index, i.e. y#SPRITESTATEDATA1_* and
; y#SPRITESTATEDATA2_* denote fields of the sprite slots iterated over in the inner loop.

	call LoadSpriteSetFromMapHeader

	call LoadMapSpritesImageBaseOffset
	farcall SpriteSpecialProperties
	farcall ColorOverworldNpcSprites

	jp LoadMapSpriteTilePatterns

LoadSpriteSetFromMapHeader:
; This loop stores the correct VRAM tile pattern slots according the sprite
; data from the map's header. Since the VRAM tile pattern slots are filled in
; the order of the sprite set, in order to find the VRAM tile pattern slot
; for a sprite slot, the picture ID for the sprite is looked up within the
; sprite set. The index of the picture ID within the sprite set plus two
; (since the Red sprite always has the first VRAM tile pattern slot and the
; Pikachu sprite reserves the second slot) is the VRAM tile pattern slot.
	ld hl, wSpriteSet
	ld bc, wSpriteSetID - wSpriteSet
	xor a
	call FillMemory
;	ld a, SPRITE_PIKACHU ; load Pikachu separately
;	ld [wSpriteSet], a
	ld hl, wSprite01StateData1
	ld a, 15
.storeVRAMSlotsLoop
	push af
	ld a, [hli] ; [x#SPRITESTATEDATA1_PICTUREID] (zero if sprite slot is not used)
	and a ; is the sprite slot used?
	jr z, .noSpriteToLoad ; if the sprite slot is not used

	ld b, a
	inc l
	ld a, [hl]
	inc a
	jr z, .noSpriteToLoad ; if the sprite slot is not used
	ld a, b

;	call SpriteSwap

	ld c, a

	ld de, wSpriteSet
	ld b, 9

	cp FIRST_STILL_SPRITE   ; is this a four tile sprite?
	jr c, .continue

	ld de, wSpriteSet + 9
	ld b, 2

.continue
	call CheckIfPictureIDAlreadyLoaded
.noSpriteToLoad
	ld a, l
	and $F0
	add SPRITESTATEDATA1_LENGTH
	ld l, a
	pop af
	dec a
	jr nz, .storeVRAMSlotsLoop
	ret

CheckIfPictureIDAlreadyLoaded:
; Check if the current picture ID has already had its tile patterns loaded.
; This done by looping through the previous sprite slots and seeing if any of
; their picture ID's match that of the current sprite slot.
.loop
	ld a, [de]
	and a ; is sprite set slot not taken up yet?
	jr z, .spriteSlotNotTaken ; if so, load it as it signifies we've reached
	                          ; the end of data for the last sprite set

	cp c  ; is the tile pattern already loaded?
	ret z ; don't redundantly load
	dec b ; have we reached the end of the sprite set?
	jr z, .spriteNotAlreadyLoaded ; if so, we're done here
	inc de
	jr .loop

.spriteSlotNotTaken
	ld a, c	
	ld [de], a
	ret
.spriteNotAlreadyLoaded
	scf
	ret

LoadMapSpriteTilePatterns:
	xor a
.loop
	ldh [hVRAMSlot], a

	call LoadTilePattern

	ldh a, [hVRAMSlot]
.alreadyLoadedInVRAM
	inc a
	cp 11
	jr nz, .loop
	xor a
	ldh [rVBK], a
	scf
	ret

LoadTilePattern:
	call ReadSpriteSheetData
	ret nc
	call GetSpriteVRAMAddress

	ldh [rVBK], a
	jp CopyVideoDataVDMA

GetSpriteVRAMAddress:
	push bc
	ldh a, [hVRAMSlot]
	ld c, a
	ld b, 0
	ld hl, SpriteVRAMAddresses
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, b
	pop bc
	ret

SpriteVRAMAddresses:
; vBank, vRAM addresse
	dbw 0, vChars0 + (1 * 24) tiles
	dbw 0, vChars0 + (2 * 24) tiles
	dbw 0, vChars0 + (3 * 24) tiles
	dbw 0, vChars0 + (4 * 24) tiles
	dbw 1, vChars0 + (0 * 24) tiles
	dbw 1, vChars0 + (1 * 24) tiles
	dbw 1, vChars0 + (2 * 24) tiles
	dbw 1, vChars0 + (3 * 24) tiles
	dbw 1, vChars0 + (4 * 24) tiles
	dbw 0, vChars0 + (5 * 24) tiles ; 4-tile sprites
	dbw 0, vChars0 + (5 * 24 + 4) tiles ; 4-tile sprites

ReadSpriteSheetData:
	ldh a, [hVRAMSlot]
	ld e, a
	ld d, 0
	ld hl, wSpriteSet
	add hl, de
	ld a, [hl]
	and a
	ret z
	dec a
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	ld de, SpriteSheetPointerTable
	add hl, de

	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ldh a, [hVRAMSlot]
	cp 9
	ld a, [hli]
	jr nc, .done
	add a
.done
	ld c, a
	ld b, [hl]

	scf
	ret

LoadMapSpritesImageBaseOffset:
	ld a, $1
	ld [wSpritePlayerStateData2ImageBaseOffset], a ; vram slot for player

	ld hl, wSprite01StateData1
.loop
	ld a, [hli] ; [x#SPRITESTATEDATA1_PICTUREID]
	and a ; is the sprite unused?
	jr z, .spriteUnused

	ld b, a
	inc l
	ld a, [hl]
	inc a
	jr z, .spriteUnused
	ld a, b

;	call SpriteSwap
	ld [hl], a

	call GetSpriteImageBaseOffset
	push hl
	ld de, wSpritePlayerStateData2ImageBaseOffset - wSpriteStateData1
	add hl, de ; [x#SPRITESTATEDATA2_IMAGEBASEOFFSET]
	ld [hl], a ; write offset

	push hl
	ld hl, SpriteVRAMAddresses
	sub 2
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	add hl, de
	bit 0, [hl]
	pop hl

	ld de, -7
	add hl, de
	res B_OAM_BANK1, [hl]
	jr z, .vbank0
	set B_OAM_BANK1, [hl]
.vbank0

	pop hl
.spriteUnused
	ld a, l
	and $F0
	add SPRITESTATEDATA1_LENGTH
	ld l, a
	jr nz, .loop
	ret

GetSpriteImageBaseOffset:
	push de
	push bc
	ld c, a  ; c = picture ID
	ld b, 11
	ld de, wSpriteSet
.findSpriteImageBaseOffsetLoop
	ld a, [de] ; a = sprite set picture ID
	cp c ; have we found a match?
	jr z, .foundSpritePictureID ; if so, get the sprite image base offset and return
	inc de
	dec b ; have we looped through all entries in wSpriteSet?
	jr nz, .findSpriteImageBaseOffsetLoop ; continue looping if not
	ld a, $1 ; assume slot one if this ever happens
	jr .done
.foundSpritePictureID
	ld a, 13
	sub b ; get sprite image base offset
.done
	pop bc
	pop de
	ret

SpriteSwap:
	ld [wSavedSpritePictureID], a
	push hl
	push bc
	farcall _SpriteSwap
	pop bc
	pop hl
	ret

INCLUDE "data/maps/sprite_sets.asm"

INCLUDE "data/sprites/sprites.asm"
