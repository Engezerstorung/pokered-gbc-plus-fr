BillsHouse_Object:
	db $d ; border block

	def_warp_events
	warp_event  2,  7, LAST_MAP, 1
	warp_event  3,  7, LAST_MAP, 1

	def_bg_events

	def_object_events
	object_event  6,  5, SPRITE_CLEFAIRY, STAY, NONE, 1 ; person
	object_event  4,  4, SPRITE_SUPER_NERD, STAY, NONE, 2 ; person
	object_event  6,  5, SPRITE_SUPER_NERD, STAY, NONE, 3 ; person
	object_event  2,  1, SPRITE_BILLS_MACHINE, STAY, LEFT, 0 ; 
	object_event  3,  1, SPRITE_BILLS_MACHINE, STAY, RIGHT, 0 ; 
	object_event  4,  1, SPRITE_BILLS_MACHINE, STAY, UP, 0 ; 
	object_event  5,  1, SPRITE_BILLS_MACHINE, STAY, DOWN, 0 ; 

	def_warps_to BILLS_HOUSE
