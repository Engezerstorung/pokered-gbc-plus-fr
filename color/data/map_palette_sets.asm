; 8 bytes per tileset for 8 palettes, which are taken from MapPalettes.
MapPaletteSets:
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
	db CRYS_TEXTBOX

.shipPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db SHIP_STOVES
	db INDOOR_BLUE
	db SHIP_MUGS
	db INDOOR_BROWN
	db SHIP_TRASHCANS
	db CRYS_TEXTBOX

.shipPortPalSet:
	db INDOOR_GRAY
	db SHIP_DOCK_CAR
	db INDOOR_GRAY
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db SHIP_DOCK1
	db SHIP_DOCK2
	db CRYS_TEXTBOX

.cavernPalSet:
	db CAVE_GRAY
	db CAVE_RED
	db CAVE_GREEN
	db CAVE_BLUE
	db CAVE_ENTRANCE
	db CAVE_BROWN
	db CAVE_LIGHT_BLUE
	db CRYS_TEXTBOX

.lobbyPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db LOBBY_CHAIR
	db INDOOR_BLUE
	db LOBBY_1STFLOOR
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db PC_POKEBALL_PAL

.mansionPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN_BG
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN
	db MANSION_WALLS
	db PC_POKEBALL_PAL

.labPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN_BG
	db INDOOR_BLUE
	db INDOOR_GREEN
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db PC_POKEBALL_PAL

.pointers
	table_width 1, .pointers
	db .overworldPalSet - MapPaletteSets   ; OVERWORLD
	db .redsHouse1PalSet - MapPaletteSets  ; REDS_HOUSE_1
	db .martPalSet - MapPaletteSets        ; MART
	db .forestPalSet - MapPaletteSets      ; FOREST
	db .redsHouse2PalSet - MapPaletteSets  ; REDS_HOUSE_2
	db .dojoPalSet - MapPaletteSets        ; DOJO
	db .pokecenterPalSet - MapPaletteSets  ; POKECENTER
	db .gymPalSet - MapPaletteSets         ; GYM
	db .housePalSet - MapPaletteSets       ; HOUSE
	db .forestGatePalSet - MapPaletteSets  ; FOREST_GATE
	db .museumPalSet - MapPaletteSets      ; MUSEUM
	db .undergroundPalSet - MapPaletteSets ; UNDERGROUND
	db .gatePalSet - MapPaletteSets        ; GATE
	db .shipPalSet - MapPaletteSets        ; SHIP
	db .shipPortPalSet - MapPaletteSets    ; SHIP_PORT
	db .cemeteryPalSet - MapPaletteSets    ; CEMETERY
	db .interiorPalSet - MapPaletteSets    ; INTERIOR
	db .cavernPalSet - MapPaletteSets      ; CAVERN
	db .lobbyPalSet - MapPaletteSets       ; LOBBY
	db .mansionPalSet - MapPaletteSets     ; MANSION
	db .labPalSet - MapPaletteSets         ; LAB
	db .clubPalSet - MapPaletteSets        ; CLUB
	db .facilityPalSet - MapPaletteSets    ; FACILITY
	db .plateauPalSet - MapPaletteSets     ; PLATEAU
	assert_table_length NUM_TILESETS
