DEF MAP_TILESET_SIZE EQU $60

UpdatePlayerSprite:
	ld a, [wSpritePlayerStateData2WalkAnimationCounter]
	and a
	jr z, .checkIfTextBoxInFrontOfSprite
	cp $ff
	jr z, .disableSprite
	dec a
	ld [wSpritePlayerStateData2WalkAnimationCounter], a
	jr .disableSprite
; check if a text box is in front of the sprite by checking if the lower left
; background tile the sprite is standing on is greater than $5F, which is
; the maximum number for map tiles
.checkIfTextBoxInFrontOfSprite
	lda_coord 8, 9
	ldh [hTilePlayerStandingOn], a

	ld a, 2
	ldh [rWBK], a
	lda_coord 8, 9, W2_TileMapPalMap
	and 7
	cp 7
	ld a, 0
	ldh [rWBK], a
	jr nz, .lowerLeftTileIsMapTile

.disableSprite
	ld a, [wSpritePlayerStateData1ImageIndex]
	inc a
	ret z

	ld a, [wSpriteFlags]
	set 1, a
	ld [wSpriteFlags], a

	ld a, $ff
	ld [wSpritePlayerStateData1ImageIndex], a
	ret
.lowerLeftTileIsMapTile
	call DetectCollisionBetweenSprites
	ld h, HIGH(wSpriteStateData1)
	ld a, [wWalkCounter]
	and a
	ld b, 4
	jr nz, .moving
	ld a, [wPlayerMovingDirection]
; check if down
	bit PLAYER_DIR_BIT_DOWN, a
	jr z, .checkIfUp
	xor a ; ld a, SPRITE_FACING_DOWN
	jr .next
.checkIfUp
	bit PLAYER_DIR_BIT_UP, a
	jr z, .checkIfLeft
	ld a, SPRITE_FACING_UP
	jr .next
.checkIfLeft
	bit PLAYER_DIR_BIT_LEFT, a
	jr z, .checkIfRight
	ld a, SPRITE_FACING_LEFT
	jr .next
.checkIfRight
	bit PLAYER_DIR_BIT_RIGHT, a
	jr z, .notMoving
	ld a, SPRITE_FACING_RIGHT
	jr .next
.notMoving
; zero the animation counters if not surfing
	ld a, [wWalkBikeSurfState]
	cp 2
	ld b, 12
	jr z, .moving
	xor a
	ld [wSpritePlayerStateData1IntraAnimFrameCounter], a
	ld [wSpritePlayerStateData1AnimFrameCounter], a
	jr .calcImageIndex
.next
	ld [wSpritePlayerStateData1FacingDirection], a
	ld a, [wFontLoaded]
	bit BIT_FONT_LOADED, a
	jr nz, .notMoving
.moving
	ld a, [wMovementFlags]
	bit BIT_SPINNING, a
	jr nz, .skipSpriteAnim
	ldh a, [hCurrentSpriteOffset]
	add $7
	ld l, a
	ld a, [hl]
	inc a
	ld [hl], a
	cp b
	jr c, .calcImageIndex
	xor a
	ld [hl], a
	inc hl
	ld a, [hl]
	inc a
	and $3
	ld [hl], a
.calcImageIndex

	ld a, [wSpritePlayerStateData1ImageIndex]
	inc a
	jr nz, .dontSetBit
	ld a, [wSpriteFlags]
	set 1, a
	ld [wSpriteFlags], a
.dontSetBit

	ld a, [wSpritePlayerStateData1AnimFrameCounter]
	ld b, a
	ld a, [wSpritePlayerStateData1FacingDirection]
	add b
	ld [wSpritePlayerStateData1ImageIndex], a
.skipSpriteAnim

; Set bits related to the generation of the player reflections on reflective surfaces
	ld d, 0
	ld b, d

	ld a, [wCurMapTileset]
	ld c, a
	ld hl, .tilesetsReflectionPointers
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a

	ld a, [hli]
	and a
	jp z, .noReflections

	ldh a, [hTilePlayerStandingOn]
	ld c, a
	lda_coord 8, 11 ; bottom-left tile south of player
	ld b, a

;	lda_coord 8, 10 ; top-left tile south of player
;	ld e, a

	push hl

.floorReflectionLoop
	ld a, [hli]
	and a
	jr z, .noFloorReflection
.checkFloorTile
	cp c
	jr z, .haveFloorReflection
	cp b
	jr nz, .floorReflectionLoop

;	cp e
;	jr z, .haveFloorReflection

	set 1, d
.haveFloorReflection
	inc d ; set 0, d
.passfloorReflection
	ld a, [hli]
	and a
	jr nz, .passfloorReflection
.noFloorReflection

	bit 1, d
	res 1, d
	jr z, .passShoreTile
	lda_coord 8, 10 ; shore tile south of player
	ld b, a
.checkShoreTile
	ld a, [hli]
	and a
	jr z, .noShoreTile
	cp b
	jr nz, .checkShoreTile
	set 1, d
.passShoreTile
	ld a, [hli]
	and a
	jr nz, .passShoreTile
.noShoreTile

	ld a, [wPlayerMovingDirection]
	ld e, a
	ld a, [wWalkCounter]
	cp 3
	lda_coord 8, 7 ; tile north of player
	jr c, .NotMovingAway
	bit PLAYER_DIR_BIT_DOWN, e
	jr z, .NotMovingAway
	lda_coord 8, 5 ; tile 1 coord further north of player
.NotMovingAway
	ld b, a

	set 6, d
	ld e, 2
.wallMirrorReflectionLoop
	ld a, [hli]
	and a
	jr z, .noWallMirrorReflectionsOfThisType
	cp b
	jr nz, .wallMirrorReflectionLoop
	pop hl
	jr .haveWallMirrorReflection
.noWallMirrorReflectionsOfThisType
	res 6, d
	dec e
	jr nz, .wallMirrorReflectionLoop
	pop hl

	bit 0, d
	jr nz, .noReflections

	ld e, 2
.floorMirrorReflectionLoop
	ld a, [hli]
	and a
	jr z, .noFloorMirrorReflectionOfThisType
	cp b
	jr z, .haveFloorMirrorReflection
	jr .floorMirrorReflectionLoop
.noFloorMirrorReflectionOfThisType
	dec e
	jr nz, .floorMirrorReflectionLoop
	jr .noReflections

.haveFloorMirrorReflection
	set 5, d
.haveWallMirrorReflection
	set 4, d

