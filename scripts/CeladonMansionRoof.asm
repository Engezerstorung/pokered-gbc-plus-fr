CeladonMansionRoof_Script:
	ld hl, wCurrentMapScriptFlags
	bit 5, [hl]
	res 5, [hl]
	call nz, CeladonMansionRoofGraphicSwapScript
	jp EnableAutoTextBoxDrawing

CeladonMansionRoof_TextPointers:
	def_text_pointers
	dw_const CeladonMansionRoofHouseSignText, TEXT_CELADONMANSIONROOF_HOUSE_SIGN

CeladonMansionRoofHouseSignText:
	text_far _CeladonMansionRoofHouseSignText
	text_end

CeladonMansionRoofGraphicSwapScript::
	ld de, Mansion_GFX tile $5A
	ld hl, vTileset tile $10
	lb bc, BANK(Mansion_GFX), $06
	call CopyVideoData

	ld de, Mansion_GFX tile $36
	ld hl, vTileset tile $16
	lb bc, BANK(Mansion_GFX), $03
	call CopyVideoData
	ret
