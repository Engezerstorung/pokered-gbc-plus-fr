MACRO textboxline
	; \1 destination map width, \2 text box width, 
	; \3 left tile, \4 middle repeated tile ; \5 right tile
	db \3
	ds \2-2, \4
	db \5
	ds \1-\2
ENDM

BasicSignBoxTileMap::
	; \1 destination width, \2 text box width, 
	; \3 left tile, \4 middle repetition tile ; \5 right tile
	textboxline TILEMAP_WIDTH, SCREEN_WIDTH, "┌", "─", "┐"
	textboxline TILEMAP_WIDTH, SCREEN_WIDTH, "│", " ", "│"
	textboxline TILEMAP_WIDTH, SCREEN_WIDTH, "│", " ", "│"
	textboxline TILEMAP_WIDTH, SCREEN_WIDTH, "└", "─", "┘"
BasicSignBoxAttrMap::
	ds 128, 7 | $80

WoodSignBoxTileMap::
	 INCBIN "color/colorplus/map_entry_signs/wood_entry_sign.tilemap"
WoodSignBoxAttrMap::
REPT 4
	ds 19, 7 | %10000000
	db 7 | %10100000
	ds 12
ENDR

IF GEN_2_GRAPHICS
FontGraphicsGrey:: INCBIN "gfx/gs/font_grey.2bpp"
FontGraphicsGreyEnd::

BasicEntrySignGraphics:: INCBIN "gfx/gs/text_box_grey.2bpp", tile 25
BasicEntrySignGraphicsEnd::

WoodEntrySignGraphics:: INCBIN "color/colorplus/map_entry_signs/wood_entry_sign.2bpp"
WoodEntrySignGraphicsEnd::

ELSE
FontGraphicsGrey:: INCBIN "gfx/font/font_grey.2bpp"
FontGraphicsGreyEnd::
BasicEntrySignGraphics:: INCBIN "gfx/font/font_extra_grey.2bpp", tile 25
BasicEntrySignGraphicsEnd::
ENDC
