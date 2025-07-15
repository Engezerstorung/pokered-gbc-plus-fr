SpriteSpecialProperties::
; This part of the function look for sprites in SpecialOAMlist and load special proporties in wSpriteStateData2
; it make use of the previously unused bytes $1, $A and $B
	ld e, $10

.spriteLoop
	ld d, HIGH(wSpriteStateData1) ; start by searching the PictureID of the current map object
	ld a, [de] ; [x#SPRITESTATEDATA1_PICTUREID]
	ld [wSavedSpritePictureID], a
	inc e
	inc d

	ld hl, SpecialOAMlist ; loading list for identification and properties values
	push de ; save d and e
	ld de, 4 ; define the number of properties in list
	call IsInArray ; check if Sprite is in list ; modify a/b/de
	pop de
	jr c, .foundMatch

	xor a
	ld [de], a
	ld a, $9
	add e
	ld e, a
	xor a
	ld [de], a
	inc e
	ld [de], a
	jr .nextCheck

.foundMatch
	inc hl
	ld a, [hli]
	ld [de], a
	ld a, $9
	add e
	ld e, a
	ld a, [hli]
	ld [de], a
	inc e
	ld a, [hl]
	ld [de], a

.nextCheck
; This part of the function look for sprites in AnimatedSpriteList and load an animation value in 
; wSpriteStateData2 if found, it make use of the previously unused byte $C of wSpriteStateData2.
	inc e

	ld a, [wSavedSpritePictureID]
	ld b, a

	ld hl, AnimatedSpriteList
.loop
	ld a, [hli]
	cp -1
	jr z, .noMatch

	cp b
	ld a, [hli]
	jr nz, .loop
	jr .found
	
.noMatch
	xor a
.found	
	ld [de], a

.nextsprite
	ld a, e
	add $10
	and $f0
	ld e, a
	jp nz, .spriteLoop
	ret

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
;	db SPRITE_POKE_BALL,				$1, 0, 0
;	db SPRITE_FOSSIL,					$1, 0, 0
;	db SPRITE_PAPER,					$1, 0, 0
;	db SPRITE_POKEDEX,					$1, 0, 0
;	db SPRITE_CLIPBOARD,				$1, 0, 0
;	db SPRITE_UNUSED_OLD_AMBER,			$1, 0, 0
;	db SPRITE_OLD_AMBER,				$1, 0, 0
;	db SPRITE_UNUSED_GAMBLER_ASLEEP_1,	$1, 0, 0
;	db SPRITE_UNUSED_GAMBLER_ASLEEP_2,	$1, 0, 0
;	db SPRITE_GAMBLER_ASLEEP,			$1, 0, 0

IF DEF(_DEBUG)	
	db SPRITE_BLANK,                    $0, 16, 0
ENDC
	db SPRITE_DOME_FOSSIL,              $1, 0, 0
; Regular sprites with -1 X offset on down/up flipped walking frame 
	db SPRITE_DODUO,                    $2, 0, 0
	db SPRITE_FEAROW,                   $2, 0, 0
	db SPRITE_JIGGLYPUFF,               $2, 0, 0
	db SPRITE_MACHOKE,                  $2, 0, 0
	db SPRITE_MACHOP,                   $2, 0, 0
	db SPRITE_NIDORANF,                 $2, 0, 1
	db SPRITE_NIDORANM,                 $2, 0, 0
	db SPRITE_PIDGEY,                   $2, 0, 0
	db SPRITE_PIKACHU,                  $2, 0, 0
	db SPRITE_SEEL2,                    $2, 0, 0
	db SPRITE_ZAPDOS,                   $2, 0, 0
	db SPRITE_KABUTO,                   $2, 0, 0
; Still, Y offset
	db SPRITE_BOULDER,                  $1, 3, 0
	db SPRITE_SNORLAX,                  $1, 4, 0
; Still, YX offset
	db SPRITE_BENCH_GUY,                $1, 4, 4
; Bill's Machines
	db SPRITE_BILLS_MACHINE,            $3, 0, 0
; 3x3 tiles Snorlax
	db SPRITE_SNORLAXBIG,               $4, 0, 0
	db -1

; Walking animation speed is 4, bigger value equal slower speed
DEF IDDLE_FLY     EQU   6 ; slightly slower speed
DEF IDDLE_SWIM    EQU  12 ; slower speed
DEF IDDLE_SNORLAX EQU $80 ; snorlax breathing

AnimatedSpriteList:
; \1 Sprite to animate, 
; \2 Ticks between animation frames, must be > 0.
; A value of 4 is the normal walking animation speed.
; Values > $80 are for special animation paterns.
	db SPRITE_ARTICUNO,    IDDLE_FLY
	db SPRITE_FEAROW,      IDDLE_FLY
	db SPRITE_KABUTO,      IDDLE_SWIM
	db SPRITE_LAPRAS,      IDDLE_SWIM
	db SPRITE_MOLTRES,     IDDLE_FLY
	db SPRITE_OMANYTE,     IDDLE_SWIM
	db SPRITE_PIDGEOT,     IDDLE_FLY
	db SPRITE_SNORLAXBIG,  IDDLE_SNORLAX
	db SPRITE_SWIMMER,     IDDLE_SWIM
	db SPRITE_ZAPDOS,      IDDLE_FLY
	db -1
