	object_const_def
	const_export BILLSHOUSE_BILL_POKEMON
	const_export BILLSHOUSE_BILL1
	const_export BILLSHOUSE_BILL2
	const_export SPRITE_BILLS_MACHINE1
	const_export SPRITE_BILLS_MACHINE2
	const_export SPRITE_BILLS_MACHINE3
	const_export SPRITE_BILLS_MACHINE4

BillsHouse_Object:
	db $d ; border block

	def_warp_events
	warp_event  2,  7, LAST_MAP, 1
	warp_event  3,  7, LAST_MAP, 1

	def_bg_events

	def_object_events
	object_event  6,  5, SPRITE_CLEFAIRY, STAY, NONE, TEXT_BILLSHOUSE_BILL_POKEMON
	object_event  4,  4, SPRITE_SUPER_NERD, STAY, NONE, TEXT_BILLSHOUSE_BILL_SS_TICKET
	object_event  6,  5, SPRITE_SUPER_NERD, STAY, NONE, TEXT_BILLSHOUSE_BILL_CHECK_OUT_MY_RARE_POKEMON
	object_event  2,  1, SPRITE_BILLS_MACHINE, STAY, LEFT, 0 
	object_event  3,  1, SPRITE_BILLS_MACHINE, STAY, RIGHT, 0 
	object_event  4,  1, SPRITE_BILLS_MACHINE, STAY, UP, 0 
	object_event  5,  1, SPRITE_BILLS_MACHINE, STAY, DOWN, 0 

	def_warps_to BILLS_HOUSE
