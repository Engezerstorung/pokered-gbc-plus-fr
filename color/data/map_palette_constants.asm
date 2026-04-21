	const_def
	const INTRO_GRAY        ; 00: used only when booting up the game
	const OUTDOOR_GRAY      ; 01
	const OUTDOOR_RED       ; 02
	const OUTDOOR_GREEN     ; 03
	const OUTDOOR_BLUE      ; 04
	const OUTDOOR_YELLOW    ; 05
	const OUTDOOR_BROWN     ; 06
	const OUTDOOR_ROOF      ; 07
	const CRYS_TEXTBOX      ; 08
	const INDOOR_GRAY       ; 09
	const INDOOR_RED        ; 0A
	const INDOOR_GREEN      ; 0B
	const INDOOR_BLUE       ; 0C
	const INDOOR_YELLOW     ; 0D
	const INDOOR_BROWN      ; 0E
	const INDOOR_LIGHT_BLUE ; 0F
	const MAP_PALETTE_10    ; 10
	const MAP_PALETTE_11    ; 11
	const MAP_PALETTE_12    ; 12
	const MAP_PALETTE_13    ; 13
	const MAP_PALETTE_14    ; 14
	const MAP_PALETTE_15    ; 15
	const MAP_PALETTE_16    ; 16
	const CAVE_GRAY         ; 17
	const CAVE_RED          ; 18
	const CAVE_GREEN        ; 19
	const CAVE_BLUE         ; 1A
	const CAVE_YELLOW       ; 1B
	const CAVE_BROWN        ; 1C
	const CAVE_LIGHT_BLUE   ; 1D
	const SHIP_STOVES       ; 1E
	const SHIP_MUGS	        ; 1F
	const FOREST_TREES      ; 20
	const PC_POKEBALL_PAL   ; 21: doubles as textbox palette for some areas
	const ALT_TEXTBOX_PAL   ; 22: used in areas with skeleton pokemon
	const ARTICUNO_TEXTBOX  ; 23: used for articuno picture in gate
	const INDOOR_PURPLE     ; 24
	const OUTDOOR_FLOWER    ; 25
	const INDOOR_FLOWER    	; 26
	const INDOOR_GREEN_BG   ; 27
	const INDOOR_BROWN_BG   ; 28
	const LOBBY_1STFLOOR  	; 29
	const LOBBY_CHAIR       ; 2A
	const UNDERGROUND_STAIRS; 2B
	const SHIP_TRASHCANS	; 2C
	const SHIP_DOCK1        ; 2D
	const SHIP_DOCK2        ; 2E
	const SHIP_DOCK_CAR     ; 2F
	const OUTDOOR_FLOWER_FADE ; 30
	const OUTDOOR_GRASS_FADE; 31
	const OUTDOOR_BLUE_FADE ; 32
	const INDOOR_FLOWER_FADE; 33
	const CAVE_ENTRANCE     ; 34
	const GATE_STAIRS       ; 35
	const REDS_STAIRS       ; 36
	const CEMETERY_STAIRS   ; 37
	const MANSION_WALLS     ; 38
	const MANSION_WALLS_ROOF; 39
	const MANSION_SKY       ; 3A
	const BATTLE_TEXT       ; 3B
	const BILLS_MACHINE_DOOR; 3C
	const WOOD_TEXTBOX      ; 3D

	; These are unused
	const MAP_PALETTE_3E    ; 3E
	const MAP_PALETTE_3F    ; 3F

; Named to make tileset palette assignments consistent with Pokecrystal
	const_def
	const PAL_BG_GRAY      ; 00
	const PAL_BG_RED       ; 01
	const PAL_BG_GREEN     ; 02
	const PAL_BG_WATER     ; 03
	const PAL_BG_YELLOW    ; 04
	const PAL_BG_BROWN     ; 05
	const PAL_BG_ROOF      ; 06
	const PAL_BG_TEXT      ; 07

; Used when you want a tile to display above the Player and NPCs
	const_def $80
	const PAL_BG_PRIORITY_GRAY   ; 80
	const PAL_BG_PRIORITY_RED    ; 81
	const PAL_BG_PRIORITY_GREEN  ; 82
	const PAL_BG_PRIORITY_WATER  ; 83
	const PAL_BG_PRIORITY_YELLOW ; 84
	const PAL_BG_PRIORITY_BROWN  ; 85
	const PAL_BG_PRIORITY_ROOF   ; 86
	const PAL_BG_PRIORITY_TEXT   ; 87
