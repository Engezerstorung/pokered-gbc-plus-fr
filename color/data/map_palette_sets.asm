; 8 bytes per tileset for 8 palettes, which are taken from MapPalettes.
MapPaletteSets:
	table_width 2, MapPaletteSets
	dw OverworldPalSet   ; OVERWORLD
	dw RedsHouse1PalSet  ; REDS_HOUSE_1
	dw MartPalSet        ; MART
	dw ForestPalSet      ; FOREST
	dw RedsHouse2PalSet  ; REDS_HOUSE_2
	dw DojoPalSet        ; DOJO
	dw PokecenterPalSet  ; POKECENTER
	dw GymPalSet         ; GYM
	dw HousePalSet       ; HOUSE
	dw ForestGatePalSet  ; FOREST_GATE
	dw MuseumPalSet      ; MUSEUM
	dw UndergroundPalSet ; UNDERGROUND
	dw GatePalSet        ; GATE
	dw ShipPalSet        ; SHIP
	dw ShipPortPalSet    ; SHIP_PORT
	dw CemeteryPalSet    ; CEMETERY
	dw InteriorPalSet    ; INTERIOR
	dw CavernPalSet      ; CAVERN
	dw LobbyPalSet       ; LOBBY
	dw MansionPalSet     ; MANSION
	dw LabPalSet         ; LAB
	dw ClubPalSet        ; CLUB
	dw FacilityPalSet    ; FACILITY
	dw PlateauPalSet     ; PLATEAU
	assert_table_length NUM_TILESETS

OverworldPalSet:	
ForestPalSet:
	db OUTDOOR_GRAY
	db OUTDOOR_FLOWER
	db OUTDOOR_GREEN
	db OUTDOOR_BLUE
	db OUTDOOR_YELLOW
	db OUTDOOR_BROWN
	db FOREST_TREES
	db CRYS_TEXTBOX

PlateauPalSet:
	db OUTDOOR_GRAY
	db OUTDOOR_RED
	db OUTDOOR_GREEN
	db OUTDOOR_BLUE
	db OUTDOOR_YELLOW
	db OUTDOOR_BROWN
	db OUTDOOR_ROOF
	db CRYS_TEXTBOX

RedsHouse1PalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN
	db INDOOR_BLUE
	db REDS_STAIRS
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db CRYS_TEXTBOX

RedsHouse2PalSet:
DojoPalSet:
HousePalSet:
ClubPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db CRYS_TEXTBOX

MartPalSet:
PokecenterPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db PC_POKEBALL_PAL

GymPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN_BG
	db INDOOR_BLUE
	db INDOOR_FLOWER
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db CRYS_TEXTBOX

ForestGatePalSet:
FacilityPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN_BG
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN_BG
	db INDOOR_LIGHT_BLUE
	db CRYS_TEXTBOX

MuseumPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN
	db INDOOR_BLUE
	db GATE_STAIRS
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db ALT_TEXTBOX_PAL ; Uses variant of textbox palette for skeleton pokemon
GatePalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN
	db INDOOR_BLUE
	db GATE_STAIRS
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db ARTICUNO_TEXTBOX ; Uses variant of textbox palette for Articuno binoculars

UndergroundPalSet:
	db INDOOR_GRAY
	db UNDERGROUND_STAIRS
	db INDOOR_GREEN
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db CRYS_TEXTBOX

ShipPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db SHIP_STOVES
	db INDOOR_BLUE
	db SHIP_MUGS
	db INDOOR_BROWN
	db SHIP_TRASHCANS
	db CRYS_TEXTBOX

ShipPortPalSet:
	db INDOOR_GRAY
	db SHIP_DOCK_CAR
	db INDOOR_GRAY
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db SHIP_DOCK1
	db SHIP_DOCK2
	db CRYS_TEXTBOX

CemeteryPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN
	db INDOOR_BLUE
	db CEMETERY_STAIRS
	db INDOOR_BROWN
	db INDOOR_PURPLE
	db CRYS_TEXTBOX

InteriorPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db OUTDOOR_GREEN
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db PC_POKEBALL_PAL

CavernPalSet:
	db CAVE_GRAY
	db CAVE_RED
	db CAVE_GREEN
	db CAVE_BLUE
	db CAVE_ENTRANCE
	db CAVE_BROWN
	db CAVE_LIGHT_BLUE
	db CRYS_TEXTBOX

LobbyPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db LOBBY_CHAIR
	db INDOOR_BLUE
	db LOBBY_1STFLOOR
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db PC_POKEBALL_PAL

MansionPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN_BG
	db INDOOR_BLUE
	db INDOOR_YELLOW
	db INDOOR_BROWN
	db MANSION_WALLS
	db PC_POKEBALL_PAL

LabPalSet:
	db INDOOR_GRAY
	db INDOOR_RED
	db INDOOR_GREEN_BG
	db INDOOR_BLUE
	db INDOOR_GREEN
	db INDOOR_BROWN
	db INDOOR_LIGHT_BLUE
	db PC_POKEBALL_PAL
