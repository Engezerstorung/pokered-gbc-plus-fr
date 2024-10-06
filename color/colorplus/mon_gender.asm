; Used  to define gender ratios
	DEF MALE_ONLY         EQU $00
	DEF MALE_88_PERCENT   EQU $1F
	DEF MALE_75_PERCENT   EQU $3F
	DEF SAME_BOTH_GENDERS EQU $7F
	DEF FEMALE_75_PERCENT EQU $BF
	DEF FEMALE_ONLY       EQU $FE
	DEF NO_GENDER         EQU $FF

; Determine a Pokémon's gender based on its DVs
; This uses the same formula as Gen 2, so gender should match if you trade them forward via Time Capsule
; INPUTS - Mon DVs in de, species in wPokedexNum
; OUTPUT - Mon's gender in wPokedexNum
GetMonGender::
	push de
	predef IndexToPokedex
	pop de
	ld a, [wPokedexNum]
	dec a
	ld c, a
	ld b, 0
	ld hl, MonGenderRatios
	add hl, bc ; hl now points to the species gender ratio

	call CheckForcedGender

; Attack DV
	ld a, [de]
	and $f0
	ld b, a
; Speed DV
	inc de
	ld a, [de]
	and $f0
	swap a
; Put them together
	or b
	ld b, a ; b now has the combined DVs

; Get the gender ratio
	ld a, [hl]

; Check for always one or another
	cp NO_GENDER
	jr z, .genderless

	cp FEMALE_ONLY
	jr z, .female

	and a ; MALE_ONLY
	jr z, .male

; Compare the ratio to the value we found earlier
	cp b
	jr c, .male

.female
	ld a, "♀" ; FEMALE
	jr .done
.male
	ld a, "♂" ; MALE
	jr .done
.genderless
	ld a, " " ; GENDERLESS
.done
	ld [wPokedexNum], a
	ret

CheckForcedGender:
	ld a, [hl]
	and a ; cp MALE_ONLY
	ret z
	cp FEMALE_ONLY
	ret nc

	push hl
	ld hl, wGenderFlags
	bit 0, [hl] ; check if force male
	res 0, [hl]
	jr nz, .forceMale
	bit 1, [hl] ; check if force female
	res 1, [hl]
	jr z, .done

	ld hl, .checkFemaleDV
	jr .forceCommon
.forceMale
	ld hl, .checkMaleDV
.forceCommon
	and $0F
	inc a
	ld b, a

.rerollAttackDV
	call Random
	and $0F
	cp b
	jp hl

.checkMaleDV
	jr c, .rerollAttackDV
	jr .gotAttackDV
.checkFemaleDV
	jr nc, .rerollAttackDV

.gotAttackDV
	ld b, a
	swap b
	ld a, [de]
	and $0F
	or b
	ld [de], a
.done
	pop hl
	ret

