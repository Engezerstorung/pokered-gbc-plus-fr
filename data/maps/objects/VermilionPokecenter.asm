	object_const_def
	const_export VERMILIONPOKECENTER_NURSE
	const_export VERMILIONPOKECENTER_FISHING_GURU
	const_export VERMILIONPOKECENTER_SAILOR
	const_export VERMILIONPOKECENTER_LINK_RECEPTIONIST
	const_export VERMILIONPOKECENTER_BENCH_GUY

VermilionPokecenter_Object:
	db $0 ; border block

	def_warp_events
	warp_event  3,  7, LAST_MAP, 1
	warp_event  4,  7, LAST_MAP, 1

	def_bg_events

	def_object_events
	object_event  3,  1, SPRITE_NURSE, STAY, DOWN, TEXT_VERMILIONPOKECENTER_NURSE
	object_event 10,  5, SPRITE_FISHING_GURU, STAY, NONE, TEXT_VERMILIONPOKECENTER_FISHING_GURU
	object_event  5,  4, SPRITE_SAILOR, STAY, NONE, TEXT_VERMILIONPOKECENTER_SAILOR
	object_event 11,  2, SPRITE_LINK_RECEPTIONIST, STAY, DOWN, TEXT_VERMILIONPOKECENTER_LINK_RECEPTIONIST
	object_event  0,  4, SPRITE_BENCH_GUY, STAY, RIGHT, 0

	def_warps_to VERMILION_POKECENTER
