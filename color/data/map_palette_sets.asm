; 8 bytes per tileset for 8 palettes, which are taken from MapPalettes.
; See TilesetBgPalSwapList in color/loadpalettes.asm for tileset palettes that dont justify a full dedicated PalSet.
MapPaletteSets:
	table_width 2
	dw .overworldPalSet   ; OVERWORLD
	dw .redsHouse1PalSet  ; REDS_HOUSE_1
	dw .martPalSet        ; MART
	dw .forestPalSet      ; FOREST
	dw .redsHouse2PalSet  ; REDS_HOUSE_2
	dw .dojoPalSet        ; DOJO
	dw .pokecenterPalSet  ; POKECENTER
	dw .gymPalSet         ; GYM
	dw .housePalSet       ; HOUSE
	dw .forestGatePalSet  ; FOREST_GATE
	dw .museumPalSet      ; MUSEUM
	dw .undergroundPalSet ; UNDERGROUND
	dw .gatePalSet        ; GATE
	dw .shipPalSet        ; SHIP
	dw .shipPortPalSet    ; SHIP_PORT
	dw .cemeteryPalSet    ; CEMETERY
	dw .interiorPalSet    ; INTERIOR
	dw .cavernPalSet      ; CAVERN
	dw .lobbyPalSet       ; LOBBY
	dw .mansionPalSet     ; MANSION
	dw .labPalSet         ; LAB
	dw .clubPalSet        ; CLUB
	dw .facilityPalSet    ; FACILITY
	dw .plateauPalSet     ; PLATEAU
	assert_table_length NUM_TILESETS

.overworldPalSet:	
.forestPalSet:
.plateauPalSet:
	db OUTDOOR_GRAY
	db OUTDOOR_FLOWER
	db OUTDOOR_GREEN
	db OUTDOOR_BLUE
	db OUTDOOR_YELLOW
	db OUTDOOR_BROWN
	db FOREST_TREES
;	db PC_POKEBALL_PAL
	db CRYS_TEXTBOX

.redsHouse1PalSet:	
.martPalSet:
.redsHouse2PalSet:
.dojoPalSet:
.pokecenterPalSet:
.gymPalSet:
.housePalSet:
.museumPalSet:
.undergroundPalSet:	
.gatePalSet:
.cemeteryPalSet:	
.interiorPalSet:	
.clubPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
;	db PC_POKEBALL_PAL
	db CRYS_TEXTBOX

.forestGatePalSet:
.facilityPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN_BG
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN_BG
	db INDOOR_LIGHT_BLUE
;	db PC_POKEBALL_PAL
	db CRYS_TEXTBOX

.shipPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db SHIP_STOVES
	db INDOOR_BLUE
	db SHIP_MUGS
	db INDOOR_BROWN
	db SHIP_TRASHCANS
;	db PC_POKEBALL_PAL
	db CRYS_TEXTBOX

.shipPortPalSet:
	db INDOOR_GRAY
	db SHIP_DOCK_CAR
	db INDOOR_GRAY
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db SHIP_DOCK1
	db SHIP_DOCK2
;	db PC_POKEBALL_PAL
	db CRYS_TEXTBOX

.cavernPalSet:
	db CAVE_GRAY
	db CAVE_RED
	db CAVE_GREEN
	db CAVE_BLUE
	db CAVE_ENTRANCE
	db CAVE_BROWN
	db CAVE_LIGHT_BLUE
;	db PC_POKEBALL_PAL
	db CRYS_TEXTBOX

.lobbyPalSet:
.mansionPalSet:
.labPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN_BG
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
;	db PC_POKEBALL_PAL
	db CRYS_TEXTBOX
