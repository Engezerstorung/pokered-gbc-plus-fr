; Handles sprite attributes

DEF ATK_PAL_GREY    EQU 0
DEF ATK_PAL_BLUE    EQU 1
DEF ATK_PAL_RED     EQU 2
DEF ATK_PAL_BROWN   EQU 3
DEF ATK_PAL_YELLOW  EQU 4
DEF ATK_PAL_GREEN   EQU 5
DEF ATK_PAL_ICE     EQU 6
DEF ATK_PAL_PURPLE  EQU 7
; 8: color based on attack type
; 9: don't change color palette (assume it's already set properly from elsewhere)


DEF SPR_PAL_ORANGE  EQU 0
DEF SPR_PAL_BLUE    EQU 1
DEF SPR_PAL_GREEN   EQU 2
DEF SPR_PAL_BROWN   EQU 3
DEF SPR_PAL_EXTRA1  EQU 4
DEF SPR_PAL_EXTRA2  EQU 5
DEF SPR_PAL_EXTRA3  EQU 6
DEF SPR_PAL_ANIM    EQU 7
DEF SPR_PAL_RANDOM  EQU 8

DEF PARTY_PAL_RED    EQU 0
DEF PARTY_PAL_BLUE   EQU 1
DEF PARTY_PAL_GREEN  EQU 2
DEF PARTY_PAL_BROWN  EQU 3
DEF PARTY_PAL_PINK   EQU 4
DEF PARTY_PAL_PURPLE EQU 5
DEF PARTY_PAL_YELLOW EQU 6
DEF PARTY_PAL_GREY   EQU 7

LoadOverworldSpritePalettes:
	ldh a, [rSVBK]
	ld b, a
	xor a
	ldh [rSVBK], a
	push bc
	; Does the map we're on use dark/night palettes?
	; Load the matching Object Pals if so
	ld a, [wCurMapTileset]
	ld hl, MapSpritePalettesNite
	cp CAVERN
	jr z, .gotPaletteList
	; If not, load the normal Object Pals
	ld hl, MapSpritePalettes
.gotPaletteList
	pop bc
	ld a, b
	ldh [rSVBK], a
	jr LoadSpritePaletteData

LoadAttackSpritePalettes:
	ld hl, AttackSpritePalettes

LoadSpritePaletteData:
	ldh a, [rSVBK]
	ld b, a
	ld a, 2
	ldh [rSVBK], a
	push bc

	ld de, W2_SprPaletteData
	ld b, $40
.sprCopyLoop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .sprCopyLoop
	ld a, 1
	ld [W2_ForceOBPUpdate], a

	pop af
	ldh [rSVBK], a
	ret

; Set an overworld sprite's colors
; On entering, A contains the flags (without a color palette) and de is the destination.
; This is called in the middle of a loop in engine/overworld/oam.asm, once per sprite.
ColorOverworldSprite::
	push af
	push bc
	push de
	and $f8
	ld b, a

	ldh a, [hSpriteOffset2]
	ld e, a
	ld d, wSpriteStateData1 >> 8
	ld a, [de] ; Load A with picture ID

	cp SPRITE_RED
	jr nz, .notRed

	ld a, [wWalkBikeSurfState]
	cp 2
	jr nz, .birdTest
	dec a ; if z, then need palette 1, which is 1 lower then the 2 already in 'a'
	jr .norandomColor
.birdTest
	cp 3 ; if z, then need palette 3, which is already the value of 'a'
	jr z, .norandomColor
.notRed
	ld a, [de]; Load A with picture ID

	dec a

	ld de, SpritePaletteAssignments
	add e
	ld e, a
	jr nc, .noCarry
	inc d
.noCarry
	ld a, [de] ; Get the picture ID's palette

	; If it's 8, that means no particular palette is assigned
	cp SPR_PAL_RANDOM
	jr nz, .norandomColor

	; Bill is always brown
	ld a, [wCurMap]
	cp BILLS_HOUSE
	ld a, SPR_PAL_BROWN
	jr z, .norandomColor

	; This is a (somewhat) random but consistent color
	ldh a, [hSpriteOffset2]
	swap a
	and 3

.norandomColor

	pop de
	or b
	ld [de], a
	inc hl
	inc e
	pop bc
	pop af
	ret

