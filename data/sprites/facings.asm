SpriteFacingAndAnimationTable:
; $00 This table is used for overworld sprites $1-$9.
	dw .StandingDown, .NormalOAM  ; facing down, walk animation frame 0
	dw .WalkingDown,  .NormalOAM  ; facing down, walk animation frame 1
	dw .StandingDown, .NormalOAM  ; facing down, walk animation frame 2
	dw .WalkingDown,  .FlippedOAM ; facing down, walk animation frame 3
	dw .StandingUp,   .NormalOAM  ; facing up, walk animation frame 0
	dw .WalkingUp,    .NormalOAM  ; facing up, walk animation frame 1
	dw .StandingUp,   .NormalOAM  ; facing up, walk animation frame 2
	dw .WalkingUp,    .FlippedOAM ; facing up, walk animation frame 3
	dw .StandingLeft, .NormalOAM  ; facing left, walk animation frame 0
	dw .WalkingLeft,  .NormalOAM  ; facing left, walk animation frame 1
	dw .StandingLeft, .NormalOAM  ; facing left, walk animation frame 2
	dw .WalkingLeft,  .NormalOAM  ; facing left, walk animation frame 3
	dw .StandingLeft, .FlippedOAM ; facing right, walk animation frame 0
	dw .WalkingLeft,  .FlippedOAM ; facing right, walk animation frame 1
	dw .StandingLeft, .FlippedOAM ; facing right, walk animation frame 2
	dw .WalkingLeft,  .FlippedOAM ; facing right, walk animation frame 3
; The rest of this table is used for sprites $a and $b.
; All orientation and animation parameters lead to the same result.
; $10 Used for immobile sprites like items on the ground.
	dw .StandingDown, .NormalOAM  ; facing down, walk animation frame 0
	dw .StandingDown, .NormalOAM  ; facing down, walk animation frame 1
	dw .StandingDown, .NormalOAM  ; facing down, walk animation frame 2
	dw .StandingDown, .NormalOAM  ; facing down, walk animation frame 3
	dw .StandingDown, .NormalOAM  ; facing up, walk animation frame 0
	dw .StandingDown, .NormalOAM  ; facing up, walk animation frame 1
	dw .StandingDown, .NormalOAM  ; facing up, walk animation frame 2
	dw .StandingDown, .NormalOAM  ; facing up, walk animation frame 3
	dw .StandingDown, .NormalOAM  ; facing left, walk animation frame 0
	dw .StandingDown, .NormalOAM  ; facing left, walk animation frame 1
	dw .StandingDown, .NormalOAM  ; facing left, walk animation frame 2
	dw .StandingDown, .NormalOAM  ; facing left, walk animation frame 3
	dw .StandingDown, .NormalOAM  ; facing right, walk animation frame 0
	dw .StandingDown, .NormalOAM  ; facing right, walk animation frame 1
	dw .StandingDown, .NormalOAM  ; facing right, walk animation frame 2
	dw .StandingDown, .NormalOAM  ; facing right, walk animation frame 3
; $20 Oddmons Up/Down Flipped Y-1 Offset
	dw .StandingDown, .NormalOAM  ; facing down, walk animation frame 0
	dw .WalkingDown,  .NormalOAM  ; facing down, walk animation frame 1
	dw .StandingDown, .NormalOAM  ; facing down, walk animation frame 2
	dw .WalkingDown,  .OddmonOAM  ; facing down, walk animation frame 3
	dw .StandingUp,   .NormalOAM  ; facing up, walk animation frame 0
	dw .WalkingUp,    .NormalOAM  ; facing up, walk animation frame 1
	dw .StandingUp,   .NormalOAM  ; facing up, walk animation frame 2
	dw .WalkingUp,    .OddmonOAM  ; facing up, walk animation frame 3
	dw .StandingLeft, .NormalOAM  ; facing left, walk animation frame 0
	dw .WalkingLeft,  .NormalOAM  ; facing left, walk animation frame 1
	dw .StandingLeft, .NormalOAM  ; facing left, walk animation frame 2
	dw .WalkingLeft,  .NormalOAM  ; facing left, walk animation frame 3
	dw .StandingLeft, .FlippedOAM ; facing right, walk animation frame 0
	dw .WalkingLeft,  .FlippedOAM ; facing right, walk animation frame 1
	dw .StandingLeft, .FlippedOAM ; facing right, walk animation frame 2
	dw .WalkingLeft,  .FlippedOAM ; facing right, walk animation frame 3

; four tile ids compose an overworld sprite
.StandingDown: db $00, $01, $02, $03
.WalkingDown:  db $80, $81, $82, $83
.StandingUp:   db $04, $05, $06, $07
.WalkingUp:    db $84, $85, $86, $87
.StandingLeft: db $08, $09, $0a, $0b
.WalkingLeft:  db $88, $89, $8a, $8b

.NormalOAM:
	; y, x, attributes
	db 0, 0, $00 ; top left
	db 0, 8, $00 ; top right
	db 8, 0, OAMFLAG_CANBEMASKED ; bottom left
	db 8, 8, OAMFLAG_CANBEMASKED | OAMFLAG_ENDOFDATA ; bottom right

.FlippedOAM:
	; y, x, attributes
	db 0, 8, OAM_HFLIP ; top left
	db 0, 0, OAM_HFLIP ; top right
	db 8, 8, OAM_HFLIP | OAMFLAG_CANBEMASKED ; bottom left
	db 8, 0, OAM_HFLIP | OAMFLAG_CANBEMASKED | OAMFLAG_ENDOFDATA ; bottom right

.OddmonOAM:
	; y, x, attributes
	db 0, 7, OAM_HFLIP ; top left
	db 0, -1, OAM_HFLIP ; top right
	db 8, 7, OAM_HFLIP | OAMFLAG_CANBEMASKED ; bottom left
	db 8, -1, OAM_HFLIP | OAMFLAG_CANBEMASKED | OAMFLAG_ENDOFDATA ; bottom right

SpecialOAMlist:
	; see constants/sprite_constants.asm
	; db SPRITE_CONSTANT, $OAMtable, YPixelOffest, XPixelOffset
	db SPRITE_BENCH_GUY,	$10, 4, 4
	db SPRITE_SNORLAX,		$10, 4, 0
	db SPRITE_BOULDER,		$10, 4, 0
	db SPRITE_DODUO,		$20, 0, 0
	db SPRITE_FEAROW,		$20, 0, 0
	db SPRITE_JIGGLYPUFF,	$20, 0, 0
	db SPRITE_MACHOKE,		$20, 0, 0
	db SPRITE_MACHOP,		$20, 0, 0
	db SPRITE_NIDORANF,		$20, 0, 0
	db SPRITE_NIDORANM,		$20, 0, 0
	db SPRITE_PIDGEY,		$20, 0, 0
	db SPRITE_PIKACHU,		$20, 0, 0
	db SPRITE_SEEL2,		$20, 0, 0
	db SPRITE_ZAPDOS,		$20, 0, 0
	db -1
