SpriteSpecialProperties::
; This function look for sprites in SpecialOAMlist and load special proporties in wSpriteStateData2
; it make use of the previously unused bytes $1, $A, $B and $C
	xor a
.spriteLoop
	ldh [hSpriteOffset2], a

	ld d, HIGH(wSpriteStateData1) ; start by searching the PictureID of the current map object
	ld e, a
	ld a, [de] ; [x#SPRITESTATEDATA1_PICTUREID]
	ld [wSavedSpritePictureID], a

	ld hl, SpecialOAMlist ; loading list for identification and properties values
	push de ; save d and e
	ld de, 4 ; define the number of properties in list
	call IsInArray ; check if Sprite is in list ; modify a/b/de
	pop de
	jr nc, .nextCheck

	inc hl
	inc e
	inc d
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
; wSpriteStateData2 if found, it make use of the previously unused bytes $C of wSpriteStateData2.
	ld d, HIGH(wSpriteStateData2)
	ldh a, [hSpriteOffset2]
	add $c
	ld e, a
	ld a, [wSavedSpritePictureID]
	ld b, a

	ld hl, AnimatedSpriteList
.loop
	ld a, [hli]
	cp -1
	jr z, .nextsprite
	cp b
	jr z, .found
	inc hl
	jr .loop

.found
	ld a, [hl]
	ld [de], a

.nextsprite
	ldh a, [hSpriteOffset2]
	add $10
	cp LOW($100)
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

	db SPRITE_DOME_FOSSIL,              $10, 0, 0
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
	db SPRITE_BILLS_MACHINE,            $30, 0, 0
; 3x3 tiles Snorlax
	db SPRITE_SNORLAXBIG,               $40, 0, 0
	db -1

AnimatedSpriteList:
; \1 Sprite to animate, 
; \2 Ticks between animation frames, must be > 0.
; A value of 4 is the normal walking animation speed.
; Values > $80 are for special animation paterns.
	db SPRITE_ARTICUNO,     4 ; normal speed
	db SPRITE_FEAROW,       4 ; normal speed
	db SPRITE_KABUTO,      12 ; slower speed
	db SPRITE_LAPRAS,      12 ; slower speed
	db SPRITE_MOLTRES,      4 ; normal speed
	db SPRITE_OMANYTE,     12 ; slower speed
	db SPRITE_PIDGEOT,      4 ; normal speed
	db SPRITE_SNORLAXBIG, $80 ; snorlax breathing
	db SPRITE_SWIMMER,     12 ; slower speed
	db SPRITE_ZAPDOS,       4 ; normal speed
	db -1
