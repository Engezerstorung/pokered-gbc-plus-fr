Route15GateLeftBinoculars:
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ret nz
	call EnableAutoTextBoxDrawing
	tx_pre Route15UpstairsBinocularsText
	ld a, ARTICUNO
	ld [wCurPartySpecies], a
	call PlayCry
	ld d, PAL_ARTICUNO
	jp DisplayMonFrontSpriteInBox

Route15UpstairsBinocularsText::
	text_far _Route15UpstairsBinocularsText
	text_end
