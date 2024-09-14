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
; $10 This table is used for sprites $a and $b.
; All orientation and animation parameters lead to the same result.
; Used for immobile sprites like items on the ground.
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
; $20 This table is used for Pokémons with an Odd number of pixels when facing Up and Down
; Add a -1 X offset on the flipped down/up walking frame 
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
; $30 This table is used for Bill's machines
	dw .MachineCenter, .MachineMOAM  ; facing down, walk animation frame 0
	dw .MachineCenter, .MachineMOAM  ; facing down, walk animation frame 1
	dw .MachineCenter, .MachineMOAM  ; facing down, walk animation frame 2
	dw .MachineCenter, .MachineMOAM  ; facing down, walk animation frame 3
	dw .MachineCenter, .MachineMOAM  ; facing up, walk animation frame 0
	dw .MachineCenter, .MachineMOAM  ; facing up, walk animation frame 1
	dw .MachineCenter, .MachineMOAM  ; facing up, walk animation frame 2
	dw .MachineCenter, .MachineMOAM  ; facing up, walk animation frame 3
	dw .MachineSides,  .MachineLOAM  ; facing left, walk animation frame 0
	dw .MachineSides,  .MachineLOAM  ; facing left, walk animation frame 1
	dw .MachineSides,  .MachineLOAM  ; facing left, walk animation frame 2
	dw .MachineSides,  .MachineLOAM  ; facing left, walk animation frame 3
	dw .MachineSides,  .MachineROAM  ; facing right, walk animation frame 0
	dw .MachineSides,  .MachineROAM  ; facing right, walk animation frame 1
	dw .MachineSides,  .MachineROAM  ; facing right, walk animation frame 2
	dw .MachineSides,  .MachineROAM  ; facing right, walk animation frame 3
; $40 Snorlax 3x3
	dw .Snorlax2, .SnorlaxSleepOAM  ; facing down, walk animation frame 0
	dw .Snorlax3, .SnorlaxOAM  ; facing down, walk animation frame 1
	dw .Snorlax2, .SnorlaxSleepOAM  ; facing down, walk animation frame 2
	dw .Snorlax1, .SnorlaxSleepOAM  ; facing down, walk animation frame 3
	dw .Snorlax2, .SnorlaxSleepOAM  ; facing up, walk animation frame 0
	dw .Snorlax3, .SnorlaxOAM  ; facing up, walk animation frame 1
	dw .Snorlax2, .SnorlaxSleepOAM  ; facing up, walk animation frame 2
	dw .Snorlax1, .SnorlaxSleepOAM  ; facing up, walk animation frame 3
	dw .Snorlax2, .SnorlaxSleepOAM  ; facing left, walk animation frame 0
	dw .Snorlax3, .SnorlaxOAM  ; facing left, walk animation frame 1
	dw .Snorlax2, .SnorlaxSleepOAM  ; facing left, walk animation frame 2
	dw .Snorlax1, .SnorlaxSleepOAM  ; facing left, walk animation frame 3
	dw .Snorlax2, .SnorlaxSleepOAM  ; facing right, walk animation frame 0
	dw .Snorlax3, .SnorlaxOAM  ; facing right, walk animation frame 1
	dw .Snorlax2, .SnorlaxSleepOAM  ; facing right, walk animation frame 2
	dw .Snorlax1, .SnorlaxSleepOAM  ; facing right, walk animation frame 3

; insert custom table starting here, each table must contain 4 facings with 4 animation frames each (16 total)

; four tile ids compose an overworld sprite
.StandingDown: db $00, $01, $02, $03
.WalkingDown:  db $80, $81, $82, $83
.StandingUp:   db $04, $05, $06, $07
.WalkingUp:    db $84, $85, $86, $87
.StandingLeft: db $08, $09, $0a, $0b
.WalkingLeft:  db $88, $89, $8a, $8b

.MachineCenter:db $01, $01
.MachineSides: ; fallthrough for $00

.Snorlax3:     db $00, $01, $00, $06, $07, $06, $08, $09, $08
.Snorlax2:     db $0a, $00, $01, $00, $04, $05, $04, $08, $09, $08
.Snorlax1:     db $0b, $00, $01, $00, $02, $03, $02, $08, $09, $08

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
	db 0,  7, OAM_HFLIP ; top left
	db 0, -1, OAM_HFLIP ; top right
	db 8,  7, OAM_HFLIP | OAMFLAG_CANBEMASKED ; bottom left
	db 8, -1, OAM_HFLIP | OAMFLAG_CANBEMASKED | OAMFLAG_ENDOFDATA ; bottom right

.MachineLOAM:
	; y, x, attributes
	db 12, 8, OAMFLAG_ENDOFDATA 
.MachineROAM:
	; y, x, attributes
	db 12, 0, OAM_HFLIP | OAMFLAG_ENDOFDATA 
.MachineMOAM:
	; y, x, attributes
	db 12, 0, $00
	db 12, 8, OAM_HFLIP | OAMFLAG_ENDOFDATA 

.SnorlaxSleepOAM:
	; y, x, attributes
	db -10, 14, $00 ; sleep
	; fallthrough
.SnorlaxOAM:
	db -3, -4, $00 ; top left
	db -3,  4, $00 ; top center
	db -3, 12, OAM_HFLIP ; top right
	db  5, -4, $00 ; middle left
	db  5,  4, $00 ; middle center
	db  5, 12, OAM_HFLIP ; middle right
	db 13, -4, $00 ; bottom left
	db 13,  4, $00 ; bottom center
	db 13, 12, OAM_HFLIP | OAMFLAG_ENDOFDATA ; bottom right