; Color the Party menu pokemon sprites
LoadPartyMenuSpritePalettes::
; Load the sprites palettes	
	ld hl,SpritePalettes
	call LoadSpritePaletteData
	ld a, %11100100
	ldh [rOBP1], a

; Assign palettes slots to the party pokemons
	ld hl, wPartySpecies ; Party pokemons IDs
	ld de, wMonPartySpritesSavedOAM ; used as a temporary storage for the palettes asignements

.copyloop
	; Get the ID of the party pokemons and convert them to podeked index number
	ld a, [hli] ; Load pokemon ID and up to next slot
	cp -1 ; Check for end of the party
	jr z, .done ; Jump if end of the party found
	ld [wd11e], a ; Store a in wram to be used in the function
	predef IndexToPokedex ; Convert ID to Pokedex ID
	call GetPredefRegisters ; Restore the 16bits registers from before the predef
	ld a, [wd11e] ; Get the result of the function
	cp 152 ; check for and ID higher than Mew's
	jr c, .notAboveMew ; Jump if not higher than Mew's
	xor a ; if higher than Mew's then give ID 0 so that purple palette is assigned
.notAboveMew
	; Find the pokemon palette assignement
	ld bc, PartyPaletteAssignments
	add c ; Add the pokemon pokedex ID which is used as a pointer in the palette assignement list
	ld c, a
	jr nc, .noCarry
	inc b
.noCarry
	ld a, [bc] ; Load pokemon assigned palette 

	ld [de], a ; Store palette assignement
	inc de ; Up to next slot
	jr .copyloop

.done
	ld [de], a ; Load party terminator

	ld a, 2
	ldh [rSVBK], a ; Change to wram bank 2

	ld hl, wShadowOAM
	ld de, wMonPartySpritesSavedOAM ; Load back the party assignement list

.spriteBigLoop
	ld a, [de] ; Get the palette assignement
	cp -1 ; Check for end of the party
	jr z, .doneAssigning ; Jump if end of the party found
	inc de
	push de
	ld c, a ; Load palette slot in c

	ld b, 4 ; Amount of tiles that will be assigned the current palette

.spriteSmallLoop
	inc hl ; up to tile 2nd byte (X position)
	inc hl ; up the 3rd byte which is the tile index
	ld a, [hli] ; tile index - up to the 4th byte which is the tile attribute byte
	ld e, a
	ld d, W2_SpritePaletteMap >> 8

	; Add the palette slot the the tile attribute byte
	; in GBC mode, the lower bits 0-3 are the bits attributing a slot to the tile
	ld a, $f8 ; load %11111000
	and [hl] ; by and-ing the [hl] value with a we get its 7-4 bits (bits 0-3 are all 0)
	or c ; or-ing with e, that only contain the palette slot value, add this value to a
	ld [hl], a ; load back the value adjusted for assigned palette slot in [hl]
	inc hl ; up to the 1st byte of next tile (Y position)

	dec b ; count down tiles left to assign before going to next pokemon
	jr nz, .spriteSmallLoop

	pop de ; to next pokemon 
	jr .spriteBigLoop

.doneAssigning
	ld hl, wShadowOAM
	ld de, wMonPartySpritesSavedOAM
	ld bc, $60
	call CopyData

	; Force palettes update, necessary for them to reload when swaping pokemons
	ld a, 1
	ld [W2_ForceBGPUpdate], a
	ld [W2_ForceOBPUpdate], a
	ldh [rSVBK], a ; Change to wram bank 1
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Alternate function that load a custom palette for each pokemon instead of attributing them one of the 8 generic ones
LoadPartyMenuSpritePalettes2::
	ld hl, wPartySpecies
	ld e, 5
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	push hl
	push de
	push de
	farcall DeterminePaletteID
	pop de
	ld d, a
	call LoadSGBPalette_Sprite
	pop de
	pop hl
	dec e
	jr nz, .loop
.done

ColorPartyMenuSprites::
	ld a, 2
	ldh [rSVBK], a

	ld hl, wShadowOAM
	ld b, 5

.spriteBigLoop
	ld c, 4

.spriteSmallLoop
	inc hl
	inc hl
	ld a, [hli] ; tile
	push de
	ld e, a
	ld d, W2_SpritePaletteMap >> 8
	pop de
	ld a, $f8
	and [hl]
	or b
	ld [hl], a
	inc hl

	dec c
	jr nz, .spriteSmallLoop

	dec b
	jr nz, .spriteBigLoop
	
	ld hl, wShadowOAM
	ld de, wMonPartySpritesSavedOAM
	ld bc, $60
	call CopyData

	ld a, 1
	ld [W2_ForceBGPUpdate], a
	ld [W2_ForceOBPUpdate], a
	xor a
	ldh [rSVBK], a

	ret

