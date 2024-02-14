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
; $20 This table is usef for Pokémons with an Odd number of pixels when facing Up and Down
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
	dw .Machine, .MachineLOAM  ; facing down, walk animation frame 0
	dw .Machine, .MachineLOAM  ; facing down, walk animation frame 1
	dw .Machine, .MachineLOAM  ; facing down, walk animation frame 2
	dw .Machine, .MachineLOAM  ; facing down, walk animation frame 3
	dw .Machine, .MachineROAM  ; facing up, walk animation frame 0
	dw .Machine, .MachineROAM  ; facing up, walk animation frame 1
	dw .Machine, .MachineROAM  ; facing up, walk animation frame 2
	dw .Machine, .MachineROAM  ; facing up, walk animation frame 3
	dw .Machine, .MachineLOAM  ; facing left, walk animation frame 0
	dw .Machine, .MachineLOAM  ; facing left, walk animation frame 1
	dw .Machine, .MachineLOAM  ; facing left, walk animation frame 2
	dw .Machine, .MachineLOAM  ; facing left, walk animation frame 3
	dw .Machine, .MachineROAM  ; facing right, walk animation frame 0
	dw .Machine, .MachineROAM  ; facing right, walk animation frame 1
	dw .Machine, .MachineROAM  ; facing right, walk animation frame 2
	dw .Machine, .MachineROAM  ; facing right, walk animation frame 3
; $40 Snorlax 3x3
	dw .Snorlax, .SnorlaxOAM  ; facing down, walk animation frame 0
	dw .Snorlax, .SnorlaxOAM  ; facing down, walk animation frame 1
	dw .Snorlax, .SnorlaxOAM  ; facing down, walk animation frame 2
	dw .Snorlax, .SnorlaxOAM  ; facing down, walk animation frame 3
	dw .Snorlax, .SnorlaxOAM  ; facing up, walk animation frame 0
	dw .Snorlax, .SnorlaxOAM  ; facing up, walk animation frame 1
	dw .Snorlax, .SnorlaxOAM  ; facing up, walk animation frame 2
	dw .Snorlax, .SnorlaxOAM  ; facing up, walk animation frame 3
	dw .Snorlax, .SnorlaxOAM  ; facing left, walk animation frame 0
	dw .Snorlax, .SnorlaxOAM  ; facing left, walk animation frame 1
	dw .Snorlax, .SnorlaxOAM  ; facing left, walk animation frame 2
	dw .Snorlax, .SnorlaxOAM  ; facing left, walk animation frame 3
	dw .Snorlax, .SnorlaxOAM  ; facing right, walk animation frame 0
	dw .Snorlax, .SnorlaxOAM  ; facing right, walk animation frame 1
	dw .Snorlax, .SnorlaxOAM  ; facing right, walk animation frame 2
	dw .Snorlax, .SnorlaxOAM  ; facing right, walk animation frame 3
; insert custom table starting here, each table must contain 4 facings with 4 animation frames each (16 total)

; four tile ids compose an overworld sprite
.StandingDown: db $00, $01, $02, $03
.WalkingDown:  db $80, $81, $82, $83
.StandingUp:   db $04, $05, $06, $07
.WalkingUp:    db $84, $85, $86, $87
.StandingLeft: db $08, $09, $0a, $0b
.WalkingLeft:  db $88, $89, $8a, $8b

.Machine:      db $02, $03, $03, $02
.Snorlax:      db $00, $01, $00, $02, $03, $02, $04, $05, $04

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

.MachineLOAM:
	; y, x, attributes
	db 0, -24, $00
	db 0, -16, $00
	db 0, -8, OAM_HFLIP
	db 0, 0, OAM_HFLIP | OAMFLAG_ENDOFDATA 

.MachineROAM:
	; y, x, attributes
	db 0, 8, $00
	db 0, 16, $00
	db 0, 24, OAM_HFLIP
	db 0, 32, OAM_HFLIP | OAMFLAG_ENDOFDATA 