MonGenderRatios:
	db MALE_88_PERCENT   ; Bulbasaur
	db MALE_88_PERCENT   ; Ivysaur
	db MALE_88_PERCENT   ; Venusaur
	db MALE_88_PERCENT   ; Charmander
	db MALE_88_PERCENT   ; Charmeleon
	db MALE_88_PERCENT   ; Charizard
	db MALE_88_PERCENT   ; Squirtle
	db MALE_88_PERCENT   ; Wartortle
	db MALE_88_PERCENT   ; Blastoise
	db SAME_BOTH_GENDERS ; Caterpie
	db SAME_BOTH_GENDERS ; Metapod
	db SAME_BOTH_GENDERS ; Butterfree
	db SAME_BOTH_GENDERS ; Weedle
	db SAME_BOTH_GENDERS ; Kakuna
	db SAME_BOTH_GENDERS ; Beedrill
	db SAME_BOTH_GENDERS ; Pidgey
	db SAME_BOTH_GENDERS ; Pidgeotto
	db SAME_BOTH_GENDERS ; Pidgeot
	db SAME_BOTH_GENDERS ; Rattata
	db SAME_BOTH_GENDERS ; Raticate
	db SAME_BOTH_GENDERS ; Spearow
	db SAME_BOTH_GENDERS ; Fearow
	db SAME_BOTH_GENDERS ; Ekans
	db SAME_BOTH_GENDERS ; Arbok
	db SAME_BOTH_GENDERS ; Pikachu
	db SAME_BOTH_GENDERS ; Raichu
	db SAME_BOTH_GENDERS ; Sandshrew
	db SAME_BOTH_GENDERS ; Sandslash
	db FEMALE_ONLY       ; Nidoran F
	db FEMALE_ONLY       ; Nidorina
	db FEMALE_ONLY       ; Nidoqueen
	db MALE_ONLY         ; Nidoran M
	db MALE_ONLY         ; Nidorino
	db MALE_ONLY         ; Nidoking
	db FEMALE_75_PERCENT ; Clefairy
	db FEMALE_75_PERCENT ; Clefable
	db FEMALE_75_PERCENT ; Vulpix
	db FEMALE_75_PERCENT ; Ninetales
	db FEMALE_75_PERCENT ; Jigglypuff
	db FEMALE_75_PERCENT ; WIgglytuff
	db SAME_BOTH_GENDERS ; Zubat
	db SAME_BOTH_GENDERS ; Golbat
	db SAME_BOTH_GENDERS ; Oddish
	db SAME_BOTH_GENDERS ; Gloom
	db SAME_BOTH_GENDERS ; Vileplume
	db SAME_BOTH_GENDERS ; Paras
	db SAME_BOTH_GENDERS ; Parasect
	db SAME_BOTH_GENDERS ; Venonat
	db SAME_BOTH_GENDERS ; Venomoth
	db SAME_BOTH_GENDERS ; Diglett
	db SAME_BOTH_GENDERS ; Dugtrio
	db SAME_BOTH_GENDERS ; Meowth
	db SAME_BOTH_GENDERS ; Persian
	db SAME_BOTH_GENDERS ; Psyduck
	db SAME_BOTH_GENDERS ; Golduck
	db SAME_BOTH_GENDERS ; Mankey
	db SAME_BOTH_GENDERS ; Primeape
	db MALE_75_PERCENT   ; Growlithe
	db MALE_75_PERCENT   ; Arcanine
	db SAME_BOTH_GENDERS ; Poliwag
	db SAME_BOTH_GENDERS ; Poliwhirl
	db SAME_BOTH_GENDERS ; Poliwrath
	db MALE_75_PERCENT   ; Abra
	db MALE_75_PERCENT   ; Kadabra
	db MALE_75_PERCENT   ; Alakazam
	db MALE_75_PERCENT   ; Machop
	db MALE_75_PERCENT   ; Machoke
	db MALE_75_PERCENT   ; Machamp
	db SAME_BOTH_GENDERS ; Bellsprout
	db SAME_BOTH_GENDERS ; Weepinbell
	db SAME_BOTH_GENDERS ; Victreebel
	db SAME_BOTH_GENDERS ; Tentacool
	db SAME_BOTH_GENDERS ; Tentacruel
	db SAME_BOTH_GENDERS ; Geodude
	db SAME_BOTH_GENDERS ; Graveler
	db SAME_BOTH_GENDERS ; Golem
	db SAME_BOTH_GENDERS ; Ponyta
	db SAME_BOTH_GENDERS ; Rapidash
	db SAME_BOTH_GENDERS ; Slowpoke
	db SAME_BOTH_GENDERS ; Slowbro
	db NO_GENDER         ; Magnemite
	db NO_GENDER         ; Magneton
	db SAME_BOTH_GENDERS ; Farfetch'd
	db SAME_BOTH_GENDERS ; Doduo
	db SAME_BOTH_GENDERS ; Dodrio
	db SAME_BOTH_GENDERS ; Seel
	db SAME_BOTH_GENDERS ; Dewgong
	db SAME_BOTH_GENDERS ; Grimer
	db SAME_BOTH_GENDERS ; Muk
	db SAME_BOTH_GENDERS ; Shellder
	db SAME_BOTH_GENDERS ; Cloyster
	db SAME_BOTH_GENDERS ; Gastly
	db SAME_BOTH_GENDERS ; Haunter
	db SAME_BOTH_GENDERS ; Gengar
	db SAME_BOTH_GENDERS ; Onix
	db SAME_BOTH_GENDERS ; Drowzee
	db SAME_BOTH_GENDERS ; Hypno
	db SAME_BOTH_GENDERS ; Krabby
	db SAME_BOTH_GENDERS ; Kingler
	db NO_GENDER         ; Voltorb
	db NO_GENDER         ; Electrode
	db SAME_BOTH_GENDERS ; Exeggcute
	db SAME_BOTH_GENDERS ; Exeggutor
	db SAME_BOTH_GENDERS ; Cubone
	db SAME_BOTH_GENDERS ; Marowak
	db MALE_ONLY         ; Hitmonlee
	db MALE_ONLY         ; Hitmonchan
	db SAME_BOTH_GENDERS ; Lickitung
	db SAME_BOTH_GENDERS ; Koffing
	db SAME_BOTH_GENDERS ; Weezing
	db SAME_BOTH_GENDERS ; Rhyhorn
	db SAME_BOTH_GENDERS ; Rhydon
	db FEMALE_ONLY       ; Chansey
	db SAME_BOTH_GENDERS ; Tangela
	db FEMALE_ONLY       ; Kangaskhan
	db SAME_BOTH_GENDERS ; Horsea
	db SAME_BOTH_GENDERS ; Seadra
	db SAME_BOTH_GENDERS ; Goldeen
	db SAME_BOTH_GENDERS ; Seaking
	db NO_GENDER         ; Staryu
	db NO_GENDER         ; Starmie
	db SAME_BOTH_GENDERS ; Mr. Mime
	db SAME_BOTH_GENDERS ; Scyther
	db FEMALE_ONLY       ; Jynx
	db MALE_75_PERCENT   ; Electabuzz
	db MALE_75_PERCENT   ; Magmar
	db SAME_BOTH_GENDERS ; Pinsir
	db MALE_ONLY         ; Tauros
	db SAME_BOTH_GENDERS ; Magikarp
	db SAME_BOTH_GENDERS ; Gyarados
	db SAME_BOTH_GENDERS ; Lapras
	db NO_GENDER         ; Ditto
	db MALE_88_PERCENT   ; Eevee
	db MALE_88_PERCENT   ; Vaporeon
	db MALE_88_PERCENT   ; Jolteon
	db MALE_88_PERCENT   ; Flareon
	db NO_GENDER         ; Porygon
	db MALE_88_PERCENT   ; Omanyte
	db MALE_88_PERCENT   ; Omastar
	db MALE_88_PERCENT   ; Kabuto
	db MALE_88_PERCENT   ; Kabutops
	db MALE_88_PERCENT   ; Aerodactyl
	db MALE_88_PERCENT   ; Snorlax
	db NO_GENDER         ; Articuno
	db NO_GENDER         ; Zapdos
	db NO_GENDER         ; Moltres
	db SAME_BOTH_GENDERS ; Dratini
	db SAME_BOTH_GENDERS ; Dragonair
	db SAME_BOTH_GENDERS ; Dragonite
	db NO_GENDER         ; Mewtwo
	db NO_GENDER         ; Mew