; This is called whenever [wUpdateSpritesEnabled] != 1 (overworld sprites not enabled?).
;
; This sometimes does occur on the overworld, such as when exclamation marks appear, and
; when trees are being cut or boulders are being moved. Though, when in the overworld,
; W2_SpritePaletteMap is all blanked out (set to 9) except for the exclamation mark tile,
; so this function usually won't do anything.
;
; This colorizes: attack sprites, party menu, exclamation mark, trades, perhaps more?
ColorNonOverworldSprites::
	ld a, 2
	ldh [rSVBK], a

	ld hl, wShadowOAM
	ld b, 40

.spriteLoop
	inc hl
	inc hl
	ld a, [hli] ; tile
	ld e, a
	ld d, W2_SpritePaletteMap >> 8
	ld a, [de]
	cp 8 ; if 8, colorize based on attack type
	jr z, .getAttackType
	cp 9 ; if 9, do not colorize (use whatever palette it's set to already)
	jr z, .nextSprite
	cp 10 ; if 10 (used in game freak intro), color based on sprite number
	jr z, .gameFreakIntro
	jr .setPalette ; Otherwise, use the value as-is

.gameFreakIntro: ; The stars under the logo all get different colors
	ld a, b
	and 3
	add 4
	jr .setPalette

.getAttackType
	push hl

	; Load animation (move) being used
	xor a
	ldh [rSVBK], a
	ld a, [wAnimationID]
	ld d, a
	ld a, 2
	ldh [rSVBK], a

	; If the absorb animation is playing, it's always green. (Needed for leech seed)
	ld a, d
	cp ABSORB
	ld a, GRASS
	jr z, .gotType

	; Make stun spore and solarbeam yellow, despite being grass moves
	ld a, d
	cp STUN_SPORE
	ld a, ELECTRIC
	jr z, .gotType
	ld a, d
	cp SOLARBEAM
	ld a, ELECTRIC
	jr z, .gotType

	; Make tri-attack yellow, despite being a normal move
	ld a, d
	cp TRI_ATTACK
	ld a, ELECTRIC
	jr z, .gotType

	ldh a, [hWhoseTurn]
	and a
	jr z, .playersTurn
	ld a, [wEnemyMoveType] ; Enemy move type
	jr .gotType
.playersTurn
	ld a, [wPlayerMoveType] ; Move type
.gotType
	ld hl, TypeColorTable
	add l
	ld l, a
	jr nc, .noCarry
	inc h
.noCarry
	ld a, [hl]
	pop hl

.setPalette
	ld c, a
	ld a, $f8
	and [hl]
	or c
	ld [hl], a

.nextSprite
	inc hl
	dec b
	jr nz, .spriteLoop

.end
	xor a
	ldh [rSVBK], a
	ret

; Called whenever an animation plays in-battle. There are two animation tilesets, each
; with its own palette.
LoadAnimationTilesetPalettes:
	push de
	ld a, [wWhichBattleAnimTileset] ; Animation tileset (0-2)
	ld c, a
	ld a, 2
	ldh [rSVBK], a

	xor a
	ld [W2_UseOBP1], a

	call LoadAttackSpritePalettes

	; Indices 0 and 2 both refer to "AnimationTileset1", just different amounts of it.
	; 0 is in-battle, 2 is during a trade.
	; Index 1 refers to "AnimationTileset2".
	ld a, c
	cp 1
	ld hl, AnimationTileset2Palettes
	jr z, .gotPalette
	ld hl, AnimationTileset1Palettes
.gotPalette
	ld de, W2_SpritePaletteMap
	ld b, $80
.copyLoop
	ld a, [hli]
	ld [de], a
	inc e
	dec b
	jr nz, .copyLoop

	; If in a trade, some of the tiles near the end are different. Override some tiles
	; for the link cable, and replace the "purple" palette to match the exact color of
	; the link cable.
	ld a, c
	cp 2
	jr nz, .done

	; Replace ATK_PAL_PURPLE with PAL_MEWMON
	ld d, PAL_MEWMON
	ld e, ATK_PAL_PURPLE
	call LoadSGBPalette_Sprite

	; Set the link cable sprite tiles
	ld a, ATK_PAL_PURPLE
	ld hl, W2_SpritePaletteMap + $7e
	ld [hli], a
	ld [hli], a

.done
	ld a, 1
	ld [W2_ForceOBPUpdate], a

	xor a
	ldh [rSVBK], a

	pop de
	ret


; Set all sprite palettes to not be colorized by "ColorNonOverworldSprites".
ClearSpritePaletteMap:
	ldh a, [rSVBK]
	ld b, a
	ld a, 2
	ldh [rSVBK], a
	push bc

	ld hl, W2_SpritePaletteMap
	ld b, $0 ; $100
	ld a, 9
.loop
	ld [hli], a
	dec b
	jr nz, .loop

	pop af
	ldh [rSVBK], a
	ret


SpritePaletteAssignments: ; Characters on the overworld
	; 0x01: SPRITE_RED
	db SPR_PAL_ORANGE

	; 0x02: SPRITE_BLUE
	db SPR_PAL_BLUE

	; 0x03: SPRITE_OAK
	db SPR_PAL_EXTRA1

	; 0x04: SPRITE_BUG_CATCHER
	db SPR_PAL_RANDOM

	; 0x05: SPRITE_SLOWBRO
	db SPR_PAL_ORANGE

	; 0x06: SPRITE_LASS
	db SPR_PAL_RANDOM

	; 0x07: SPRITE_BLACK_HAIR_BOY_1
	db SPR_PAL_RANDOM

	; 0x08: SPRITE_LITTLE_GIRL
	db SPR_PAL_RANDOM

	; 0x09: SPRITE_BIRD
	db SPR_PAL_BROWN

	; 0x0a: SPRITE_FAT_BALD_GUY
	db SPR_PAL_RANDOM

	; 0x0b: SPRITE_GAMBLER
	db SPR_PAL_RANDOM

	; 0x0c: SPRITE_BLACK_HAIR_BOY_2
	db SPR_PAL_RANDOM

	; 0x0d: SPRITE_GIRL
	db SPR_PAL_RANDOM

	; 0x0e: SPRITE_HIKER
	db SPR_PAL_RANDOM

	; 0x0f: SPRITE_FOULARD_WOMAN
	db SPR_PAL_RANDOM

	; 0x10: SPRITE_GENTLEMAN
	db SPR_PAL_BLUE

	; 0x11: SPRITE_DAISY
	db SPR_PAL_BLUE

	; 0x12: SPRITE_BIKER
	db SPR_PAL_RANDOM

	; 0x13: SPRITE_SAILOR
	db SPR_PAL_RANDOM

	; 0x14: SPRITE_COOK
	db SPR_PAL_RANDOM

	; 0x15: SPRITE_BIKE_SHOP_GUY
	db SPR_PAL_RANDOM

	; 0x16: SPRITE_MR_FUJI
	db SPR_PAL_GREEN

	; 0x17: SPRITE_GIOVANNI
	db SPR_PAL_EXTRA1

	; 0x18: SPRITE_ROCKET
	db SPR_PAL_BROWN

	; 0x19: SPRITE_MEDIUM
	db SPR_PAL_RANDOM

	; 0x1a: SPRITE_WAITER
	db SPR_PAL_RANDOM

	; 0x1b: SPRITE_ERIKA
	db SPR_PAL_RANDOM

	; 0x1c: SPRITE_MOM_GEISHA
	db SPR_PAL_RANDOM

	; 0x1d: SPRITE_BRUNETTE_GIRL
	db SPR_PAL_RANDOM

	; 0x1e: SPRITE_LANCE
	db SPR_PAL_ORANGE

	; 0x1f: SPRITE_OAK_SCIENTIST_AIDE
	db SPR_PAL_BROWN

	; 0x20: SPRITE_OAK_AIDE
	db SPR_PAL_BROWN

	; 0x21: SPRITE_ROCKER ($20)
	db SPR_PAL_RANDOM

	; 0x22: SPRITE_SWIMMER
	db SPR_PAL_RANDOM

	; 0x23: SPRITE_WHITE_PLAYER
	db SPR_PAL_RANDOM

	; 0x24: SPRITE_GYM_HELPER
	db SPR_PAL_RANDOM

	; 0x25: SPRITE_OLD_PERSON
	db SPR_PAL_RANDOM

	; 0x26: SPRITE_MART_GUY
	db SPR_PAL_RANDOM

	; 0x27: SPRITE_FISHER
	db SPR_PAL_RANDOM

	; 0x28: SPRITE_OLD_MEDIUM_WOMAN
	db SPR_PAL_RANDOM

	; 0x29: SPRITE_NURSE
	db SPR_PAL_ORANGE

	; 0x2a: SPRITE_CABLE_CLUB_WOMAN
	db SPR_PAL_GREEN

	; 0x2b: SPRITE_MR_MASTERBALL
	db SPR_PAL_EXTRA2

	; 0x2c: SPRITE_LAPRAS_GIVER
	db SPR_PAL_RANDOM

	; 0x2d: SPRITE_WARDEN
	db SPR_PAL_RANDOM

	; 0x2e: SPRITE_SS_CAPTAIN
	db SPR_PAL_RANDOM

	; 0x2f: SPRITE_FISHER2
	db SPR_PAL_RANDOM

	; 0x30: SPRITE_BLACKBELT
	db SPR_PAL_RANDOM

	; 0x31: SPRITE_GUARD ($30)
	db SPR_PAL_BLUE

	; 0x32: $32
	db SPR_PAL_RANDOM

	; 0x33: SPRITE_MOM
	db SPR_PAL_ORANGE

	; 0x34: SPRITE_BALDING_GUY
	db SPR_PAL_RANDOM

	; 0x35: SPRITE_YOUNG_BOY
	db SPR_PAL_RANDOM

	; 0x36: SPRITE_GAMEBOY_KID
	db SPR_PAL_RANDOM

	; 0x37: SPRITE_GAMEBOY_KID_COPY
	db SPR_PAL_RANDOM

	; 0x38: SPRITE_CLEFAIRY
	db SPR_PAL_EXTRA1

	; 0x39: SPRITE_AGATHA
	db SPR_PAL_BLUE

	; 0x3a: SPRITE_BRUNO
	db SPR_PAL_BROWN

	; 0x3b: SPRITE_LORELEI
	db SPR_PAL_ORANGE

	; 0x3c: SPRITE_SEEL
	db SPR_PAL_BLUE

; Start of custom sprites
	; SPRITE_BLANK
	db SPR_PAL_RANDOM
	; SPRITE_DOME_FOSSIL
	db SPR_PAL_EXTRA3
; Gym Leaders
	; SPRITE_BROCK
	db SPR_PAL_EXTRA1
	; SPRITE_MISTY
	db SPR_PAL_EXTRA1
	; SPRITE_SURGE
	db SPR_PAL_EXTRA1
	; SPRITE_ERIKA
	db SPR_PAL_EXTRA1
	; SPRITE_KOGA2
	db SPR_PAL_EXTRA1
	; SPRITE_SABRINA
	db SPR_PAL_EXTRA1
	; SPRITE_BLAINE
	db SPR_PAL_EXTRA1
; Map Pokémons	
	; SPRITE_ARTICUNO
	db SPR_PAL_BLUE
	; SPRITE_CHANSEY
	db SPR_PAL_EXTRA1
	; SPRITE_CLEFAIRY
	db SPR_PAL_EXTRA1
	; SPRITE_CUBONE
	db SPR_PAL_EXTRA1
	; SPRITE_KANGASKHAN
	db SPR_PAL_BROWN
	; SPRITE_LAPRAS
	db SPR_PAL_BLUE
	; SPRITE_MEOWTH
	db SPR_PAL_BROWN
	; SPRITE_MEWTWO
	db SPR_PAL_EXTRA2
	; SPRITE_MOLTRES
	db SPR_PAL_ORANGE
	; SPRITE_NIDORINO
	db SPR_PAL_EXTRA1
	; SPRITE_OMANYTE
	db SPR_PAL_BLUE
	; SPRITE_PIDGEOT
	db SPR_PAL_BROWN
	; SPRITE_POLYWRATH
	db SPR_PAL_BLUE
	; SPRITE_PSYDUCK
	db SPR_PAL_EXTRA2
	; SPRITE_SLOWBRO
	db SPR_PAL_EXTRA1
	; SPRITE_SLOWPOKE
	db SPR_PAL_EXTRA1
	; SPRITE_SPEAROW
	db SPR_PAL_BROWN
	; SPRITE_VOLTORB
	db SPR_PAL_ORANGE
	; SPRITE_WIGGLYTUFF
	db SPR_PAL_EXTRA1
; Pokémons with odd pixel number
	; SPRITE_DODUO
	db SPR_PAL_BROWN
	; SPRITE_FEAROW
	db SPR_PAL_BROWN
	; SPRITE_JIGGLYPUFF
	db SPR_PAL_EXTRA1
	; SPRITE_KABUTO
	db SPR_PAL_BROWN
	; SPRITE_MACHOKE
	db SPR_PAL_EXTRA1
	; SPRITE_MACHOP
	db SPR_PAL_EXTRA1
	; SPRITE_NIDORANF
	db SPR_PAL_EXTRA2
	; SPRITE_NIDORANM
	db SPR_PAL_EXTRA1
	; SPRITE_PIDGEY
	db SPR_PAL_BROWN
	; SPRITE_PIKACHU
	db SPR_PAL_ORANGE
	; SPRITE_SEEL2
	db SPR_PAL_EXTRA1
	; SPRITE_ZAPDOS
	db SPR_PAL_EXTRA1
; One face but use 9 tiles
	; SPRITE_SNORLAXBIG
	db SPR_PAL_BLUE

	; 0x3d: SPRITE_POKE_BALL
	db SPR_PAL_ORANGE

	; 0x3e: SPRITE_HELIX_FOSSIL
	db SPR_PAL_EXTRA3

	; 0x3f: SPRITE_BOULDER
	db SPR_PAL_EXTRA3

	; 0x40: SPRITE_PAPER_SHEET
	db SPR_PAL_BROWN

	; 0x41: SPRITE_BOOK_MAP_DEX
	db SPR_PAL_ORANGE

	; 0x42: SPRITE_CLIPBOARD
	db SPR_PAL_BROWN

	; 0x43: SPRITE_SNORLAX
	db SPR_PAL_BLUE

	; 0x44: SPRITE_OLD_AMBER_COPY
	db SPR_PAL_EXTRA3

	; 0x45: SPRITE_OLD_AMBER
	db SPR_PAL_EXTRA3

	; 0x46: SPRITE_LYING_OLD_MAN_UNUSED_1
	db SPR_PAL_BROWN

	; 0x47: SPRITE_LYING_OLD_MAN_UNUSED_2
	db SPR_PAL_BROWN

	; 0x48: SPRITE_LYING_OLD_MAN
	db SPR_PAL_BROWN

; Start of custom still sprites
	; SPRITE_BENCH_GUY
	db SPR_PAL_RANDOM
	; SPRITE_BILLS_MACHINE
	db SPR_PAL_EXTRA2

AnimationTileset1Palettes:
	INCBIN "color/data/animtileset1palettes.bin"

AnimationTileset2Palettes:
	INCBIN "color/data/animtileset2palettes.bin"

TypeColorTable: ; Used for a select few sprites to be colorized based on attack type
	db 0 ; NORMAL EQU $00
	db 0 ; FIGHTING EQU $01
	db 0 ; FLYING EQU $02
	db 7 ; POISON EQU $03
	db 3 ; GROUND EQU $04
	db 3 ; ROCK EQU $05
	db 0
	db 5 ; BUG EQU $07
	db 7 ; GHOST EQU $08
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 0
	db 2 ; FIRE EQU $14
	db 1 ; WATER EQU $15
	db 5 ; GRASS EQU $16
	db 4 ; ELECTRIC EQU $17
	db 7 ; PSYCHIC EQU $18
	db 6 ; ICE EQU $19
	db 1 ; DRAGON EQU $1A

PartyPaletteAssignments:
	; MISSINGNO
	db PARTY_PAL_PURPLE
	; BULBASAUR
	db PARTY_PAL_GREEN
	; IVYSAUR
	db PARTY_PAL_GREEN
	; VENUSAUR
	db PARTY_PAL_GREEN
	; CHARMANDER
	db PARTY_PAL_RED
	; CHARMELEON
	db PARTY_PAL_RED
	; CHARIZARD
	db PARTY_PAL_RED
	; SQUIRTLE
	db PARTY_PAL_BLUE
	; WARTORTLE
	db PARTY_PAL_BLUE
	; BLASTOISE
	db PARTY_PAL_BLUE
	; CATERPIE
	db PARTY_PAL_GREEN
	; METAPOD
	db PARTY_PAL_GREEN
	; BUTTERFREE
	db PARTY_PAL_BLUE
	; WEEDLE
	db PARTY_PAL_YELLOW
	; KAKUNA
	db PARTY_PAL_YELLOW
	; BEEDRILL
	db PARTY_PAL_YELLOW
	; PIDGEY
	db PARTY_PAL_BROWN
	; PIDGEOTTO
	db PARTY_PAL_BROWN
	; PIDGEOT
	db PARTY_PAL_BROWN
	; RATTATA
	db PARTY_PAL_PURPLE
	; RATICATE
	db PARTY_PAL_BROWN
	; SPEAROW
	db PARTY_PAL_BROWN
	; FEAROW
	db PARTY_PAL_BROWN
	; EKANS
	db PARTY_PAL_PURPLE
	; ARBOK
	db PARTY_PAL_PURPLE
	; PIKACHU
	db PARTY_PAL_RED
	; RAICHU
	db PARTY_PAL_YELLOW
	; SANDSHREW
	db PARTY_PAL_YELLOW
	; SANDSLASH
	db PARTY_PAL_YELLOW
	; NIDORAN_F
	db PARTY_PAL_BLUE
	; NIDORINA
	db PARTY_PAL_BLUE
	; NIDOQUEEN
	db PARTY_PAL_BLUE
	; NIDORAN_M
	db PARTY_PAL_PINK
	; NIDORINO
	db PARTY_PAL_PINK
	; NIDOKING
	db PARTY_PAL_PINK
	; CLEFAIRY
	db PARTY_PAL_PINK
	; CLEFABLE
	db PARTY_PAL_PINK
	; VULPIX
	db PARTY_PAL_RED
	; NINETALES
	db PARTY_PAL_YELLOW
	; JIGGLYPUFF
	db PARTY_PAL_PINK
	; WIGGLYTUFF
	db PARTY_PAL_PINK
	; ZUBAT
	db PARTY_PAL_BLUE
	; GOLBAT
	db PARTY_PAL_BLUE
	; ODDISH
	db PARTY_PAL_GREEN
	; GLOOM
	db PARTY_PAL_RED
	; VILEPLUME
	db PARTY_PAL_RED
	; PARAS
	db PARTY_PAL_RED
	; PARASECT
	db PARTY_PAL_RED
	; VENONAT
	db PARTY_PAL_RED
	; VENOMOTH
	db PARTY_PAL_PURPLE
	; DIGLETT
	db PARTY_PAL_BROWN
	; DUGTRIO
	db PARTY_PAL_BROWN
	; MEOWTH
	db PARTY_PAL_YELLOW
	; PERSIAN
	db PARTY_PAL_YELLOW
	; PSYDUCK
	db PARTY_PAL_YELLOW
	; GOLDUCK
	db PARTY_PAL_BLUE
	; MANKEY
	db PARTY_PAL_BROWN
	; PRIMEAPE
	db PARTY_PAL_BROWN
	; GROWLITHE
	db PARTY_PAL_RED
	; ARCANINE
	db PARTY_PAL_RED
	; POLIWAG
	db PARTY_PAL_RED
	; POLIWHIRL
	db PARTY_PAL_BLUE
	; POLIWRATH
	db PARTY_PAL_BLUE
	; ABRA
	db PARTY_PAL_YELLOW
	; KADABRA
	db PARTY_PAL_YELLOW
	; ALAKAZAM
	db PARTY_PAL_YELLOW
	; MACHOP
	db PARTY_PAL_GREY
	; MACHOKE
	db PARTY_PAL_GREY
	; MACHAMP
	db PARTY_PAL_GREY
	; BELLSPROUT
	db PARTY_PAL_GREEN
	; WEEPINBELL
	db PARTY_PAL_GREEN
	; VICTREEBEL
	db PARTY_PAL_GREEN
	; TENTACOOL
	db PARTY_PAL_BLUE
	; TENTACRUEL
	db PARTY_PAL_BLUE
	; GEODUDE
	db PARTY_PAL_GREY
	; GRAVELER
	db PARTY_PAL_GREY
	; GOLEM
	db PARTY_PAL_GREY
	; PONYTA
	db PARTY_PAL_RED
	; RAPIDASH
	db PARTY_PAL_RED
	; SLOWPOKE
	db PARTY_PAL_PINK
	; SLOWBRO
	db PARTY_PAL_PINK
	; MAGNEMITE
	db PARTY_PAL_GREY
	; MAGNETON
	db PARTY_PAL_GREY
	; FARFETCH_D
	db PARTY_PAL_BROWN
	; DODUO
	db PARTY_PAL_BROWN
	; DODRIO
	db PARTY_PAL_BROWN
	; SEEL
	db PARTY_PAL_BLUE
	; DEWGONG
	db PARTY_PAL_BLUE
	; GRIMER
	db PARTY_PAL_PURPLE
	; MUK
	db PARTY_PAL_PURPLE
	; SHELLDER
	db PARTY_PAL_PURPLE
	; CLOYSTER
	db PARTY_PAL_PURPLE
	; GASTLY
	db PARTY_PAL_PURPLE
	; HAUNTER
	db PARTY_PAL_RED
	; GENGAR
	db PARTY_PAL_RED
	; ONIX
	db PARTY_PAL_GREY
	; DROWZEE
	db PARTY_PAL_YELLOW
	; HYPNO
	db PARTY_PAL_YELLOW
	; KRABBY
	db PARTY_PAL_RED
	; KINGLER
	db PARTY_PAL_RED
	; VOLTORB
	db PARTY_PAL_RED
	; ELECTRODE
	db PARTY_PAL_RED
	; EXEGGCUTE
	db PARTY_PAL_PINK
	; EXEGGUTOR
	db PARTY_PAL_GREEN
	; CUBONE
	db PARTY_PAL_BROWN
	; MAROWAK
	db PARTY_PAL_BROWN
	; HITMONLEE
	db PARTY_PAL_BROWN
	; HITMONCHAN
	db PARTY_PAL_BROWN
	; LICKITUNG
	db PARTY_PAL_PINK
	; KOFFING
	db PARTY_PAL_PURPLE
	; WEEZING
	db PARTY_PAL_PURPLE
	; RHYHORN
	db PARTY_PAL_GREY
	; RHYDON
	db PARTY_PAL_GREY
	; CHANSEY
	db PARTY_PAL_PINK
	; TANGELA
	db PARTY_PAL_BLUE
	; KANGASKHAN
	db PARTY_PAL_BROWN
	; HORSEA
	db PARTY_PAL_BLUE
	; SEADRA
	db PARTY_PAL_BLUE
	; GOLDEEN
	db PARTY_PAL_RED
	; SEAKING
	db PARTY_PAL_RED
	; STARYU
	db PARTY_PAL_RED
	; STARMIE
	db PARTY_PAL_PURPLE
	; MR_MIME
	db PARTY_PAL_RED
	; SCYTHER
	db PARTY_PAL_GREEN
	; JYNX
	db PARTY_PAL_RED
	; ELECTABUZZ
	db PARTY_PAL_YELLOW
	; MAGMAR
	db PARTY_PAL_RED
	; PINSIR
	db PARTY_PAL_BROWN
	; TAUROS
	db PARTY_PAL_BROWN
	; MAGIKARP
	db PARTY_PAL_RED
	; GYARADOS
	db PARTY_PAL_BLUE
	; LAPRAS
	db PARTY_PAL_BLUE
	; DITTO
	db PARTY_PAL_PURPLE
	; EEVEE
	db PARTY_PAL_BROWN
	; VAPOREON
	db PARTY_PAL_BLUE
	; JOLTEON
	db PARTY_PAL_YELLOW
	; FLAREON
	db PARTY_PAL_RED
	; PORYGON
	db PARTY_PAL_PURPLE
	; OMANYTE
	db PARTY_PAL_BLUE
	; OMASTAR
	db PARTY_PAL_BLUE
	; KABUTO
	db PARTY_PAL_BROWN
	; KABUTOPS
	db PARTY_PAL_BROWN
	; AERODACTYL
	db PARTY_PAL_GREY
	; SNORLAX
	db PARTY_PAL_YELLOW
	; ARTICUNO
	db PARTY_PAL_BLUE
	; ZAPDOS
	db PARTY_PAL_YELLOW
	; MOLTRES
	db PARTY_PAL_RED
	; DRATINI
	db PARTY_PAL_BLUE
	; DRAGONAIR
	db PARTY_PAL_BLUE
	; DRAGONITE
	db PARTY_PAL_YELLOW
	; MEWTWO
	db PARTY_PAL_PURPLE
	; MEW
	db PARTY_PAL_PINK

INCLUDE "color/data/spritepalettes.asm"