.SnorlaxOAM:
	; y, x, attributes
	db -3, -4, $00 ; top left
	db -3, 4, $00 ; top center
	db -3, 12, OAM_HFLIP ; top middle
	db 5, -4, $00 ; middle left
	db 5, 4, $00 ; middle center
	db 5, 12, OAM_HFLIP ; middle right
	db 13, -4, $00 ; bottom left
	db 13, 4, $00 ; bottom center
	db 13, 12, OAM_HFLIP | OAMFLAG_ENDOFDATA ; bottom right

SpecialOAMlist:
	; see constants/sprite_constants.asm
	; db SPRITE_CONSTANT, $OAMtable, YPixelOffest, XPixelOffset
; Regular sprites
;	db SPRITE_NONE,						$00, 0, 0
;	db SPRITE_RED,						$00, 0, 0
;	db SPRITE_BLUE,						$00, 0, 0
;	db SPRITE_OAK,						$00, 0, 0
;	db SPRITE_YOUNGSTER,				$00, 0, 0
;	db SPRITE_MONSTER,					$00, 0, 0
;	db SPRITE_COOLTRAINER_F,			$00, 0, 0
;	db SPRITE_COOLTRAINER_M,			$00, 0, 0
;	db SPRITE_LITTLE_GIRL,				$00, 0, 0
;	db SPRITE_BIRD,						$00, 0, 0
;	db SPRITE_MIDDLE_AGED_MAN,			$00, 0, 0
;	db SPRITE_GAMBLER,					$00, 0, 0
;	db SPRITE_SUPER_NERD,				$00, 0, 0
;	db SPRITE_GIRL,						$00, 0, 0
;	db SPRITE_HIKER,					$00, 0, 0
;	db SPRITE_BEAUTY,					$00, 0, 0
;	db SPRITE_GENTLEMAN,				$00, 0, 0
;	db SPRITE_DAISY,					$00, 0, 0
;	db SPRITE_BIKER,					$00, 0, 0
;	db SPRITE_SAILOR,					$00, 0, 0
;	db SPRITE_COOK,						$00, 0, 0
;	db SPRITE_BIKE_SHOP_CLERK,			$00, 0, 0
;	db SPRITE_MR_FUJI,					$00, 0, 0
;	db SPRITE_GIOVANNI,					$00, 0, 0
;	db SPRITE_ROCKET,					$00, 0, 0
;	db SPRITE_CHANNELER,				$00, 0, 0
;	db SPRITE_WAITER,					$00, 0, 0
;	db SPRITE_ERIKA,					$00, 0, 0
;	db SPRITE_MIDDLE_AGED_WOMAN,		$00, 0, 0
;	db SPRITE_BRUNETTE_GIRL,			$00, 0, 0
;	db SPRITE_LANCE,					$00, 0, 0
;	db SPRITE_UNUSED_SCIENTIST,			$00, 0, 0
;	db SPRITE_SCIENTIST,				$00, 0, 0
;	db SPRITE_ROCKER,					$00, 0, 0
;	db SPRITE_SWIMMER,					$00, 0, 0
;	db SPRITE_SAFARI_ZONE_WORKER,		$00, 0, 0
;	db SPRITE_GYM_GUIDE,				$00, 0, 0
;	db SPRITE_GRAMPS,					$00, 0, 0
;	db SPRITE_CLERK,					$00, 0, 0
;	db SPRITE_FISHING_GURU,				$00, 0, 0
;	db SPRITE_GRANNY,					$00, 0, 0
;	db SPRITE_NURSE,					$00, 0, 0
;	db SPRITE_LINK_RECEPTIONIST,		$00, 0, 0
;	db SPRITE_SILPH_PRESIDENT,			$00, 0, 0
;	db SPRITE_SILPH_WORKER,				$00, 0, 0
;	db SPRITE_WARDEN,					$00, 0, 0
;	db SPRITE_CAPTAIN,					$00, 0, 0
;	db SPRITE_FISHER,					$00, 0, 0
;	db SPRITE_KOGA,						$00, 0, 0
;	db SPRITE_GUARD,					$00, 0, 0
;	db SPRITE_UNUSED_GUARD,				$00, 0, 0
;	db SPRITE_MOM,						$00, 0, 0
;	db SPRITE_BALDING_GUY,				$00, 0, 0
;	db SPRITE_LITTLE_BOY,				$00, 0, 0
;	db SPRITE_UNUSED_GAMEBOY_KID,		$00, 0, 0
;	db SPRITE_GAMEBOY_KID,				$00, 0, 0
;	db SPRITE_FAIRY,					$00, 0, 0
;	db SPRITE_AGATHA,					$00, 0, 0
;	db SPRITE_BRUNO,					$00, 0, 0
;	db SPRITE_LORELEI,					$00, 0, 0
;	db SPRITE_SEEL,						$00, 0, 0
;	db SPRITE_ARTICUNO,					$00, 0, 0
;	db SPRITE_CHANSEY,					$00, 0, 0
;	db SPRITE_CLEFAIRY,					$00, 0, 0
;	db SPRITE_CUBONE,					$00, 0, 0
;	db SPRITE_KANGASKHAN,				$00, 0, 0
;	db SPRITE_LAPRAS,					$00, 0, 0
;	db SPRITE_MEOWTH,					$00, 0, 0
;	db SPRITE_MEWTWO,					$00, 0, 0
;	db SPRITE_MOLTRES,					$00, 0, 0
;	db SPRITE_NIDORINO,					$00, 0, 0
;	db SPRITE_PIDGEOT,					$00, 0, 0
;	db SPRITE_POLYWRATH,				$00, 0, 0
;	db SPRITE_PSYDUCK,					$00, 0, 0
;	db SPRITE_SLOWBRO,					$00, 0, 0
;	db SPRITE_SLOWPOKE,					$00, 0, 0
;	db SPRITE_SPEAROW,					$00, 0, 0
;	db SPRITE_VOLTORB,					$00, 0, 0
;	db SPRITE_WIGGLYTUFF,				$00, 0, 0
; Still Sprites
;	db SPRITE_POKE_BALL,				$10, 0, 0
;	db SPRITE_FOSSIL,					$10, 0, 0
;	db SPRITE_PAPER,					$10, 0, 0
;	db SPRITE_POKEDEX,					$10, 0, 0
;	db SPRITE_CLIPBOARD,				$10, 0, 0
;	db SPRITE_UNUSED_OLD_AMBER,			$10, 0, 0
;	db SPRITE_OLD_AMBER,				$10, 0, 0
;	db SPRITE_UNUSED_GAMBLER_ASLEEP_1,	$10, 0, 0
;	db SPRITE_UNUSED_GAMBLER_ASLEEP_2,	$10, 0, 0
;	db SPRITE_GAMBLER_ASLEEP,			$10, 0, 0

