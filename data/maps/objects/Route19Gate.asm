	object_const_def
	const_export ROUTE19GATE_GIRL
	const_export ROUTE19GATE_LITTLE_GIRL

Route19Gate_Object:
	db $a ; border block

	def_warp_events
	warp_event  5,  0, FUCHSIA_CITY, 11
	warp_event  4,  7, ROUTE_19, 1
	warp_event  5,  7, ROUTE_19, 1

	def_bg_events

	def_object_events
	object_event  8,  4, SPRITE_GIRL, STAY, LEFT, TEXT_ROUTE19GATE_GIRL
	object_event  2,  4, SPRITE_LITTLE_GIRL, WALK, UP_DOWN, TEXT_ROUTE19GATE_LITTLE_GIRL

	def_warps_to ROUTE_19_GATE