.noReflections
	ld a, d
	ld [wSpritePlayerStateData2 + $F], a

	and a
	jr z, .noReflectionDistances

	ld a, [wWalkBikeSurfState]
	ld b, a
	ld a, [wPlayerMovingDirection]
	ld e, a

	ld a, 3
	ldh [rWBK], a

	bit 0, d
	jr z, .noFloorReflectionDistance

	bit 1, d
	ld a, 14 ; distance if shore tile
	jr nz, .gotFlootRelfectionDistance

	ld a, b ; wWalkBikeSurfState
	cp 2
	ld a, -3 ; distance if swimming
	jr z, .gotFlootRelfectionDistance

	ld a, 7 ; default distance

.gotFlootRelfectionDistance
	ld [w3FloorReflectionDistance], a

.noFloorReflectionDistance

	bit 4, d
	jr z, .doneMirrorReflectionDistance

	bit 5, d

	ld a, -9 ; default floor mirror reflection distance
	jr nz, .gotMirrorReflectionDistance
	ld a, -13 ; default wall mirror reflection distance	
	ld [w3MirrorReflectionDistance], a

	ld a, e ; wPlayerMovingDirection
	and %1100
	jr z, .doneMirrorReflectionDistance
	ld c, a
	ld a, [wWalkCounter]
	and a
	jr z, .doneMirrorReflectionDistance
	bit PLAYER_DIR_BIT_UP, c
	ld b, 10
	jr nz, .gotYShiftOffset
	cpl
	add 1+ 7
	ld b, 20
.gotYShiftOffset
	ld c, a
	add a
	add c
	add b
	cpl
	inc a
.gotMirrorReflectionDistance
	ld [w3MirrorReflectionDistance], a
.doneMirrorReflectionDistance
	xor a
	ldh [rWBK], a
.noReflectionDistances

; If the player is standing on a grass tile, make the player's sprite have
; lower priority than the background so that it's partially obscured by the
; grass. Only the lower half of the sprite is permitted to have the priority
; bit set by later logic.
	ld hl, wSpritePlayerStateData2GrassPriority
	ldh a, [hTilePlayerStandingOn]
	ld c, a
	ld a, [wGrassTile]
	cp c
	res B_OAM_PRIO, [hl]
	ret nz
	set B_OAM_PRIO, [hl]
	ret

MACRO reflective_tiles
	db \#
	db 0
ENDM

; first byte is enabling reflections on the tilesed : 0 = no, 1 = yes
; if enabled, a tileset entry need to be filed with 4 categories
; use a 0 for an empty category
; 1 : reflective floor tiles
; 2 : shore tiles for floor tiles
; 3 : highly reflective wall tiles (no transparency)
; 4 : reflective wall tiles
.overworld   ; OVERWORLD
	db 1
	reflective_tiles $14, $32, $5F ; reflective floor tiles
	reflective_tiles $33           ; shore tiles for floor tiles
	reflective_tiles $80, $81      ; highly reflective wall tiles (no transparency) 
	reflective_tiles $85           ; reflective wall tiles
.gate        ; GATE
	db 1
	db 0
	db 0
	db 0
	reflective_tiles $3A, $3D ; reflective wall tiles
.redsHouse1  ; REDS_HOUSE_1
.mart        ; MART
.forest      ; FOREST
.redsHouse2  ; REDS_HOUSE_2
.dojo        ; DOJO
.pokecenter  ; POKECENTER
.gym         ; GYM
.house       ; HOUSE
.forestGate  ; FOREST_GATE
.museum      ; MUSEUM
.underground ; UNDERGROUND
.ship        ; SHIP
.shipPort    ; SHIP_PORT
.cemetery    ; CEMETERY
.interior    ; INTERIOR
.cavern      ; CAVERN
.lobby       ; LOBBY
.mansion     ; MANSION
.lab         ; LAB
.club        ; CLUB
.facility    ; FACILITY
.plateau     ; PLATEAU
	db 0

.tilesetsReflectionPointers
	table_width 2
	dw .overworld  ; OVERWORLD
	dw .redsHouse1 ; REDS_HOUSE_1
	dw .mart       ; MART
	dw .forest     ; FOREST
	dw .redsHouse2 ; REDS_HOUSE_2
	dw .dojo       ; DOJO
	dw .pokecenter ; POKECENTER
	dw .gym        ; GYM
	dw .house      ; HOUSE
	dw .forestGate ; FOREST_GATE
	dw .museum     ; MUSEUM
	dw .underground; UNDERGROUND
	dw .gate       ; GATE
	dw .ship       ; SHIP
	dw .shipPort   ; SHIP_PORT
	dw .cemetery   ; CEMETERY
	dw .interior   ; INTERIOR
	dw .cavern     ; CAVERN
	dw .lobby      ; LOBBY
	dw .mansion    ; MANSION
	dw .lab        ; LAB
	dw .club       ; CLUB
	dw .facility   ; FACILITY
	dw .plateau    ; PLATEAU
	assert_table_length NUM_TILESETS

UnusedReadSpriteDataFunction:
	push bc
	push af
	ldh a, [hCurrentSpriteOffset]
	ld c, a
	pop af
	add c
	ld l, a
	pop bc
	ret