; Regular sprites with -1 X offset on down/up flipped walking frame 
	db SPRITE_DODUO,                    $20, 0, 0
	db SPRITE_FEAROW,                   $20, 0, 0
	db SPRITE_JIGGLYPUFF,               $20, 0, 0
	db SPRITE_MACHOKE,                  $20, 0, 0
	db SPRITE_MACHOP,                   $20, 0, 0
	db SPRITE_NIDORANF,                 $20, 0, 1
	db SPRITE_NIDORANM,                 $20, 0, 0
	db SPRITE_PIDGEY,                   $20, 0, 0
	db SPRITE_PIKACHU,                  $20, 0, 0
	db SPRITE_SEEL2,                    $20, 0, 0
	db SPRITE_ZAPDOS,                   $20, 0, 0
	db SPRITE_KABUTO,                   $20, 0, 0
; Still, Y offset
	db SPRITE_BOULDER,                  $10, 3, 0
	db SPRITE_SNORLAX,                  $10, 4, 0
; Still, YX offset
	db SPRITE_BENCH_GUY,                $10, 4, 4
; Bill's Machines
	db SPRITE_BILLS_MACHINE,            $30, -4, 0
; 3x3 tiles Snorlax
	db SPRITE_SNORLAXBIG,               $40, 0, 0
	db -1
	