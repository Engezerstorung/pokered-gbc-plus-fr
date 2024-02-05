Route19Gate_Script:
	jp EnableAutoTextBoxDrawing

Route19Gate_TextPointers:
	def_text_pointers
	dw_const Route19GateGirlText,       TEXT_ROUTE19GATE_GIRL
	dw_const Route19GateLittleGirlText, TEXT_ROUTE19GATE_LITTLE_GIRL

Route19GateGirlText:
	text_far _Route19GateGirlText
	text_end

Route19GateLittleGirlText:
	text_far _Route19GateLittleGirlText
	text_end
