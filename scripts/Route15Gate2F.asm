Route15Gate2F_Script:
	ld a, %0001_0000
	ld [wSpriteStateData2 + $f | ROUTE15GATE2F_OAKS_AIDE << 4], a
	ld a, [rWBK]
	ld b, a
	ld a, 3
	ld [rWBK], a
	ld a, -13
	ld [w3MirrorReflectionDistance + ROUTE15GATE2F_OAKS_AIDE], a
	ld a, b
	ld [rWBK], a

	jp DisableAutoTextBoxDrawing

Route15Gate2F_TextPointers:
	def_text_pointers
	dw_const Route15Gate2FOaksAideText,   TEXT_ROUTE15GATE2F_OAKS_AIDE
	dw_const Route15Gate2FBinocularsText, TEXT_ROUTE15GATE2F_BINOCULARS

Route15Gate2FOaksAideText:
	text_asm
	CheckEvent EVENT_GOT_EXP_ALL
	jr nz, .got_item
	ld a, 50
	ldh [hOaksAideRequirement], a
	ld a, EXP_ALL
	ldh [hOaksAideRewardItem], a
	ld [wNamedObjectIndex], a
	call GetItemName
	ld hl, wNameBuffer
	ld de, wOaksAideRewardItemName
	ld bc, ITEM_NAME_LENGTH
	call CopyData
	predef OaksAideScript
	ldh a, [hOaksAideResult]
	cp OAKS_AIDE_GOT_ITEM
	jr nz, .no_item
	SetEvent EVENT_GOT_EXP_ALL
.got_item
	ld hl, .ExpAllText
	call PrintText
.no_item
	jp TextScriptEnd

.ExpAllText:
	text_far _Route15Gate2FOaksAideExpAllText
	text_end

Route15Gate2FBinocularsText:
	text_asm
	ld hl, .Text
	jp GateUpstairsScript_PrintIfFacingUp

.Text:
	text_far _Route15Gate2FBinocularsText
	text_end