UpdateNPCSprite:
	ldh a, [hCurrentSpriteOffset]
	swap a
	dec a
	add a
	ld hl, wMapSpriteData
	add l
	ld l, a
	ld a, [hl]        ; read movement byte 2
	ld [wCurSpriteMovement2], a
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	ld l, a
	inc l
	ld a, [hl]        ; x#SPRITESTATEDATA1_MOVEMENTSTATUS
	and a
	jp z, InitializeSpriteStatus
	call CheckSpriteAvailability
	ret c             ; don't do anything if sprite is invisible
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	ld l, a
	inc l
	ld a, [hl]        ; x#SPRITESTATEDATA1_MOVEMENTSTATUS
	bit BIT_FACE_PLAYER, a
	jp nz, MakeNPCFacePlayer
	ld b, a
	ld a, [wFontLoaded]
	bit BIT_FONT_LOADED, a
	jp nz, NotYetMoving
	ld a, b
	cp $2
	jp z, UpdateSpriteMovementDelay  ; [x#SPRITESTATEDATA1_MOVEMENTSTATUS] == 2
	cp $3
	jp z, UpdateSpriteInWalkingAnimation  ; [x#SPRITESTATEDATA1_MOVEMENTSTATUS] == 3
	ld a, [wWalkCounter]
	and a
	ret nz           ; don't do anything yet if player is currently moving
	lb bc, 1, 3
	add hl, bc
	call InitializeSpriteScreenPosition
	inc h
	ld a, [hl]       ; x#SPRITESTATEDATA2_MOVEMENTBYTE1
	inc a
	jr z, .randomMovement  ; value STAY
	inc a
	jr z, .randomMovement  ; value WALK
; scripted movement
	dec a
	ld [hl], a       ; increment movement byte 1 (movement data index)
	dec a
	push hl
	ld hl, wNPCNumScriptedSteps
	dec [hl]         ; decrement wNPCNumScriptedSteps
	pop hl
	ld de, wNPCMovementDirections
	call LoadDEPlusA ; a = [wNPCMovementDirections + movement byte 1]
	cp NPC_CHANGE_FACING
	jp z, ChangeFacingDirection
	cp STAY
	jr nz, .next
; reached end of wNPCMovementDirections list
	ld [hl], a ; store $ff in movement byte 1, disabling scripted movement
	ld hl, wStatusFlags5
	res BIT_SCRIPTED_NPC_MOVEMENT, [hl]
	xor a
	ld [wSimulatedJoypadStatesIndex], a
	ld [wUnusedOverrideSimulatedJoypadStatesIndex], a
	ret
.next
	cp WALK
	jr nz, .determineDirection
; current NPC movement data is WALK ($fe). this seems buggy
	ld [hl], $1     ; set movement byte 1 to $1
	ld de, wNPCMovementDirections
	call LoadDEPlusA ; a = [wNPCMovementDirections + $fe] (?)
	jr .determineDirection
.randomMovement
	call GetTileSpriteStandsOn
	call Random
.determineDirection
	ld b, a
	ld a, [wCurSpriteMovement2]
	cp DOWN
	jr z, .moveDown
	cp UP
	jr z, .moveUp
	cp LEFT
	jr z, .moveLeft
	cp RIGHT
	jr z, .moveRight
	ld a, b
	cp NPC_MOVEMENT_UP ; NPC_MOVEMENT_DOWN <= a < NPC_MOVEMENT_UP: down (or left)
	jr nc, .notDown
	ld a, [wCurSpriteMovement2]
	cp LEFT_RIGHT
	jr z, .moveLeft
.moveDown
	ld de, 2*SCREEN_WIDTH
	add hl, de         ; move tile pointer two rows down
	lb de, 1, 0
	lb bc, 4, SPRITE_FACING_DOWN
	jr TryWalking
.notDown
	cp NPC_MOVEMENT_LEFT ; NPC_MOVEMENT_UP <= a < NPC_MOVEMENT_LEFT: up (or right)
	jr nc, .notUp
	ld a, [wCurSpriteMovement2]
	cp LEFT_RIGHT
	jr z, .moveRight
.moveUp
	ld de, -2*SCREEN_WIDTH
	add hl, de         ; move tile pointer two rows up
	lb de, -1, 0
	lb bc, 8, SPRITE_FACING_UP
	jr TryWalking
.notUp
	cp NPC_MOVEMENT_RIGHT ; NPC_MOVEMENT_LEFT <= a < NPC_MOVEMENT_RIGHT: left (or up)
	jr nc, .notLeft
	ld a, [wCurSpriteMovement2]
	cp UP_DOWN
	jr z, .moveUp
.moveLeft
	dec hl
	dec hl             ; move tile pointer two columns left
	lb de, 0, -1
	lb bc, 2, SPRITE_FACING_LEFT
	jr TryWalking
.notLeft               ; NPC_MOVEMENT_RIGHT <= a: right (or down)
	ld a, [wCurSpriteMovement2]
	cp UP_DOWN
	jr z, .moveDown
.moveRight
	inc hl
	inc hl             ; move tile pointer two columns right
	lb de, 0, 1
	lb bc, 1, SPRITE_FACING_RIGHT
	jr TryWalking

; changes facing direction by zeroing the movement delta and calling TryWalking
ChangeFacingDirection:
	ld de, $0
	; fall through

; b: direction (1,2,4 or 8)
; c: new facing direction (0,4,8 or $c)
; d: Y movement delta (-1, 0 or 1)
; e: X movement delta (-1, 0 or 1)
; hl: pointer to tile the sprite would walk onto
; set carry on failure, clears carry on success
TryWalking:
	push hl
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	add $9
	ld l, a
	ld [hl], c          ; x#SPRITESTATEDATA1_FACINGDIRECTION
	ldh a, [hCurrentSpriteOffset]
	add $3
	ld l, a
	ld [hl], d          ; x#SPRITESTATEDATA1_YSTEPVECTOR
	inc l
	inc l
	ld [hl], e          ; x#SPRITESTATEDATA1_XSTEPVECTOR
	pop hl
	push de
	ld c, [hl]          ; read tile to walk onto
	call CanWalkOntoTile
	pop de
	ret c               ; cannot walk there (reinitialization of delay values already done)
	ld h, HIGH(wSpriteStateData2)
	ldh a, [hCurrentSpriteOffset]
	add $4
	ld l, a
	ld a, [hl]          ; x#SPRITESTATEDATA2_MAPY
	add d
	ld [hli], a         ; update Y position
	ld a, [hl]          ; x#SPRITESTATEDATA2_MAPX
	add e
	ld [hl], a          ; update X position
	ldh a, [hCurrentSpriteOffset]
	ld l, a
	ld [hl], $10        ; [x#SPRITESTATEDATA2_WALKANIMATIONCOUNTER] = 16
	dec h
	inc l
	ld [hl], $3         ; x#SPRITESTATEDATA1_MOVEMENTSTATUS
	jp UpdateSpriteImage

; update the walking animation parameters for a sprite that is currently walking
UpdateSpriteInWalkingAnimation:
	ld a, l
	add 6
	ld l, a

	ld c, 4
	call UpdateSpriteAnimation

	ld a, l
	sub 4
	ld l, a
	ld a, [hli]                      ; x#SPRITESTATEDATA1_YSTEPVECTOR
	ld b, a
	ld a, [hl]                       ; x#SPRITESTATEDATA1_YPIXELS
	add b
	ld [hli], a                      ; update [x#SPRITESTATEDATA1_YPIXELS]
	ld a, [hli]                      ; x#SPRITESTATEDATA1_XSTEPVECTOR
	ld b, a
	ld a, [hl]                       ; x#SPRITESTATEDATA1_XPIXELS
	add b
	ld [hl], a                       ; update [x#SPRITESTATEDATA1_XPIXELS]
	ldh a, [hCurrentSpriteOffset]
	ld l, a
	inc h
	ld a, [hl]                       ; x#SPRITESTATEDATA2_WALKANIMATIONCOUNTER
	dec a
	ld [hl], a                       ; update walk animation counter
	ret nz
	ld a, $6                         ; walking finished, update state
	add l
	ld l, a
	ld a, [hl]                       ; x#SPRITESTATEDATA2_MOVEMENTBYTE1
	cp WALK
	jr nc, .initNextMovementCounter  ; values WALK or STAY
	ldh a, [hCurrentSpriteOffset]
	inc a
	ld l, a
	dec h
	ld [hl], $1                      ; [x#SPRITESTATEDATA1_MOVEMENTSTATUS] = 1 (movement status ready)
	ret
.initNextMovementCounter
	call Random
	ldh a, [hCurrentSpriteOffset]
	add $8
	ld l, a
	ldh a, [hRandomAdd]
	and $7f
	ld [hl], a                       ; x#SPRITESTATEDATA2_MOVEMENTDELAY:
	                                 ; set next movement delay to a random value in [0,$7f]
	                                 ; note that value 0 actually makes the delay $100 (bug?)
	dec h ; HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	inc a
	ld l, a
	ld [hl], $2                      ; [x#SPRITESTATEDATA1_MOVEMENTSTATUS] = 2 (movement status)
	inc l
	inc l
	xor a
	ld b, [hl]                       ; x#SPRITESTATEDATA1_YSTEPVECTOR
	ld [hli], a                      ; [x#SPRITESTATEDATA1_YSTEPVECTOR] = 0
	inc l
	ld c, [hl]                       ; x#SPRITESTATEDATA1_XSTEPVECTOR
	ld [hl], a                       ; [x#SPRITESTATEDATA1_XSTEPVECTOR] = 0
	ret

UpdateSpriteAnimation:
	ld a, [hl]                       ; x#SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER
	inc a
	ld [hl], a                       ; [x#SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER]++
	cp c
	ret c
	xor a
	ld [hli], a                       ; [x#SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER] = 0
	ld a, [hl]                       ; x#SPRITESTATEDATA1_ANIMFRAMECOUNTER
	inc a
	and $3
	ld [hld], a                       ; advance to next animation frame every 4 ticks (16 ticks total for one step)
	ret

UpdateSpriteIdleAnimation:
	cp $80
	jr c, .regularFrameLenght
	push hl
	sub $80
	inc l
	ld d, 0
	ld e, [hl]
	ld h, d
	ld l, a
	ld bc, IdleAnimationFrameLenghtList
	add hl, hl
	add hl, hl
	add hl, bc
	add hl, de
	ld a, [hl]
	pop hl
.regularFrameLenght
	ld c, a
	call UpdateSpriteAnimation
	jp UpdateSpriteImage

IdleAnimationFrameLenghtList:
	; Lenght of each frames of the idle animation
	db 6, 30, 6, 30 ; $80 SNORLAX 3x3

; update [x#SPRITESTATEDATA2_MOVEMENTDELAY] for sprites in the delayed state (x#SPRITESTATEDATA1_MOVEMENTSTATUS)
UpdateSpriteMovementDelay:
	lb bc, 1, 5
	add hl, bc
	ld a, [hl]              ; x#SPRITESTATEDATA2_MOVEMENTBYTE1
	inc l
	inc l
	cp WALK
	jr nc, .tickMoveCounter ; values WALK or STAY
	ld [hl], $0
	jr .moving
.tickMoveCounter
	dec [hl]                ; x#SPRITESTATEDATA2_MOVEMENTDELAY
	jr nz, NotYetMoving
.moving
	dec h
	ldh a, [hCurrentSpriteOffset]
	inc a
	ld l, a
	ld [hl], $1             ; [x#SPRITESTATEDATA1_MOVEMENTSTATUS] = 1 (mark as ready to move)
	; fallthrough
NotYetMoving:
	ld h, HIGH(wSpriteStateData2)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA2_ANIMATION
	ld l, a
	ld a, [hl] ; x#SPRITESTATEDATA2_ANIMATION : Custom - animation status
	ld bc, -$100 - (SPRITESTATEDATA2_ANIMATION - SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER)
	add hl, bc
	and a
	jp nz, UpdateSpriteIdleAnimation ; update animation frame if the npc is an idle animated one
	inc l
	ld [hl], $0             ; [x#SPRITESTATEDATA1_ANIMFRAMECOUNTER] = 0 (walk animation frame)
	jp UpdateSpriteImage

MakeNPCFacePlayer:
; Make an NPC face the player if the player has spoken to him or her.

; Check if the behaviour of the NPC facing the player when spoken to is
; disabled. This is only done when rubbing the S.S. Anne captain's back.
	ld a, [wStatusFlags3]
	bit BIT_NO_NPC_FACE_PLAYER, a
	jr nz, NotYetMoving
	res BIT_FACE_PLAYER, [hl]
	ld a, [wPlayerDirection]
	ld c, a

	ldh a, [hCurrentSpriteOffset]
	add $9
	ld l, a

	xor a
	bit PLAYER_DIR_BIT_UP, c
	jr nz, .facingDirectionDetermined
	inc a
	bit PLAYER_DIR_BIT_DOWN, c
	jr nz, .facingDirectionDetermined
	inc a
	bit PLAYER_DIR_BIT_RIGHT, c
	jr nz, .facingDirectionDetermined
	inc a
.facingDirectionDetermined
	add a
	add a ; value 0 to 3 time 4 = facing direction
	ld [hl], a         ; [x#SPRITESTATEDATA1_FACINGDIRECTION]: set facing direction

	jr NotYetMoving

InitializeSpriteStatus:
	ld [hl], $1   ; [x#SPRITESTATEDATA1_MOVEMENTSTATUS] = ready
	inc l
	ld [hl], $ff  ; [x#SPRITESTATEDATA1_IMAGEINDEX] = invisible/off screen
	inc h ; HIGH(wSpriteStateData2)
	ld a, $8
	ld [hli], a   ; [x#SPRITESTATEDATA2_YDISPLACEMENT] = 8
	ld [hli], a    ; [x#SPRITESTATEDATA2_XDISPLACEMENT] = 8

; calculates the sprite's screen position from its map position and the player position
InitializeSpriteScreenPosition:
	ld a, [wYCoord]
;	ld b, a
;	ld a, [hl]      ; x#SPRITESTATEDATA2_MAPY
;	sub b           ; relative to player position
;	call Func_515D

	cpl
	inc a
	add [hl] ; x#SPRITESTATEDATA2_MAPY
	and $f
	swap a ; * 16

	sub $4          ; - 4
	dec h
	ld [hli], a     ; [x#SPRITESTATEDATA1_YPIXELS]
	inc h
	ld a, [wXCoord]
;	ld b, a
;	ld a, [hli]     ; x#SPRITESTATEDATA2_MAPX
;	sub b           ; relative to player position
;	call Func_515D

	cpl
	inc a
	add [hl] ; x#SPRITESTATEDATA2_MAPX
	and $f
	swap a ; * 16
	inc l

	dec h
	ld [hl], a      ; [x#SPRITESTATEDATA1_XPIXELS]
	ret

;Func_515D:
;	jr nc, .asm_5166
;	cpl
;	inc a
;	swap a
;	cpl
;	inc a
;	ret
;.asm_5166
;	swap a          ; * 16
;	ret

; tests if sprite is off screen or otherwise unable to do anything
CheckSpriteAvailability:
	predef IsObjectHidden
	ldh a, [hIsToggleableObjectOff]
	and a
	jp nz, .spriteInvisible
	ld h, HIGH(wSpriteStateData2)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA2_MAPY
	ld l, a
	ld a, [hli]     ; x#SPRITESTATEDATA2_MAPY
	ld b, a
	ld c, a
	ld d, [hl]      ; x#SPRITESTATEDATA2_MAPX

	ld a, [wCurMap]
	cp OAKS_LAB
	jr nz, .dontLimitY
	CheckEvent EVENT_GOT_STARTER
	jr nz, .dontLimitY
	CheckEvent EVENT_OAK_APPEARED_IN_PALLET
	jr nz, .limitY
.dontLimitY
	inc b
	dec c
	dec c
.limitY
	inc d

	ld a, l
	sub SPRITESTATEDATA2_MAPX - SPRITESTATEDATA2_MOVEMENTBYTE1
	ld l, a
	ld a, [hl]      ; x#SPRITESTATEDATA2_MOVEMENTBYTE1

;	ld hl, wSpriteFlags
;	res 6, [hl]

	cp WALK
	jr c, .skipXVisibilityTest ; movement byte 1 < WALK (i.e. the sprite's movement is scripted)

	ld a, [wYCoord]
	cp b
	jr z, .skipYVisibilityTest
	jr nc, .spriteInvisible ; above screen region
	add SCREEN_HEIGHT / 2 - 1
	cp c
;	add SCREEN_WIDTH / 2 + 1
;	cp b
	jr c, .spriteInvisible  ; below screen region

;	dec a
;	cp c ; check if just under screen
;	jr nz, .noFlag6
;	set 6, [hl]
;.noFlag6

.skipYVisibilityTest
	ld a, [wXCoord]
	cp d
	jr z, .skipXVisibilityTest
	jr nc, .spriteInvisible ; left of screen region
	add SCREEN_WIDTH / 2 + 1
	cp d
	jr c, .spriteInvisible  ; right of screen region

.skipXVisibilityTest
; make the sprite invisible if a text box is in front of it
; do so by checking if a tile in front of the sprite is using the text palette

	ld a, [wFontLoaded]
	bit 0, a ; check if text is loaded, skip visibility check if not
	jr z, .skipVisibilityCheck

	call GetTileSpriteStandsOn
;	ld c, [hl] ; get bottom left tile for grass detection

;	ld a, [wFontLoaded]
;	bit 0, a ; check if text is loaded, skip visibility check if not
;	jr z, .skipVisibilityCheck

;	ld a, [wSpriteFlags]
;	bit 6, a ; test the flag signifying that the sprite is just under the screen

	ld a, 2
	ldh [rWBK], a
	ld bc, W2_TileMapPalMap - wTileMap
	add hl, bc

	ld a, d
	cp 144

	ld d, 7 ; used both as a mask for palette bits and as value for text palette

	jr nc, .onlyCheckTop ; if object just under screen, pass the check of the bottom tiles

;	jr nz, .onlyCheckTop ; if wSpriteFlags bit 6 is set, pass the check of the bottom tiles

	ld a, [hli]
	and d
	cp d
	jr z, .spriteInvisible ; standing on tile with text palette (bottom left tile)
	ld a, [hld]
	and d
	cp d
	jr z, .spriteInvisible ; standing on tile with text palette (bottom right tile)
.onlyCheckTop
	ld bc, -SCREEN_WIDTH
	add hl, bc              ; go back one row of tiles
	ld a, [hli]
	and d
	cp d
	jr z, .spriteInvisible ; standing on tile with text palette (top left tile)
	ld a, [hld]
	and d
	cp d
	jr nz, .spriteVisible ; not standing on tile with text palette (top right tile)
.spriteInvisible
	xor a
	ldh [rWBK], a
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA1_IMAGEINDEX
	ld l, a

	scf
	ld a, [hl]
	inc a
	ret z

	ld a, [wSpriteFlags]
	set 1, a
	ld [wSpriteFlags], a

	ld [hl], $ff       ; x#SPRITESTATEDATA1_IMAGEINDEX
;	scf
	ret
.spriteVisible
	xor a
	ldh [rWBK], a
;	ld bc, - ((W2_TileMapPalMap - wTileMap) - SCREEN_WIDTH) ; go back to the bottom left tile
;	add hl, bc
;	ld c, [hl] ; get bottom left tile for grass detection
.skipVisibilityCheck
;	ld a, [wWalkCounter]
;	and a
;	call z, UpdateSpriteImage

	call UpdateSpriteImage

	ld a, [wGrassTile]
	inc a
	ld c, a
	call nz, GetAccurateMapTileSpriteStandsOn ; dont call if wGrassTile = $ff

	ld h, HIGH(wSpriteStateData2)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA2_GRASSPRIORITY
	ld l, a

	ld a, [wGrassTile]
	cp c
	res B_OAM_PRIO, [hl] ; x#SPRITESTATEDATA2_GRASSPRIORITY
	jr nz, .notInGrass
	set B_OAM_PRIO, [hl] ; x#SPRITESTATEDATA2_GRASSPRIORITY
.notInGrass
	and a
	ret

UpdateSpriteImage:
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	add $8
	ld l, a
	ld a, [hli]        ; x#SPRITESTATEDATA1_ANIMFRAMECOUNTER
	ld b, a
	ld a, [hl]         ; x#SPRITESTATEDATA1_FACINGDIRECTION
	add b
	ld b, a
;	ldh a, [hTilePlayerStandingOn]
;	add b
;	ld b, a
	ldh a, [hCurrentSpriteOffset]
	add $2
	ld l, a

	inc [hl]
	jr nz, .dontSetBit
	ld a, [wSpriteFlags]
	set 1, a
	ld [wSpriteFlags], a
.dontSetBit

	ld [hl], b         ; x#SPRITESTATEDATA1_IMAGEINDEX
	ret

; tests if sprite can walk the specified direction
; b: direction (1,2,4 or 8)
; c: ID of tile the sprite would walk onto
; d: Y movement delta (-1, 0 or 1)
; e: X movement delta (-1, 0 or 1)
; set carry on failure, clears carry on success
CanWalkOntoTile:
	ld h, HIGH(wSpriteStateData2)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA2_MOVEMENTBYTE1
	ld l, a
	ld a, [hl]         ; x#SPRITESTATEDATA2_MOVEMENTBYTE1
	cp WALK
	jr nc, .notScripted    ; values WALK or STAY
; always allow walking if the movement is scripted
	and a
	ret
.notScripted
	ld a, [wTilesetCollisionPtr]
	ld l, a
	ld a, [wTilesetCollisionPtr+1]
	ld h, a
.tilePassableLoop
	ld a, [hli]
	cp $ff
	jr z, .impassable
	cp c
	jr nz, .tilePassableLoop
	ld h, HIGH(wSpriteStateData2)
	ldh a, [hCurrentSpriteOffset]
	add $6
	ld l, a
	ld a, [hl]         ; x#SPRITESTATEDATA2_MOVEMENTBYTE1
	inc a
	jr z, .impassable  ; if $ff, no movement allowed (however, changing direction is)
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA1_YPIXELS
	ld l, a
	ld a, [hli]        ; x#SPRITESTATEDATA1_YPIXELS
	add $4             ; align to blocks (Y pos is always 4 pixels off)
	add d              ; add Y delta
	cp $80             ; if value is >$80, the destination is off screen (either $81 or $FF underflow)
	jr nc, .impassable ; don't walk off screen
	inc l
	ld a, [hl]         ; x#SPRITESTATEDATA1_XPIXELS
	add e              ; add X delta
	cp $90             ; if value is >$90, the destination is off screen (either $91 or $FF underflow)
	jr nc, .impassable ; don't walk off screen
	push de
	push bc
	call DetectCollisionBetweenSprites
	pop bc
	pop de
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	add $c
	ld l, a
	ld a, [hl]         ; x#SPRITESTATEDATA1_COLLISIONDATA (directions in which sprite collision would occur)
	and b              ; check against chosen direction (1,2,4 or 8)
	jr nz, .impassable ; collision between sprites, don't go there
	ld h, HIGH(wSpriteStateData2)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA2_YDISPLACEMENT
	ld l, a
	ld a, [hli]        ; x#SPRITESTATEDATA2_YDISPLACEMENT (initialized at $8, keep track of where a sprite did go)
	bit 7, d           ; check if going upwards (d == -1)
	jr nz, .upwards
	add d
	; bug: these tests against $5 probably were supposed to prevent
	; sprites from walking out too far, but this line makes sprites get
	; stuck whenever they walked upwards 5 steps
	; on the other hand, the amount a sprite can walk out to the
	; right of bottom is not limited (until the counter overflows)
	cp $5
	jr c, .impassable  ; if [x#SPRITESTATEDATA2_YDISPLACEMENT]+d < 5, don't go
	jr .checkHorizontal
.upwards
	sub $1
	jr c, .impassable  ; if [x#SPRITESTATEDATA2_YDISPLACEMENT] == 0, don't go
.checkHorizontal
	ld d, a
	ld a, [hl]         ; x#SPRITESTATEDATA2_XDISPLACEMENT (initialized at $8, keep track of where a sprite did go)
	bit 7, e           ; check if going left (e == -1)
	jr nz, .left
	add e
	cp $5              ; compare, but no conditional jump like in the vertical check above (bug?)
	jr .passable
.left
	sub $1
	jr c, .impassable  ; if [x#SPRITESTATEDATA2_XDISPLACEMENT] == 0, don't go
.passable
	ld [hld], a        ; update x#SPRITESTATEDATA2_XDISPLACEMENT
	ld [hl], d         ; update x#SPRITESTATEDATA2_YDISPLACEMENT
	and a              ; clear carry (marking success)
	ret
.impassable
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	inc a
	ld l, a
	ld [hl], $2        ; [x#SPRITESTATEDATA1_MOVEMENTSTATUS] = 2 (delayed)
	inc l
	inc l
	xor a
	ld [hli], a        ; [x#SPRITESTATEDATA1_YSTEPVECTOR] = 0
	inc l
	ld [hl], a         ; [x#SPRITESTATEDATA1_XSTEPVECTOR] = 0
	inc h
	ldh a, [hCurrentSpriteOffset]
	add $8
	ld l, a
	call Random
	ldh a, [hRandomAdd]
	and $7f
	ld [hl], a         ; x#SPRITESTATEDATA2_MOVEMENTDELAY: set to a random value in [0,$7f] (again with delay $100 if value is 0)
	scf                ; set carry (marking failure to walk)
	ret

; calculates the tile pointer pointing to the tile the current sprite stands on
; this is always the lower left tile of the 2x2 tile blocks all sprites are snapped to
; hl: output pointer
GetTileSpriteStandsOn:
;	ld h, HIGH(wSpriteStateData2) ; start finding sprite Y map position
;	ldh a, [hCurrentSpriteOffset]
;	add SPRITESTATEDATA2_MAPY
;	ld l, a
;	ld b, [hl]      ; load Sprite Y map position ; x#SPRITESTATEDATA2_MAPY
;
;	ld a, [wYCoord]
;	add SCREEN_HEIGHT / 2
;	cp b ; test if the sprite is just under the screen and such, have its head popping out from the bottom
;	ld c, 4 ; value to add to an on-screen sprite to align to 2*2 tile blocks (Y position is always off 4 pixels to the top)
;	ld hl, wSpriteFlags
;	res 6, [hl] ; reset the flag signifying that the sprite is just under the screen
;	jr nz, .notjustunderscreen ; jr if not just under screen
;	ld c, -4 ; value to add to a just-under-screen sprite so the head is considered under the text (Y position is always off 4 pixels to the top)
;	set 6, [hl] ; set the flag signifying that the sprite is just under the screen

;	ld c, 4 ; value to add to an on-screen sprite to align to 2*2 tile blocks (Y position is always off 4 pixels to the top)
;	ld a, [wSpriteFlags]
;	bit 6, a ; test the flag signifying that the sprite is just under the screen
;	jr z, .notjustunderscreen ; jr if not just under screen
;	ld c, -4 ; value to add to a just-under-screen sprite so the head is considered under the text (Y position is always off 4 pixels to the top)
;.notjustunderscreen
	ld h, HIGH(wSpriteStateData1)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA1_YPIXELS
	ld l, a
	
	ld a, [wFontLoaded]
	ld b, a

	ld a, [hli]     ; x#SPRITESTATEDATA1_YPIXELS
	; Add 'c' from the sprite Y position (in pixels), -4 if just under the screen, 4 if not 
	; If it is just under the screen then it offset the Y coordinate used to determine if under the menu or not
;	add c
;	and $f8         ; in case object is currently moving

	add $4          ; align to 2*2 tile blocks (Y position is always off 4 pixels to the top)
	and $f8         ; in case object is currently moving
	ld d, a
	bit 0, b
	jr z, .notJustUnderScreen
	cp 144
	jr c, .notJustUnderScreen
	sub 8           ; if just under screen, shift it one coordinate up to be properly hidden by text box on the bottom
.notJustUnderScreen

;	srl a           ; screen Y tile * 4
	ld c, a         ; screen Y tile * 8
;	ld b, $0
	inc l
	ld a, [hl]      ; x#SPRITESTATEDATA1_XPIXELS
;	srl a
;	srl a
;	srl a            ; screen X tile
	and $f8
	rrca
	rrca
	rrca             ; screen X tile
	add SCREEN_WIDTH ; screen X tile + 20
;	ld d, $0
;	ld e, a
	ld b, $0
	hlcoord 0, 0
	add hl, bc
	add hl, bc
;	add hl, bc
;	add hl, bc
	rrc c           ; screen Y tile * 4
	add hl, bc
;	add hl, de     ; wTileMap + 20*(screen Y tile + 1) + screen X tile
	ld c, a
	add hl, bc     ; wTileMap + 20*(screen Y tile + 1) + screen X tile
	ret

; loads [de+a] into a
LoadDEPlusA:
	add e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	ld a, [de]
	ret

DoScriptedNPCMovement:
; This is an alternative method of scripting an NPC's movement and is only used
; a few times in the game. It is used when the NPC and player must walk together
; in sync, such as when the player is following the NPC somewhere. An NPC can't
; be moved in sync with the player using the other method.
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_MOVEMENT_STATE, a
	ret z
	ld hl, wStatusFlags4
	bit BIT_INIT_SCRIPTED_MOVEMENT, [hl]
	set BIT_INIT_SCRIPTED_MOVEMENT, [hl]
	jp z, InitScriptedNPCMovement
	ld hl, wNPCMovementDirections2
	ld a, [wNPCMovementDirections2Index]
	add l
	ld l, a
	jr nc, .noCarry
	inc h
.noCarry
	ld a, [hl]
; check if moving up
	cp NPC_MOVEMENT_UP
	jr nz, .checkIfMovingDown
	call GetSpriteScreenYPointer
	ld c, SPRITE_FACING_UP
	ld a, -2
	jr .move
.checkIfMovingDown
	cp NPC_MOVEMENT_DOWN
	jr nz, .checkIfMovingLeft
	call GetSpriteScreenYPointer
	ld c, SPRITE_FACING_DOWN
	ld a, 2
	jr .move
.checkIfMovingLeft
	cp NPC_MOVEMENT_LEFT
	jr nz, .checkIfMovingRight
	call GetSpriteScreenXPointer
	ld c, SPRITE_FACING_LEFT
	ld a, -2
	jr .move
.checkIfMovingRight
	cp NPC_MOVEMENT_RIGHT
	jr nz, .noMatch
	call GetSpriteScreenXPointer
	ld c, SPRITE_FACING_RIGHT
	ld a, 2
	jr .move
.noMatch
	cp $ff
	ret
.move
	ld b, a
	ld a, [hl]
	add b
	ld [hl], a
	ldh a, [hCurrentSpriteOffset]
	add $9
	ld l, a
	ld a, c
	ld [hl], a ; facing direction
	call AnimScriptedNPCMovement
	ld hl, wScriptedNPCWalkCounter
	dec [hl]
	ret nz
	ld a, 8
	ld [wScriptedNPCWalkCounter], a
	ld hl, wNPCMovementDirections2Index
	inc [hl]
	ret

InitScriptedNPCMovement:
	xor a
	ld [wNPCMovementDirections2Index], a
	ld a, 8
	ld [wScriptedNPCWalkCounter], a
	jp AnimScriptedNPCMovement

GetSpriteScreenYPointer:
	ld a, SPRITESTATEDATA1_YPIXELS
	ld b, a
	jr GetSpriteScreenXYPointerCommon

GetSpriteScreenXPointer:
	ld a, SPRITESTATEDATA1_XPIXELS
	ld b, a

GetSpriteScreenXYPointerCommon:
	ld hl, wSpriteStateData1
	ldh a, [hCurrentSpriteOffset]
	add l
	add b
	ld l, a
	ret

AnimScriptedNPCMovement:
	ld hl, wSpriteStateData2
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA2_IMAGEBASEOFFSET
	ld l, a
	ld a, [hl] ; VRAM slot
	dec a
	swap a
	ld b, a
	ld hl, wSpriteStateData1
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA1_FACINGDIRECTION
	ld l, a
	ld a, [hl] ; facing direction
	cp SPRITE_FACING_DOWN
	jr z, .anim
	cp SPRITE_FACING_UP
	jr z, .anim
	cp SPRITE_FACING_LEFT
	jr z, .anim
	cp SPRITE_FACING_RIGHT
	jr z, .anim
	ret
.anim
	add b
	ld b, a
	ldh [hSpriteVRAMSlotAndFacing], a
	call AdvanceScriptedNPCAnimFrameCounter
	ld hl, wSpriteStateData1
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA1_IMAGEINDEX
	ld l, a

	inc [hl]
	jr nz, .dontSetBit
	ld a, [wSpriteFlags]
	set 1, a
	ld [wSpriteFlags], a
.dontSetBit

	ldh a, [hSpriteVRAMSlotAndFacing]
	ld b, a
	ldh a, [hSpriteAnimFrameCounter]
	add b
	ld [hl], a ; x#SPRITESTATEDATA1_IMAGEINDEX
	ret

AdvanceScriptedNPCAnimFrameCounter:
	ldh a, [hCurrentSpriteOffset]
	add $7
	ld l, a
	ld a, [hl] ; intra-animation frame counter
	inc a
	ld [hl], a
	cp 4
	ret nz
	xor a
	ld [hl], a ; reset intra-animation frame counter
	inc l
	ld a, [hl] ; animation frame counter
	inc a
	and $3
	ld [hl], a
	ldh [hSpriteAnimFrameCounter], a
	ret

AnimateNpcDuringText::
; called during vblank if text is loaded while in the overworld 
; to update the animation of idly animating sprites
	ld a, [wSpritePlayerStateData1ImageIndex]
	inc a
	jr z, .dontAnimatePlayer
	ld a, [wMovementFlags]
	bit BIT_SPINNING, a
	jr nz, .dontAnimatePlayer
	ld a, [wWalkBikeSurfState]
	cp 2
	jr nz, .dontAnimatePlayer
	ld hl, wSpriteStateData1 + 7
	ld a, [hl]
	inc a
	ld [hl], a
	cp 12
	jr c, .calcImageIndex
	xor a
	ld [hl], a
	inc hl
	ld a, [hl]
	inc a
	and $3
	ld [hl], a
.calcImageIndex
	ld a, [wSpritePlayerStateData1AnimFrameCounter]
	ld b, a
	ld a, [wSpritePlayerStateData1FacingDirection]
	add b
	ld [wSpritePlayerStateData1ImageIndex], a
.dontAnimatePlayer

	ld h, HIGH(wSpriteStateData1)
	ld a, LOW(wSprite01StateData1)
.nextSprite
	ldh [hCurrentSpriteOffset], a
	ld l, a
	ld a, [hli] ; x#SPRITESTATEDATA1_PICTUREID
	and a
	jr z, .checkNextSprite
	ld a, [hli] ; x#SPRITESTATEDATA1_MOVEMENTSTATUS
	and a
	jr z, .checkNextSprite
	ld a, [hl] ; x#SPRITESTATEDATA1_IMAGEINDEX
	inc a
	jr z, .checkNextSprite
	ld a, SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER - SPRITESTATEDATA1_IMAGEINDEX
	add l
	ld l, a ; x#SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER

	push hl
	lb bc, 1, SPRITESTATEDATA2_IMAGEBASEOFFSET - SPRITESTATEDATA1_INTRAANIMFRAMECOUNTER
	add hl, bc
	ld a, [hld] ; x#SPRITESTATEDATA2_IMAGEBASEOFFSET
	dec a
	swap a
	ldh [hTilePlayerStandingOn], a ; $10 * sprite#
	dec l
	ld a, [hl] ; x#SPRITESTATEDATA2_ANIMATION : Custom - animation status
	pop hl

	and a
	jr z, .checkNextSprite
	call UpdateSpriteIdleAnimation
	call UpdateSpriteImage
.checkNextSprite
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA1_LENGTH
	jr nz, .nextSprite

	ret

GetAccurateMapTileSpriteStandsOn::
	; Find the map tile the sprite is standing on by directly looking into the map blocks data.
	; Allow to get grass priority for sprites that are loaded on the
	; screen border for which no appropriate wTileMap data exist.
	; return tile ID in `c`
	ld h, HIGH(wSpriteStateData2)
	ldh a, [hCurrentSpriteOffset]
	add SPRITESTATEDATA2_MAPY
	ld l, a

	lb de, 0, 4
	ld a, [hli] ; x#SPRITESTATEDATA2_MAPY
	sub e ; remove +4 npc Y coordinate offset
	ld b, a
	ld a, [hl] ; x#SPRITESTATEDATA2_MAPX 
	sub e ; remove +4 npc X coordinate offset
	ld c, a

	ld a, %0100_0000
	srl b ; divide map Y coordinate by 2 to get map block coordinate
	rla ; load Y carry, will result in +8 if carry in final value
	rlca ; rotate original bit 6 in bit 0, will result in +4 in final value
    srl c ; divide map X coordinate by 2 to get map block coordinate
	rla ; load X carry, will result in +2 if carry in final value
	rlca ; double a to get final block data tile offset
	ld e, a ; block data tile offset
	push de ; save block data tile offset

	ld a, [wCurMapWidth]
	add 6 ; map is padded with 3 blocks on each side for adjacent maps
	ld l, a
	ld h, d
	push hl ; save map data width x1 for later use

	add hl, hl
	add hl, hl ; multiply map data width by 4 to reduce amount of loops
	ld e, l
	ld d, h ; pass it in de

	ld hl, wOverworldMap + 3 ; starting address of map data with padding offset for X starting position

; Begin adding the Y offset, this is done by adding (Y * wCurMapWidth + 6) to wOverworldMap
	ld a, b ; Y map block coordinate
	ld b, 4 ; 4 lines will be loaded on each big loop, value used to check there is >= 4 lines to load and to adjust remaining amount
	add 3 ; take padding lines at the top of the map data into consideration

.add4Loop
	cp b
	jr c, .lastLoops ; quit loop if less than 4 lines to add
	add hl, de ; add 4 lines at once
	sub b ; sub 4 lines to the amount left to add
	jr nz, .add4Loop

.lastLoops
	pop de ; retrieve x1 line value saved earlier
	jr z, .doneAdding ; stop if no more line to add

.addLoop ; this loop add single lines
	add hl, de
	dec a
	jr nz, .addLoop

.doneAdding
	ld e, c ; X map block coordinate
	add hl, de ; add X offset

	pop de ; retrieve block data tile offset

	ld l, [hl]
	ld h, d ; get block ID in hl to multiply it

	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl ; block ID * 16
	add hl, de ; adding block data tile offset

	ld a, [wTilesetBlocksPtr]
	add l
	ld l, a
	ld a, [wTilesetBlocksPtr + 1]
	adc h
	ld h, a ; added tileset blocks data base address to the tile data offset

	jp GetTileIDFromBlock ; go in Home to retrieve tile ID
