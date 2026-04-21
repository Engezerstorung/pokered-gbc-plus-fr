MACRO ledge_tileset
	db \1
	dw \1LedgeTiles + 2
ENDM

MACRO ledge_pointers
\1LedgeTiles:
	dw .walkable
	dw .down
	dw .up
	dw .left
	dw .right
ENDM

MACRO ledge_tiles
.\1:
	IF _NARG > 1
	SHIFT
		db \# ; all args
	ENDC
	db -1 ; end
ENDM

LedgeTilesets:
	ledge_tileset OVERWORLD;, OverworldLedgeTiles
	ledge_tileset CAVERN
	db -1

;OverworldLedgeTiles:
ledge_pointers OVERWORLD
	ledge_tiles walkable, $23, $2C, $39, $52 ;,$11
	ledge_tiles down, $36, $37
	ledge_tiles up
	ledge_tiles left, $27
;	ledge_tiles right, $24
	ledge_tiles right, $0D, $1D

ledge_pointers CAVERN
	ledge_tiles walkable, -1
	ledge_tiles down, -1
	ledge_tiles up, -1
	ledge_tiles left, -1
	ledge_tiles right, -1

LedgeCheckDataTable:
	db PAD_DOWN
;	dwcoord 8, 11
	dwcoord 8, 13
	db PAD_UP
;	dwcoord 8, 6
	dwcoord 8, 5
	db PAD_LEFT
;	dwcoord 6, 9
	dwcoord 4, 9
	db PAD_RIGHT
;	dwcoord 12, 11
	dwcoord 12, 9

LedgeTiles:
	; player direction, tile player standing on, ledge tile, input required
	db SPRITE_FACING_DOWN,  $2C, $37, PAD_DOWN
	db SPRITE_FACING_DOWN,  $39, $36, PAD_DOWN
	db SPRITE_FACING_DOWN,  $39, $37, PAD_DOWN
	db SPRITE_FACING_LEFT,  $2C, $27, PAD_LEFT
	db SPRITE_FACING_LEFT,  $39, $27, PAD_LEFT
	db SPRITE_FACING_RIGHT, $2C, $0D, PAD_RIGHT
	db SPRITE_FACING_RIGHT, $2C, $1D, PAD_RIGHT
	db SPRITE_FACING_RIGHT, $39, $0D, PAD_RIGHT
;	db SPRITE_FACING_RIGHT, $2C, $24, PAD_RIGHT
;	db SPRITE_FACING_RIGHT, $39, $24, PAD_RIGHT
	db -1 ; end
