	object_const_def
	const_export VIRIDIANFOREST_YOUNGSTER1
	const_export VIRIDIANFOREST_YOUNGSTER2
	const_export VIRIDIANFOREST_YOUNGSTER3
	const_export VIRIDIANFOREST_YOUNGSTER4
	const_export VIRIDIANFOREST_ANTIDOTE
	const_export VIRIDIANFOREST_POTION
	const_export VIRIDIANFOREST_POKE_BALL
	const_export VIRIDIANFOREST_YOUNGSTER5

ViridianForest_Object:
	db $2 ; border block

	def_warp_events
	warp_event  1,  0, VIRIDIAN_FOREST_NORTH_GATE, 3
	warp_event  2,  0, VIRIDIAN_FOREST_NORTH_GATE, 4
	warp_event 15, 47, VIRIDIAN_FOREST_SOUTH_GATE, 2
	warp_event 16, 47, VIRIDIAN_FOREST_SOUTH_GATE, 2
	warp_event 17, 47, VIRIDIAN_FOREST_SOUTH_GATE, 2
	warp_event 18, 47, VIRIDIAN_FOREST_SOUTH_GATE, 2

	def_bg_events
	bg_event 24, 40, TEXT_VIRIDIANFOREST_TRAINER_TIPS1
	bg_event 16, 32, TEXT_VIRIDIANFOREST_USE_ANTIDOTE_SIGN
	bg_event 26, 17, TEXT_VIRIDIANFOREST_TRAINER_TIPS2
	bg_event  4, 24, TEXT_VIRIDIANFOREST_TRAINER_TIPS3
	bg_event 18, 45, TEXT_VIRIDIANFOREST_TRAINER_TIPS4
	bg_event  2,  1, TEXT_VIRIDIANFOREST_LEAVING_SIGN

	def_object_events
	object_event 16, 43, SPRITE_YOUNGSTER, STAY, NONE, TEXT_VIRIDIANFOREST_YOUNGSTER1
	object_event 30, 33, SPRITE_YOUNGSTER, STAY, LEFT, TEXT_VIRIDIANFOREST_YOUNGSTER2, OPP_BUG_CATCHER, 1
	object_event 30, 19, SPRITE_YOUNGSTER, STAY, LEFT, TEXT_VIRIDIANFOREST_YOUNGSTER3, OPP_BUG_CATCHER, 2
	object_event  2, 18, SPRITE_YOUNGSTER, STAY, LEFT, TEXT_VIRIDIANFOREST_YOUNGSTER4, OPP_BUG_CATCHER, 3
	object_event 25, 11, SPRITE_POKE_BALL, STAY, NONE, TEXT_VIRIDIANFOREST_ANTIDOTE, ANTIDOTE
	object_event 12, 29, SPRITE_POKE_BALL, STAY, NONE, TEXT_VIRIDIANFOREST_POTION, POTION
	object_event  1, 31, SPRITE_POKE_BALL, STAY, NONE, TEXT_VIRIDIANFOREST_POKE_BALL, POKE_BALL
	object_event 27, 40, SPRITE_YOUNGSTER, STAY, NONE, TEXT_VIRIDIANFOREST_YOUNGSTER5

	def_warps_to VIRIDIAN_FOREST
